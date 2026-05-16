from typing import Optional, List, Any
from datetime import datetime
from pydantic import BaseModel
from app.features.orders.models.order import OrderStatus
from app.features.customers.schemas.customer import Customer as CustomerSchema
from app.features.catalog.schemas.product import Product as ProductSchema
from app.features.orders.schemas.sales_extras import ShipmentOut

# Shared properties
class OrderItemBase(BaseModel):
    product_id: Optional[int] = None
    variant_id: Optional[int] = None # NEW: Selected variant
    quantity: int

class OrderItemCreate(OrderItemBase):
    price: Optional[float] = None # NEW: Support passing price from frontend if needed (or verify on backend)
    pass

class OrderItemUpdate(BaseModel):
    product_id: Optional[int] = None
    variant_id: Optional[int] = None
    quantity: Optional[int] = None

class OrderItem(OrderItemBase):
    id: int
    order_id: int
    unit_price: float
    total_price: float
    product: Optional[ProductSchema] = None
    # We could also include variant details here if needed
    
    class Config:
        from_attributes = True

class OrderStatusUpdateCreate(BaseModel):
    new_status: str
    notes: Optional[str] = None

class OrderStatusUpdate(BaseModel):
    id: int
    old_status: str
    new_status: str
    changed_at: datetime
    notes: Optional[str] = None

    class Config:
        from_attributes = True

class OrderBase(BaseModel):
    customer_id: int
    location_id: Optional[int] = None
    notes: Optional[str] = None
    payment_terms: Optional[str] = None
    po_number: Optional[str] = None
    delivery_fee: float = 0.0
    platform_fee: float = 0.0
    order_source: Optional[str] = "web"

class OrderCreate(OrderBase):
    customer_id: Optional[int] = None # Optional for consumer portal (taken from token)
    items: List[OrderItemCreate]
    total_amount: Optional[float] = None
    delivery_method: Optional[str] = "standard"
    delivery_address: Optional[str] = None
    contact_name: Optional[str] = None
    contact_phone: Optional[str] = None
    contact_email: Optional[str] = None
    promo_code: Optional[str] = None
    payment_method: Optional[str] = "card"

class OrderUpdate(BaseModel):
    status: Optional[OrderStatus] = None
    payment_status: Optional[str] = None
    payment_terms: Optional[str] = None
    po_number: Optional[str] = None
    notes: Optional[str] = None
    delivery_otp: Optional[str] = None

class OrderInDBBase(OrderBase):
    id: int
    total_amount: float
    promotion_id: Optional[int] = None # NEW
    discount_amount: Optional[float] = 0.0 # NEW
    wallet_amount_used: Optional[float] = 0.0
    delivery_fee: Optional[float] = 0.0
    platform_fee: Optional[float] = 0.0
    status: OrderStatus
    created_at: datetime
    updated_at: datetime
    payment_status: Optional[str]
    items: List[OrderItem] = []
    customer: Optional[CustomerSchema] = None
    shipment: Optional[ShipmentOut] = None # CORRECTED: Use ShipmentOut for proper serialization
    status_updates: List[OrderStatusUpdate] = []
    delivery_otp: Optional[str] = None
    order_source: Optional[str] = "web"

    class Config:
        from_attributes = True

class Order(OrderInDBBase):
    pass
