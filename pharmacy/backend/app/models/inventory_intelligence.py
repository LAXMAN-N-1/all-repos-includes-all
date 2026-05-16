from sqlalchemy import Column, String, Integer, Float, ForeignKey, DateTime, Date, Enum as SQLEnum, Text, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import JSONB
import enum
from datetime import datetime
from app.models.base import BaseModel

class ForecastMethod(str, enum.Enum):
    MOVING_AVERAGE = "MOVING_AVERAGE"
    EXPONENTIAL_SMOOTHING = "EXPONENTIAL_SMOOTHING"
    ARIMA = "ARIMA"
    PROPHET = "PROPHET" # Facebook Prophet
    MACHINE_LEARNING = "MACHINE_LEARNING" # Custom ML Model

class DemandForecast(BaseModel):
    """
    AI-Predicted Demand for Medicines.
    Populated by async ML jobs.
    """
    __tablename__ = "demand_forecasts"

    store_id = Column(Integer, ForeignKey('stores.id'), nullable=False, index=True)
    medicine_id = Column(Integer, ForeignKey('medicines.id'), nullable=False, index=True)
    
    forecast_date = Column(Date, nullable=False, index=True) # Date being predicted
    predicted_quantity = Column(Float, nullable=False)
    
    confidence_interval_lower = Column(Float)
    confidence_interval_upper = Column(Float)
    
    method = Column(SQLEnum(ForecastMethod), default=ForecastMethod.MOVING_AVERAGE)
    generated_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    store = relationship("Store")
    medicine = relationship("Medicine")


class SupplierScorecard(BaseModel):
    """
    Data-driven Vendor Performance Ratings.
    """
    __tablename__ = "supplier_scorecards"

    supplier_id = Column(Integer, ForeignKey('suppliers.id'), nullable=False)
    organization_id = Column(Integer, ForeignKey('organizations.id'), nullable=False)
    
    rating_period = Column(String(20)) # "2024-Q1", "2024-JAN"
    
    # Metrics (0-100)
    delivery_timeliness_score = Column(Float, default=0.0) # On-time delivery %
    order_accuracy_score = Column(Float, default=0.0) # Correct items %
    quality_score = Column(Float, default=0.0) # Defect rate inverted
    price_competitiveness_score = Column(Float, default=0.0)
    
    overall_rating = Column(Float, default=0.0) # Weighted Average
    
    total_orders = Column(Integer, default=0)
    total_value = Column(Float, default=0.0)
    
    notes = Column(Text)

    # Relationships
    supplier = relationship("Supplier")
    organization = relationship("Organization")


class ReorderRule(BaseModel):
    """
    Intelligent Reorder Logic.
    Overrides static min/max levels with dynamic rules.
    """
    __tablename__ = "reorder_rules"

    store_id = Column(Integer, ForeignKey('stores.id'), nullable=False)
    medicine_id = Column(Integer, ForeignKey('medicines.id'), nullable=False)
    
    is_dynamic = Column(Boolean, default=True) # If True, auto-calculate min/max
    
    # Static fallback
    min_quantity = Column(Integer, default=10)
    max_quantity = Column(Integer, default=100)
    reorder_quantity = Column(Integer, default=50)
    
    # Dynamic settings
    safety_stock_days = Column(Integer, default=7) # Maintain 7 days of stock
    lead_time_days = Column(Integer, default=3) # Vendor lead time estimate
    
    auto_create_po = Column(Boolean, default=False) # Auto-draft Procurement Orders
    preferred_supplier_id = Column(Integer, ForeignKey('suppliers.id'), nullable=True)

    # Relationships
    store = relationship("Store")
    medicine = relationship("Medicine")
    preferred_supplier = relationship("Supplier")
