from sqlalchemy import Column, String, Integer, ForeignKey
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel


class EventType(BaseModel):
    """Event Types: In-Person, Virtual, Hybrid, Outdoor, etc."""
    __tablename__ = "event_types"

    category_id = Column(Integer, ForeignKey("categories.id"), nullable=False)
    name = Column(String(100), nullable=False)
    code = Column(String(50), nullable=False, unique=True)
    color = Column(String(50), default="blue")
    
    # Relationships
    category = relationship("Category", back_populates="event_types")
    events = relationship("Event", back_populates="event_type")