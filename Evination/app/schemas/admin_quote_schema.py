from pydantic import BaseModel
from typing import List, Optional
from decimal import Decimal

class QuoteVendorSchema(BaseModel):
    name: str
    contact: str  # We can map this to contact person name or company name if not available
    email: str
    phone: Optional[str]

class QuoteItemSchema(BaseModel):
    id: int
    description: str
    quantity: int
    unitPrice: float
    total: float

class AdminQuoteDetailSchema(BaseModel):
    id: str  # "QT-{id}"
    orderId: str  # "ORD-{event_id}"
    eventName: str
    eventDate: str
    location: str
    
    vendor: QuoteVendorSchema
    
    status: str
    validUntil: Optional[str]
    
    items: List[QuoteItemSchema]
    
    subtotal: float
    tax: float
    discount: float
    total: float
    
    terms: List[str]
    notes: Optional[str]

# List View Schema (Simplified)
class QuoteListSchema(BaseModel):
    id: str
    orderId: str
    eventName: str
    vendorName: str
    totalAmount: float
    status: str
    submittedAt: str

# Comparison Schema
class QuoteComparisonRequestSchema(BaseModel):
    quote_ids: List[str]

class QuoteComparisonResponseSchema(BaseModel):
    quotes: List[AdminQuoteDetailSchema]
