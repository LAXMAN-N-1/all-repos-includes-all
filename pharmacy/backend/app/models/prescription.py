from sqlalchemy import Column, String, ForeignKey, DateTime, Enum as SQLEnum, Text, Float, Integer
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship
import enum
from app.models.base import BaseModel


class PrescriptionStatus(str, enum.Enum):
    PENDING = "PENDING"
    PROCESSING = "PROCESSING"  # OCR in progress
    VERIFIED = "VERIFIED"
    REJECTED = "REJECTED"
    FILLED = "FILLED"
    CANCELLED = "CANCELLED"


class Prescription(BaseModel):
    __tablename__ = "prescriptions"

    customer_id = Column(Integer, ForeignKey('users.id'), nullable=False, index=True)
    store_id = Column(Integer, ForeignKey('stores.id'), nullable=True, index=True)
    verified_by = Column(Integer, ForeignKey('users.id'), nullable=True)
    
    status = Column(SQLEnum(PrescriptionStatus, name='prescription_status_enum'), default=PrescriptionStatus.PENDING, index=True)
    
    # Image storage
    image_url = Column(String(500), nullable=True)
    image_thumbnail_url = Column(String(500), nullable=True)
    
    # OCR/NLP extracted data
    extracted_data = Column(JSONB, nullable=True)
    # Format: {"doctor_name": "", "patient_name": "", "medicines": [{"name": "", "dosage": "", "quantity": ""}], "hospital": "", "date": ""}
    
    ocr_confidence_score = Column(Float, nullable=True)  # 0.0 to 1.0
    ocr_processed_at = Column(DateTime(timezone=True), nullable=True)
    
    # Doctor information
    doctor_name = Column(String(255))
    doctor_license = Column(String(100))
    hospital_clinic = Column(String(255))
    prescription_date = Column(DateTime(timezone=True))
    
    # Validity
    valid_until = Column(DateTime(timezone=True))
    refills_allowed = Column(Integer, default=0)
    refills_used = Column(Integer, default=0)
    
    # Verification
    verified_at = Column(DateTime(timezone=True))
    rejection_reason = Column(Text)
    
    # Notes
    notes = Column(Text, nullable=True)
    pharmacist_notes = Column(Text)
    
    # Relationships
    customer = relationship("User", foreign_keys=[customer_id], back_populates="prescriptions")
    verified_by_user = relationship("User", foreign_keys=[verified_by], back_populates="verified_prescriptions")
    store = relationship("Store", back_populates="prescriptions")
    order = relationship("Order", back_populates="prescription", uselist=False)


