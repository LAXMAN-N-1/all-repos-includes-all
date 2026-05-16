from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class ReviewBase(BaseModel):
    rating: float
    comment: Optional[str] = None
    event_id: Optional[int] = None

class ReviewCreate(ReviewBase):
    vendor_id: int

class ReviewResponse(ReviewBase):
    id: int
    consumer_id: int
    vendor_id: int
    created_at: datetime
    
    class Config:
        from_attributes = True

class VendorReviewList(BaseModel):
    id: int
    consumer_name: str
    rating: float
    comment: Optional[str]
    created_at: datetime
    
    class Config:
        from_attributes = True
