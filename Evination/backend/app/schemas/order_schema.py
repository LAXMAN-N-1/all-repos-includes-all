from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class OrderBase(BaseModel):
    event_id: Optional[int] = None
    vendor_id: int
    amount: float
    status: Optional[str] = "confirmed"

class OrderCreate(OrderBase):
    pass

class OrderUpdate(BaseModel):
    status: Optional[str] = None
    amount: Optional[float] = None
    notes: Optional[str] = None

class OrderResponse(OrderBase):
    id: int
    order_ref: str
    vendor_name: Optional[str] = None
    
    # Event Info
    event_name: Optional[str] = None
    event_date: Optional[datetime] = None
    event_location: Optional[str] = None
    
    # Customer Info (from Organization/Event Manager)
    customer_name: Optional[str] = None
    customer_email: Optional[str] = None
    customer_phone: Optional[str] = None
    
    # Vendor Info
    vendor_contact: Optional[str] = None
    vendor_email: Optional[str] = None
    service_description: Optional[str] = None # Using Order Notes or Vendor Desc
    
    # Payment Info
    paid_amount: float = 0.0
    payment_status: str = "Pending"
    
    # Progress
    progress: int = 0
    delivery_date: Optional[datetime] = None # Estimated

    confirmed_at: Optional[datetime]
    completed_at: Optional[datetime]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
