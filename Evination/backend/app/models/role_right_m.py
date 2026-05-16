from sqlalchemy import Column, Integer, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel

class RoleRight(BaseModel):
    __tablename__ = "role_rights"
    
    role_id = Column(Integer, ForeignKey("roles.id"), nullable=False)
    menu_id = Column(Integer, ForeignKey("menus.id"), nullable=False)
    can_view = Column(Boolean, default=True)
    can_create = Column(Boolean, default=False)
    can_edit = Column(Boolean, default=False)
    can_delete = Column(Boolean, default=False)
    
    # Relationships
    role = relationship("Role", back_populates="role_rights")
    menu = relationship("Menu", back_populates="role_rights")