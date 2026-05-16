from sqlalchemy import Column, Integer, String, Text, DateTime, Numeric, Enum, ForeignKey
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel
import enum


class EventStatus(str, enum.Enum):
    PLANNING = "Planning"
    CONFIRMED = "Confirmed"
    ACTIVE = "Active"
    COMPLETED = "Completed"
    CANCELLED = "Cancelled"


class Event(BaseModel):
    __tablename__ = "events"

    # Organization
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
    
    # Status & Assignment
    status = Column(Enum(EventStatus), default=EventStatus.PLANNING)
    event_manager_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    created_by_user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    
    # Relationships
    organization = relationship("Organization")
    category = relationship("Category", back_populates="events")
    event_type = relationship("EventType", back_populates="events")
    event_manager = relationship("User", foreign_keys=[event_manager_id])
    creator = relationship("User", foreign_keys=[created_by_user_id])
    
    # Bidding
    bids = relationship("VendorBid", back_populates="event", foreign_keys="VendorBid.event_id")