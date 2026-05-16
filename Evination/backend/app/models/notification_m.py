from sqlalchemy import Column, Integer, String, Text, Boolean, ForeignKey, DateTime
from app.models.base_model import BaseModel
from datetime import datetime

class Notification(BaseModel):
    __tablename__ = "notifications"

    recipient_type = Column(String(50), nullable=False) # USER, VENDOR, ADMIN
    recipient_id = Column(Integer, nullable=False) # ID of User or Vendor
    
    title = Column(String(255), nullable=False)
    message = Column(Text, nullable=False)
    
    reference_type = Column(String(50), nullable=True) # e.g., "BOOKING", "BID"
    reference_id = Column(String(100), nullable=True)
    
    is_read = Column(Boolean, default=False)
    read_at = Column(DateTime, nullable=True)
    
    # Legacy fields (Made nullable to support migration transition)
    user_id = Column(Integer, nullable=True)
    type = Column(String(50), nullable=True)
    
    created_at = Column(DateTime, default=datetime.now)
