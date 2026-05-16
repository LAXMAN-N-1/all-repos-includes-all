from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, JSON
from app.db.base_class import Base, TimestampMixin

class Notification(Base, TimestampMixin):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id"), index=True)
    title = Column(String(255))
    message = Column(String(500))
    type = Column(String(50)) # invoice_pushed, order_confirmed, etc.
    payload = Column(JSON, nullable=True) # Any extra data
    is_read = Column(Boolean, default=False)
    is_delivered = Column(Boolean, default=False)
