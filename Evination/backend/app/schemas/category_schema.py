from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class CategoryBase(BaseModel):
    name: str
    code: str
    description: Optional[str] = None
    icon: Optional[str] = None
    color: Optional[str] = "purple"


class CategoryCreate(CategoryBase):
    pass


class CategoryUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    icon: Optional[str] = None
    color: Optional[str] = None


class CategoryResponse(CategoryBase):
    id: int
    events_count: Optional[int] = 0
    created_at: datetime
    
    class Config:
        from_attributes = True


class CategoryWithStats(CategoryResponse):
    events_count: int
    event_types_count: int