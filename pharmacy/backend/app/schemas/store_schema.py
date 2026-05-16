from pydantic import BaseModel, Field, EmailStr
from typing import Optional, List, Dict, Any
from datetime import date, datetime


# ============= Request Schemas =============

class OperatingHoursDay(BaseModel):
    """Operating hours for a single day"""
    open: str = Field(..., pattern=r"^\d{2}:\d{2}$", description="Opening time in HH:MM format")
    close: str = Field(..., pattern=r"^\d{2}:\d{2}$", description="Closing time in HH:MM format")


class StoreCreate(BaseModel):
    """Schema for creating a new store"""
    name: str = Field(..., min_length=1, max_length=255)
    code: str = Field(..., min_length=1, max_length=50)
    address: str = Field(..., min_length=1)
    city: str = Field(..., min_length=1, max_length=100)
    state: str = Field(..., min_length=1, max_length=100)
    postal_code: Optional[str] = Field(None, max_length=20)
    phone: str = Field(..., min_length=1, max_length=20)
    email: Optional[EmailStr] = None
    operating_hours: Optional[Dict[str, OperatingHoursDay]] = None
    license_number: str = Field(..., min_length=1, max_length=100)
    license_expiry: Optional[date] = None
    inactive: bool = False


class StoreUpdate(BaseModel):
    """Schema for updating a store"""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    address: Optional[str] = None
    city: Optional[str] = Field(None, max_length=100)
    state: Optional[str] = Field(None, max_length=100)
    postal_code: Optional[str] = Field(None, max_length=20)
    phone: Optional[str] = Field(None, max_length=20)
    email: Optional[EmailStr] = None
    operating_hours: Optional[Dict[str, OperatingHoursDay]] = None
    license_expiry: Optional[date] = None
    inactive: Optional[bool] = None


# ============= Response Schemas =============

class UserBasicResponse(BaseModel):
    """Basic user info for store response"""
    id: int
    full_name: str
    email: str
    role: str

    class Config:
        from_attributes = True


class StoreResponse(BaseModel):
    """Schema for store response"""
    id: int
    organization_id: int
    name: str
    code: str
    address: str
    city: str
    state: str
    postal_code: Optional[str] = None
    phone: str
    email: Optional[str] = None
    operating_hours: Optional[Dict[str, Any]] = None
    license_number: str
    license_expiry: Optional[date] = None
    inactive: bool
    user_count: int = 0  # Computed field
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class StoreDetailResponse(StoreResponse):
    """Detailed store response with assigned users"""
    assigned_users: List[UserBasicResponse] = []


class StoreListResponse(BaseModel):
    """Schema for paginated store list"""
    items: List[StoreResponse]
    total: int
    page: int
    page_size: int
    total_pages: int


# ============= Filter Schemas =============

class StoreFilters(BaseModel):
    """Schema for store filters"""
    city: Optional[str] = None
    state: Optional[str] = None
    inactive: Optional[bool] = None
    search: Optional[str] = None  # Search by name or code
