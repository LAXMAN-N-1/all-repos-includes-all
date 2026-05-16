from sqlalchemy import Column, Integer, String, Float, Text, Boolean
from app.db.base_class import Base, TimestampMixin

class Supplier(Base, TimestampMixin):
    __tablename__ = "suppliers"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), index=True, nullable=False)
    contact_name = Column(String(255), nullable=True)
    email = Column(String(255), index=True, nullable=True)
    phone = Column(String(50), nullable=True)
    address = Column(Text, nullable=True)
    rating = Column(Float, default=0.0)
    status = Column(String(50), default="Active") # Active, Inactive
    is_active = Column(Boolean, default=True)
