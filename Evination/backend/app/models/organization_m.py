from sqlalchemy import Column, String, Text
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel

class Organization(BaseModel):
    __tablename__ = "organizations"
    
    name = Column(String(200), nullable=False, unique=True)
    code = Column(String(50), nullable=False, unique=True)
    email = Column(String(100), nullable=True)
    phone = Column(String(20), nullable=True)
    address = Column(Text, nullable=True)
    city = Column(String(100), nullable=True)
    state = Column(String(100), nullable=True)
    country = Column(String(100), nullable=True)
    pincode = Column(String(10), nullable=True)
    logo_url = Column(String(500), nullable=True)
    website = Column(String(200), nullable=True)
    gst_number = Column(String(50), nullable=True)
    
    # Relationships
    branches = relationship("Branch", back_populates="organization")
    users = relationship("User", back_populates="organization")
    settings = relationship("Settings", back_populates="organization")