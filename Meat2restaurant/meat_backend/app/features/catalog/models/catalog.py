from sqlalchemy import Column, Integer, String, Boolean, Float, ForeignKey
from sqlalchemy.orm import relationship
from app.db.base_class import Base, TimestampMixin


class Category(Base, TimestampMixin):
    __tablename__ = "categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), index=True)
    description = Column(String(500), nullable=True)
    parent_id = Column(Integer, ForeignKey("categories.id"), nullable=True)
    is_active = Column(Boolean, default=True)
    image_url = Column(String(500), nullable=True)
    icon_url = Column(String(500), nullable=True)  # Category icon for storefront bar

    products = relationship("Product", back_populates="category_rel")
    subcategories = relationship("Category", backref="parent", remote_side=[id])


class Attribute(Base, TimestampMixin):
    __tablename__ = "attributes"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), index=True)   # ✅ FIXED
    is_active = Column(Boolean, default=True)

    values = relationship("AttributeValue", back_populates="attribute")


class AttributeValue(Base, TimestampMixin):
    __tablename__ = "attribute_values"

    id = Column(Integer, primary_key=True, index=True)
    attribute_id = Column(Integer, ForeignKey("attributes.id"))
    value = Column(String(100))

    attribute = relationship("Attribute", back_populates="values")


class TaxTemplate(Base, TimestampMixin):
    __tablename__ = "tax_templates"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), index=True)   # ✅ FIXED
    rate = Column(Float)
    is_default = Column(Boolean, default=False)
