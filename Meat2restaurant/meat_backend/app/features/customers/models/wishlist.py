from sqlalchemy import Column, Integer, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship

from app.db.base_class import Base, TimestampMixin

class Wishlist(Base, TimestampMixin):
    __tablename__ = "wishlists"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id", ondelete="CASCADE"), nullable=False, index=True)
    product_id = Column(Integer, ForeignKey("products.id", ondelete="CASCADE"), nullable=False, index=True)

    # Relationships
    customer = relationship("Customer", backref="wishlist_items")
    product = relationship("Product")

    # A customer should not have duplicate wishlist entries for the same product
    __table_args__ = (
        UniqueConstraint("customer_id", "product_id", name="uq_customer_product_wishlist"),
    )
