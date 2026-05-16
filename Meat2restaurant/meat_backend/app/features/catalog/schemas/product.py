from typing import Optional, Any, Dict, List
from datetime import datetime
from pydantic import BaseModel
from .catalog import AttributeValueOut

# --- Product Variants ---
class ProductVariantBase(BaseModel):
    sku: Optional[str] = None
    name: Optional[str] = None
    price: Optional[float] = None
    wholesale_price: Optional[float] = None
    stock_quantity: Optional[int] = 0
    is_active: Optional[bool] = True

class ProductVariantCreate(ProductVariantBase):
    sku: str
    attribute_value_ids: List[int] = [] # List of AttributeValue IDs to link

class ProductVariantUpdate(ProductVariantBase):
    attribute_value_ids: Optional[List[int]] = None

class ProductVariant(ProductVariantBase):
    id: int
    product_id: int
    attribute_values: List[AttributeValueOut] = []
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# --- Products ---
class ProductBase(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    wholesale_price: Optional[float] = None
    sku: Optional[str] = None
    image_url: Optional[str] = None
    stock_quantity: Optional[int] = 0
    unit: Optional[str] = "unit"
    min_order_quantity: Optional[int] = 1
    volume_tiers: Optional[Dict[str, float]] = None # e.g. {"10": 40.0, "50": 35.0}
    is_active: Optional[bool] = True
    category: Optional[str] = None
    category_id: Optional[int] = None

# Properties to receive via API on creation
class ProductCreate(ProductBase):
    name: str
    price: float
    sku: str
    variants: List[ProductVariantCreate] = []

# Properties to receive via API on update
class ProductUpdate(ProductBase):
    pass

class ProductInDBBase(ProductBase):
    id: Optional[int] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# Additional properties to return via API
class Product(ProductInDBBase):
    variants: List[ProductVariant] = []
