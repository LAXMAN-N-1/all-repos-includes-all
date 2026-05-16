from sqlalchemy import Column, String, Integer, Float, ForeignKey, DateTime, Date, Enum as SQLEnum, Text, Boolean, Interval
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import JSONB
import enum
from datetime import datetime
from app.models.base import BaseModel

class PlanType(str, enum.Enum):
    TRIAL = "TRIAL"
    BASIC = "BASIC"         # Small Pharmacy
    PROFESSIONAL = "PROFESSIONAL" # Multi-store
    ENTERPRISE = "ENTERPRISE" # Hospital Chain

class BillingPeriod(str, enum.Enum):
    MONTHLY = "MONTHLY"
    YEARLY = "YEARLY"

class Plan(BaseModel):
    """
    SaaS Pricing Tiers.
    """
    __tablename__ = "saas_plans"

    name = Column(String(50), unique=True, nullable=False) # Basic, Pro
    code = Column(SQLEnum(PlanType), unique=True, nullable=False)
    
    # Pricing
    monthly_price = Column(Float, default=0.0)
    yearly_price = Column(Float, default=0.0)
    currency = Column(String(10), default="INR")
    
    # Limits
    max_stores = Column(Integer, default=1)
    max_users = Column(Integer, default=5)
    storage_limit_gb = Column(Integer, default=1)
    
    # Feature Bundle (JSONB list of Module codes included)
    # e.g. ["INVENTORY", "POS"]
    included_modules = Column(JSONB, default=list)
    
    description = Column(Text)
    is_public = Column(Boolean, default=True) # Visible on pricing page
    
    # Relationships
    subscriptions = relationship("Subscription", back_populates="plan")


class Subscription(BaseModel):
    """
    Active Subscription of an Organization.
    """
    __tablename__ = "saas_subscriptions"

    organization_id = Column(Integer, ForeignKey('organizations.id'), unique=True, nullable=False)
    plan_id = Column(Integer, ForeignKey('saas_plans.id'), nullable=False)
    
    # Status
    is_active = Column(Boolean, default=True)
    status = Column(String(20), default="ACTIVE") # ACTIVE, PAST_DUE, CANCELLED
    
    # Dates
    start_date = Column(DateTime)
    end_date = Column(DateTime) # Next billing date
    trial_ends_at = Column(DateTime, nullable=True)
    
    # Billing
    billing_period = Column(SQLEnum(BillingPeriod), default=BillingPeriod.MONTHLY)
    payment_method_id = Column(String(100)) # Stripe/Razorpay Card ID
    
    # Auto-renew
    auto_renew = Column(Boolean, default=True)

    # Relationships
    organization = relationship("Organization", backref="current_subscription")
    plan = relationship("Plan", back_populates="subscriptions")
    invoices = relationship("PlatformInvoice", back_populates="subscription")


class PlatformInvoice(BaseModel):
    """
    Invoice sent BY the Platform TO the Organization (SaaS Billing).
    Distinct from 'Invoice' (sent by Org to Customer).
    """
    __tablename__ = "saas_invoices"

    invoice_number = Column(String(50), unique=True, nullable=False)
    subscription_id = Column(Integer, ForeignKey('saas_subscriptions.id'), nullable=False)
    organization_id = Column(Integer, ForeignKey('organizations.id'), nullable=False)
    
    amount = Column(Float, nullable=False)
    tax_amount = Column(Float, default=0.0)
    total_amount = Column(Float, nullable=False)
    currency = Column(String(10), default="INR")
    
    status = Column(String(20), default="PAID") # PAID, FAILED, PENDING
    
    billing_date = Column(Date, default=datetime.utcnow)
    due_date = Column(Date)
    paid_at = Column(DateTime(timezone=True))
    
    # Gateway Ref
    transaction_id = Column(String(100)) # Strip/Razorpay Charge ID
    invoice_pdf = Column(String(500))

    # Relationships
    subscription = relationship("Subscription", back_populates="invoices")
    organization = relationship("Organization")
