from sqlalchemy import Column, String, Text, ForeignKey, Enum as SQLEnum, Integer
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship
import enum
from app.models.base import BaseModel


class AuditActionType(str, enum.Enum):
    """Types of audit actions"""
    CREATE = "CREATE"
    READ = "READ"
    UPDATE = "UPDATE"
    DELETE = "DELETE"
    LOGIN = "LOGIN"
    LOGOUT = "LOGOUT"
    EXPORT = "EXPORT"
    IMPORT = "IMPORT"
    APPROVE = "APPROVE"
    REJECT = "REJECT"
    VERIFY = "VERIFY"
    STATUS_CHANGE = "STATUS_CHANGE"


class AuditLog(BaseModel):
    """
    Audit log model for compliance-ready tracking.
    Records all significant actions in the system for regulatory compliance.
    """
    __tablename__ = "audit_logs"

    # User who performed the action
    user_id = Column(Integer, ForeignKey('users.id'), nullable=True, index=True)
    
    # Action details
    action = Column(
        SQLEnum(AuditActionType, name='audit_action_type_enum'),
        nullable=False,
        index=True
    )
    
    # Entity being acted upon
    entity_type = Column(String(100), nullable=False, index=True)  # e.g., 'Order', 'Prescription'
    entity_id = Column(Integer, nullable=True, index=True)
    
    # Data changes (stored as JSON for flexibility)
    old_values = Column(JSONB, nullable=True)  # State before change
    new_values = Column(JSONB, nullable=True)  # State after change
    
    # Request context
    ip_address = Column(String(50))
    user_agent = Column(String(500))
    request_path = Column(String(500))
    request_method = Column(String(10))
    
    # Additional context
    description = Column(Text)
    extra_data = Column(JSONB)  # Any additional structured data
    
    # Organization and store context
    organization_id = Column(Integer, ForeignKey('organizations.id'), nullable=True, index=True)
    store_id = Column(Integer, ForeignKey('stores.id'), nullable=True, index=True)
    
    # Relationships
    user = relationship("User", foreign_keys=[user_id])
    organization = relationship("Organization")
    store = relationship("Store")

