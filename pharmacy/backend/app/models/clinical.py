from sqlalchemy import Column, String, Integer, Boolean, ForeignKey, DateTime, Date, Text
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import JSONB
from app.models.base import BaseModel

class Patient(BaseModel):
    """
    Clinical Patient Profile (EMR Lite).
    Linked to a Customer (User Account).
    """
    __tablename__ = "patients"

    user_id = Column(Integer, ForeignKey('users.id'), unique=True, nullable=True) # Optional link to registered user
    organization_id = Column(Integer, ForeignKey('organizations.id'), nullable=False)
    
    # Demographics
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    dob = Column(Date)
    gender = Column(String(20))
    blood_group = Column(String(10))
    
    # Contact (if not linked to user)
    phone = Column(String(20))
    email = Column(String(100))
    address = Column(Text)
    
    # Medical Info
    allergies = Column(JSONB, default=list) # ["Penicillin", "Peanuts"]
    chronic_conditions = Column(JSONB, default=list) # ["Diabetes", "Hypertension"]
    
    # Hospital specific
    uhid = Column(String(50), unique=True, index=True) # Universal Health ID

    # Relationships
    user = relationship("User", backref="patient_profile")
    organization = relationship("Organization")


class Doctor(BaseModel):
    """
    Prescribing Doctor Profile.
    """
    __tablename__ = "doctors"

    user_id = Column(Integer, ForeignKey('users.id'), unique=True, nullable=True) # If doctor has login
    organization_id = Column(Integer, ForeignKey('organizations.id'), nullable=False)
    
    name = Column(String(150), nullable=False)
    specialty = Column(String(100))
    license_number = Column(String(50), nullable=False)
    
    phone = Column(String(20))
    email = Column(String(100))
    
    # Commission/Referral
    commission_rate = Column(Integer, default=0) # Percentage

    # Relationships
    user = relationship("User", backref="doctor_profile")
    organization = relationship("Organization")


class Ward(BaseModel):
    """
    Hospital Ward / Inpatient Department unit.
    For internal pharmacy requests.
    """
    __tablename__ = "wards"

    organization_id = Column(Integer, ForeignKey('organizations.id'), nullable=False)
    name = Column(String(100), nullable=False)
    type = Column(String(50)) # ICU, General, ER
    floor = Column(String(20))
    
    # Relationships
    organization = relationship("Organization")
