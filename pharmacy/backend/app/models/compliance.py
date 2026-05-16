from sqlalchemy import Column, String, Integer, ForeignKey, Date, Boolean, Text, Enum as SQLEnum
from sqlalchemy.orm import relationship
import enum
from app.models.base import BaseModel

class LicenseType(str, enum.Enum):
    DRUG_LICENSE_20 = "DRUG_LICENSE_20" # Retail
    DRUG_LICENSE_21 = "DRUG_LICENSE_21" # Retail
    DRUG_LICENSE_20B = "DRUG_LICENSE_20B" # Wholesale
    DRUG_LICENSE_21B = "DRUG_LICENSE_21B" # Wholesale
    FSSAI = "FSSAI" # Food safety
    GST = "GST" # Tax
    NARCOTIC = "NARCOTIC" # NDPS
    FIRE_SAFETY = "FIRE_SAFETY"
    ESTABLISHMENT = "ESTABLISHMENT" # Shop act

class StoreLicense(BaseModel):
    """
    Track various licenses for a store with expiry alerts.
    """
    __tablename__ = "store_licenses"

    store_id = Column(Integer, ForeignKey('stores.id'), nullable=False)
    
    name = Column(String(100), nullable=False) # e.g. "Retail Drug License"
    license_type = Column(SQLEnum(LicenseType), default=LicenseType.DRUG_LICENSE_20)
    license_number = Column(String(100), nullable=False)
    
    issue_date = Column(Date)
    expiry_date = Column(Date, nullable=False, index=True)
    
    issuing_authority = Column(String(100)) # e.g. "FDA Maharashtra"
    document_url = Column(String(500)) # Scan of the license
    
    status = Column(String(20), default="ACTIVE") # ACTIVE, EXPIRED, SUSPENDED

    # Relationships
    store = relationship("Store", backref="licenses")


class DrugRecall(BaseModel):
    """
    Track official drug recalls (FDA/CDSCO).
    """
    __tablename__ = "drug_recalls"

    recall_number = Column(String(50), unique=True, nullable=False)
    
    medicine_id = Column(Integer, ForeignKey('medicines.id'), nullable=True) # Linked to local Master
    batch_number = Column(String(100), nullable=True) # Specific batch or NULL for all
    
    reason = Column(Text)
    severity = Column(String(20)) # HIGH, MEDIUM, LOW
    
    issued_date = Column(Date, nullable=False)
    action_required = Column(Text) # "Stop sale immediately"
    
    status = Column(String(20), default="OPEN") # OPEN, COMPLETED

    # Relationships
    medicine = relationship("Medicine")
