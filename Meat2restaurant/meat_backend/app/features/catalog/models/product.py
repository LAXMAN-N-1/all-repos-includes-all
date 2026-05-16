from sqlalchemy import Boolean, Column, Integer, String, Float, Text, ForeignKey, Table
from sqlalchemy.dialects.mysql import JSON
from sqlalchemy.orm import relationship

from app.db.base_class import Base, TimestampMixin

# Association table for linking Variants to AttributeValues (Many-to-Many)
variant_attribute_values = Table(
    "variant_attribute_values",
    Base.metadata,
    Column("variant_id", Integer, ForeignKey("product_variants.id"), primary_key=True),
    Column("attribute_value_id", Integer, ForeignKey("attribute_values.id"), primary_key=True),
)

class Product(Base, TimestampMixin):
    __tablename__ = "products"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), index=True, nullable=False)
    description = Column(Text, nullable=True)
    price = Column(Float, nullable=False) # Retail price
    wholesale_price = Column(Float, nullable=True) # B2B price
    sku = Column(String(100), unique=True, index=True)
    image_url = Column(String(500), nullable=True)
    stock_quantity = Column(Integer, default=0, index=True)
    unit = Column(String(50), default="unit") # lbs, unit, box, etc.
    min_order_quantity = Column(Integer, default=1) # MOQ
    volume_tiers = Column(JSON, nullable=True) # e.g. {"10": 40.0, "50": 35.0}
    
    category_id = Column(Integer, ForeignKey("categories.id"), nullable=True)
    low_stock_threshold = Column(Integer, default=10) # Alert if stock <= this
    
    category_rel = relationship("Category", back_populates="products")
    
    # New Relationship: A product can have multiple variants (e.g. Diced, Primal)
    variants = relationship("ProductVariant", back_populates="product", cascade="all, delete-orphan")

    is_active = Column(Boolean, default=True)
    is_popular = Column(Boolean, default=False)      # Show in "Popular Products"
    is_bestseller = Column(Boolean, default=False)    # Show in "Best Sellers"
    is_special = Column(Boolean, default=False)       # Show in "Special Items"
    category = Column(String(100), index=True, nullable=True)

class ProductVariant(Base, TimestampMixin):
    __tablename__ = "product_variants"

    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, ForeignKey("products.id"))
    sku = Column(String(100), unique=True, index=True)
    name = Column(String(255), nullable=True) # e.g. "Diced" or "Extra Trim"
    price = Column(Float, nullable=True) # Optional override
    wholesale_price = Column(Float, nullable=True) # Optional B2B override
    stock_quantity = Column(Integer, default=0)
    low_stock_threshold = Column(Integer, default=5)
    is_active = Column(Boolean, default=True)

    product = relationship("Product", back_populates="variants")
    
    # Link to attributes (e.g. Cut Style -> Diced)
    attribute_values = relationship(
        "AttributeValue", 
        secondary="variant_attribute_values",
        backref="variants"
    )

class ProductReview(Base, TimestampMixin):
    __tablename__ = "product_reviews"

    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, ForeignKey("products.id"))
    customer_id = Column(Integer, index=True) # Link to user/customer
    customer_name = Column(String(255))
    rating = Column(Integer, nullable=False) # 1-5
    comment = Column(Text, nullable=True)
    status = Column(String(20), default="pending") # pending, approved, rejected
    
    product = relationship("Product", backref="reviews")
