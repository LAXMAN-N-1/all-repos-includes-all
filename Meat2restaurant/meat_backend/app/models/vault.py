from sqlalchemy import Column, Integer, Float, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime

from app.db.base_class import Base

class WalletTransaction(Base):
    __tablename__ = "wallet_transactions"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id"), index=True)
    amount = Column(Float, nullable=False)
    transaction_type = Column(String(50), nullable=False) # deposit, payment, refund, adjustment
    reference_id = Column(String(100), nullable=True) # order_id or payment_id
    notes = Column(String(500), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    customer = relationship("Customer")
