from sqlalchemy import Column, Integer, String, Float, Boolean, Date, Enum
from app.models.base_model import BaseModel
import enum
from datetime import date

class MasterType(str, enum.Enum):
    COMMISSION = "commission"
    TAX = "tax"
    TDS = "tds"

class TaxCommissionMaster(BaseModel):
    __tablename__ = "tax_commission_masters"

    name = Column(String(100), nullable=False) # e.g., "Standard Commission", "GST"
    rate = Column(Float, nullable=False) # e.g., 0.08, 0.18
    type = Column(Enum(MasterType), nullable=False)
    
    effective_date = Column(Date, default=date.today)
    is_active = Column(Boolean, default=True)
    
    description = Column(String(255), nullable=True)
