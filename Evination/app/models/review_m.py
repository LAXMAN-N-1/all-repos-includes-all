from sqlalchemy import Column, Integer, String, Text, ForeignKey, Float
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel

class Review(BaseModel):
    __tablename__ = "reviews"

    consumer_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    vendor_id = Column(Integer, ForeignKey("vendors.id"), nullable=False)
    event_id = Column(Integer, ForeignKey("events.id"), nullable=True) # Optional link to specific event

    rating = Column(Float, nullable=False)
    comment = Column(Text, nullable=True)

    consumer = relationship("User", backref="reviews_given")
    vendor = relationship("Vendor", backref="reviews_received")
    event = relationship("Event", backref="review")
