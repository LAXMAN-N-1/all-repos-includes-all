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


# ---- Portfolio Upload Schemas ----

class PortfolioUploadRequest(BaseModel):
    """Request to add portfolio URLs."""
    portfolio_urls: List[str]  # List of image/video URLs to add


class PortfolioResponse(BaseModel):
    """Response after portfolio update."""
    message: str
    portfolio_urls: List[str]


# ---- Vendor Reviews Schemas ----

class VendorReviewItem(BaseModel):
    """Single review item for vendor view."""
    id: int
    consumer_name: str
    rating: float
    comment: Optional[str]
    event_name: Optional[str] = None
    created_at: str

    class Config:
        from_attributes = True


class VendorReviewSummary(BaseModel):
    """Review summary stats for vendor."""
    average_rating: float
    total_reviews: int


class VendorReviewsResponse(BaseModel):
    """Paginated reviews response for vendor."""
    summary: VendorReviewSummary
    reviews: List[VendorReviewItem]
    skip: int
    limit: int

