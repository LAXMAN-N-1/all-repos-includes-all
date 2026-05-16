from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, Float, Enum
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel
import enum

class SecurityDepositType(str, enum.Enum):
    NONE = "none"
    FIXED = "fixed"
    PERCENTAGE = "percentage"

class VendorPayoutSetting(BaseModel):
    __tablename__ = "vendor_payout_settings"

    vendor_id = Column(Integer, ForeignKey("vendors.id"), nullable=False, unique=True)
    
    payout_schedule_days = Column(Integer, default=3) # Days after event completion
    
    security_deposit_type = Column(Enum(SecurityDepositType), default=SecurityDepositType.NONE)
    security_deposit_amount = Column(Float, default=0.0)
    security_deposit_release_days = Column(Integer, default=30)
    
    # Banking details here (encrypted ideally, but plain for prototype)
    bank_account_number = Column(String(100), nullable=True)
    bank_ifsc = Column(String(20), nullable=True)
    bank_verified = Column(Boolean, default=False)
    
    upi_id = Column(String(100), nullable=True)
    upi_verified = Column(Boolean, default=False)
    
    vendor = relationship("Vendor", back_populates="payout_setting")
