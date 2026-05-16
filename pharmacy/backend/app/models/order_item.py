from sqlalchemy import Column, Integer, Float, ForeignKey, String
from sqlalchemy.orm import relationship
from app.models.base import BaseModel


class OrderItem(BaseModel):
    """
    Order line item model.
    Represents individual items within an order.
    """
    __tablename__ = "order_items"

    # Parent order
    order_id = Column(Integer, ForeignKey('orders.id', ondelete='CASCADE'), nullable=False, index=True)
    
    # Product references
    medicine_id = Column(Integer, ForeignKey('medicines.id'), nullable=False, index=True)
    inventory_batch_id = Column(Integer, ForeignKey('inventory_batches.id'), nullable=True, index=True)
    
    # Quantity and pricing
    quantity = Column(Integer, nullable=False, default=1)
    unit_price = Column(Float, nullable=False, default=0.0)
    discount_percent = Column(Float, default=0.0)
    tax_percent = Column(Float, default=0.0)
    total_price = Column(Float, nullable=False, default=0.0)
    
    # Product snapshot (in case medicine details change later)
    product_name = Column(String(255), nullable=False)
    product_strength = Column(String(100))
    batch_number = Column(String(100))
    
    # Fulfillment tracking
    quantity_fulfilled = Column(Integer, default=0)
    
    # Relationships
    order = relationship("Order", back_populates="items")
    medicine = relationship("Medicine", back_populates="order_items")
    inventory_batch = relationship("InventoryBatch", back_populates="order_items")

