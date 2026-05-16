from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class MenuBase(BaseModel):
    name: str
    code: str
    parent_id: Optional[int] = None
    icon: Optional[str] = None
    route: Optional[str] = None
    menu_type: Optional[str] = "main"

class MenuCreate(MenuBase):
    pass

class MenuResponse(MenuBase):
    id: int
    sort_order: int
    created_at: datetime
    
    class Config:
        from_attributes = True