import datetime
import enum
from typing import Optional

from sqlalchemy import Boolean, Column, Date, DateTime, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship

from app.db.base_class import Base, TimestampMixin


class CustomerType(str, enum.Enum):
    B2B = "b2b"
    WHOLESALE = "wholesale"
    DIRECT = "direct"
    RETAIL = "retail"


class BillingCycle(str, enum.Enum):
    TEN_DAYS = "10_days"
    WEEKLY = "weekly"
    BIWEEKLY = "biweekly"
    MONTHLY = "monthly"
    IMMEDIATE = "immediate"


class Customer(Base, TimestampMixin):
    __tablename__ = "customers"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), index=True)
    email = Column(String(255), unique=True, index=True)
    phone = Column(String(20), index=True)
    address = Column(String(500))
    zip_code = Column(String(20), nullable=True)

    customer_type = Column(String(20), default=CustomerType.DIRECT.value)
    billing_cycle = Column(String(20), default=BillingCycle.IMMEDIATE.value)

    credit_limit = Column(Float, default=0.0)
    current_balance = Column(Float, default=0.0)
    is_verified = Column(Boolean, default=False)
    status = Column(String(50), default="draft", index=True)  # draft, submitted, verified, suspended

    business_name = Column(String(255), index=True, nullable=True)
    owner_name = Column(String(255), nullable=True)
    tax_id = Column(String(100), nullable=True)
    business_description = Column(Text, nullable=True)  # Description of business core
    hashed_password = Column(String(255), nullable=True)  # For B2B Login
    is_active = Column(Boolean, default=True)
    stripe_customer_id = Column(String(255), nullable=True)
    wallet_balance = Column(Float, default=0.0)
    wallet_enabled = Column(Boolean, default=True)
    
    # Billing Cycle Configuration (1-31)
    cycle_start_day = Column(Integer, default=1)
    cycle_cutoff_day = Column(Integer, default=30)
    payment_due_day = Column(Integer, default=5)
    
    # Password Reset
    otp_code = Column(String(10), nullable=True)
    otp_expiry = Column(DateTime, nullable=True)
    
    # Invoice Generation Tracking
    last_combined_invoice_date = Column(Date, nullable=True)  # Track last combined invoice generation

    # Group Association
    group_id = Column(Integer, ForeignKey("customer_groups.id"), nullable=True)

    # Meat2Restaurant Redesign Fields
    whatsapp_opted_in = Column(Boolean, default=True)
    preferred_location = Column(String(100), nullable=True)

    orders = relationship("Order", back_populates="customer")
    invoices = relationship("Invoice", back_populates="customer")
    membership = relationship("Membership", uselist=False, back_populates="customer")
    locations = relationship("Location", back_populates="customer", cascade="all, delete-orphan")
    group = relationship("CustomerGroup", back_populates="customers")


class MembershipPlan(Base, TimestampMixin):
    __tablename__ = "membership_plans"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), index=True)
    description = Column(String(500), nullable=True)
    price = Column(Integer)
    duration_days = Column(Integer)
    benefits = Column(Text)  # better for JSON/text
    is_active = Column(Boolean, default=True)


class Membership(Base, TimestampMixin):
    __tablename__ = "memberships"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id"))
    plan_id = Column(Integer, ForeignKey("membership_plans.id"))

    start_date = Column(Date)
    end_date = Column(Date)
    is_active = Column(Boolean, default=True)

    customer = relationship("Customer", back_populates="membership")
    plan = relationship("MembershipPlan")
