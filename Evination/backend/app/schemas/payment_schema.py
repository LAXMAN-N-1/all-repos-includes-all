from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class PaymentBase(BaseModel):
    vendor_id: int
    order_id: Optional[int] = None
    amount: float
    payment_method: Optional[str] = None
    status: Optional[str] = "completed"

class PaymentCreate(PaymentBase):
    pass

class PaymentUpdate(BaseModel):
    status: Optional[str] = None
    payment_method: Optional[str] = None

class PaymentResponse(PaymentBase):
    id: int
    payment_ref: str
    vendor_name: Optional[str] = None
    order_ref: Optional[str] = None
    paid_at: Optional[datetime]
    
    class Config:
        from_attributes = True
