from sqlalchemy import Column, String, Integer, ForeignKey, Text
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel

class Settings(BaseModel):
    __tablename__ = "settings"
    
    organization_id = Column(Integer, ForeignKey("organizations.id"), nullable=False)
    setting_key = Column(String(100), nullable=False)
    setting_value = Column(Text, nullable=True)
    setting_type = Column(String(50), default="string")  # string, number, boolean, json
    category = Column(String(50), nullable=True)  # general, email, payment, etc.
    description = Column(Text, nullable=True)
    
    # Relationships
    organization = relationship("Organization", back_populates="settings")