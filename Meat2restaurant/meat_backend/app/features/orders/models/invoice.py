from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime, Boolean, Text
from sqlalchemy.orm import relationship


from app.db.base_class import Base, TimestampMixin

class Invoice(Base, TimestampMixin):
    __tablename__ = "invoices"
    
    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id"), index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), nullable=True, index=True) # Nullable for consolidated invoices
    amount_due = Column(Float, nullable=False)
    due_date = Column(DateTime, nullable=False)
    status = Column(String(50), default="draft", index=True) # draft, sent, paid, overdue, void
    pdf_url = Column(String(500), nullable=True)
    stripe_invoice_id = Column(String(255), nullable=True)
    combined_invoice_id = Column(Integer, ForeignKey("combined_invoices.id"), nullable=True)
    discount_percentage = Column(Float, default=0.0)
    discount_amount = Column(Float, default=0.0)
    subtotal = Column(Float, default=0.0)
    tax_total = Column(Float, default=0.0)
    
    # New Dynamic Fields
    invoice_date = Column(DateTime, default=datetime.utcnow)
    terms = Column(String(100), nullable=True) # e.g., "Net 7", "Due on Receipt"
    subject = Column(String(500), nullable=True)
    salesperson_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    notes = Column(Text, nullable=True)

    customer = relationship("Customer", back_populates="invoices")
    order = relationship("Order", back_populates="invoices")
    combined_invoice = relationship("CombinedInvoice", back_populates="invoices")

class CombinedInvoice(Base, TimestampMixin):
    __tablename__ = "combined_invoices"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id"), index=True)
    invoice_date = Column(DateTime, default=datetime.utcnow)
    total_amount = Column(Float, nullable=False)
    status = Column(String(50), default="draft") # draft, sent, paid, cancelled
    due_date = Column(DateTime, nullable=True)
    pdf_url = Column(String(500), nullable=True)
    discount_percentage = Column(Float, default=0.0)
    discount_amount = Column(Float, default=0.0)
    subtotal = Column(Float, default=0.0)
    tax_total = Column(Float, default=0.0)

    customer = relationship("Customer")
    invoices = relationship("Invoice", back_populates="combined_invoice")
    payments = relationship("Payment", back_populates="combined_invoice")

class Payment(Base, TimestampMixin):
    __tablename__ = "payments"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id"), index=True)
    combined_invoice_id = Column(Integer, ForeignKey("combined_invoices.id"), index=True, nullable=True)
    invoice_id = Column(Integer, ForeignKey("invoices.id"), index=True, nullable=True)
    
    amount = Column(Float, nullable=False)
    payment_method = Column(String(50), nullable=False) # Cash, Cheque, UPI, Bank Transfer, Vault, etc.
    reference_id = Column(String(255), nullable=True) # transaction hash, cheque number, etc.
    payment_date = Column(DateTime, default=datetime.utcnow)
    status = Column(String(50), default="pending") # pending, confirmed, rejected
    notes = Column(Text, nullable=True)

    customer = relationship("Customer")
    combined_invoice = relationship("CombinedInvoice", back_populates="payments")
    invoice = relationship("Invoice")

class CreditNote(Base, TimestampMixin):
    __tablename__ = "credit_notes"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id"), index=True)
    invoice_id = Column(Integer, ForeignKey("invoices.id"), index=True, nullable=True)
    amount = Column(Float, nullable=False)
    reason = Column(Text, nullable=True)
    status = Column(String(50), default="issued") # issued, applied, voided
    
    customer = relationship("Customer")
    invoice = relationship("Invoice")
