from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.api import deps
from app import models, schemas

router = APIRouter()

# --- Categories ---

@router.get("/categories", response_model=List[schemas.CategoryOut])
def read_categories(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
):
    return db.query(models.Category).offset(skip).limit(limit).all()

@router.post("/categories", response_model=schemas.CategoryOut)
def create_category(
    category_in: schemas.CategoryCreate,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_superuser),
):
    db_obj = models.Category(**category_in.dict())
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

@router.get("/categories/{category_id}", response_model=schemas.CategoryOut)
def read_category(
    category_id: int,
    db: Session = Depends(deps.get_db),
):
    """Get category by ID."""
    category = db.query(models.Category).filter(models.Category.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    return category

@router.put("/categories/{category_id}", response_model=schemas.CategoryOut)
def update_category(
    category_id: int,
    category_in: schemas.CategoryUpdate,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_superuser),
):
    """Update a category."""
    category = db.query(models.Category).filter(models.Category.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    
    # Validate parent_id if provided
    if category_in.parent_id is not None and category_in.parent_id != category.parent_id:
        if category_in.parent_id == category_id:
            raise HTTPException(status_code=400, detail="Category cannot be its own parent")
        parent = db.query(models.Category).filter(models.Category.id == category_in.parent_id).first()
        if not parent:
            raise HTTPException(status_code=400, detail="Parent category not found")
    
    update_data = category_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(category, field, value)
    
    db.add(category)
    db.commit()
    db.refresh(category)
    return category

@router.delete("/categories/{category_id}", response_model=schemas.CategoryOut)
def delete_category(
    category_id: int,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_superuser),
):
    """Delete a category. Check for products using this category first."""
    from app.features.catalog.models.product import Product
    
    category = db.query(models.Category).filter(models.Category.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    
    # Check if any products use this category
    products_count = db.query(Product).filter(Product.category_id == category_id).count()
    if products_count > 0:
        raise HTTPException(
            status_code=400,
            detail=f"Cannot delete category. {products_count} product(s) are using this category."
        )
    
    db.delete(category)
    db.commit()
    return category

# --- Attributes ---

@router.get("/attributes", response_model=List[schemas.AttributeOut])
def read_attributes(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
):
    return db.query(models.Attribute).offset(skip).limit(limit).all()

@router.post("/attributes", response_model=schemas.AttributeOut)
def create_attribute(
    attribute_in: schemas.AttributeCreate,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_superuser),
):
    db_obj = models.Attribute(**attribute_in.dict())
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

@router.get("/attributes/{attribute_id}", response_model=schemas.AttributeOut)
def read_attribute(
    attribute_id: int,
    db: Session = Depends(deps.get_db),
):
    """Get attribute by ID."""
    attribute = db.query(models.Attribute).filter(models.Attribute.id == attribute_id).first()
    if not attribute:
        raise HTTPException(status_code=404, detail="Attribute not found")
    return attribute

@router.put("/attributes/{attribute_id}", response_model=schemas.AttributeOut)
def update_attribute(
    attribute_id: int,
    attribute_in: schemas.AttributeUpdate,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_superuser),
):
    """Update an attribute."""
    attribute = db.query(models.Attribute).filter(models.Attribute.id == attribute_id).first()
    if not attribute:
        raise HTTPException(status_code=404, detail="Attribute not found")
    
    update_data = attribute_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(attribute, field, value)
    
    db.add(attribute)
    db.commit()
    db.refresh(attribute)
    return attribute

@router.delete("/attributes/{attribute_id}", response_model=schemas.AttributeOut)
def delete_attribute(
    attribute_id: int,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_superuser),
):
    """Delete an attribute."""
    attribute = db.query(models.Attribute).filter(models.Attribute.id == attribute_id).first()
    if not attribute:
        raise HTTPException(status_code=404, detail="Attribute not found")
    
    db.delete(attribute)
    db.commit()
    return attribute

# --- Attribute Values ---

@router.get("/attributes/{attribute_id}/values", response_model=List[schemas.AttributeValueOut])
def read_attribute_values(
    attribute_id: int,
    db: Session = Depends(deps.get_db),
):
    """Retrieve values for a specific attribute."""
    return db.query(models.AttributeValue).filter(models.AttributeValue.attribute_id == attribute_id).all()

@router.post("/attribute-values", response_model=schemas.AttributeValueOut)
def create_attribute_value(
    value_in: schemas.AttributeValueCreate,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_superuser),
):
    """Create a new value for an attribute."""
    # Verify attribute exists
    attribute = db.query(models.Attribute).filter(models.Attribute.id == value_in.attribute_id).first()
    if not attribute:
        raise HTTPException(status_code=404, detail="Attribute not found")
        
    db_obj = models.AttributeValue(**value_in.dict())
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

@router.delete("/attribute-values/{value_id}", response_model=schemas.AttributeValueOut)
def delete_attribute_value(
    value_id: int,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_superuser),
):
    """Delete an attribute value."""
    db_obj = db.query(models.AttributeValue).filter(models.AttributeValue.id == value_id).first()
    if not db_obj:
        raise HTTPException(status_code=404, detail="Value not found")
    
    db.delete(db_obj)
    db.commit()
    return db_obj
