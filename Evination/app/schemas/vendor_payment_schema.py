# app/schemas/vendor_payment_schema.py

from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class PaymentOverviewSchema(BaseModel):
    """Payment overview stats for vendor dashboard."""
    total_earnings: float
    pending_amount: float
    paid_amount: float
    total_transactions: int
    pending_transactions: int
    completed_transactions: int


class PaymentListItemSchema(BaseModel):
    """Single payment item in transaction history."""
    id: int
    order_id: Optional[int] = None
    order_ref: Optional[str] = None
    amount: float
    payment_method: Optional[str] = None
    payment_ref: Optional[str] = None
    status: str
    paid_at: Optional[datetime] = None
    created_at: datetime
    
    # Related event info
    event_name: Optional[str] = None
    consumer_name: Optional[str] = None

    class Config:
        from_attributes = True


class PaymentListResponse(BaseModel):
    """Paginated payment list response."""
    items: List[PaymentListItemSchema]
    total: int
    skip: int
    limit: int


class PaymentInvoiceSchema(BaseModel):
    """Invoice details for a specific payment."""
    invoice_number: str
    payment_id: int
    payment_ref: Optional[str] = None
    
    # Vendor details
    vendor_id: int
    vendor_company_name: str
    vendor_address: Optional[str] = None
    vendor_phone: Optional[str] = None
    vendor_tax_id: Optional[str] = None
    
    # Order details
    order_id: Optional[int] = None
    order_ref: Optional[str] = None
    
    # Event details
    event_id: Optional[int] = None
    event_name: Optional[str] = None
    event_date: Optional[datetime] = None
    
    # Consumer details
    consumer_name: Optional[str] = None
    consumer_email: Optional[str] = None
    
    # Payment details
    amount: float
    payment_method: Optional[str] = None
    status: str
    paid_at: Optional[datetime] = None
    created_at: datetime
    
    # Additional invoice fields
    currency: str = "INR"
    notes: Optional[str] = None

    class Config:
        from_attributes = True
