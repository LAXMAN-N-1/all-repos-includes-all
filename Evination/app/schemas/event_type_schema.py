from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class EventTypeBase(BaseModel):
    category_id: int
    name: str = Field(..., max_length=100)
    code: str = Field(..., max_length=50)
    color: str = "blue"

class EventTypeCreate(EventTypeBase):
    pass

class EventTypeUpdate(BaseModel):
    name: Optional[str] = None
    color: Optional[str] = None

class EventTypeResponse(EventTypeBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True

class EventTypeWithStats(EventTypeResponse):
    category_name: Optional[str] = None
    events_count: int = 0
