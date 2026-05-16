from sqlalchemy import Column, Integer, String, Text, Numeric, ForeignKey
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel


class EventManagerProfile(BaseModel):
    """Extended profile for users who are event managers"""
    __tablename__ = "event_manager_profiles"

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, unique=True)
    
    # Stats
    active_events_count = Column(Integer, default=0)
    completed_events_count = Column(Integer, default=0)
    rating = Column(Numeric(3, 2), default=0.0)  # 0.00 to 5.00
    
    # Specialties (comma-separated or JSON)
    specialties = Column(Text, nullable=True)  # JSON array: ["Weddings", "Corporate"]
    
    # Availability
    availability_status = Column(String(50), default="Available")  # Available, Busy, On Leave
    max_concurrent_events = Column(Integer, default=5)
    
    # Relationships
    user = relationship("User", back_populates="event_manager_profile")