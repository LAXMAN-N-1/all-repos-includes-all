# app/models/service_m.py

from sqlalchemy import Column, String, Text, Numeric, Boolean
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel


class Service(BaseModel):
    """
    Master table for all services that can be offered for events
    Examples: Catering, Photography, Decoration, Venue, Music, Transport
    """
    __tablename__ = "services"

    name = Column(String(100), nullable=False)
    code = Column(String(50), nullable=False, unique=True)
    description = Column(Text, nullable=True)
    icon = Column(String(100), nullable=True)  # Emoji or icon identifier
    
    # Pricing (optional - can be overridden at event level)
    base_price = Column(Numeric(15, 2), nullable=True)
    price_unit = Column(String(50), nullable=True)  # per person, per hour, fixed, etc.
    
    # Availability
    is_active = Column(Boolean, default=True)
    
    # Relationships
