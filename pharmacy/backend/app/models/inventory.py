from sqlalchemy import Column, String, Integer, Float, ForeignKey, DateTime, Date
from sqlalchemy.orm import relationship
from app.models.base import BaseModel


class InventoryBatch(BaseModel):
    __tablename__ = "inventory_batches"

    store_id = Column(Integer, ForeignKey('stores.id'), nullable=False, index=True)
    medicine_id = Column(Integer, ForeignKey('medicines.id'), nullable=True, index=True)
    
    product_name = Column(String(255), nullable=False)
    batch_number = Column(String(100), nullable=False, index=True)
    expiry_date = Column(Date, nullable=False, index=True)
    manufacture_date = Column(Date)
    
    # Quantities
    quantity = Column(Integer, default=0)
    quantity_reserved = Column(Integer, default=0)  # Reserved for orders
    reorder_level = Column(Integer, default=10)  # Low stock threshold
    
    # Pricing
    cost_price = Column(Float, default=0.0)
    selling_price = Column(Float, default=0.0)
    mrp = Column(Float, default=0.0)  # Maximum Retail Price
    
    # Supplier info
    supplier_invoice = Column(String(100))
    supplier_batch = Column(String(100))
    
    # Location
    rack_location = Column(String(50))
    
    # Relationships
    store = relationship("Store", back_populates="inventory_batches")
    medicine = relationship("Medicine", back_populates="inventory_batches")
    order_items = relationship("OrderItem", back_populates="inventory_batch")


