# app/schemas/admin_bidding_schema.py

from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class BidSummaryResponse(BaseModel):
    id: int
    vendor_name: str
    vendor_rating: Optional[float] = None
    amount: float
    status: str
    event_name: Optional[str] = None
    event_date: Optional[datetime] = None
    is_pushed: int = 0

    class Config:
        from_attributes = True


class BidDetailResponse(BaseModel):
    id: int
    vendor_name: str
    vendor_rating: Optional[float] = None
    vendor_category: Optional[str] = None
    vendor_experience: Optional[str] = None
    completed_events: Optional[int] = None
    vendor_phone: Optional[str] = None
    vendor_email: Optional[str] = None
    vendor_location: Optional[str] = None
    vendor_team_size: Optional[str] = None
    vendor_notes: Optional[str] = None
    vendor_documents: Optional[List[str]] = []
    vendor_certifications: Optional[List[str]] = []
    vendor_specializations: Optional[List[str]] = []
    
    vendor_specializations: Optional[List[str]] = []
    
    amount: float
    status: str
    is_recommended: Optional[bool] = False

    proposal: Optional[str] = None
    includes: Optional[List[str]] = None
    requirements: Optional[List[str]] = None
    requirements: Optional[List[str]] = None
    advantages: Optional[List[str]] = None
    
    line_items: Optional[List[dict]] = None
    tax: Optional[float] = 0.0
    terms: Optional[List[str]] = None

    discount: Optional[float] = 0.0
    valid_until: Optional[datetime] = None

    timeline_days: Optional[int] = None
    proposed_date: Optional[datetime] = None
    submitted_at: Optional[datetime] = None

    event_id: Optional[int] = None
    event_name: Optional[str] = None
    event_venue: Optional[str] = None
    event_location: Optional[str] = None
    event_guests: Optional[int] = None
    event_date: Optional[datetime] = None

    class Config:
        from_attributes = True


class BidActionRequest(BaseModel):
    notes: Optional[str] = None


class PushBidsRequest(BaseModel):
    event_id: int
    bid_ids: List[int]

class BidPricingRequest(BaseModel):
    final_price: float
    platform_commission: Optional[float] = None
    notes: Optional[str] = None


class VendorSimpleResponse(BaseModel):
    id: int
    name: str
    amount: float
    rating: float

class BiddingDashboardEventResponse(BaseModel):
    id: int
    event_name: str
    event_date: datetime
    event_type: str
    status: str
    categories: List[str]
    location: str
    description: Optional[str]
    
    total_bids: int
    lowest_bid: float
    average_bid: float
    highest_bid: float
    
    time_left: str
    assigned_vendor: Optional[VendorSimpleResponse] = None
    payment_status: str

    class Config:
        from_attributes = True

class CustomerViewResponse(BaseModel):
    event_id: int
    event_name: str
    event_date: datetime
    event_location: str
    event_venue: str
    event_guests: int
    
    assigned_bid: Optional[BidDetailResponse] = None
    top_bids: List[BidDetailResponse] = []
    
    class Config:
        from_attributes = True


class BiddingEventDetailResponse(BiddingDashboardEventResponse):
    venue: Optional[str] = None
    expected_guests: Optional[int] = 0
    duration: Optional[str] = None
    
    class Config:
        from_attributes = True
