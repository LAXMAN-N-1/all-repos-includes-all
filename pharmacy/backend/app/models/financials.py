from sqlalchemy import Column, String, Integer, Float, ForeignKey, DateTime, Enum as SQLEnum, Text
from sqlalchemy.orm import relationship
import enum
from app.models.base import BaseModel

class TransactionType(str, enum.Enum):
    SALE = "SALE"
    REFUND = "REFUND"
    PURCHASE = "PURCHASE" # Payment to supplier
    EXPENSE = "EXPENSE" # Utility bills, salary, etc.

class PaymentMode(str, enum.Enum):
    CASH = "CASH"
    CARD = "CARD"
    UPI = "UPI"
    BANK_TRANSFER = "BANK_TRANSFER"
    CHECK = "CHECK"

class Invoice(BaseModel):
    """
    Official Tax Invoice generated after an Order is completed.
    Must be immutable once generated.
    """
    __tablename__ = "invoices"

    invoice_number = Column(String(50), unique=True, nullable=False, index=True) # e.g. INV-2024-0001
    order_id = Column(Integer, ForeignKey('orders.id'), unique=True, nullable=True)
    
    store_id = Column(Integer, ForeignKey('stores.id'), nullable=False)
    customer_id = Column(Integer, ForeignKey('users.id'), nullable=True)
    
    # Financials snapshot
    subtotal = Column(Float, default=0.0)
    tax_total = Column(Float, default=0.0)
    discount_total = Column(Float, default=0.0)
    grand_total = Column(Float, default=0.0)
    
    # PDF Link
    pdf_url = Column(String(500))
    
    status = Column(String(20), default="PAID") # PAID, VOID, REFUNDED

    # Relationships
    order = relationship("Order", backref="invoice")
    store = relationship("Store")
    customer = relationship("User")


class Transaction(BaseModel):
    """
    Financial Ledger for all money in/out.
    """
    __tablename__ = "transactions"

    store_id = Column(Integer, ForeignKey('stores.id'), nullable=False)
    
    type = Column(SQLEnum(TransactionType), nullable=False)
    mode = Column(SQLEnum(PaymentMode), nullable=False)
    
    amount = Column(Float, nullable=False) # Positive for credit, Negative for debit
    currency = Column(String(10), default="INR")
    
    reference_id = Column(String(100)) # Order ID, PO Number, or External Trans ID
    description = Column(Text)
    
    performed_by = Column(Integer, ForeignKey('users.id'))

    # Relationships
    store = relationship("Store")
    user = relationship("User")
