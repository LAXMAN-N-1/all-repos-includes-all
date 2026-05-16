from sqlalchemy import Column, String, Text
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel

class Permission(BaseModel):
    __tablename__ = "permissions"
    
    code = Column(String(100), nullable=False, unique=True)  # e.g., "user.view"
    name = Column(String(200), nullable=False)  # e.g., "View Users"
    description = Column(Text, nullable=True)
    module = Column(String(50), nullable=False)  # e.g., "user", "event", "order"
    action = Column(String(50), nullable=False)  # e.g., "view", "create", "update", "delete"
    
    # Relationships
    role_permissions = relationship("RolePermission", back_populates="permission")
    menu_permissions = relationship("MenuPermission", back_populates="permission")