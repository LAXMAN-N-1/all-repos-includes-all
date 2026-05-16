from typing import Optional
from pydantic import BaseModel
from datetime import datetime

class ProductReviewBase(BaseModel):
    product_id: int
    rating: int
    comment: Optional[str] = None
    customer_id: int
    customer_name: str

class ProductReviewCreate(ProductReviewBase):
    pass

class ProductReviewUpdateStatus(BaseModel):
    status: str # approved, rejected

class ProductReviewResponse(ProductReviewBase):
    id: int
    status: str
    product_name: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
