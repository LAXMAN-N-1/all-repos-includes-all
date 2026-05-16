from sqlalchemy import Column, String, Boolean, ForeignKey, Integer, Text, Enum as SQLEnum
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import JSONB
import enum
from app.models.base import BaseModel

class ModuleType(str, enum.Enum):
    """Available System Modules"""
    CORE = "CORE"             # Basic ERP (Users, Roles, Stores)
    INVENTORY = "INVENTORY"   # Advanced Inventory
    POS = "POS"               # Point of Sale
    WARD = "WARD"             # Inpatient/Ward Management
    LAB = "LAB"               # Laboratory Integration
    INSURANCE = "INSURANCE"   # Insurance Claims
    ANALYTICS = "ANALYTICS"   # Advanced Reporting
    INTEGRATION = "INTEGRATION" # HL7/FHIR

class Module(BaseModel):
    """
    System Modules definition.
    Master list of what features are available in the SaaS platform.
    """
    __tablename__ = "modules"

    name = Column(String(100), unique=True, nullable=False)
    code = Column(SQLEnum(ModuleType), unique=True, nullable=False)
    description = Column(Text)
    is_beta = Column(Boolean, default=False)
    
    # Relationships
    organizations = relationship("OrganizationModule", back_populates="module")

class OrganizationModule(BaseModel):
    """
    Modules enabled for a specific Organization (Tenant).
    Controls feature flags per-hospital.
    """
    __tablename__ = "organization_modules"

    organization_id = Column(Integer, ForeignKey("organizations.id", ondelete="CASCADE"), nullable=False)
    module_id = Column(Integer, ForeignKey("modules.id", ondelete="CASCADE"), nullable=False)
    
    is_enabled = Column(Boolean, default=True)
    config = Column(JSONB, default={}) # Module-specific config per org (e.g. Lab IP address)

    # Relationships
    organization = relationship("Organization", back_populates="enabled_modules")
    module = relationship("Module", back_populates="organizations")
