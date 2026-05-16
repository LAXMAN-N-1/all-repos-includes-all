from sqlalchemy import Column, String, Integer, ForeignKey, DateTime, Enum as SQLEnum, Text, Boolean
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship
import enum
from datetime import datetime
from app.models.base import BaseModel

class IntegrationType(str, enum.Enum):
    HL7_V2 = "HL7_V2"
    FHIR_R4 = "FHIR_R4"
    WEBHOOK = "WEBHOOK"
    REST_API = "REST_API"

class ExternalSystem(BaseModel):
    """
    Registry of connected external systems (HIS, EMR, LIS).
    """
    __tablename__ = "external_systems"

    organization_id = Column(Integer, ForeignKey('organizations.id'), nullable=False)
    
    name = Column(String(100), nullable=False)
    system_type = Column(SQLEnum(IntegrationType), default=IntegrationType.REST_API)
    
    # Connection Details
    base_url = Column(String(500))
    api_key = Column(String(255)) # Encrypted
    secret = Column(String(255)) # Encrypted
    
    is_active = Column(Boolean, default=True)
    
    # Configuration
    config = Column(JSONB, default={}) # {"retry_count": 3, "timeout": 30}

    # Relationships
    organization = relationship("Organization")


class IntegrationLog(BaseModel):
    """
    Log of all data exchanges with external systems.
    Crucial for debugging HL7/FHIR messages.
    """
    __tablename__ = "integration_logs"

    external_system_id = Column(Integer, ForeignKey('external_systems.id'), nullable=False)
    
    direction = Column(String(10), nullable=False) # INBOUND, OUTBOUND
    event_type = Column(String(50)) # ADT^A01, ORM^O01
    
    payload = Column(Text) # The raw XML/JSON/HL7 message
    response = Column(Text)
    
    status = Column(String(20)) # SUCCESS, FAILED
    error_message = Column(Text)
    
    processed_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    system = relationship("ExternalSystem")


class ApiKey(BaseModel):
    """
    Developer API Keys for the Public API Marketplace.
    """
    __tablename__ = "api_keys"

    user_id = Column(Integer, ForeignKey('users.id'), nullable=False) # Developer
    organization_id = Column(Integer, ForeignKey('organizations.id'), nullable=True)
    
    key_prefix = Column(String(10), nullable=False)
    key_hash = Column(String(255), nullable=False, unique=True, index=True)
    
    name = Column(String(50))
    scopes = Column(JSONB, default=[]) # ["inventory:read", "orders:write"]
    
    expires_at = Column(DateTime)
    last_used_at = Column(DateTime)
    
    is_active = Column(Boolean, default=True)

    # Relationships
    user = relationship("User")
