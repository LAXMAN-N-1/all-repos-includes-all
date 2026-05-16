from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class EventTypeBase(BaseModel):
    category_id: int
    name: str
    code: str
    color: Optional[str] = "blue"


class EventTypeCreate(EventTypeBase):
    pass


class EventTypeUpdate(BaseModel):
    name: Optional[str] = None
    color: Optional[str] = None


class EventTypeResponse(EventTypeBase):
    id: int
    category_name: Optional[str] = None
    events_count: Optional[int] = 0
    created_at: datetime
    
    class Config:
        from_attributes = True