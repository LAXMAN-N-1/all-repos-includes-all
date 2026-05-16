from pydantic import BaseModel
from typing import Optional
from datetime import datetime

from app.schemas.auth_schema import UserInfo

class BranchBase(BaseModel):
    name: str
    code: str
    email: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    country: Optional[str] = None
    pincode: Optional[str] = None
    inactive: Optional[bool] = False

class BranchCreate(BranchBase):
    organization_id: int
    is_head_office: Optional[int] = 0
    manager_id: Optional[int] = None
    employees_count: Optional[int] = 0

class BranchUpdate(BaseModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    email: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    country: Optional[str] = None
    pincode: Optional[str] = None
    manager_id: Optional[int] = None
    inactive: Optional[bool] = None

class BranchResponse(BranchBase):
    id: int
    organization_id: int
    is_head_office: int
    manager_id: Optional[int]
    manager: Optional[UserInfo]
    created_at: datetime
    
    class Config:
        from_attributes = True