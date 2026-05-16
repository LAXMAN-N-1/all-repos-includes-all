from sqlalchemy import Column, String, Integer, Float, ForeignKey, DateTime, Text, Enum as SQLEnum, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import JSONB
import enum
from app.models.base import BaseModel

class LabTestCategory(str, enum.Enum):
    HEMATOLOGY = "HEMATOLOGY"
    BIOCHEMISTRY = "BIOCHEMISTRY"
    MICROBIOLOGY = "MICROBIOLOGY"
    PATHOLOGY = "PATHOLOGY"
    RADIOLOGY = "RADIOLOGY"
    OTHER = "OTHER"

class LabRequestStatus(str, enum.Enum):
    PENDING = "PENDING"
    SAMPLE_COLLECTED = "SAMPLE_COLLECTED"
    PROCESSING = "PROCESSING"
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"

class LabTest(BaseModel):
    """
    Catalog of available Lab Tests (e.g., CBC, Lipid Panel).
    """
    __tablename__ = "lab_tests"

    name = Column(String(100), nullable=False, index=True)
    code = Column(String(50), unique=True, index=True) # CPT Code or Internal
    category = Column(SQLEnum(LabTestCategory), default=LabTestCategory.OTHER, index=True)
    
    cost_price = Column(Float, default=0.0)
    selling_price = Column(Float, default=0.0)
    
    reference_range = Column(Text) # "10-20 mg/dL" - Information only
    unit = Column(String(20)) # "mg/dL"
    
    tat_hours = Column(Integer, default=24) # Turnaround time estimate

    organization_id = Column(Integer, ForeignKey('organizations.id'), nullable=True) # Null if system-wide master

    # Relationships
    organization = relationship("Organization")


class LabRequest(BaseModel):
    """
    Order for one or more Lab Tests.
    """
    __tablename__ = "lab_requests"

    request_number = Column(String(50), unique=True, nullable=False, index=True)
    
    organization_id = Column(Integer, ForeignKey('organizations.id'), nullable=False)
    patient_id = Column(Integer, ForeignKey('patients.id'), nullable=False)
    doctor_id = Column(Integer, ForeignKey('doctors.id'), nullable=True)
    
    status = Column(SQLEnum(LabRequestStatus), default=LabRequestStatus.PENDING, index=True)
    
    # Financials
    total_amount = Column(Float, default=0.0)
    is_paid = Column(Boolean, default=False) # Linked to Invoice/Order? 
    # For now, simplistic paid flag. In real ERP, this links to Invoice.
    
    requested_at = Column(DateTime(timezone=True))
    sample_collected_at = Column(DateTime(timezone=True))
    completed_at = Column(DateTime(timezone=True))

    # Relationships
    organization = relationship("Organization")
    patient = relationship("Patient", backref="lab_requests")
    doctor = relationship("Doctor", backref="lab_requests")
    test_results = relationship("LabResult", back_populates="request", cascade="all, delete-orphan")


class LabResult(BaseModel):
    """
    Actual result data for a specific test in a request.
    """
    __tablename__ = "lab_results"

    request_id = Column(Integer, ForeignKey('lab_requests.id'), nullable=False)
    test_id = Column(Integer, ForeignKey('lab_tests.id'), nullable=False)
    
    # Measurement
    value = Column(String(255), nullable=False) # "12.5" or "Positive"
    unit = Column(String(50))
    is_abnormal = Column(Boolean, default=False)
    
    notes = Column(Text)
    technician_id = Column(Integer, ForeignKey('users.id')) # Who performed the test

    # Relationships
    request = relationship("LabRequest", back_populates="test_results")
    test = relationship("LabTest")
    technician = relationship("User")
