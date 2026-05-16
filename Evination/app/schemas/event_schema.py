# app/schemas/event_schema.py

from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from decimal import Decimal
from app.models.event_m import EventStatus, BiddingStatus

class EventCreateSchema(BaseModel):
    name: str = Field(..., max_length=255)
    organization_id: Optional[int] = None  # Consumer can specify org
    category_id: int
    event_type_id: int

    event_date: datetime
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None

    location: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    venue: Optional[str] = None

    expected_attendees: Optional[int] = 0
    budget: Optional[Decimal] = None

    description: Optional[str] = None
    special_requirements: Optional[str] = None
    theme: Optional[str] = None

    # IMPORTANT
    required_services: List[int]

    class Config:
        from_attributes = True

class EventUpdateSchema(BaseModel):
    name: Optional[str] = None
    event_date: Optional[datetime] = None
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None

    location: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    venue: Optional[str] = None

    expected_attendees: Optional[int] = None
    budget: Optional[Decimal] = None

    description: Optional[str] = None
    special_requirements: Optional[str] = None
    theme: Optional[str] = None

    required_services: Optional[List[int]] = None

    bidding_status: Optional[BiddingStatus] = None
    status: Optional[EventStatus] = None

    class Config:
        from_attributes = True

class EventServiceResponse(BaseModel):
    id: int
    name: str
    category: Optional[str]
    eventType: Optional[str]

    eventDate: datetime
    location: Optional[str]
    city: Optional[str]
    state: Optional[str]

    expectedAttendees: int
    budget: Optional[Decimal]
    theme: Optional[str]

    biddingStatus: BiddingStatus
    biddingDeadline: Optional[datetime]
    status: EventStatus

    requiredServices: List[dict]

    class Config:
        from_attributes = True

class ConsumerEventListSchema(BaseModel):
    id: int
    name: str
    eventDate: str
    location: Optional[str]
    budget: Decimal
    biddingStatus: BiddingStatus
    bidCount: int
    createdAt: datetime

    class Config:
        from_attributes = True
