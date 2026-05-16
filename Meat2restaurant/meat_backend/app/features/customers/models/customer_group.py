from sqlalchemy import Column, Integer, String, Float, Boolean, Text
from sqlalchemy.orm import relationship

from app.db.base_class import Base, TimestampMixin

class CustomerGroup(Base, TimestampMixin):
    __tablename__ = "customer_groups"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, index=True)
    description = Column(String(500), nullable=True)
    is_active = Column(Boolean, default=True)
    discount_percentage = Column(Float, default=0.0)

    customers = relationship("Customer", back_populates="group")
