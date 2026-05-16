from sqlalchemy import Column, Integer, ForeignKey, JSON, Float, Boolean
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel


class VendorCategory(BaseModel):
    __tablename__ = "vendor_categories"

    vendor_id = Column(Integer, ForeignKey("vendors.id"), nullable=False)
    category_id = Column(Integer, ForeignKey("categories.id"), nullable=False)

    sub_categories = Column(JSON, default=[]) # List of sub-services
    experience_years = Column(Integer, default=0)
    completed_events_count = Column(Integer, default=0)
    price_range_min = Column(Float, default=0.0)
    price_range_max = Column(Float, nullable=True)
    
    is_active = Column(Boolean, default=True)

    vendor = relationship("Vendor", back_populates="categories_link")
    category = relationship("Category", back_populates="vendors")


# IMPORTANT bottom imports:
from .vendor_m import Vendor
from .category_m import Category
