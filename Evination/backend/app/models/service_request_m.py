from sqlalchemy import Column, Integer, String, Text, ForeignKey
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel

class ServiceRequest(BaseModel):
    __tablename__ = "service_requests"

    booking_id = Column(Integer, ForeignKey("bookings.id"))
    service_name = Column(String(255))
    requirements = Column(Text, nullable=True)
    status = Column(String(50), default="pending")

    booking = relationship("Booking", back_populates="service_requests")
    
    # Updated Relationship: Link to VendorBid
    bids = relationship("VendorBid", back_populates="service_request")
