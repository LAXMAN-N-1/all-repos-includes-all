from pydantic import BaseModel
from typing import Optional, List, Any
from decimal import Decimal
from datetime import datetime

class VendorMatchSchema(BaseModel):
    id: int
    company_name: str

    offered_services: List[int] = []
    service_areas: Optional[List[str]] = None

    rating: Decimal
    completed_events: int
    year_established: Optional[str]

    status: str

    class Config:
        from_attributes = True

class VendorPublicSchema(BaseModel):
    id: int
    company_name: str
    business_type: Optional[str]

    city: Optional[str]
    state: Optional[str]

    rating: Decimal
    total_reviews: int
    completed_events: int

    portfolio_urls: Optional[List[str]]

    class Config:
        from_attributes = True

class VendorProfileUpdate(BaseModel):
    company_name: Optional[str] = None
    business_type: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    zip_code: Optional[str] = None
    website: Optional[str] = None
    year_established: Optional[str] = None
    team_size: Optional[str] = None
    license_number: Optional[str] = None
    insurance_provider: Optional[str] = None
    tax_id: Optional[str] = None
    description: Optional[str] = None
    offered_services: Optional[List[int]] = None
    portfolio_urls: Optional[List[str]] = None
    service_areas: Optional[List[str]] = None

class VendorProfileResponse(BaseModel):
    id: int
    user_id: int
    company_name: str
    business_type: Optional[str]
    phone: Optional[str]
    address: Optional[str]
    city: Optional[str]
    state: Optional[str]
    zip_code: Optional[str]
    website: Optional[str]
    year_established: Optional[str]
    team_size: Optional[str]
    license_number: Optional[str]
    insurance_provider: Optional[str]
    tax_id: Optional[str]
    description: Optional[str]
    
    offered_services: List[int] = []
    portfolio_urls: Optional[List[str]] = []
    
    rating: Decimal
    total_reviews: int
    completed_events: int
    
    service_areas: Optional[List[str]] = []
    status: str
    
    created_at: Optional[datetime]
    updated_at: Optional[datetime]

    class Config:
        from_attributes = True
