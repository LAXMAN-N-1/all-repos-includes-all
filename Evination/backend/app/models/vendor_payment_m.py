from sqlalchemy import Column, Integer, Float, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel


class VendorPayment(BaseModel):
    __tablename__ = "vendor_payments"

    vendor_id = Column(Integer, ForeignKey("vendors.id"), nullable=False)

    order_id = Column(Integer, ForeignKey("vendor_orders.id"), nullable=True)

    amount = Column(Float, nullable=False)

    payment_method = Column(String(100), nullable=True)
    payment_ref = Column(String(100), unique=True, index=True)

    status = Column(String(50), default="completed")
    # pending, completed, failed

    paid_at = Column(DateTime, nullable=True)

    vendor = relationship("Vendor", back_populates="payments")
    order = relationship("VendorOrder", back_populates="payments")
