from typing import List, Optional
from pydantic import BaseModel

# Shared properties
class MenuBase(BaseModel):
    title: str
    path: Optional[str] = None
    icon: Optional[str] = None
    parent_id: Optional[int] = None
    sort_order: int = 0
    is_active: bool = True
    required_permission: Optional[str] = None

# Properties to receive via API on creation
class MenuCreate(MenuBase):
    pass

# Properties to receive via API on update
class MenuUpdate(MenuBase):
    title: Optional[str] = None

class MenuInDBBase(MenuBase):
    id: int

    class Config:
        from_attributes = True

# Additional properties to return via API
class Menu(MenuInDBBase):
    children: List["Menu"] = []

# To handle recursive children
Menu.update_forward_refs()
