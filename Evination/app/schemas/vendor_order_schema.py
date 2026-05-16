from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from decimal import Decimal


# --------------------------------------------
# BASE
# --------------------------------------------
class VendorOrderBase(BaseModel):
    vendor_id: int
    event_id: Optional[int]
    order_ref: str
    amount: Decimal
    status: str


# --------------------------------------------
# CREATE (internal use)
# --------------------------------------------
class VendorOrderCreateSchema(VendorOrderBase):
    confirmed_at: Optional[datetime] = None


# --------------------------------------------
# RESPONSE (API)
# --------------------------------------------
class VendorOrderResponseSchema(VendorOrderBase):
    id: int

    confirmed_at: Optional[datetime]
    completed_at: Optional[datetime]

    created_at: datetime
    updated_at: Optional[datetime]

    class Config:
        from_attributes = True

class VendorOrderListSchema(BaseModel):
    id: int
    order_ref: str
    event_name: str
    event_date: str
    customer_name: str # From Event -> Organization or User? Need check. VendorOrder -> Event -> Organization?
    amount: Decimal
    status: str
    created_at: datetime

class VendorOrderDetailSchema(BaseModel):
    id: int
    order_ref: str
    amount: Decimal
    status: str
    created_at: datetime
    confirmed_at: Optional[datetime]
    completed_at: Optional[datetime]
    
    # Event Info
    event_id: int
    event_name: str
    event_date: str
    event_location: Optional[str]
    
    # Customer Info (Organizer)
    customer_name: str
    customer_email: Optional[str]
    customer_phone: Optional[str]
    
    # Payment Info? (If linked)
    
class VendorOrderStatusUpdateSchema(BaseModel):
    status: str # confirmed, completed, etc.

class VendorOrderStatsSchema(BaseModel):
    total_orders: int
    pending_orders: int
    active_orders: int
    completed_orders: int
    total_revenue: Decimal

