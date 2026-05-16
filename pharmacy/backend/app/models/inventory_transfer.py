from sqlalchemy import Column, String, Integer, ForeignKey, DateTime, Date, Enum as SQLEnum, Text
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import JSONB
import enum
from app.models.base import BaseModel

class TransferStatus(str, enum.Enum):
    REQUESTED = "REQUESTED"
    APPROVED = "APPROVED"
    IN_TRANSIT = "IN_TRANSIT"
    RECEIVED = "RECEIVED"
    REJECTED = "REJECTED"
    CANCELLED = "CANCELLED"

class StockTransfer(BaseModel):
    """
    Tracks movement of inventory between stores (inter-store transfer) 
    or from Warehouse to Store.
    """
    __tablename__ = "stock_transfers"

    transfer_number = Column(String(50), unique=True, nullable=False, index=True)
    
    # Source & Destination
    from_store_id = Column(Integer, ForeignKey('stores.id'), nullable=True, index=True) # Null if external/warehouse
    to_store_id = Column(Integer, ForeignKey('stores.id'), nullable=False, index=True)
    
    # Workflow
    status = Column(SQLEnum(TransferStatus), default=TransferStatus.REQUESTED, nullable=False)
    requested_by = Column(Integer, ForeignKey('users.id'))
    approved_by = Column(Integer, ForeignKey('users.id'), nullable=True)
    sent_at = Column(DateTime(timezone=True))
    received_at = Column(DateTime(timezone=True))
    
    # Items (JSON for flexibility, or could be separate table)
    # [{"medicine_id": 1, "batch_number": "B123", "quantity": 50}]
    items = Column(JSONB, default=list)
    
    notes = Column(Text)

    # Relationships
    from_store = relationship("Store", foreign_keys=[from_store_id], backref="outgoing_transfers")
    to_store = relationship("Store", foreign_keys=[to_store_id], backref="incoming_transfers")
    requester = relationship("User", foreign_keys=[requested_by])


class AdjustmentType(str, enum.Enum):
    DAMAGE = "DAMAGE"
    EXPIRY = "EXPIRY"
    THEFT = "THEFT"
    AUDIT_CORRECTION = "AUDIT_CORRECTION"
    OTHER = "OTHER"

class StockAdjustment(BaseModel):
    """
    Tracks manual inventory corrections (Audit Logs).
    """
    __tablename__ = "stock_adjustments"

    store_id = Column(Integer, ForeignKey('stores.id'), nullable=False, index=True)
    batch_id = Column(Integer, ForeignKey('inventory_batches.id'), nullable=False)
    
    adjustment_type = Column(SQLEnum(AdjustmentType), nullable=False)
    quantity_adjusted = Column(Integer, nullable=False) # Negative for loss, Positive for gain
    reason = Column(Text)
    
    performed_by = Column(Integer, ForeignKey('users.id'), nullable=False)
    approved_by = Column(Integer, ForeignKey('users.id'), nullable=True) # For large adjustments

    # Relationships
    store = relationship("Store", backref="adjustments")
    batch = relationship("InventoryBatch")
    user = relationship("User", foreign_keys=[performed_by])
