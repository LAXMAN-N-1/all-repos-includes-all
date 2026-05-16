from sqlalchemy import Column, Integer, Boolean, DateTime, String, func
from app.database import Base

class BaseModel(Base):
    __abstract__ = True
    
    id = Column(Integer, primary_key=True, index=True)
    
    # Audit timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    deleted_at = Column(DateTime(timezone=True), nullable=True)
    
    # Audit user tracking
    created_by = Column(String(100), nullable=True)
    modified_by = Column(String(100), nullable=True)
    
    # Soft delete flag
    inactive = Column(Boolean, default=False)