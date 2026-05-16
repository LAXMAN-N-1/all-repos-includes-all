from sqlalchemy import Column, Integer, String, Boolean, Float, DateTime, Enum
from app.db.base_class import Base, TimestampMixin
from datetime import datetime
import enum

class DiscountType(str, enum.Enum):
    PERCENTAGE = "percentage"
    FIXED = "fixed"

class Promotion(Base, TimestampMixin):
    __tablename__ = "promotions"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), index=True)
    code = Column(String(100), unique=True, index=True)
    description = Column(String(500), nullable=True)
    discount_type = Column(String(50), default=DiscountType.PERCENTAGE)
    discount_value = Column(Float) # e.g. 10.0 for 10% or $10
    start_date = Column(DateTime, nullable=True)
    end_date = Column(DateTime, nullable=True)
    is_active = Column(Boolean, default=True)
    usage_limit = Column(Integer, nullable=True)
    usage_count = Column(Integer, default=0)
    
    # Marketing Features
    banner_url = Column(String(500), nullable=True)
    target_type = Column(String(50), default="all") # "product", "category", "all"
    target_id = Column(Integer, nullable=True) # ID of product or category
