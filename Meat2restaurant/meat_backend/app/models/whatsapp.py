from sqlalchemy import Column, String, JSON, DateTime
from datetime import datetime
from app.db.base_class import Base

class WhatsAppSession(Base):
    __tablename__ = "whatsapp_sessions"

    phone = Column(String(20), primary_key=True, index=True)
    state = Column(String(50), default="START")
    context = Column(JSON, nullable=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
