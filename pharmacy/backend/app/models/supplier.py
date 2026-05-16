from sqlalchemy import Column, String, Text, Boolean, Float, Integer, ForeignKey
from sqlalchemy.orm import relationship
from app.models.base import BaseModel


class Supplier(BaseModel):
    """
    Supplier/Vendor model for pharmacy procurement.
    Manages supplier relationships for store direct purchase mode.
    Supports Scope: 'ORG' (Global) vs 'STORE' (Local).
    """
    __tablename__ = "suppliers"

    # Basic information
    name = Column(String(255), nullable=False, index=True)
    code = Column(String(50), unique=True, nullable=False, index=True)
    
    # Scope (ORG | STORE)
    scope = Column(String(20), default="ORG", nullable=False)
    store_id = Column(Integer, ForeignKey('stores.id'), nullable=True, index=True)
    
    # Contact information
    contact_person = Column(String(255))
    email = Column(String(255))
    phone = Column(String(20), nullable=False)
    fax = Column(String(20))
    website = Column(String(255))
    
    # Address
    address = Column(Text, nullable=False)
    city = Column(String(100), nullable=False, index=True)
    state = Column(String(100), nullable=False)
    postal_code = Column(String(20))
    country = Column(String(100), default="India")
    
    # Business information
    license_number = Column(String(100), unique=True)
    drug_license_number = Column(String(100))
    gst_number = Column(String(50))
    tax_id = Column(String(50))
    
    # Payment terms
    payment_terms = Column(String(100))  # Net 30, Net 60, etc.
    credit_limit = Column(Float, default=0.0)
    
    # Rating and notes
    rating = Column(Float, default=0.0)  # 0-5 star rating
    notes = Column(Text)
    
    # Status (uses BaseModel.inactive instead of is_active)
    is_approved = Column(Boolean, default=False, nullable=False)
    
    # Relationships
    procurement_orders = relationship("ProcurementOrder", back_populates="supplier")
    store = relationship("Store", back_populates="suppliers")
