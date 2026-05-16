# app/models/vendor_order_m.py

from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel   # use Base


class VendorOrder(BaseModel):
    __tablename__ = "vendor_orders"

    vendor_id = Column(Integer, ForeignKey("vendors.id"), nullable=False)
    event_id = Column(Integer, nullable=True)

    order_ref = Column(String(100), unique=True, index=True)

    amount = Column(Float, nullable=False)

    status = Column(String(50), default="confirmed")

    confirmed_at = Column(DateTime, nullable=True)
    completed_at = Column(DateTime, nullable=True)

    vendor = relationship("Vendor", back_populates="orders")

    payments = relationship(
        "VendorPayment",
        back_populates="order",
        cascade="all, delete-orphan"
    )
