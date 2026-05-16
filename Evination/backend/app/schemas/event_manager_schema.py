from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from decimal import Decimal


class EventManagerProfileBase(BaseModel):
    specialties: Optional[List[str]] = []
    availability_status: Optional[str] = "Available"
    max_concurrent_events: Optional[int] = 5


class EventManagerProfileCreate(EventManagerProfileBase):
    user_id: int


class EventManagerProfileUpdate(BaseModel):
    specialties: Optional[List[str]] = None
    availability_status: Optional[str] = None
    max_concurrent_events: Optional[int] = None


class EventManagerResponse(BaseModel):
    id: int
    user_id: int
    name: str
    email: str
    avatar: Optional[str] = None
    active_events_count: int
    completed_events_count: int
    rating: Decimal
    specialties: List[str]
    availability_status: str
    
    class Config:
        from_attributes = True


class EventManagerWithStats(EventManagerResponse):
    total_budget_managed: Optional[Decimal] = None
    avg_attendees: Optional[int] = None