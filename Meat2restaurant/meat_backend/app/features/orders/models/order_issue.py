from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime, Text
from sqlalchemy.orm import relationship
import enum

from app.db.base_class import Base, TimestampMixin


class IssuePriority(str, enum.Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class IssueStatus(str, enum.Enum):
    OPEN = "open"
    INVESTIGATING = "investigating"
    RESOLVED = "resolved"
    CLOSED = "closed"


class IssueType(str, enum.Enum):
    MISSING_ITEMS = "missing_items"
    DAMAGED_PACKAGING = "damaged_packaging"
    WRONG_ITEMS = "wrong_items"
    LATE_DELIVERY = "late_delivery"
    QUALITY_ISSUE = "quality_issue"
    BILLING_DISPUTE = "billing_dispute"
    OTHER = "other"


class OrderIssue(Base, TimestampMixin):
    __tablename__ = "order_issues"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), index=True, nullable=False)
    customer_id = Column(Integer, ForeignKey("customers.id"), index=True, nullable=False)
    issue_type = Column(String(50), default=IssueType.OTHER, nullable=False)
    priority = Column(String(50), default=IssuePriority.MEDIUM, nullable=False)
    status = Column(String(50), default=IssueStatus.OPEN, index=True)
    description = Column(Text, nullable=False)
    resolution = Column(Text, nullable=True)
    assigned_to_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    resolved_at = Column(DateTime, nullable=True)
    refund_amount = Column(Float, default=0.0)

    # Relationships
    order = relationship("Order")
    customer = relationship("Customer")
    assigned_to = relationship("User")
