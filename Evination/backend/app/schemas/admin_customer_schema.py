from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class CustomerStatResponse(BaseModel):
    id: int
    name: str
    email: str
    phone: Optional[str]
    location: Optional[str]
    join_date: datetime
    last_active: Optional[datetime]
    
    # Stats
    total_bookings: int
    active_bookings: int
    total_spent: float
    avg_spent: float
    
    tier: str # Standard, Premium, VIP
    status: str # Active, Inactive

    class Config:
        from_attributes = True

class CustomerDetailResponse(CustomerStatResponse):
    # Additional Details
    gender: Optional[str] = None
    anniversary: Optional[datetime] = None
    preferences: Optional[dict] = None
    admin_notes: Optional[str] = None
    
    class Config:
        from_attributes = True
