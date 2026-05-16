from sqlalchemy import Column, Integer, Float, ForeignKey, JSON
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel

class VendorRestriction(BaseModel):
    __tablename__ = "vendor_restrictions"

    vendor_id = Column(Integer, ForeignKey("vendors.id"), nullable=False, unique=True)
    
    max_quotations_per_day = Column(Integer, nullable=True) # Null = unlimited
    max_concurrent_bookings = Column(Integer, nullable=True) 
    
    min_booking_value = Column(Float, default=0.0)
    max_booking_value = Column(Float, nullable=True)
    
    allowed_service_areas = Column(JSON, default=[]) # List of cities
    restricted_categories = Column(JSON, default=[]) # List of category IDs
    
    updated_by_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    
    vendor = relationship("Vendor", back_populates="restriction")
