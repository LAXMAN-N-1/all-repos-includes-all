from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from enum import Enum

class BookingStatus(str, Enum):
    under_process = "under_process"
    awaiting_vendors = "awaiting_vendors"
    awaiting_payment = "awaiting_payment"
    confirmed = "confirmed"
    completed = "completed"
    cancelled = "cancelled"

class BookingBase(BaseModel):
    event_name: str
    event_type: str
    event_date: str
    event_time: Optional[str] = None
    location: str
    city: Optional[str] = None
    guest_count: Optional[str] = None
    budget: float
    requirements: Optional[str] = None
    services: Optional[List[str]] = []

class BookingCreate(BookingBase):
    pass

class BookingUpdate(BookingBase):
    status: Optional[BookingStatus] = None

class BookingResponse(BookingBase):
    id: int
    reference_id: str
    customer_id: int
    status: BookingStatus
    transaction_id: Optional[str] = None
    booking_step: str
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
