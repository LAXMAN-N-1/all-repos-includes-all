from sqlalchemy import Column, String, Text
from sqlalchemy.orm import relationship
from app.models.base import BaseModel
from app.models.role import role_permissions

class Permission(BaseModel):
    """
    Permission model for granular access control.
    Permissions are assigned to roles.
    """
    __tablename__ = "permissions"

    name = Column(String(100), unique=True, nullable=False, index=True)
    code = Column(String(100), unique=True, nullable=False, index=True)
    resource = Column(String(100), nullable=False, index=True)  # e.g., 'orders', 'inventory'
    action = Column(String(50), nullable=False)  # e.g., 'create', 'read', 'update', 'delete'
    description = Column(Text)
    
    # Relationships
    roles = relationship("Role", secondary=role_permissions, back_populates="permissions")

