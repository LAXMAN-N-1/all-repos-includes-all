from sqlalchemy import Column, Integer, Float, String, ForeignKey, Enum, Date, Boolean, JSON
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel
import enum

class DiscountType(str, enum.Enum):
    PERCENTAGE = "percentage"
    FLAT = "flat"

class VendorDiscount(BaseModel):
    __tablename__ = "vendor_discounts"

    vendor_id = Column(Integer, ForeignKey("vendors.id"), nullable=False)
    
    title = Column(String(255), nullable=True)
    discount_type = Column(Enum(DiscountType), nullable=False)
    discount_value = Column(Float, nullable=False)
    
    applied_on_all = Column(Boolean, default=True)
    specific_category_ids = Column(JSON, default=[]) 
    
    valid_from = Column(Date, nullable=True)
    valid_until = Column(Date, nullable=True)
    
    cost_sharing_platform_percent = Column(Float, default=0.0)
    cost_sharing_vendor_percent = Column(Float, default=100.0)
    
    is_active = Column(Boolean, default=True)
    created_by_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    
    vendor = relationship("Vendor", back_populates="discounts")
