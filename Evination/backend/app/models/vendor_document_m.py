from sqlalchemy import Column, Integer, String, Text, ForeignKey, Enum, Date
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel
import enum

class DocumentType(str, enum.Enum):
    GST = "gst"
    PAN = "pan"
    AADHAR = "aadhar"
    BUSINESS_REGISTRATION = "business_registration"
    ADDRESS_PROOF = "address_proof"
    BANK_PROOF = "bank_proof"
    INSURANCE = "insurance"
    OTHER = "other"

class VerificationStatus(str, enum.Enum):
    PENDING = "pending"
    VERIFIED = "verified"
    REJECTED = "rejected"

class VendorDocument(BaseModel):
    __tablename__ = "vendor_documents"

    vendor_id = Column(Integer, ForeignKey("vendors.id"), nullable=False)
    document_type = Column(Enum(DocumentType), nullable=False)
    document_number = Column(String(100), nullable=True)
    file_url = Column(String(500), nullable=False)
    
    verification_status = Column(Enum(VerificationStatus), default=VerificationStatus.PENDING)
    rejection_reason = Column(String(255), nullable=True)
    expiry_date = Column(Date, nullable=True)
    
    verified_by_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    
    vendor = relationship("Vendor", back_populates="documents")
    verified_by = relationship("User")
