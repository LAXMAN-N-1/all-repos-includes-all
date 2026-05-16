
from sqlalchemy import Column, Integer, String, Text, DateTime, Numeric, Enum, ForeignKey, JSON
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel
import enum


class EventStatus(str, enum.Enum):
    PLANNING = "Planning"
    CONFIRMED = "Confirmed"
    ACTIVE = "Active"
    COMPLETED = "Completed"
    CANCELLED = "Cancelled"


class BiddingStatus(str, enum.Enum):
    OPEN = "open"
    CLOSED = "closed"
    UNDER_REVIEW = "under_review"
    SHORTLISTED = "shortlisted"
    AWARDED = "awarded"


class Event(BaseModel):
    __tablename__ = "events"

    # Organization (Consumer who created the event)
    organization_id = Column(Integer, ForeignKey("organizations.id"), nullable=False)
    
    # Event Details
    name = Column(String(255), nullable=False)
    category_id = Column(Integer, ForeignKey("categories.id"), nullable=False)
    event_type_id = Column(Integer, ForeignKey("event_types.id"), nullable=False)
    
    # Date & Location
    event_date = Column(DateTime, nullable=False)
    start_time = Column(DateTime, nullable=True)
    end_time = Column(DateTime, nullable=True)
    location = Column(String(255), nullable=True)
    city = Column(String(100), nullable=True)
    state = Column(String(100), nullable=True)
    venue = Column(String(255), nullable=True)
    
    # Event Metrics
    expected_attendees = Column(Integer, default=0)
    actual_attendees = Column(Integer, nullable=True)
    budget = Column(Numeric(15, 2), nullable=True)
    
    # Description
    description = Column(Text, nullable=True)
    special_requirements = Column(Text, nullable=True)
    
    # NEW: Additional fields from frontend
    theme = Column(String(100), nullable=True)
    
    # NEW: Required Services (JSON array of service IDs)
    required_services = Column(JSON, nullable=False)
    # Example: [1, 2, 3, 5] means needs Catering, Decoration, Photography, Music
    
    # Status & Assignment
    status = Column(Enum(EventStatus), default=EventStatus.PLANNING)
    event_manager_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    
    # NEW: Bidding Status - use String to match existing DB schema
    bidding_status = Column(
        Enum(BiddingStatus, values_callable=lambda x: [e.value for e in x]),
        default=BiddingStatus.OPEN
    )
    bidding_deadline = Column(DateTime, nullable=True)
    
    # NEW: Selected Vendor (after consumer selection)
    selected_vendor_id = Column(Integer, ForeignKey("vendors.id"), nullable=True)
    selected_bid_id = Column(Integer, ForeignKey("vendor_bids.id", use_alter=True, name="fk_events_vendor_bids_id"), nullable=True)
    vendor_selected_at = Column(DateTime, nullable=True)
    
    # Relationships
    organization = relationship("Organization")
    category = relationship("Category", back_populates="events")
    event_type = relationship("EventType", back_populates="events")
    event_manager = relationship("User", foreign_keys=[event_manager_id])
    
    # NEW: Bidding relationships
    bids = relationship("VendorBid", back_populates="event", foreign_keys="VendorBid.event_id")
    selected_vendor = relationship("Vendor", foreign_keys=[selected_vendor_id])
    selected_bid = relationship("VendorBid", foreign_keys=[selected_bid_id], post_update=True)
