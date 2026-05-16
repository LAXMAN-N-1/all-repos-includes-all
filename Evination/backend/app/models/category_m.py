from sqlalchemy import Column, String, Text, Integer
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel


class Category(BaseModel):
    """Event Categories: Weddings, Corporate Events, Conferences, etc."""
    __tablename__ = "categories"

    name = Column(String(100), nullable=False, unique=True)
    code = Column(String(50), nullable=False, unique=True)
    description = Column(Text, nullable=True)
    icon = Column(String(100), nullable=True)  # Emoji or icon name
    color = Column(String(50), default="purple")  # Color theme
    
    # Relationships
    events = relationship("Event", back_populates="category")
    event_types = relationship("EventType", back_populates="category")

    vendors = relationship(
        "VendorCategory",
        back_populates="category",
        cascade="all, delete-orphan"
    )

