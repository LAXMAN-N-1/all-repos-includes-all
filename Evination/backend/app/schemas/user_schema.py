from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime
from app.schemas.role_schema import RoleResponse
from app.schemas.branch_schema import BranchResponse

class UserBase(BaseModel):
    username: str
    email: EmailStr
    first_name: str
    last_name: Optional[str] = None
    phone: Optional[str] = None

class UserCreate(UserBase):
    password: str
    role_id: int
    branch_id: Optional[int] = None
    department_id: Optional[int] = None

class UserUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone: Optional[str] = None
    branch_id: Optional[int] = None
    department_id: Optional[int] = None
    role_id: Optional[int] = None

class UserResponse(UserBase):
    id: int
    organization_id: int
    branch_id: Optional[int]
    department_id: Optional[int]
    role_id: int
    avatar_url: Optional[str]
    inactive: bool
    created_at: datetime
    
    role: Optional['RoleResponse'] = None
    branch: Optional['BranchResponse'] = None
    
    class Config:
        from_attributes = True