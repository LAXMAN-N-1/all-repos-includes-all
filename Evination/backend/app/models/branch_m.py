from sqlalchemy import Column, String, Integer, ForeignKey, Text
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel

class Branch(BaseModel):
    __tablename__ = "branches"
    
    organization_id = Column(Integer, ForeignKey("organizations.id"), nullable=False)
    name = Column(String(200), nullable=False)
    code = Column(String(50), nullable=False)
    email = Column(String(100), nullable=True)
    phone = Column(String(20), nullable=True)
    address = Column(Text, nullable=True)
    city = Column(String(100), nullable=True)
    state = Column(String(100), nullable=True)
    country = Column(String(100), nullable=True)
    pincode = Column(String(10), nullable=True)
    is_head_office = Column(Integer, default=0)
    manager_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    
    # Relationships
    organization = relationship("Organization", back_populates="branches")
    departments = relationship("Department", back_populates="branch")
    users = relationship("User", back_populates="branch", foreign_keys="[User.branch_id]")
    manager = relationship("User", foreign_keys=[manager_id])