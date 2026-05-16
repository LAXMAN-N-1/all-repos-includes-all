from sqlalchemy import Column, String, Text
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel

class Role(BaseModel):
    __tablename__ = "roles"
    
    name = Column(String(100), nullable=False, unique=True)
    code = Column(String(50), nullable=False, unique=True)
    description = Column(Text, nullable=True)
    color = Column(String(50), nullable=True, default='gray')
    
    # Relationships
    users = relationship("User", back_populates="role")
    role_rights = relationship("RoleRight", back_populates="role")
    role_permissions = relationship("RolePermission", back_populates="role")

    @property
    def users_count(self):
        return len(self.users) if self.users else 0