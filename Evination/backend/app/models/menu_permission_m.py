from sqlalchemy import Column, Integer, ForeignKey, String
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel

class MenuPermission(BaseModel):
    __tablename__ = "menu_permissions"
    
    menu_id = Column(Integer, ForeignKey("menus.id"), nullable=False)
    permission_id = Column(Integer, ForeignKey("permissions.id"), nullable=False)
    action_type = Column(String(20), nullable=False)  # "view", "create", "edit", "delete"
    
    # Relationships
    menu = relationship("Menu", back_populates="menu_permissions")
    permission = relationship("Permission", back_populates="menu_permissions")