from sqlalchemy import Column, Integer, Float, ForeignKey, Boolean, Enum, String, Date
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel
import enum

class GstTreatment(str, enum.Enum):
    PLATFORM_COLLECTS = "platform_collects"
    VENDOR_INVOICES = "vendor_invoices"
    REVERSE_CHARGE = "reverse_charge"

class FeeBearer(str, enum.Enum):
    CUSTOMER = "customer"
    VENDOR = "vendor"
    PLATFORM = "platform"
    SPLIT = "split"

class VendorCommissionSetting(BaseModel):
    __tablename__ = "vendor_commission_settings"

    vendor_id = Column(Integer, ForeignKey("vendors.id"), nullable=False)
    category_id = Column(Integer, ForeignKey("categories.id"), nullable=True) # Null means default for all
    
    commission_percentage = Column(Float, nullable=False, default=15.0)
    gst_treatment = Column(Enum(GstTreatment), default=GstTreatment.PLATFORM_COLLECTS)
    
    tds_applicable = Column(Boolean, default=False)
    tds_percentage = Column(Float, default=0.0)
    
    gateway_fee_percentage = Column(Float, default=2.0)
    gateway_fee_bearer = Column(Enum(FeeBearer), default=FeeBearer.CUSTOMER)
    
    effective_from = Column(Date, nullable=True)
    effective_until = Column(Date, nullable=True)
    
    created_by_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    
    vendor = relationship("Vendor", back_populates="commission_settings")
    category = relationship("Category")
