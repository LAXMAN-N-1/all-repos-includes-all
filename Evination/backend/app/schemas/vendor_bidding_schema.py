from pydantic import BaseModel
from typing import Optional, List, Dict
from datetime import datetime

class VendorBidBase(BaseModel):
    event_id: int
    amount: float
    notes: Optional[str] = None
    timeline_days: Optional[int] = None
    proposed_date: Optional[datetime] = None
    # JSON fields
    includes: Optional[List[str]] = None
    requirements: Optional[List[str]] = None
    advantages: Optional[List[str]] = None
    
    line_items: Optional[List[dict]] = None
    tax: Optional[float] = 0.0
    terms: Optional[List[str]] = None

    discount: Optional[float] = 0.0
    valid_until: Optional[datetime] = None

class VendorBidCreate(VendorBidBase):
    pass

class VendorBidUpdate(BaseModel):
    amount: Optional[float] = None
    notes: Optional[str] = None
    timeline_days: Optional[int] = None
    proposed_date: Optional[datetime] = None
    includes: Optional[List[str]] = None
    requirements: Optional[List[str]] = None
    advantages: Optional[List[str]] = None
    
    line_items: Optional[List[dict]] = None
    tax: Optional[float] = None
    terms: Optional[List[str]] = None
    
    discount: Optional[float] = None
    valid_until: Optional[datetime] = None

class VendorBidResponse(VendorBidBase):
    id: int
    vendor_id: int
    status: str
    submitted_at: Optional[datetime] = None
    accepted_at: Optional[datetime] = None
    event_name: Optional[str] = None

    class Config:
        from_attributes = True
