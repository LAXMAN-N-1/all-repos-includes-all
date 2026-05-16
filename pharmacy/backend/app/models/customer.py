from sqlalchemy import Column, String, Text, Boolean, ForeignKey, Date, Integer
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship
from app.models.base import BaseModel


class Customer(BaseModel):
    """
    Extended customer profile model.
    Links to User model and stores additional customer-specific information.
    """
    __tablename__ = "customers"

    # Link to User
    user_id = Column(Integer, ForeignKey('users.id'), unique=True, nullable=False, index=True)
    
    # Personal details
    date_of_birth = Column(Date)
    gender = Column(String(20))
    
    # Primary address
    address_line1 = Column(String(255))
    address_line2 = Column(String(255))
    city = Column(String(100), index=True)
    state = Column(String(100))
    postal_code = Column(String(20))
    country = Column(String(100), default="India")
    
    # Additional addresses (stored as JSON)
    # Format: [{"type": "home/work", "address": "...", "city": "...", ...}, ...]
    additional_addresses = Column(JSONB, default=list)
    
    # Health information (for prescription validation)
    allergies = Column(Text)
    chronic_conditions = Column(Text)
    emergency_contact_name = Column(String(255))
    emergency_contact_phone = Column(String(20))
    
    # Insurance (for future use)
    insurance_provider = Column(String(255))
    insurance_policy_number = Column(String(100))
    
    # Preferences
    notification_preferences = Column(JSONB, default=dict)
    # Format: {"email": true, "sms": true, "push": false, "promotional": false}
    
    preferred_store_id = Column(Integer, ForeignKey('stores.id'), nullable=True)
    
    # Loyalty program (future)
    loyalty_points = Column(Integer, default=0)
    membership_tier = Column(String(50), default="STANDARD")
    
    # Notes
    notes = Column(Text)
    
    # Relationships
    user = relationship("User", back_populates="customer_profile")
    preferred_store = relationship("Store")

