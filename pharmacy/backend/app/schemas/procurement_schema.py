from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime, date
from enum import Enum


class ProcurementStatusEnum(str, Enum):
    DRAFT = "DRAFT"
    SUBMITTED = "SUBMITTED"
    APPROVED = "APPROVED"
    REJECTED = "REJECTED"
    ORDERED = "ORDERED"
    PARTIALLY_RECEIVED = "PARTIALLY_RECEIVED"
    RECEIVED = "RECEIVED"
    CANCELLED = "CANCELLED"


# ============= Nested Schemas =============

class ProcurementItemCreate(BaseModel):
    """Schema for PO line item creation"""
    medicine_id: Optional[int] = None
    medicine_name: str = Field(..., max_length=255)  # Snapshot for reference
    quantity: int = Field(..., gt=0)
    unit_price: float = Field(..., ge=0)

    @property
    def total(self) -> float:
        return self.quantity * self.unit_price


class ProcurementItemReceived(BaseModel):
    """Schema for received item during receiving process"""
    medicine_id: Optional[int] = None
    medicine_name: str
    ordered_quantity: int
    received_quantity: int = Field(..., ge=0)
    batch_number: Optional[str] = None
    expiry_date: Optional[datetime] = None
    notes: Optional[str] = None


class ProcurementItemResponse(BaseModel):
    """Schema for PO item in responses"""
    medicine_id: Optional[int] = None
    medicine_name: str
    quantity: int
    unit_price: float
    total: float


# ============= Request Schemas =============

class ProcurementOrderCreate(BaseModel):
    """Schema for creating a new procurement order"""
    store_id: int
    supplier_id: int
    expected_delivery_date: Optional[date] = None
    items: List[ProcurementItemCreate] = Field(..., min_length=1)
    notes: Optional[str] = None
    
    def calculate_totals(self) -> dict:
        subtotal = sum(item.quantity * item.unit_price for item in self.items)
        return {
            "subtotal": subtotal,
            "tax_amount": 0.0,  # Can be calculated based on rules
            "discount_amount": 0.0,
            "total_amount": subtotal
        }


class ProcurementOrderUpdate(BaseModel):
    """Schema for updating a procurement order (draft status only)"""
    expected_delivery_date: Optional[datetime] = None
    items: Optional[List[ProcurementItemCreate]] = None
    notes: Optional[str] = None


class ProcurementSubmit(BaseModel):
    """Schema for submitting PO for approval"""
    internal_notes: Optional[str] = None


class ProcurementApproval(BaseModel):
    """Schema for approving/rejecting a PO"""
    approved: bool
    rejection_reason: Optional[str] = None


class ProcurementReceive(BaseModel):
    """Schema for receiving items against a PO"""
    items_received: List[ProcurementItemReceived]
    partial: bool = False  # True if partial receipt
    notes: Optional[str] = None


# ============= Response Schemas =============

class ProcurementOrderResponse(BaseModel):
    """Schema for full procurement order response"""
    id: int
    po_number: str
    store_id: int
    store_name: Optional[str] = None
    supplier_id: int
    supplier_name: Optional[str] = None
    status: ProcurementStatusEnum
    order_date: Optional[datetime] = None
    expected_delivery_date: Optional[datetime] = None
    received_date: Optional[datetime] = None
    subtotal: float
    tax_amount: float
    discount_amount: float
    total_amount: float
    items: List[ProcurementItemResponse]
    items_received: Optional[List[dict]] = None
    approved_by: Optional[int] = None
    approved_at: Optional[datetime] = None
    rejection_reason: Optional[str] = None
    notes: Optional[str] = None
    internal_notes: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class ProcurementOrderSummaryResponse(BaseModel):
    """Schema for PO summary (list view)"""
    id: int
    po_number: str
    store_name: Optional[str] = None
    supplier_name: Optional[str] = None
    status: ProcurementStatusEnum
    total_amount: float
    expected_delivery_date: Optional[datetime] = None
    created_at: datetime

    class Config:
        from_attributes = True


class ProcurementOrderListResponse(BaseModel):
    """Schema for paginated PO list"""
    items: List[ProcurementOrderSummaryResponse]
    total: int
    page: int
    page_size: int
    total_pages: int


# ============= Filter Schemas =============

class ProcurementFilters(BaseModel):
    """Schema for PO search filters"""
    store_id: Optional[int] = None
    supplier_id: Optional[int] = None
    status: Optional[ProcurementStatusEnum] = None
    date_from: Optional[datetime] = None
    date_to: Optional[datetime] = None
    po_number: Optional[str] = None
