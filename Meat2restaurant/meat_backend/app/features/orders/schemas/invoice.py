from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel

__all__ = ["Invoice", "InvoiceCreate", "InvoiceUpdate", "CombinedInvoice", "CombinedInvoiceCreate", "Payment", "PaymentCreate", "ConsolidatedInvoiceRequest", "CreditNote", "CreditNoteCreate"]

class InvoiceBase(BaseModel):
    customer_id: int
    order_id: Optional[int] = None
    combined_invoice_id: Optional[int] = None
    amount_due: float
    due_date: datetime
    status: Optional[str] = "draft"
    pdf_url: Optional[str] = None
    discount_percentage: Optional[float] = 0.0
    discount_amount: Optional[float] = 0.0
    subtotal: Optional[float] = 0.0
    tax_total: Optional[float] = 0.0
    invoice_date: Optional[datetime] = None
    terms: Optional[str] = None
    subject: Optional[str] = None
    salesperson_id: Optional[int] = None
    notes: Optional[str] = None

class InvoiceItemCreate(BaseModel):
    product_id: Optional[int] = 0
    variant_id: Optional[int] = None
    name: Optional[str] = None
    quantity: float
    unit_price: float
    discount: Optional[float] = 0.0

class InvoiceCreate(InvoiceBase):
    items: Optional[List[InvoiceItemCreate]] = None # For direct invoice creation

class InvoiceUpdate(BaseModel):
    status: Optional[str] = None
    pdf_url: Optional[str] = None
    stripe_invoice_id: Optional[str] = None

class InvoiceInDBBase(InvoiceBase):
    id: int
    created_at: datetime
    updated_at: datetime
    stripe_invoice_id: Optional[str] = None

    class Config:
        from_attributes = True

class Invoice(InvoiceInDBBase):
    pass

# --- Combined Invoice Schemas ---

class CombinedInvoiceBase(BaseModel):
    customer_id: int
    invoice_date: datetime
    total_amount: float
    status: Optional[str] = "draft"
    due_date: Optional[datetime] = None
    pdf_url: Optional[str] = None
    discount_percentage: Optional[float] = 0.0
    discount_amount: Optional[float] = 0.0
    subtotal: Optional[float] = 0.0
    tax_total: Optional[float] = 0.0

class CombinedInvoiceCreate(CombinedInvoiceBase):
    pass

class CombinedInvoice(CombinedInvoiceBase):
    id: int
    created_at: datetime
    updated_at: datetime
    invoices: List[Invoice] = []
    payments: List["Payment"] = []

    class Config:
        from_attributes = True

# --- New Request Schema for Manual Consolidation ---
class ConsolidatedInvoiceRequest(BaseModel):
    customer_id: int
    order_ids: Optional[List[int]] = None
    month: Optional[int] = None
    year: Optional[int] = None
    due_date: Optional[datetime] = None

# --- Payment Tracking Schemas ---

class PaymentBase(BaseModel):
    customer_id: int
    combined_invoice_id: Optional[int] = None
    invoice_id: Optional[int] = None
    amount: float
    payment_method: str # Cash, Cheque, UPI, Bank Transfer, Vault, etc.
    reference_id: Optional[str] = None
    payment_date: Optional[datetime] = None
    status: Optional[str] = "pending"
    notes: Optional[str] = None

class PaymentCreate(PaymentBase):
    pass

class PaymentUpdate(BaseModel):
    amount: Optional[float] = None
    payment_method: Optional[str] = None
    reference_id: Optional[str] = None
    payment_date: Optional[datetime] = None
    status: Optional[str] = None
    notes: Optional[str] = None

class Payment(PaymentBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# --- Credit Note Schemas ---

class CreditNoteBase(BaseModel):
    customer_id: int
    invoice_id: Optional[int] = None
    amount: float
    reason: Optional[str] = None
    status: Optional[str] = "issued"

class CreditNoteCreate(CreditNoteBase):
    pass

class CreditNote(CreditNoteBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Update forward reference
CombinedInvoice.model_rebuild()
