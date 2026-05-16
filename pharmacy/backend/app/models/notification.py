from sqlalchemy import Column, String, Text, Enum as SQLEnum, Integer, ForeignKey
from sqlalchemy.orm import relationship
import enum
from app.models.base import BaseModel

class AlertSeverity(str, enum.Enum):
    CRITICAL = "Critical"
    WARNING = "Warning"
    INFO = "Info"
    ERROR = "Error"

class Alert(BaseModel):
    """
    System-wide notifications and alerts for administrators.
    """
    __tablename__ = "alerts"

    title = Column(String(255), nullable=False)
    message = Column(Text, nullable=False)
    severity = Column(SQLEnum(AlertSeverity), default=AlertSeverity.INFO, nullable=False)
    
    # Store the icon as a string name for Flutter/Web to map
    icon_name = Column(String(100), default="warning")
    color_hex = Column(String(10), default="#FF0000") # Hex color for the alert
    
    # Relationship to organization (optional, null for system-wide hq alerts)
    organization_id = Column(Integer, ForeignKey('organizations.id'), nullable=True)
    organization = relationship("Organization")

    # Link to a specific store if relevant
    store_id = Column(Integer, ForeignKey('stores.id'), nullable=True)
    store = relationship("Store")
