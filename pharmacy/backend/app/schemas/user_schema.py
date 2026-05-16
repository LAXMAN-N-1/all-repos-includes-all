from pydantic import BaseModel, Field, EmailStr
from typing import Optional, List
from datetime import datetime
from enum import Enum


class UserRoleEnum(str, Enum):
    """User roles matching the database enum"""
    SAAS_SUPER_ADMIN = "SAAS_SUPER_ADMIN"
    
    ORG_ADMIN = "ORG_ADMIN"
    HQ_ADMIN = "HQ_ADMIN"
    ORG_MANAGER = "ORG_MANAGER"
    
    STORE_MANAGER = "STORE_MANAGER"
    STORE_ADMIN = "STORE_ADMIN"
    PHARMACIST = "PHARMACIST"
    CASHIER = "CASHIER"
    
    DOCTOR = "DOCTOR"
    NURSE = "NURSE"
    LAB_TECHNICIAN = "LAB_TECHNICIAN"
    
    PATIENT = "PATIENT"
    CUSTOMER = "CUSTOMER"


# ============= Request Schemas =============

from app.schemas.role_schema import RoleResponse

# ... (UserRoleEnum is probably still needed for Filters? Or maybe drop it?) 
# Keeping UserRoleEnum for now as safe measure, but UserCreate/Response update is key.

class UserCreate(BaseModel):
    """Schema for creating a new user"""
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=128)
    full_name: str = Field(..., min_length=1, max_length=255)
    phone: Optional[str] = Field(None, max_length=20)
    role_id: int
    store_ids: Optional[List[int]] = Field(default_factory=list, description="Store IDs to assign to user")
    inactive: bool = False


class UserUpdate(BaseModel):
    """Schema for updating a user"""
    full_name: Optional[str] = Field(None, min_length=1, max_length=255)
    phone: Optional[str] = Field(None, max_length=20)
    role_id: Optional[int] = None
    inactive: Optional[bool] = None
    email_verified: Optional[bool] = None
    phone_verified: Optional[bool] = None

class UserPasswordUpdate(BaseModel):
    """Schema for updating user password"""
    current_password: str
    new_password: str = Field(..., min_length=8, max_length=128)


class UserStoreAssign(BaseModel):
    """Schema for assigning stores to a user"""
    store_ids: List[int]


# ============= Response Schemas =============

class StoreBasicResponse(BaseModel):
    """Basic store info for user response"""
    id: int
    name: str
    code: str
    city: str

    class Config:
        from_attributes = True


class UserResponse(BaseModel):
    """Schema for user response"""
    id: int
    organization_id: int
    email: str
    full_name: str
    phone: Optional[str] = None
    role: RoleResponse
    inactive: bool
    email_verified: bool
    phone_verified: bool
    last_login_at: Optional[datetime] = None
    assigned_stores: List[StoreBasicResponse] = []
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class UserListResponse(BaseModel):
    """Schema for paginated user list"""
    items: List[UserResponse]
    total: int
    page: int
    page_size: int
    total_pages: int


# ============= Filter Schemas =============

class UserFilters(BaseModel):
    """Schema for user filters"""
    role: Optional[UserRoleEnum] = None
    store_id: Optional[int] = None
    inactive: Optional[bool] = None
    search: Optional[str] = None  # Search by name or email
