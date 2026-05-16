from sqlalchemy import Column, String, Text,Boolean, Enum as SQLEnum
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import JSONB
import enum
from app.models.base import BaseModel

class InventoryMode(str, enum.Enum):
    """Inventory operating modes"""
    STORE_DIRECT = "STORE_DIRECT"
    CENTRAL_WAREHOUSE = "CENTRAL_WAREHOUSE"  # Future
    HYBRID = "HYBRID"  # Future

class Organization(BaseModel):
    """
    Multi-tenant organization/pharmacy chain.
    Each organization operates independently with isolated data.
    """
    __tablename__ = "organizations"

    name = Column(String(255), nullable=False, index=True)
    code = Column(String(50), unique=True, nullable=False, index=True)
    
    # Contact information
    email = Column(String(255))
    phone = Column(String(20))
    address = Column(Text)
    city = Column(String(100))
    state = Column(String(100))
    postal_code = Column(String(20))
    
    # Regulatory information
    license_number = Column(String(100), unique=True)
    tax_id = Column(String(50))

    # SaaS Configuration
    domain = Column(String(255), unique=True, index=True) # Custom domain (e.g. hospital.erp.com)
    config = Column(JSONB, default={}) # Global org settings (theme, logo, timezone)
    subscription_status = Column(String(50), default="TRIAL") # ACTIVE, SUSPENDED, TRIAL

    
    # Inventory operating mode (locked to STORE_DIRECT in MVP)
    inventory_mode = Column(
        SQLEnum(InventoryMode, name='inventory_mode_enum'), 
        default=InventoryMode.STORE_DIRECT,
        nullable=False
    )
    
    # Status - uses BaseModel.inactive instead of is_active
    
    # Relationships
    stores = relationship("Store", back_populates="organization", cascade="all, delete-orphan")
    enabled_modules = relationship("OrganizationModule", back_populates="organization", cascade="all, delete-orphan")
    users = relationship("User", back_populates="organization")