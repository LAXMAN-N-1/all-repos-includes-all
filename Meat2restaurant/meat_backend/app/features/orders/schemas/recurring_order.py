from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel
from app.features.catalog.schemas.product import Product as ProductSchema


# --- Recurring Order Item ---
class RecurringOrderItemBase(BaseModel):
    product_id: int
    variant_id: Optional[int] = None
    quantity: int = 1


class RecurringOrderItemCreate(RecurringOrderItemBase):
    pass


class RecurringOrderItemOut(RecurringOrderItemBase):
    id: int
    recurring_order_id: int
    product: Optional[ProductSchema] = None

    class Config:
        from_attributes = True


# --- Recurring Order ---
class RecurringOrderBase(BaseModel):
    customer_id: int
    frequency: str = "weekly"
    next_delivery_date: Optional[datetime] = None
    notes: Optional[str] = None
    delivery_fee: float = 0.0
    platform_fee: float = 0.0
    location_id: Optional[int] = None
    payment_terms: Optional[str] = None


class RecurringOrderCreate(RecurringOrderBase):
    items: List[RecurringOrderItemCreate]


class RecurringOrderUpdate(BaseModel):
    frequency: Optional[str] = None
    next_delivery_date: Optional[datetime] = None
    notes: Optional[str] = None
    status: Optional[str] = None
    delivery_fee: Optional[float] = None
    platform_fee: Optional[float] = None
    location_id: Optional[int] = None
    payment_terms: Optional[str] = None


class RecurringOrderOut(RecurringOrderBase):
    id: int
    status: str
    last_generated_at: Optional[datetime] = None
    total_orders_generated: int = 0
    created_at: datetime
    updated_at: datetime
    items: List[RecurringOrderItemOut] = []

    class Config:
        from_attributes = True
