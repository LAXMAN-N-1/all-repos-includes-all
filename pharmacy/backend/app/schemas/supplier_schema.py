from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum


class SupplierScopeEnum(str, Enum):
    ORG = "ORG"
    STORE = "STORE"


# ============= Request Schemas =============

class SupplierCreate(BaseModel):
    """Schema for creating a new supplier"""
    name: str = Field(..., min_length=1, max_length=255)
    code: str = Field(..., min_length=1, max_length=50)
    scope: Optional[SupplierScopeEnum] = Field(SupplierScopeEnum.ORG)
    store_id: Optional[int] = None
    contact_person: Optional[str] = Field(None, max_length=255)
    email: Optional[str] = Field(None, max_length=255)
    phone: str = Field(..., min_length=1, max_length=20)
    fax: Optional[str] = Field(None, max_length=20)
    website: Optional[str] = Field(None, max_length=255)
    address: str = Field(..., min_length=1)
    city: str = Field(..., min_length=1, max_length=100)
    state: str = Field(..., min_length=1, max_length=100)
    postal_code: Optional[str] = Field(None, max_length=20)
    country: Optional[str] = Field("India", max_length=100)
    license_number: Optional[str] = Field(None, max_length=100)
    drug_license_number: Optional[str] = Field(None, max_length=100)
    gst_number: Optional[str] = Field(None, max_length=50)
    tax_id: Optional[str] = Field(None, max_length=50)
    payment_terms: Optional[str] = Field(None, max_length=100)
    credit_limit: Optional[float] = Field(0.0, ge=0)
    notes: Optional[str] = None


class SupplierUpdate(BaseModel):
    """Schema for updating a supplier"""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    contact_person: Optional[str] = Field(None, max_length=255)
    email: Optional[str] = Field(None, max_length=255)
    phone: Optional[str] = Field(None, min_length=1, max_length=20)
    fax: Optional[str] = Field(None, max_length=20)
    website: Optional[str] = Field(None, max_length=255)
    address: Optional[str] = None
    city: Optional[str] = Field(None, max_length=100)
    state: Optional[str] = Field(None, max_length=100)
    postal_code: Optional[str] = Field(None, max_length=20)
    country: Optional[str] = Field(None, max_length=100)
    license_number: Optional[str] = Field(None, max_length=100)
    drug_license_number: Optional[str] = Field(None, max_length=100)
    gst_number: Optional[str] = Field(None, max_length=50)
    tax_id: Optional[str] = Field(None, max_length=50)
    payment_terms: Optional[str] = Field(None, max_length=100)
    credit_limit: Optional[float] = Field(None, ge=0)
    rating: Optional[float] = Field(None, ge=0, le=5)
    notes: Optional[str] = None
    inactive: Optional[bool] = None
    is_approved: Optional[bool] = None


# ============= Response Schemas =============

class SupplierResponse(BaseModel):
    """Schema for supplier response"""
    id: int
    name: str
    code: str
    scope: SupplierScopeEnum
    store_id: Optional[int] = None
    contact_person: Optional[str] = None
    email: Optional[str] = None
    phone: str
    fax: Optional[str] = None
    website: Optional[str] = None
    address: str
    city: str
    state: str
    postal_code: Optional[str] = None
    country: str
    license_number: Optional[str] = None
    drug_license_number: Optional[str] = None
    gst_number: Optional[str] = None
    tax_id: Optional[str] = None
    payment_terms: Optional[str] = None
    credit_limit: float
    rating: float
    notes: Optional[str] = None
    inactive: bool
    is_approved: bool
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class SupplierSummaryResponse(BaseModel):
    """Schema for supplier summary (list view)"""
    id: int
    name: str
    code: str
    scope: SupplierScopeEnum
    store_id: Optional[int] = None
    contact_person: Optional[str] = None
    phone: str
    city: str
    state: str
    inactive: bool
    is_approved: bool
    rating: float

    class Config:
        from_attributes = True


class SupplierListResponse(BaseModel):
    """Schema for paginated supplier list"""
    items: List[SupplierSummaryResponse]
    total: int
    page: int
    page_size: int
    total_pages: int


# ============= Filter Schemas =============

class SupplierFilters(BaseModel):
    """Schema for supplier search filters"""
    search: Optional[str] = None  # Searches name, code, contact_person
    scope: Optional[SupplierScopeEnum] = None
    store_id: Optional[int] = None
    city: Optional[str] = None
    state: Optional[str] = None
    inactive: Optional[bool] = None
    is_approved: Optional[bool] = None
