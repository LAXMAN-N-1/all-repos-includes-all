from sqlalchemy import Column, Integer, String, Text, ForeignKey, JSON, Float, Boolean, Enum
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel
import enum

class VendorType(str, enum.Enum):
    COMPANY = "company"
    INDIVIDUAL = "individual"

class VendorTier(str, enum.Enum):
    BASIC = "basic"
    STANDARD = "standard"
    PREMIUM = "premium"
    ELITE = "elite"

class Vendor(BaseModel):
    __tablename__ = "vendors"

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, unique=True)

    vendor_type = Column(Enum(VendorType), default=VendorType.COMPANY)
    tier = Column(Enum(VendorTier), default=VendorTier.BASIC)
    
    company_name = Column(String(255), nullable=False)
    trade_name = Column(String(255), nullable=True)
    contact_person = Column(String(255), nullable=True)
    
    phone = Column(String(20), nullable=True)
    alt_phone = Column(String(20), nullable=True)
    whatsapp = Column(String(20), nullable=True)
    email = Column(String(255), nullable=True)
    
    address = Column(String(500), nullable=True)
    city = Column(String(100), nullable=True)
    state = Column(String(100), nullable=True)
    zip_code = Column(String(20), nullable=True)
    landmark = Column(String(255), nullable=True)
    location_coordinates = Column(String(100), nullable=True) # latitude,longitude
    
    website = Column(String(255), nullable=True)
    
    # Business Details
    year_established = Column(String(10), nullable=True)
    team_size = Column(String(50), nullable=True)
    company_type = Column(String(50), nullable=True) # Proprietorship, etc
    office_type = Column(String(50), nullable=True)
    description = Column(Text, nullable=True)
    
    # Service Details
    services_offered = Column(JSON, default=[]) # For basic listing
    primary_services = Column(JSON, default=[]) # For individuals
    coverage_areas = Column(JSON, default=[]) # List of cities
    
    # Stats / Portfolio
    rating = Column(Float, default=0.0)
    is_verified = Column(Boolean, default=False)
    portfolio_images = Column(JSON, default=[])
    
    status = Column(String(50), nullable=False, default="pending") 
    
    # KYC Details (Legacy fields kept or migrated to PayoutSetting/Documents)
    pan_number = Column(String(20), nullable=True) # Kept for quick access
    gst_number = Column(String(20), nullable=True)
    
    # RELATIONSHIPS
    user = relationship("User", back_populates="vendor_profile")

    categories_link = relationship(
        "VendorCategory",
        back_populates="vendor",
        cascade="all, delete-orphan"
    )

    documents = relationship("VendorDocument", back_populates="vendor", cascade="all, delete-orphan")
    commission_settings = relationship("VendorCommissionSetting", back_populates="vendor", cascade="all, delete-orphan")
    payout_setting = relationship("VendorPayoutSetting", back_populates="vendor", uselist=False, cascade="all, delete-orphan")
    restriction = relationship("VendorRestriction", back_populates="vendor", uselist=False, cascade="all, delete-orphan")
    discounts = relationship("VendorDiscount", back_populates="vendor", cascade="all, delete-orphan")

    bids = relationship("VendorBid", back_populates="vendor")
    orders = relationship("VendorOrder", back_populates="vendor")
    payments = relationship("VendorPayment", back_populates="vendor")


# IMPORTANT — Import AFTER class definition
from .vendor_category_m import VendorCategory
from .vendor_bid_m import VendorBid
from .vendor_order_m import VendorOrder
from .vendor_payment_m import VendorPayment
from .vendor_document_m import VendorDocument
from .vendor_commission_m import VendorCommissionSetting
from .vendor_payout_m import VendorPayoutSetting
from .vendor_restriction_m import VendorRestriction
from .vendor_discount_m import VendorDiscount
