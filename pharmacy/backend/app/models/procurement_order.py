from sqlalchemy import Column, String, Text, Float, ForeignKey, DateTime, Enum as SQLEnum, Integer
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship
import enum
from app.models.base import BaseModel


class ProcurementStatus(str, enum.Enum):
    """Procurement order status workflow"""
    DRAFT = "DRAFT"
    SUBMITTED = "SUBMITTED"
    APPROVED = "APPROVED"
    REJECTED = "REJECTED"
    ORDERED = "ORDERED"
    PARTIALLY_RECEIVED = "PARTIALLY_RECEIVED"
    RECEIVED = "RECEIVED"
    CANCELLED = "CANCELLED"


class ProcurementOrder(BaseModel):
    """
    Procurement Order model for Store Direct Purchase mode.
    Manages the ordering process from suppliers to stores.
    """
    __tablename__ = "procurement_orders"

    # Order identification
    po_number = Column(String(50), unique=True, nullable=False, index=True)
    
    # Store and supplier
    store_id = Column(Integer, ForeignKey('stores.id'), nullable=False, index=True)
    supplier_id = Column(Integer, ForeignKey('suppliers.id'), nullable=False, index=True)
    
    # Status
    status = Column(
        SQLEnum(ProcurementStatus, name='procurement_status_enum'),
        default=ProcurementStatus.DRAFT,
        nullable=False,
        index=True
    )
    
    # Dates
    order_date = Column(DateTime(timezone=True))
    expected_delivery_date = Column(DateTime(timezone=True))
    received_date = Column(DateTime(timezone=True))
    
    # Financial
    subtotal = Column(Float, default=0.0)
    tax_amount = Column(Float, default=0.0)
    discount_amount = Column(Float, default=0.0)
    total_amount = Column(Float, default=0.0)
    
    # Items (stored as JSON for flexibility)
    # Format: [{"medicine_id": int, "quantity": int, "unit_price": float, "total": float}, ...]
    items = Column(JSONB, default=list)
    
    # Receiving details
    items_received = Column(JSONB, default=list)  # Actual received items
    received_by = Column(Integer, ForeignKey('users.id'), nullable=True)
    
    # Approval workflow
    approved_by = Column(Integer, ForeignKey('users.id'), nullable=True)
    approved_at = Column(DateTime(timezone=True))
    rejection_reason = Column(Text)
    
    # Notes
    notes = Column(Text)
    internal_notes = Column(Text)
    
    # Relationships
    store = relationship("Store", back_populates="procurement_orders")
    supplier = relationship("Supplier", back_populates="procurement_orders")
    approver = relationship("User", foreign_keys=[approved_by])
    receiver = relationship("User", foreign_keys=[received_by])

