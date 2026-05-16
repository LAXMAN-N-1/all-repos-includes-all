from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime, Date, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.models.base_model import BaseModel
import enum

class SettlementStatus(str, enum.Enum):
    PROCESSING = "processing"
    PAID = "paid"
    FAILED = "failed"

class Settlement(BaseModel):
    __tablename__ = "settlements"

    vendor_id = Column(Integer, ForeignKey("vendors.id"), nullable=False)
    
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)
    
    total_bookings_amount = Column(Float, default=0.0)
    total_commission = Column(Float, default=0.0) # 8%
    total_gst = Column(Float, default=0.0) # 18% on Comm
    total_tds = Column(Float, default=0.0) # 1% on Net
    net_payout = Column(Float, default=0.0)
    
    status = Column(Enum(SettlementStatus), default=SettlementStatus.PROCESSING)
    transaction_reference = Column(String(100), nullable=True)
    
    processed_at = Column(DateTime, nullable=True)
    
    vendor = relationship("Vendor", backref="settlements")
