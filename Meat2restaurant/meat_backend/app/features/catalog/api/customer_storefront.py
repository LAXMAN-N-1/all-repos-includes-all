"""
Customer Storefront API
Authenticated endpoints for B2B Partners (Customers)
Includes profile, orders history, and wishlist management.
"""
from typing import List, Any
from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from sqlalchemy import desc
from pydantic import BaseModel

from app.api import deps
from app import models, schemas
from app.features.customers.models.wishlist import Wishlist
from app.features.orders.models.order import Order
from app.features.catalog.models.product import Product
from app.features.orders.api.orders import create_order as create_order_internal

router = APIRouter()

# ──────────────────── Schemas ────────────────────

class WishlistAdd(BaseModel):
    product_id: int

class WishlistItemOut(BaseModel):
    id: int
    product_id: int
    product_name: str | None = None
    product_price: float | None = None
    product_image: str | None = None
    
    class Config:
        from_attributes = True

# ──────────────────── Endpoints: Profile ────────────────────

@router.get("/profile", response_model=schemas.Customer)
def get_customer_profile(
    current_user: Any = Depends(deps.get_current_active_user)
):
    """Get the current authenticated customer's profile."""
    if getattr(current_user, "identity_type", None) != "partner":
        raise HTTPException(status_code=403, detail="Only B2B customers can access this endpoint")
    return current_user

@router.put("/profile", response_model=schemas.Customer)
def update_customer_profile(
    *,
    db: Session = Depends(deps.get_db),
    current_user: Any = Depends(deps.get_current_active_user),
    profile_update: schemas.CustomerUpdatePartner
):
    """Update profile details for the current customer."""
    if getattr(current_user, "identity_type", None) != "partner":
        raise HTTPException(status_code=403, detail="Only B2B customers can access this endpoint")
    
    update_data = profile_update.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(current_user, field, value)
        
    db.add(current_user)
    db.commit()
    db.refresh(current_user)
    return current_user

# ──────────────────── Endpoints: Orders ────────────────────

from app.features.orders.schemas.order import Order as SchemaOrder

@router.get("/orders", response_model=List[SchemaOrder])
def get_customer_orders(
    db: Session = Depends(deps.get_db),
    current_user: Any = Depends(deps.get_current_active_user),
    skip: int = 0,
    limit: int = 50,
):
    """Get the order history for the current customer."""
    if getattr(current_user, "identity_type", None) != "partner":
        raise HTTPException(status_code=403, detail="Only B2B customers can access this endpoint")
    
    orders = db.query(Order).filter(
        Order.customer_id == current_user.id
    ).order_by(desc(Order.created_at)).offset(skip).limit(limit).all()
    
    return orders

@router.post("/orders", response_model=SchemaOrder)
def create_customer_order(
    *,
    db: Session = Depends(deps.get_db),
    order_in: schemas.OrderCreate,
    current_user: Any = Depends(deps.get_current_active_user),
):
    """Create a new order for the current customer."""
    if getattr(current_user, "identity_type", None) != "partner":
        raise HTTPException(status_code=403, detail="Only B2B customers can access this endpoint")
    
    # Force the customer_id to be the current user's ID for security
    order_in.customer_id = current_user.id
    
    return create_order_internal(db=db, order_in=order_in, current_user=current_user)


# ──────────────────── Endpoints: Wishlist ────────────────────

@router.get("/wishlist", response_model=List[WishlistItemOut])
def get_customer_wishlist(
    db: Session = Depends(deps.get_db),
    current_user: Any = Depends(deps.get_current_active_user)
):
    """Get all wishlist items for the current customer."""
    if getattr(current_user, "identity_type", None) != "partner":
        raise HTTPException(status_code=403, detail="Only B2B customers can access this endpoint")
    
    wishlist_items = db.query(Wishlist).filter(
        Wishlist.customer_id == current_user.id
    ).all()
    
    results = []
    for item in wishlist_items:
        product = db.query(Product).filter(Product.id == item.product_id).first()
        results.append(WishlistItemOut(
            id=item.id,
            product_id=item.product_id,
            product_name=product.name if product else None,
            product_price=product.price if product else None,
            product_image=product.image_url if product else None
        ))
        
    return results

@router.post("/wishlist", response_model=WishlistItemOut)
def add_to_wishlist(
    *,
    db: Session = Depends(deps.get_db),
    current_user: Any = Depends(deps.get_current_active_user),
    wishlist_in: WishlistAdd
):
    """Add a product to the customer's wishlist."""
    if getattr(current_user, "identity_type", None) != "partner":
        raise HTTPException(status_code=403, detail="Only B2B customers can access this endpoint")
    
    # check if product exists
    product = db.query(Product).filter(Product.id == wishlist_in.product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
        
    # check if already in wishlist
    existing = db.query(Wishlist).filter(
        Wishlist.customer_id == current_user.id,
        Wishlist.product_id == wishlist_in.product_id
    ).first()
    
    if existing:
        return WishlistItemOut(
            id=existing.id,
            product_id=existing.product_id,
            product_name=product.name,
            product_price=product.price,
            product_image=product.image_url
        )
        
    new_item = Wishlist(
        customer_id=current_user.id,
        product_id=wishlist_in.product_id
    )
    db.add(new_item)
    db.commit()
    db.refresh(new_item)
    
    return WishlistItemOut(
        id=new_item.id,
        product_id=new_item.product_id,
        product_name=product.name,
        product_price=product.price,
        product_image=product.image_url
    )

@router.delete("/wishlist/{product_id}")
def remove_from_wishlist(
    product_id: int,
    db: Session = Depends(deps.get_db),
    current_user: Any = Depends(deps.get_current_active_user)
):
    """Remove a product from the customer's wishlist."""
    if getattr(current_user, "identity_type", None) != "partner":
        raise HTTPException(status_code=403, detail="Only B2B customers can access this endpoint")
        
    item = db.query(Wishlist).filter(
        Wishlist.customer_id == current_user.id,
        Wishlist.product_id == product_id
    ).first()
    
    if item:
        db.delete(item)
        db.commit()
        
    return {"status": "success", "message": "Item removed from wishlist"}
