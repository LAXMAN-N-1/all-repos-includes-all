from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime, Enum, Boolean, Text
from sqlalchemy.orm import relationship
import enum

from app.db.base_class import Base, TimestampMixin


class RecurringFrequency(str, enum.Enum):
    DAILY = "daily"
    WEEKLY = "weekly"
    BIWEEKLY = "biweekly"
    MONTHLY = "monthly"


class RecurringOrderStatus(str, enum.Enum):
    ACTIVE = "active"
    PAUSED = "paused"
    CANCELLED = "cancelled"


class RecurringOrder(Base, TimestampMixin):
    __tablename__ = "recurring_orders"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id"), index=True, nullable=False)
    frequency = Column(String(50), default=RecurringFrequency.WEEKLY, nullable=False)
    status = Column(String(50), default=RecurringOrderStatus.ACTIVE, index=True)
    next_delivery_date = Column(DateTime, nullable=True)
    last_generated_at = Column(DateTime, nullable=True)
    total_orders_generated = Column(Integer, default=0)
    notes = Column(Text, nullable=True)
    delivery_fee = Column(Float, default=0.0)
    platform_fee = Column(Float, default=0.0)
    location_id = Column(Integer, ForeignKey("locations.id"), nullable=True)
    payment_terms = Column(String(100), nullable=True)

    # Relationships
    customer = relationship("Customer")
    location = relationship("Location")
    items = relationship("RecurringOrderItem", back_populates="recurring_order", cascade="all, delete-orphan")


class RecurringOrderItem(Base):
    __tablename__ = "recurring_order_items"

    id = Column(Integer, primary_key=True, index=True)
    recurring_order_id = Column(Integer, ForeignKey("recurring_orders.id"), index=True, nullable=False)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=False)
    variant_id = Column(Integer, ForeignKey("product_variants.id"), nullable=True)
    quantity = Column(Integer, nullable=False, default=1)

    recurring_order = relationship("RecurringOrder", back_populates="items")
    product = relationship("Product")
    variant = relationship("ProductVariant")
