from pydantic import BaseModel, EmailStr
from typing import List, Optional

class LoginRequest(BaseModel):
    email: EmailStr  # Changed from username to email
    password: str

class UserInfo(BaseModel):
    id: int
    username: str
    email: str
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    role_code: str

class MenuInfo(BaseModel):
    id: int
    name: str
    route: Optional[str]
    code: str
    icon: Optional[str]

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