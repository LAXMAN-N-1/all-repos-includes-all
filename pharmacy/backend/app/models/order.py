from sqlalchemy import Column, String, Float, ForeignKey, DateTime, Enum as SQLEnum, Integer, Text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship
import enum
from app.models.base import BaseModel


class OrderStatus(str, enum.Enum):
    PENDING = "PENDING"
    CONFIRMED = "CONFIRMED"
    PACKED = "PACKED"
    READY_FOR_PICKUP = "READY_FOR_PICKUP"
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"


class PaymentStatus(str, enum.Enum):
    PENDING = "PENDING"
    PAID = "PAID"
    FAILED = "FAILED"
    REFUNDED = "REFUNDED"


class PaymentMethod(str, enum.Enum):
    CASH = "CASH"
    CARD = "CARD"
    UPI = "UPI"
    NET_BANKING = "NET_BANKING"
    WALLET = "WALLET"
    RAZORPAY = "RAZORPAY"


class Order(BaseModel):
    __tablename__ = "orders"

    order_number = Column(String(50), unique=True, nullable=False, index=True)
    customer_id = Column(Integer, ForeignKey('users.id'), nullable=True, index=True)
    store_id = Column(Integer, ForeignKey('stores.id'), nullable=False, index=True)
    prescription_id = Column(Integer, ForeignKey('prescriptions.id'), nullable=True, index=True)
    
    # Status
    status = Column(SQLEnum(OrderStatus, name='order_status_enum'), default=OrderStatus.PENDING, index=True)
    payment_status = Column(SQLEnum(PaymentStatus, name='payment_status_enum'), default=PaymentStatus.PENDING, index=True)
    payment_method = Column(SQLEnum(PaymentMethod, name='payment_method_enum'), nullable=True)
    
    # Financial
    subtotal = Column(Float, default=0.0)
    tax_amount = Column(Float, default=0.0)
    discount_amount = Column(Float, default=0.0)
    total_amount = Column(Float, default=0.0)
    
    # Razorpay Payment Tracking
    razorpay_order_id = Column(String(100), nullable=True, index=True)
    razorpay_payment_id = Column(String(100), nullable=True)
    razorpay_signature = Column(String(255), nullable=True)
    
    # Pickup workflow
    estimated_pickup_time = Column(DateTime(timezone=True))
    ready_at = Column(DateTime(timezone=True))
    picked_up_at = Column(DateTime(timezone=True))
    packed_by = Column(Integer, ForeignKey('users.id'), nullable=True)
    
    # Customer contact
    customer_phone = Column(String(20))
    customer_email = Column(String(255))
    
    # Notes
    notes = Column(Text)
    internal_notes = Column(Text)
    cancellation_reason = Column(Text)
    
    # Relationships
    customer = relationship("User", foreign_keys=[customer_id], back_populates="orders")
    store = relationship("Store", back_populates="orders")
    prescription = relationship("Prescription", back_populates="order")
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")
    packer = relationship("User", foreign_keys=[packed_by])


