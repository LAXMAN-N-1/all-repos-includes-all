from sqlalchemy import Column, Integer, String, Text, ForeignKey, DateTime, Boolean
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel


class VendorNotification(BaseModel):
    __tablename__ = "vendor_notifications"
    
    vendor_id = Column(Integer, ForeignKey("vendors.id"), nullable=False)
    event_id = Column(Integer, ForeignKey("events.id"), nullable=True)
    
    notification_type = Column(String(50), nullable=False)
    # new_event_match, bid_status_update, event_awarded, event_cancelled, etc.
    
    title = Column(String(255), nullable=False)
    message = Column(Text, nullable=False)
    
    # Priority & Category
    priority = Column(String(20), default="normal")  # low, normal, high, urgent
    category = Column(String(50), nullable=True)  # bidding, orders, payments, system
    
    # Action link (optional)
    action_url = Column(String(500), nullable=True)
    action_text = Column(String(100), nullable=True)  # "View Event", "Submit Bid"
    
    # Read status
    is_read = Column(Boolean, default=False)
    read_at = Column(DateTime, nullable=True)
    
    # Expiry (optional)
    expires_at = Column(DateTime, nullable=True)
    
    # Relationships
    vendor = relationship("Vendor", back_populates="notifications")
    event = relationship("Event")

