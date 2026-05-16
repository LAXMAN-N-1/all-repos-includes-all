from sqlalchemy import Column, String, Integer, ForeignKey, DateTime, Enum as SQLEnum, Text, Boolean
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship
import enum
from datetime import datetime
from app.models.base import BaseModel

class ReportStatus(str, enum.Enum):
    PENDING = "PENDING"
    PROCESSING = "PROCESSING"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"

class ReportFormat(str, enum.Enum):
    PDF = "PDF"
    EXCEL = "EXCEL"
    CSV = "CSV"
    JSON = "JSON"

class RecurringInterval(str, enum.Enum):
    DAILY = "DAILY"
    WEEKLY = "WEEKLY"
    MONTHLY = "MONTHLY"

class ReportJob(BaseModel):
    """
    Async Job for generating heavy reports.
    """
    __tablename__ = "report_jobs"

    organization_id = Column(Integer, ForeignKey('organizations.id'), nullable=False)
    requested_by = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    report_type = Column(String(50)) # SALES, INVENTORY, GST, AUDIT
    parameters = Column(JSONB, default={}) # {date_from: ..., date_to: ...}
    
    status = Column(SQLEnum(ReportStatus), default=ReportStatus.PENDING, index=True)
    generated_file_url = Column(String(500))
    
    started_at = Column(DateTime)
    completed_at = Column(DateTime)
    error_message = Column(Text)

    # Relationships
    organization = relationship("Organization")
    user = relationship("User")


class ScheduledReport(BaseModel):
    """
    Configuration for automated email reports.
    """
    __tablename__ = "scheduled_reports"

    organization_id = Column(Integer, ForeignKey('organizations.id'), nullable=False)
    created_by = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    name = Column(String(100), nullable=False)
    report_type = Column(String(50), nullable=False)
    parameters = Column(JSONB, default={})
    
    interval = Column(SQLEnum(RecurringInterval), default=RecurringInterval.WEEKLY)
    last_run_at = Column(DateTime)
    next_run_at = Column(DateTime, nullable=False)
    
    recipients = Column(JSONB) # ["admin@hospital.com", "manager@store.com"]
    is_active = Column(Boolean, default=True)

    # Relationships
    organization = relationship("Organization")
    user = relationship("User")


class DashboardConfig(BaseModel):
    """
    Custom dashboard layout per user or role.
    """
    __tablename__ = "dashboard_configs"

    user_id = Column(Integer, ForeignKey('users.id'), nullable=True) # If null, applies to role/org
    organization_id = Column(Integer, ForeignKey('organizations.id'), nullable=False)
    role_code = Column(String(50), nullable=True)
    
    # Layout definition
    # e.g. [{"widget": "SALES_CHART", "x": 0, "y": 0, "w": 6, "h": 4}, ...]
    layout = Column(JSONB, default=list)
    
    is_default = Column(Boolean, default=False)

    # Relationships
    organization = relationship("Organization")
    user = relationship("User")
