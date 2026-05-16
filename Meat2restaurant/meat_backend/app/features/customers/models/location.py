from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.db.base_class import Base, TimestampMixin
from datetime import datetime

class Location(Base, TimestampMixin):
    __tablename__ = "locations"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), index=True)
    address = Column(String(500))
    city = Column(String(100))
    state = Column(String(100))
    zip_code = Column(String(20))
    phone = Column(String(20))
    is_default = Column(Boolean, default=False)
    
    customer_id = Column(Integer, ForeignKey("customers.id"), nullable=True) # made nullable initially for migration ease, but ideally False
    
    customer = relationship("Customer", back_populates="locations")
    is_active = Column(Boolean, default=True)
    
    # Relationships can be added here, e.g. orders at this location
    orders = relationship("Order", back_populates="location")
