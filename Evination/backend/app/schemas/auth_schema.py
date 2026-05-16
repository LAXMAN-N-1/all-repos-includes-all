from pydantic import BaseModel, EmailStr
from typing import List, Optional

class LoginRequest(BaseModel):
    username: str
    password: str

class UserInfo(BaseModel):
    id: int
    username: str
    email: str
    first_name: str
    last_name: Optional[str]
    role_code: str
    role_id: int  # Added
    organization_id: Optional[int] = None  # Added
    branch_id: Optional[int] = None  # Added

class MenuInfo(BaseModel):
    id: int
    name: str
    route: Optional[str]
    code: str
    icon: Optional[str]
    parent_id: Optional[int] = None  # Added

class RightInfo(BaseModel):
    menu_id: int
    can_view: bool
    can_create: bool
    can_edit: bool
    can_delete: bool

class LoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserInfo
    menus: List[MenuInfo]  # NEW
    rights: List[RightInfo]  # NEW
    permissions: List[str]  # NEW

class TokenData(BaseModel):
    user_id: int
    username: str
    email: str
    role_code: str