from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from decimal import Decimal


class EventBase(BaseModel):
    name: str
    category_id: int
    event_type_id: int
    event_date: datetime
    location: Optional[str] = None
    city: Optional[str] = None
    venue: Optional[str] = None
    expected_attendees: Optional[int] = 0
    budget: Optional[Decimal] = None
    description: Optional[str] = None


class EventCreate(EventBase):
    event_manager_id: Optional[int] = None


class EventUpdate(BaseModel):
    name: Optional[str] = None
    event_type_id: Optional[int] = None
    event_date: Optional[datetime] = None
    location: Optional[str] = None
    city: Optional[str] = None
    venue: Optional[str] = None
    expected_attendees: Optional[int] = None
    budget: Optional[Decimal] = None
    description: Optional[str] = None
    status: Optional[str] = None
    event_manager_id: Optional[int] = None


class EventResponse(EventBase):
    id: int
    organization_id: int
    status: str
    event_manager_id: Optional[int]
    
    # Populated fields
    category_name: Optional[str] = None
    event_type_name: Optional[str] = None
    manager_name: Optional[str] = None
    
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True


class EventListResponse(BaseModel):
    """For list view with stats"""
    id: int
    name: str
    category: str
    event_type: str
    event_date: str
    location: str
    expected_attendees: int
    budget: Optional[Decimal]
    manager: Optional[str]
    status: str