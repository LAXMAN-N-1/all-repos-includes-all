from typing import Any, List, Optional

from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session, joinedload, selectinload
import boto3
from botocore.exceptions import NoCredentialsError

from app import models, schemas
from app.api import deps
from app.core.config import settings
import csv
import io

router = APIRouter()

# S3 Client (Initialize if configured)
s3_client = boto3.client(
    's3',
    aws_access_key_id=getattr(settings, 'AWS_ACCESS_KEY_ID', None),
    aws_secret_access_key=getattr(settings, 'AWS_SECRET_ACCESS_KEY', None),
    region_name=settings.AWS_REGION
)

@router.get("/", response_model=List[schemas.Product])
def read_products(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    category_id: Optional[int] = None,
    category: Optional[str] = None,
    in_stock: Optional[bool] = None,
    search: Optional[str] = None,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Retrieve products.
    """
    query = db.query(models.Product).options(
        joinedload(models.Product.category_rel),
        selectinload(models.Product.variants).selectinload(models.ProductVariant.attribute_values)
    ).filter(models.Product.is_active == True)

    if category_id:
        query = query.filter(models.Product.category_id == category_id)

    if category:
        query = query.filter(models.Product.category == category)
    
    if in_stock is True:
        query = query.filter(models.Product.stock_quantity > 0)
    elif in_stock is False:
        query = query.filter(models.Product.stock_quantity <= 0)
    
    if search:
        search_filter = f"%{search}%"
        query = query.filter(models.Product.name.ilike(search_filter) | models.Product.description.ilike(search_filter))

    products = query.offset(skip).limit(limit).all()
    return products


@router.post("/", response_model=schemas.Product)
def create_product(
    *,
    db: Session = Depends(deps.get_db),
    product_in: schemas.ProductCreate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Create new product.
    Only Staff/Admins should be allowed to create products.
    """
    if current_user.role not in ["super_admin", "admin", "staff"]:
        raise HTTPException(
            status_code=403,
            detail="You do not have permission to create products."
        )

    # 1. Check for SKU conflict to prevent 500 IntegrityError
    existing_product = db.query(models.Product).filter(models.Product.sku == product_in.sku).first()
    if existing_product:
        raise HTTPException(
            status_code=400,
            detail=f"Product with SKU '{product_in.sku}' already exists."
        )

    # 2. Validate category_id if provided
    if product_in.category_id:
        category = db.query(models.Category).filter(models.Category.id == product_in.category_id).first()
        if not category:
            raise HTTPException(
                status_code=400,
                detail=f"Category ID {product_in.category_id} not found."
            )

    product = models.Product(
        name=product_in.name,
        description=product_in.description,
        price=product_in.price,
        wholesale_price=product_in.wholesale_price,
        sku=product_in.sku,
        image_url=product_in.image_url,
        stock_quantity=product_in.stock_quantity,
        unit=product_in.unit,
        min_order_quantity=product_in.min_order_quantity,
        is_active=product_in.is_active,
        category_id=product_in.category_id,
        category=product_in.category, # 🟢 Set the string category field too
        volume_tiers=product_in.volume_tiers
    )
    db.add(product)
    db.flush() # Get product.id

    # Handle Variants if provided
    for variant_in in product_in.variants:
        variant = models.ProductVariant(
            product_id=product.id,
            sku=variant_in.sku,
            name=variant_in.name,
            price=variant_in.price,
            wholesale_price=variant_in.wholesale_price,
            stock_quantity=variant_in.stock_quantity,
            is_active=variant_in.is_active
        )
        if variant_in.attribute_value_ids:
            attr_values = db.query(models.AttributeValue).filter(
                models.AttributeValue.id.in_(variant_in.attribute_value_ids)
            ).all()
            variant.attribute_values = attr_values
        db.add(variant)

    db.commit()
    db.refresh(product)
    return product

# --- Product Variants ---

@router.post("/{product_id}/variants", response_model=schemas.ProductVariant)
def create_product_variant(
    *,
    db: Session = Depends(deps.get_db),
    product_id: int,
    variant_in: schemas.ProductVariantCreate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """Create a new variant for a product."""
    if current_user.role not in ["super_admin", "admin", "staff"]:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    product = db.query(models.Product).filter(models.Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    variant = models.ProductVariant(
        product_id=product_id,
        sku=variant_in.sku,
        name=variant_in.name,
        price=variant_in.price,
        wholesale_price=variant_in.wholesale_price,
        stock_quantity=variant_in.stock_quantity,
        is_active=variant_in.is_active
    )
    if variant_in.attribute_value_ids:
        attr_values = db.query(models.AttributeValue).filter(
            models.AttributeValue.id.in_(variant_in.attribute_value_ids)
        ).all()
        variant.attribute_values = attr_values
    
    db.add(variant)
    db.commit()
    db.refresh(variant)
    return variant

@router.delete("/variants/{variant_id}", response_model=schemas.ProductVariant)
def delete_product_variant(
    *,
    db: Session = Depends(deps.get_db),
    variant_id: int,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """Delete a variant."""
    if current_user.role not in ["super_admin", "admin", "staff"]:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    variant = db.query(models.ProductVariant).filter(models.ProductVariant.id == variant_id).first()
    if not variant:
        raise HTTPException(status_code=404, detail="Variant not found")
        
    db.delete(variant)
    db.commit()
    return variant

@router.post("/bulk-upload")
async def bulk_upload_products(
    file: UploadFile = File(...),
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user)
) -> Any:
    """
    Bulk upload products from CSV.
    Expected format: name,sku,price,wholesale_price,unit,min_order_quantity,stock_quantity
    """
    if not file.filename.endswith('.csv'):
        raise HTTPException(status_code=400, detail="Only CSV files are supported")
    
    contents = await file.read()
    decoded = contents.decode('utf-8')
    reader = csv.DictReader(io.StringIO(decoded))
    
    products_created = 0
    errors = []
    
    for row in reader:
        try:
            product = models.Product(
                name=row['name'],
                sku=row.get('sku'),
                price=float(row['price']),
                wholesale_price=float(row['wholesale_price']) if row.get('wholesale_price') else None,
                unit=row.get('unit', 'unit'),
                min_order_quantity=int(row.get('min_order_quantity', 1)),
                stock_quantity=int(row.get('stock_quantity', 0)),
                is_active=True
            )
            db.merge(product) # Use merge to update if SKU exists (assuming SKU is unique)
            products_created += 1
        except Exception as e:
            errors.append(f"Row {row.get('name', 'Unknown')}: {str(e)}")
            
    db.commit()
    return {"status": "success", "created": products_created, "errors": errors}

@router.post("/upload-image")
async def upload_image(
    file: UploadFile = File(...),
    current_user: models.User = Depends(deps.get_current_active_user)
) -> Any:
    """
    Upload image to Local Storage and return URL.
    """
    try:
        import shutil
        import os
        import uuid
        
        # Ensure directory exists
        static_path = os.path.join("app", "static", "products")
        os.makedirs(static_path, exist_ok=True)
        
        # Generate unique filename to avoid collisions
        file_ext = os.path.splitext(file.filename)[1]
        unique_filename = f"{uuid.uuid4()}{file_ext}"
        file_path = os.path.join(static_path, unique_filename)
        
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        # Return local URL (assuming backend runs on localhost:8000)
        # In prod, this would be a full domain or CDN URL
        url = f"http://127.0.0.1:8000/static/products/{unique_filename}"
        return {"url": url}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Image upload failed: {str(e)}")


# --- Product Reviews & Moderation ---

@router.get("/reviews", response_model=List[schemas.ProductReviewResponse])
def read_reviews(
    db: Session = Depends(deps.get_db),
    status: Optional[str] = None,
    product_id: Optional[int] = None,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """List product reviews with filtering."""
    query = db.query(models.ProductReview).options(joinedload(models.ProductReview.product))
    if status:
        query = query.filter(models.ProductReview.status == status.lower())
    if product_id:
        query = query.filter(models.ProductReview.product_id == product_id)
    
    reviews = query.all()
    # Map product name to the response
    for r in reviews:
        r.product_name = r.product.name if r.product else "Unknown Product"
    return reviews

@router.patch("/reviews/{review_id}/status", response_model=schemas.ProductReviewResponse)
def update_review_status(
    review_id: int,
    status_in: schemas.ProductReviewUpdateStatus,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """Approve or reject a product review."""
    if current_user.role not in ["super_admin", "admin", "staff"]:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    review = db.query(models.ProductReview).filter(models.ProductReview.id == review_id).first()
    if not review:
        raise HTTPException(status_code=404, detail="Review not found")
    
    review.status = status_in.status.lower()
    db.commit()
    db.refresh(review)
    return review

# --- Stock Alerts (Low Stock & Out of Stock) ---

@router.get("/stock/low")
def get_low_stock(
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """List products and variants that are low in stock."""
    # Products with no variants or standalone products
    low_products = db.query(models.Product).filter(
        models.Product.stock_quantity <= models.Product.low_stock_threshold,
        models.Product.is_active == True
    ).all()

    # Variants below their specific thresholds
    low_variants = db.query(models.ProductVariant).options(
        joinedload(models.ProductVariant.product)
    ).filter(
        models.ProductVariant.stock_quantity <= models.ProductVariant.low_stock_threshold,
        models.ProductVariant.is_active == True
    ).all()

    results = []
    for p in low_products:
        results.append({
            "type": "product",
            "id": p.id,
            "name": p.name,
            "sku": p.sku,
            "stock": p.stock_quantity,
            "threshold": p.low_stock_threshold,
            "supplier": "N/A" # Placeholder based on user's existing UI
        })
    
    for v in low_variants:
        results.append({
            "type": "variant",
            "id": v.id,
            "name": f"{v.product.name} - {v.name}",
            "sku": v.sku,
            "stock": v.stock_quantity,
            "threshold": v.low_stock_threshold,
            "supplier": "N/A"
        })
    
    return results

@router.get("/stock/out")
def get_out_of_stock(
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """List products and variants that are out of stock."""
    out_products = db.query(models.Product).filter(
        models.Product.stock_quantity <= 0,
        models.Product.is_active == True
    ).all()

    out_variants = db.query(models.ProductVariant).options(
        joinedload(models.ProductVariant.product)
    ).filter(
        models.ProductVariant.stock_quantity <= 0,
        models.ProductVariant.is_active == True
    ).all()

    results = []
    for p in out_products:
        results.append({
            "type": "product",
            "id": p.id,
            "name": p.name,
            "sku": p.sku,
            "threshold": p.low_stock_threshold,
            "days_out": 0 # Placeholder for now
        })
    
    for v in out_variants:
        results.append({
            "type": "variant",
            "id": v.id,
            "name": f"{v.product.name} - {v.name}",
            "sku": v.sku,
            "threshold": v.low_stock_threshold,
            "days_out": 0
        })
    
    return results


@router.get("/{product_id}", response_model=schemas.Product)
def read_product(
    product_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get product by ID.
    """
    product = db.query(models.Product).filter(models.Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product


@router.put("/{product_id}", response_model=schemas.Product)
def update_product(
    *,
    db: Session = Depends(deps.get_db),
    product_id: int,
    product_in: schemas.ProductUpdate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update a product.
    Only Staff/Admins should be allowed to update products.
    """
    if current_user.role not in ["super_admin", "admin", "staff"]:
        raise HTTPException(
            status_code=403,
            detail="You do not have permission to update products."
        )

    # Get existing product
    product = db.query(models.Product).filter(models.Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    # Check for SKU conflict if SKU is being updated
    if product_in.sku is not None and product_in.sku != product.sku:
        existing_product = db.query(models.Product).filter(
            models.Product.sku == product_in.sku,
            models.Product.id != product_id
        ).first()
        if existing_product:
            raise HTTPException(
                status_code=400,
                detail=f"Product with SKU '{product_in.sku}' already exists."
            )

    # Validate category_id if provided
    if product_in.category_id is not None:
        category = db.query(models.Category).filter(models.Category.id == product_in.category_id).first()
        if not category:
            raise HTTPException(
                status_code=400,
                detail=f"Category ID {product_in.category_id} not found."
            )

    # Update product fields
    update_data = product_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(product, field, value)

    db.add(product)
    db.commit()
    db.refresh(product)
    return product


@router.delete("/{product_id}", response_model=schemas.Product)
def delete_product(
    *,
    db: Session = Depends(deps.get_db),
    product_id: int,
    current_user: models.User = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Delete a product.
    """
    product = db.query(models.Product).filter(models.Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    db.delete(product)
    db.commit()
    return product
