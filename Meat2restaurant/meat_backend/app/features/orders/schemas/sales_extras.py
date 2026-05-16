from typing import Optional
from datetime import datetime
from pydantic import BaseModel

# --- Shipments ---
class ShipmentBase(BaseModel):
    order_id: int
    tracking_number: Optional[str] = None
    carrier: Optional[str] = None
    status: str = "pending"
    driver_id: Optional[int] = None # Added driver_id

class ShipmentCreate(ShipmentBase):
    pass

class ShipmentUpdate(BaseModel):
    tracking_number: Optional[str] = None
    carrier: Optional[str] = None
    status: Optional[str] = None
    shipped_date: Optional[datetime] = None
    delivered_date: Optional[datetime] = None

class ShipmentOut(ShipmentBase):
    id: int
    shipped_date: Optional[datetime]
    delivered_date: Optional[datetime]
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

# --- Gift Cards ---
class GiftCardBase(BaseModel):
    code: str
    initial_amount: float
    current_balance: float
    expiry_date: Optional[datetime] = None
    customer_id: Optional[int] = None
    is_active: bool = True

class GiftCardCreate(GiftCardBase):
    pass

class GiftCardUpdate(BaseModel):
    current_balance: Optional[float] = None
    expiry_date: Optional[datetime] = None
    is_active: Optional[bool] = None

class GiftCardRedeem(BaseModel):
    code: str
    amount: float

class GiftCardOut(GiftCardBase):
    id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
