from datetime import datetime
from sqlalchemy import Boolean, Column, Integer, String, Float, ForeignKey, DateTime, Enum
from sqlalchemy.orm import relationship
import enum

from app.db.base_class import Base, TimestampMixin

class OrderStatus(str, enum.Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    PACKED = "packed"
    ACCEPTED = "accepted"
    OUT_FOR_DELIVERY = "out_for_delivery"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"

class Order(Base, TimestampMixin):
    __tablename__ = "orders"
    
    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id"), index=True)
    total_amount = Column(Float, nullable=False)
    status = Column(String(50), default=OrderStatus.PENDING, index=True)
    payment_status = Column(String(50), default="pending") # pending, paid, failed
    payment_terms = Column(String(100), nullable=True) # e.g., Net 30, Due on Receipt
    po_number = Column(String(100), nullable=True) # Purchase Order Number
    notes = Column(String(1000), nullable=True)
    wallet_amount_used = Column(Float, default=0.0)
    delivery_fee = Column(Float, default=0.0)
    platform_fee = Column(Float, default=0.0)
    delivery_otp = Column(String(4), nullable=True)
    
    location_id = Column(Integer, ForeignKey("locations.id"), nullable=True, index=True)
    promotion_id = Column(Integer, ForeignKey("promotions.id"), nullable=True) # NEW: Link to applied promo
    discount_amount = Column(Float, default=0.0) # NEW: Value of discount applied
    order_source = Column(String(20), default="web") # NEW: web, whatsapp, offline
    
    # Meat2Restaurant Redesign Fields
    pickup_time = Column(DateTime, nullable=True)
    delivery_type = Column(String(20), default="pickup") # pickup, delivery
    delivery_address = Column(String(500), nullable=True)
    reminder_30_sent = Column(Boolean, default=False)
    reminder_ready_sent = Column(Boolean, default=False)
    
    customer = relationship("Customer", back_populates="orders")
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")
    invoices = relationship("Invoice", back_populates="order")
    location = relationship("Location", back_populates="orders")
    shipment = relationship("Shipment", uselist=False, back_populates="order")
    
    status_updates = relationship("OrderStatusUpdate", back_populates="order", cascade="all, delete-orphan")
    ratings = relationship("Rating", back_populates="order")

class Rating(Base):
    __tablename__ = "ratings"
    
    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), index=True)
    customer_id = Column(Integer, ForeignKey("customers.id"), index=True)
    stars = Column(Integer, nullable=False) # 1-5
    comment = Column(String(1000), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    order = relationship("Order", back_populates="ratings")
    customer = relationship("Customer")

class OrderStatusUpdate(Base):
    __tablename__ = "order_status_updates"
    
    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), index=True)
    old_status = Column(String(50))
    new_status = Column(String(50))
    changed_at = Column(DateTime, default=datetime.utcnow)
    changed_by_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    notes = Column(String(1000), nullable=True)

    order = relationship("Order", back_populates="status_updates")
    changed_by = relationship("User")

class OrderItem(Base):
    __tablename__ = "order_items"
    
    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), index=True)
    product_id = Column(Integer, ForeignKey("products.id"))
    variant_id = Column(Integer, ForeignKey("product_variants.id"), nullable=True) # NEW
    quantity = Column(Integer, nullable=False)
    unit_price = Column(Float, nullable=False) # Snapshot of price at time of order
    total_price = Column(Float, nullable=False)
    notes = Column(String(500), nullable=True)

    order = relationship("Order", back_populates="items")
    product = relationship("Product")
    variant = relationship("ProductVariant")
