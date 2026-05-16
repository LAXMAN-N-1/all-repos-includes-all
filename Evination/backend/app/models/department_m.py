from sqlalchemy import Column, String, Integer, ForeignKey, Text
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel

class Department(BaseModel):
    __tablename__ = "departments"
    
    branch_id = Column(Integer, ForeignKey("branches.id"), nullable=False)
    name = Column(String(200), nullable=False)
    code = Column(String(50), nullable=False)
    description = Column(Text, nullable=True)
    
    # Relationships
    branch = relationship("Branch", back_populates="departments")
    users = relationship("User", back_populates="department")