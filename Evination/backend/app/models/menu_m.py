from sqlalchemy import Column, String, Integer, Text
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel

class Menu(BaseModel):
    __tablename__ = "menus"
    
    parent_id = Column(Integer, nullable=True)
    name = Column(String(100), nullable=False)
    code = Column(String(50), nullable=False, unique=True)
    icon = Column(String(100), nullable=True)
    route = Column(String(200), nullable=True)
    description = Column(Text, nullable=True)
    sort_order = Column(Integer, default=0)
    menu_type = Column(String(20), default="main")  # main, sub, inner
    
    # Relationships
    role_rights = relationship("RoleRight", back_populates="menu")
    menu_permissions = relationship("MenuPermission", back_populates="menu")