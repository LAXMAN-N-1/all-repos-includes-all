from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from app.db.base_class import Base, TimestampMixin

class PartnerPrice(Base, TimestampMixin):
    __tablename__ = "partner_prices"
    
    id = Column(Integer, primary_key=True, index=True)
    partner_id = Column(Integer, ForeignKey("customers.id"), nullable=False)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=False)
    custom_price = Column(Float, nullable=False)
    
    partner = relationship("Customer")
    product = relationship("Product")
