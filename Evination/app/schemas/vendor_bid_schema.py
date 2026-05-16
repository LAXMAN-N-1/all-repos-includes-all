from pydantic import BaseModel
from typing import Optional, List
from decimal import Decimal
from datetime import datetime

class BidServiceBreakdown(BaseModel):
    service_id: int
    service_name: str
    cost: Decimal
    notes: Optional[str] = None


class BidPortfolioItem(BaseModel):
    type: str  # image / video
    url: str

class VendorBidCreateSchema(BaseModel):
    event_id: int
    total_amount: Decimal

    service_breakdown: Optional[List[BidServiceBreakdown]] = None
    proposal_description: Optional[str] = None
    timeline_days: Optional[int] = None

    advantages: Optional[List[str]] = []
    portfolio_items: Optional[List[BidPortfolioItem]] = []

    terms_and_conditions: Optional[str] = None
    cancellation_policy: Optional[str] = None
    notes: Optional[str] = None

class BidRequiredServiceSchema(BaseModel):
    id: int
    name: str
    icon: Optional[str]


class VendorAvailableEventSchema(BaseModel):
    id: int
    name: str
    eventDate: str
    location: Optional[str]
    expectedAttendees: int
    budget: Optional[Decimal]

    requiredServices: List[BidRequiredServiceSchema]

    biddingDeadline: Optional[str]
    description: Optional[str]
    specialRequirements: Optional[str]

class VendorMyBidSchema(BaseModel):
    bidId: int
    eventName: str
    eventDate: str
    totalAmount: Decimal
    status: str
    submittedAt: Optional[str]
    shortlisted: bool
    shortlistedRank: Optional[int]

class AdminVendorSnapshotSchema(BaseModel):
    id: int
    name: str
    rating: float
    totalReviews: int
    completedEvents: int
    experienceYears: int
    teamSize: Optional[int]

class AdminBidPricingSchema(BaseModel):
    totalAmount: Decimal
    serviceBreakdown: Optional[list]


class AdminBidProposalSchema(BaseModel):
    description: Optional[str]
    timelineDays: Optional[int]
    advantages: List[str]
    portfolio: List[dict]


class AdminBidReviewItemSchema(BaseModel):
    bidId: int
    vendor: AdminVendorSnapshotSchema
    pricing: AdminBidPricingSchema
    proposal: AdminBidProposalSchema

    submittedAt: Optional[str]
    autoScore: float
    adminScore: Optional[float]
    adminNotes: Optional[str]
    shortlisted: bool

class AdminEventBidReviewResponse(BaseModel):
    event: dict
    bids: List[AdminBidReviewItemSchema]

class AdminShortlistSchema(BaseModel):
    bid_ids: List[int]



class AdminScoreUpdateSchema(BaseModel):
    score: float
    notes: Optional[str]


class VendorBidUpdateSchema(BaseModel):
    total_amount: Optional[Decimal] = None
    service_breakdown: Optional[List[BidServiceBreakdown]] = None
    proposal_description: Optional[str] = None
    timeline_days: Optional[int] = None
    advantages: Optional[List[str]] = None
    portfolio_items: Optional[List[BidPortfolioItem]] = None
    terms_and_conditions: Optional[str] = None
    cancellation_policy: Optional[str] = None
    notes: Optional[str] = None

class VendorBidDetailSchema(BaseModel):
    id: int
    event_id: int
    event_name: str
    event_date: str
    bidding_deadline: Optional[str]
    
    total_amount: Decimal
    service_breakdown: Optional[List[dict]]
    proposal_description: Optional[str]
    timeline_days: Optional[int]
    advantages: List[str]
    portfolio_items: List[dict]
    terms_and_conditions: Optional[str]
    cancellation_policy: Optional[str]
    notes: Optional[str]
    
    status: str
    submitted_at: Optional[str]
    shortlisted: bool


