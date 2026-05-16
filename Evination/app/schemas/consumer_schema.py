
from pydantic import BaseModel
from typing import Optional, List
from decimal import Decimal
from datetime import datetime
from app.schemas.vendor_order_schema import VendorOrderResponseSchema

class ConsumerVendorSchema(BaseModel):
    id: int
    name: str
    rating: float
    totalReviews: int
    completedEvents: int
    experienceYears: int
    teamSize: Optional[int]
    description: Optional[str]


class ConsumerBidPricingSchema(BaseModel):
    totalAmount: Decimal
    serviceBreakdown: Optional[list]


class ConsumerBidProposalSchema(BaseModel):
    description: Optional[str]
    timelineDays: Optional[int]
    advantages: List[str]
    portfolio: List[dict]
    termsAndConditions: Optional[str]
    cancellationPolicy: Optional[str]


class ConsumerShortlistedBidSchema(BaseModel):
    rank: int
    bidId: int
    vendor: ConsumerVendorSchema
    pricing: ConsumerBidPricingSchema
    proposal: ConsumerBidProposalSchema
    submittedAt: Optional[datetime]

class ConsumerShortlistedEventSchema(BaseModel):
    id: int
    name: str
    eventDate: datetime
    budget: Optional[Decimal]


class ConsumerShortlistedBidResponse(BaseModel):
    event: ConsumerShortlistedEventSchema
    shortlistedBids: List[ConsumerShortlistedBidSchema]

class ConsumerBidSelectionResponse(BaseModel):
    message: str
    order: VendorOrderResponseSchema
