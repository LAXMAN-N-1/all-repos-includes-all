"""
Public Storefront API — No authentication required.
These endpoints power the customer-facing web/mobile storefront.
"""
from typing import List, Optional
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from pydantic import BaseModel, EmailStr

from app.api import deps
from app import models
from app.features.catalog.models.storefront import (
    ServiceLocation, BirthdayClubEntry, NewsletterSubscription
)

router = APIRouter()


# ──────────────────── Schemas ────────────────────

class CategoryOut(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    image_url: Optional[str] = None
    icon_url: Optional[str] = None

    class Config:
        from_attributes = True


class ProductOut(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    price: float
    wholesale_price: Optional[float] = None
    sku: Optional[str] = None
    image_url: Optional[str] = None
    stock_quantity: int = 0
    unit: str = "unit"
    category_id: Optional[int] = None
    category: Optional[str] = None
    is_popular: Optional[bool] = False
    is_bestseller: Optional[bool] = False
    is_special: Optional[bool] = False
    in_stock: bool = True

    class Config:
        from_attributes = True


class LocationOut(BaseModel):
    id: int
    name: str
    address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    zip_code: Optional[str] = None
    country: str = "UAE"

    class Config:
        from_attributes = True


class BlogOut(BaseModel):
    id: int
    title: str
    slug: str
    excerpt: Optional[str] = None
    featured_image: Optional[str] = None
    published_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class BirthdayClubIn(BaseModel):
    name: str
    email: str
    phone: Optional[str] = None
    date_of_birth: Optional[str] = None


class NewsletterIn(BaseModel):
    email: str


# ──────────────────── Endpoints ────────────────────

@router.get("/categories", response_model=List[CategoryOut])
def store_categories(db: Session = Depends(deps.get_db)):
    """List active categories for storefront."""
    return db.query(models.Category).filter(
        models.Category.is_active == True
    ).all()


@router.get("/products", response_model=List[ProductOut])
def store_products(
    db: Session = Depends(deps.get_db),
    category_id: Optional[int] = None,
    is_popular: Optional[bool] = None,
    is_bestseller: Optional[bool] = None,
    is_special: Optional[bool] = None,
    search: Optional[str] = None,
    skip: int = 0,
    limit: int = 50,
):
    """List active products with optional filters."""
    query = db.query(models.Product).filter(models.Product.is_active == True)

    if category_id:
        query = query.filter(models.Product.category_id == category_id)
    if is_popular:
        query = query.filter(models.Product.is_popular == True)
    if is_bestseller:
        query = query.filter(models.Product.is_bestseller == True)
    if is_special:
        query = query.filter(models.Product.is_special == True)
    if search:
        query = query.filter(models.Product.name.ilike(f"%{search}%"))

    products = query.offset(skip).limit(limit).all()

    # Add computed in_stock field
    result = []
    for p in products:
        out = ProductOut.model_validate(p)
        out.in_stock = p.stock_quantity > 0
        result.append(out)

    return result


@router.get("/products/{product_id}", response_model=ProductOut)
def store_product_detail(product_id: int, db: Session = Depends(deps.get_db)):
    """Get single product detail."""
    product = db.query(models.Product).filter(
        models.Product.id == product_id,
        models.Product.is_active == True
    ).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    out = ProductOut.model_validate(product)
    out.in_stock = product.stock_quantity > 0
    return out


@router.get("/locations", response_model=List[LocationOut])
def store_locations(db: Session = Depends(deps.get_db)):
    """List service locations."""
    return db.query(ServiceLocation).filter(
        ServiceLocation.is_active == True
    ).all()


@router.get("/blogs", response_model=List[BlogOut])
def store_blogs(db: Session = Depends(deps.get_db), limit: int = 10):
    """List published blog posts."""
    from app.features.cms.models.cms import BlogPost
    return db.query(BlogPost).filter(
        BlogPost.status == "published"
    ).order_by(BlogPost.published_at.desc()).limit(limit).all()


@router.post("/birthday-club")
def store_birthday_club(entry: BirthdayClubIn, db: Session = Depends(deps.get_db)):
    """Submit birthday club registration."""
    from datetime import date
    dob = None
    if entry.date_of_birth:
        try:
            dob = date.fromisoformat(entry.date_of_birth)
        except ValueError:
            pass

    db_entry = BirthdayClubEntry(
        name=entry.name,
        email=entry.email,
        phone=entry.phone,
        date_of_birth=dob,
    )
    db.add(db_entry)
    db.commit()
    return {"status": "success", "message": "Welcome to the Birthday Club!"}


@router.post("/newsletter")
def store_newsletter(sub: NewsletterIn, db: Session = Depends(deps.get_db)):
    """Subscribe to newsletter."""
    existing = db.query(NewsletterSubscription).filter(
        NewsletterSubscription.email == sub.email
    ).first()
    if existing:
        return {"status": "exists", "message": "Already subscribed!"}

    db_sub = NewsletterSubscription(email=sub.email)
    db.add(db_sub)
    db.commit()
    return {"status": "success", "message": "Subscribed successfully!"}
