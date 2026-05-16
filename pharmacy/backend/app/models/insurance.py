from sqlalchemy import Column, String, Integer, Float, ForeignKey, DateTime, Date, Enum as SQLEnum, Text, Boolean
from sqlalchemy.orm import relationship
import enum
from app.models.base import BaseModel

class ClaimStatus(str, enum.Enum):
    DRAFT = "DRAFT"
    SUBMITTED = "SUBMITTED"
    PENDING_ADJUDICATION = "PENDING_ADJUDICATION"
    APPROVED = "APPROVED"
    PARTIALLY_APPROVED = "PARTIALLY_APPROVED"
    REJECTED = "REJECTED"
    PAID = "PAID"

class InsuranceProvider(BaseModel):
    """
    Insurance Company / Payer Entity.
    """
    __tablename__ = "insurance_providers"

    name = Column(String(100), unique=True, nullable=False)
    payer_id = Column(String(50), unique=True, index=True) # EDI Payer ID
    
    contact_phone = Column(String(20))
    email = Column(String(100))
    
    api_endpoint = Column(String(255)) # For auto-claims
    
    organization_id = Column(Integer, ForeignKey('organizations.id'), nullable=True) # If org-specific

    # Relationships
    organization = relationship("Organization")


class PatientPolicy(BaseModel):
    """
    Patient's specific insurance coverage.
    """
    __tablename__ = "patient_policies"

    patient_id = Column(Integer, ForeignKey('patients.id'), nullable=False)
    provider_id = Column(Integer, ForeignKey('insurance_providers.id'), nullable=False)
    
    policy_number = Column(String(100), nullable=False) # Member ID
    group_number = Column(String(100))
    
    start_date = Column(Date)
    end_date = Column(Date)
    
    is_active = Column(Boolean, default=True)
    
    # Coverage details
    copay_amount = Column(Float, default=0.0) # Flat fee
    coinsurance_percent = Column(Float, default=0.0) # % patient pays

    # Relationships
    patient = relationship("Patient", backref="insurance_policies")
    provider = relationship("InsuranceProvider")


class Claim(BaseModel):
    """
    Insurance Claim for reimbursement.
    Linked to an Order (Pharmacy) or LabRequest.
    """
    __tablename__ = "claims"

    claim_number = Column(String(50), unique=True, nullable=False, index=True)
    
    provider_id = Column(Integer, ForeignKey('insurance_providers.id'), nullable=False)
    patient_id = Column(Integer, ForeignKey('patients.id'), nullable=False)
    
    # Linked Context (One of these should be set)
    order_id = Column(Integer, ForeignKey('orders.id'), nullable=True)
    lab_request_id = Column(Integer, ForeignKey('lab_requests.id'), nullable=True)
    
    # Financials
    total_billed = Column(Float, nullable=False)
    total_approved = Column(Float, default=0.0)
    patient_responsibility = Column(Float, default=0.0) # Copay + Deductible
    
    status = Column(SQLEnum(ClaimStatus), default=ClaimStatus.DRAFT, index=True)
    rejection_reason = Column(Text)
    
    submission_date = Column(DateTime(timezone=True))
    adjudication_date = Column(DateTime(timezone=True))

    # Relationships
    provider = relationship("InsuranceProvider")
    patient = relationship("Patient")
    order = relationship("Order", backref="claims")
    lab_request = relationship("LabRequest", backref="claims")
