from pydantic import BaseModel, EmailStr, Field
from typing import Optional, Dict, Any, List
from datetime import datetime
from app.schemas.saas_schema import OrgModuleResponse

class OrganizationBase(BaseModel):
    name: str
    code: str
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    postal_code: Optional[str] = None
    license_number: Optional[str] = None
    tax_id: Optional[str] = None
    domain: Optional[str] = None
    config: Dict[str, Any] = {}
    subscription_status: str = "TRIAL"

class OrganizationCreate(OrganizationBase):
    pass

class OrganizationUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    postal_code: Optional[str] = None
    domain: Optional[str] = None
    config: Optional[Dict[str, Any]] = None
    subscription_status: Optional[str] = None

class OrganizationResponse(OrganizationBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    enabled_modules: List[OrgModuleResponse] = []

    class Config:
        from_attributes = True
