from sqlalchemy import Column, String, Text, JSON, ForeignKey, Integer, Boolean, Date
from sqlalchemy.orm import relationship
from app.models.base import BaseModel
from app.models.user import user_stores


class Store(BaseModel):
    """
    Pharmacy store/branch model.
    Each store belongs to an organization and operates semi-independently.
    """
    __tablename__ = "stores"

    # Organization (tenant)
    organization_id = Column(Integer, ForeignKey('organizations.id'), nullable=False, index=True)
    
    # Basic information
    name = Column(String(255), nullable=False)
    code = Column(String(50), nullable=False, index=True)
    
    # Contact information
    address = Column(Text, nullable=False)
    city = Column(String(100), nullable=False, index=True)
    state = Column(String(100), nullable=False)
    postal_code = Column(String(20))
    phone = Column(String(20), nullable=False)
    email = Column(String(255))
    
    # Operating hours (JSON format)
    # {"monday": {"open": "09:00", "close": "21:00"}, ...}
    operating_hours = Column(JSON)
    
    # Regulatory
    license_number = Column(String(100), unique=True, nullable=False)
    license_expiry = Column(Date)
    
    # Status - uses BaseModel.inactive instead of is_active
    
    # Relationships
    organization = relationship("Organization", back_populates="stores")
    assigned_users = relationship("User", secondary=user_stores, back_populates="assigned_stores")
    inventory_batches = relationship("InventoryBatch", back_populates="store", cascade="all, delete-orphan")
    prescriptions = relationship("Prescription", back_populates="store")
    orders = relationship("Order", back_populates="store")
    procurement_orders = relationship("ProcurementOrder", back_populates="store")
    suppliers = relationship("Supplier", back_populates="store")