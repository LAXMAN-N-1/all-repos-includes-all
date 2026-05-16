from sqlalchemy import Column, String, Text, Boolean, Enum as SQLEnum, Float
from sqlalchemy.orm import relationship
import enum
from app.models.base import BaseModel


class DrugSchedule(str, enum.Enum):
    """Drug scheduling classification"""
    OTC = "OTC"  # Over-the-counter
    PRESCRIPTION = "PRESCRIPTION"  # Requires prescription
    SCHEDULE_II = "SCHEDULE_II"  # High potential for abuse
    SCHEDULE_III = "SCHEDULE_III"  # Moderate potential for abuse
    SCHEDULE_IV = "SCHEDULE_IV"  # Low potential for abuse
    SCHEDULE_V = "SCHEDULE_V"  # Lowest potential for abuse


class DrugCategory(str, enum.Enum):
    """Drug category classification"""
    ANALGESIC = "ANALGESIC"
    ANTIBIOTIC = "ANTIBIOTIC"
    ANTIVIRAL = "ANTIVIRAL"
    ANTIFUNGAL = "ANTIFUNGAL"
    CARDIOVASCULAR = "CARDIOVASCULAR"
    RESPIRATORY = "RESPIRATORY"
    GASTROINTESTINAL = "GASTROINTESTINAL"
    DERMATOLOGICAL = "DERMATOLOGICAL"
    NEUROLOGICAL = "NEUROLOGICAL"
    HORMONAL = "HORMONAL"
    IMMUNOLOGICAL = "IMMUNOLOGICAL"
    VITAMIN_SUPPLEMENT = "VITAMIN_SUPPLEMENT"
    OTHER = "OTHER"


class Medicine(BaseModel):
    """
    Medicine/Drug catalog model.
    Central drug database for the pharmacy chain.
    """
    __tablename__ = "medicines"

    # Drug identification
    name = Column(String(255), nullable=False, index=True)
    generic_name = Column(String(255), nullable=False, index=True)
    brand = Column(String(255), index=True)
    manufacturer = Column(String(255), nullable=False)
    
    # Regulatory codes
    ndc_code = Column(String(50), unique=True, index=True)  # National Drug Code
    upc_code = Column(String(50), index=True)  # Universal Product Code
    
    # Classification
    category = Column(
        SQLEnum(DrugCategory, name='drug_category_enum'),
        default=DrugCategory.OTHER,
        nullable=False,
        index=True
    )
    schedule = Column(
        SQLEnum(DrugSchedule, name='drug_schedule_enum'),
        default=DrugSchedule.OTC,
        nullable=False,
        index=True
    )
    
    # Regulatory flags
    requires_prescription = Column(Boolean, default=False, nullable=False)
    is_controlled_substance = Column(Boolean, default=False, nullable=False)
    is_refrigerated = Column(Boolean, default=False, nullable=False)
    
    # Dosage information
    dosage_form = Column(String(100))  # tablet, capsule, liquid, etc.
    strength = Column(String(100))  # 500mg, 10ml, etc.
    unit_of_measure = Column(String(50))  # mg, ml, etc.
    
    # Pricing
    base_price = Column(Float, default=0.0)
    
    # Description
    description = Column(Text)
    usage_instructions = Column(Text)
    side_effects = Column(Text)
    contraindications = Column(Text)
    
    # Status - uses BaseModel.inactive instead of is_active
    
    # Relationships
    inventory_batches = relationship("InventoryBatch", back_populates="medicine")
    order_items = relationship("OrderItem", back_populates="medicine")
