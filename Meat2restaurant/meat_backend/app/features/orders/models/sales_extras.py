from sqlalchemy import Column, Integer, String, Boolean, Float, ForeignKey, DateTime, Enum
from sqlalchemy.orm import relationship
from app.db.base_class import Base, TimestampMixin
from datetime import datetime
import enum

class ShipmentStatus(str, enum.Enum):
    PENDING = "pending"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    RETURNED = "returned"

class Shipment(Base, TimestampMixin):
    __tablename__ = "shipments"
    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), index=True)
    tracking_number = Column(String(255), index=True, nullable=True)
    carrier = Column(String(100), nullable=True)
    status = Column(String(50), default=ShipmentStatus.PENDING, index=True)
    shipped_date = Column(DateTime, nullable=True)
    delivered_date = Column(DateTime, nullable=True)
    
    order = relationship("Order", back_populates="shipment")
    
    driver_id = Column(Integer, ForeignKey("users.id"), nullable=True, index=True)
    driver = relationship("User")

class GiftCard(Base, TimestampMixin):
    __tablename__ = "gift_cards"
    id = Column(Integer, primary_key=True, index=True)
    code = Column(String(100), unique=True, index=True)
    initial_amount = Column(Float)
    current_balance = Column(Float)
    is_active = Column(Boolean, default=True)
    expiry_date = Column(DateTime, nullable=True)
    customer_id = Column(Integer, ForeignKey("customers.id"), nullable=True)
    
    customer = relationship("Customer")
