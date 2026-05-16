from pydantic import BaseModel
from typing import Optional

class MenuInfo(BaseModel):
    id: int
    name: str
    code: str

    class Config:
        from_attributes = True

class RoleRightResponse(BaseModel):
    id: int
    role_id: int
    menu_id: int
    can_view: bool
    can_create: bool
    can_edit: bool
    can_delete: bool
    menu: Optional[MenuInfo] = None

    class Config:
        from_attributes = True
