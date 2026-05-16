from sqlalchemy import Column, String, Integer, Text, DateTime, func
from app.models.base_model import BaseModel

class AuditLog(BaseModel):
    __tablename__ = "audit_logs"
    
    user_id = Column(Integer, nullable=True)
    action = Column(String(100), nullable=False)  # CREATE, UPDATE, DELETE, LOGIN, etc.
    entity_type = Column(String(100), nullable=False)  # user, product, order, etc.
    entity_id = Column(Integer, nullable=True)
    old_values = Column(Text, nullable=True)  # JSON string
    new_values = Column(Text, nullable=True)  # JSON string
    ip_address = Column(String(50), nullable=True)
    user_agent = Column(Text, nullable=True)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())