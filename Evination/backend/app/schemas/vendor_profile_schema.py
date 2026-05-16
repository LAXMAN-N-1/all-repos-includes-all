from pydantic import BaseModel
from typing import Optional, List


class VendorProfileResponse(BaseModel):
    id: int
    company_name: str
    business_type: Optional[str]
    phone: Optional[str]
    address: Optional[str]
    city: Optional[str]
    state: Optional[str]
    zip_code: Optional[str]
    website: Optional[str]

    # FIXED → Provide default empty lists
    categories: Optional[List[str]] = []
    service_areas: Optional[List[str]] = []

    year_established: Optional[str]
    team_size: Optional[str]
    license_number: Optional[str]
    insurance_provider: Optional[str]
    tax_id: Optional[str]
    description: Optional[str]

    status: str

    class Config:
        from_attributes = True



class VendorProfileUpdateRequest(BaseModel):
    company_name: Optional[str]
    business_type: Optional[str]
    phone: Optional[str]
    address: Optional[str]
    city: Optional[str]
    state: Optional[str]
    zip_code: Optional[str]
    website: Optional[str]

    # Make them optional lists for updates
    categories: Optional[List[str]] = []
    service_areas: Optional[List[str]] = []

    year_established: Optional[str]
    team_size: Optional[str]
    license_number: Optional[str]
    insurance_provider: Optional[str]
    tax_id: Optional[str]
    description: Optional[str]
