from sqlalchemy import Column, String, Boolean, ForeignKey, Table, Integer, func, DateTime, Enum as SQLEnum
from sqlalchemy.orm import relationship
import enum
from app.models.base import BaseModel


class UserRole(str, enum.Enum):
    """User roles in the system"""
    # Platform
    SAAS_SUPER_ADMIN = "SAAS_SUPER_ADMIN"

    # Organization Level
    ORG_ADMIN = "ORG_ADMIN"
    HQ_ADMIN = "HQ_ADMIN" # Legacy alias for ORG_ADMIN
    ORG_MANAGER = "ORG_MANAGER"

    # Store Level
    STORE_MANAGER = "STORE_MANAGER"
    STORE_ADMIN = "STORE_ADMIN" # Legacy alias for STORE_MANAGER
    PHARMACIST = "PHARMACIST"
    CASHIER = "CASHIER"

    # Clinical
    DOCTOR = "DOCTOR"
    NURSE = "NURSE"
    LAB_TECHNICIAN = "LAB_TECHNICIAN"

    # End Users
    PATIENT = "PATIENT"
    CUSTOMER = "CUSTOMER" # Legacy alias for PATIENT


# Association table for many-to-many relationship between users and stores
user_stores = Table(
    'user_stores',
    BaseModel.metadata,
    Column('user_id', Integer, ForeignKey('users.id', ondelete='CASCADE'), primary_key=True),
    Column('store_id', Integer, ForeignKey('stores.id', ondelete='CASCADE'), primary_key=True),
    Column('created_at', DateTime(timezone=True), server_default=func.now())
)


class User(BaseModel):
    """
    User model with multi-tenant support and RBAC.
    """
    __tablename__ = "users"

    # Organization (tenant) - Nullable for global platform users (B2C)
    organization_id = Column(Integer, ForeignKey('organizations.id'), nullable=True, index=True)
    
    # Basic information
    email = Column(String(255), unique=True, nullable=True, index=True) # Nullable for phone-only
    password_hash = Column(String(255), nullable=True) # Nullable for OTP users
    full_name = Column(String(255), nullable=True) # Can be captured later
    phone = Column(String(20), unique=True, index=True)
    
    # Role
    # Role
    role_id = Column(Integer, ForeignKey('roles.id'), nullable=False, index=True)
    role = relationship("Role", back_populates="users")
    
    # Status (uses BaseModel.inactive instead of is_active)
    email_verified = Column(Boolean, default=False)
    phone_verified = Column(Boolean, default=False)
    
    # Last login tracking
    last_login_at = Column(DateTime(timezone=True))
    last_login_ip = Column(String(50))
    
    # Relationships
    organization = relationship("Organization", back_populates="users")
    assigned_stores = relationship("Store", secondary=user_stores, back_populates="assigned_users")
    
    # User-specific relationships
    prescriptions = relationship("Prescription", back_populates="customer", foreign_keys="[Prescription.customer_id]") 
    verified_prescriptions = relationship("Prescription", back_populates="verified_by_user", foreign_keys="[Prescription.verified_by]")
    orders = relationship("Order", back_populates="customer", foreign_keys="[Order.customer_id]")
    customer_profile = relationship("Customer", back_populates="user", uselist=False)