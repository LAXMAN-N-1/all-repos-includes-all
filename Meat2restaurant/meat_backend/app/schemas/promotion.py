from typing import Optional
from pydantic import BaseModel
from datetime import datetime

class PromotionBase(BaseModel):
    name: str
    code: str
    description: Optional[str] = None
    discount_type: str = "percentage"
    discount_value: float
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    is_active: bool = True
    usage_limit: Optional[int] = None
    banner_url: Optional[str] = None
    target_type: str = "all"
    target_id: Optional[int] = None

class PromotionCreate(PromotionBase):
    pass

class PromotionUpdate(BaseModel):
    name: Optional[str] = None
    code: Optional[str] = None
    description: Optional[str] = None
    discount_type: Optional[str] = None
    discount_value: Optional[float] = None
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    is_active: Optional[bool] = None
    usage_limit: Optional[int] = None
    banner_url: Optional[str] = None
    target_type: Optional[str] = None
    target_id: Optional[int] = None

class PromotionOut(PromotionBase):
    id: int
    usage_count: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
