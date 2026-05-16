
from sqlalchemy import Column, Integer, String, Text, ForeignKey, Numeric, JSON
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel


class Vendor(BaseModel):
    __tablename__ = "vendors"

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, unique=True)

    # Basic Info
    company_name = Column(String(255), nullable=False)
    business_type = Column(String(255), nullable=True)
    phone = Column(String(20), nullable=True)
    address = Column(String(500), nullable=True)
    city = Column(String(100), nullable=True)
    state = Column(String(100), nullable=True)
    zip_code = Column(String(20), nullable=True)
    website = Column(String(255), nullable=True)

    year_established = Column(String(10), nullable=True)
    team_size = Column(String(50), nullable=True)

    license_number = Column(String(100), nullable=True)
    insurance_provider = Column(String(255), nullable=True)
    tax_id = Column(String(100), nullable=True)

    description = Column(Text, nullable=True)
    
    # NEW: Services this vendor can provide (JSON array of service IDs)
    offered_services = Column(JSON, nullable=False, default=list)
    # Example: [1, 2, 3, 4, 5, 6] means can provide all 6 services
    
    # NEW: Portfolio & Performance
    portfolio_urls = Column(JSON, nullable=True)  # Array of image/video URLs
    rating = Column(Numeric(3, 2),nullable=False, default=0.0)  # 0.00 to 5.00
    total_reviews = Column(Integer,nullable=False, default=0)
    completed_events = Column(Integer,nullable=False, default=0)
    
    # NEW: Service Areas (cities/states they operate in)
    service_areas = Column(JSON, nullable=True)  # ["Mumbai", "Pune", "Delhi"]

    # Status
    status = Column(String(50), nullable=False, default="pending")
    # pending, approved, rejected, suspended

    # Relationships
    user = relationship("User", back_populates="vendor_profile")

    categories_link = relationship(
        "VendorCategory",
        back_populates="vendor",
        cascade="all, delete-orphan"
    )

    bids = relationship("VendorBid", back_populates="vendor", foreign_keys="VendorBid.vendor_id")
    orders = relationship("VendorOrder", back_populates="vendor")
    payments = relationship("VendorPayment", back_populates="vendor")
    notifications = relationship("VendorNotification", back_populates="vendor")


# IMPORTANT — Import AFTER class definition
from .vendor_category_m import VendorCategory
from .vendor_bid_m import VendorBid
from .vendor_order_m import VendorOrder
from .vendor_payment_m import VendorPayment