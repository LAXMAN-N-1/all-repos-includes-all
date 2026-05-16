from sqlalchemy import Column, String, Text, Integer, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.models.base import BaseModel
from app.models.role import role_menus


class Menu(BaseModel):
    """
    Menu/Screen model for dynamic UI generation.
    Hierarchical structure: Main Menu → Sub Menu → Inner Menu
    """
    __tablename__ = "menus"

    name = Column(String(100), nullable=False)
    code = Column(String(100), unique=True, nullable=False, index=True)
    description = Column(Text)
    
    # Menu hierarchy
    parent_id = Column(Integer, ForeignKey('menus.id'), nullable=True)
    level = Column(Integer, default=1)  # 1=Main, 2=Sub, 3=Inner
    sequence = Column(Integer, default=0)  # Display order
    
    # UI properties
    icon = Column(String(50))  # Icon class name
    route = Column(String(255))  # Frontend route path
    component = Column(String(255))  # Component name
    
    # Status (uses BaseModel.inactive instead of is_active)
    is_visible = Column(Boolean, default=True, nullable=False)
    
    # Relationships
    parent = relationship("Menu", remote_side="[Menu.id]", backref="children")
    roles = relationship("Role", secondary=role_menus, back_populates="menus")