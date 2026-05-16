from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime, Text, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.models.base_model import BaseModel
import enum

class RefundStatus(str, enum.Enum):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"
    PROCESSED = "processed"

class RefundType(str, enum.Enum):
    AUTOMATIC = "automatic"
    MANUAL = "manual"

class Refund(BaseModel):
    __tablename__ = "refunds"

    booking_id = Column(Integer, ForeignKey("bookings.id"), nullable=False)
    vendor_id = Column(Integer, ForeignKey("vendors.id"), nullable=True) # Optional, if refund relates to vendor penalty
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False) # User receiving refund
    
    amount = Column(Float, nullable=False)
    reason = Column(String(500), nullable=True)
    
    status = Column(Enum(RefundStatus), default=RefundStatus.PENDING)
    refund_type = Column(Enum(RefundType), default=RefundType.AUTOMATIC)
    
    admin_notes = Column(Text, nullable=True)
    processed_at = Column(DateTime, nullable=True)
    
    # Gateway specific
    gateway_refund_id = Column(String(100), nullable=True)

    # Relationships
    booking = relationship("Booking", backref="refunds")
    user = relationship("User", backref="refunds")
    vendor = relationship("Vendor", backref="refunds")
