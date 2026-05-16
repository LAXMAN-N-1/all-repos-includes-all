from typing import Optional, Any
from datetime import datetime
from pydantic import BaseModel

class NotificationBase(BaseModel):
    title: str
    message: str
    type: str # invoice_pushed, order_confirmed
    payload: Optional[Any] = None

class NotificationCreate(NotificationBase):
    customer_id: int

class NotificationUpdate(BaseModel):
    is_read: Optional[bool] = None
    is_delivered: Optional[bool] = None

class Notification(NotificationBase):
    id: int
    customer_id: int
    is_read: bool
    is_delivered: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
