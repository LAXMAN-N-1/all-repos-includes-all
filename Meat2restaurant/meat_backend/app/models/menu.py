from sqlalchemy import Column, Integer, String, Boolean, ForeignKey
from sqlalchemy.orm import relationship, backref
from app.db.base_class import Base, TimestampMixin

class Menu(Base, TimestampMixin):
    __tablename__ = "menus"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), index=True, nullable=False)
    path = Column(String(500), nullable=True) # Route path, e.g., /dashboard/orders
    icon = Column(String(100), nullable=True) # Icon name, e.g., 'ShoppingCart'
    parent_id = Column(Integer, ForeignKey("menus.id"), nullable=True)
    sort_order = Column(Integer, default=0)
    is_active = Column(Boolean, default=True)
    
    # Permission requirement to see this menu item
    # This maps to the User.permissions list or inferred from User.role
    required_permission = Column(String(100), nullable=True) 

    # Relationships
    children = relationship("Menu", backref=backref("parent", remote_side=[id]), order_by="Menu.sort_order")
