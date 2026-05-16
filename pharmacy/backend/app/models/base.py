from sqlalchemy import Column, DateTime, Integer, Boolean, func
from app.database import Base


class BaseModel(Base):
    """
    Abstract base model with common audit fields for all tables.
    Includes soft delete, timestamps, and user tracking.
    """
    __abstract__ = True

    # Primary Key - Integer with auto-increment
    id = Column(Integer, primary_key=True, autoincrement=True, index=True)

    # Audit timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    deleted_at = Column(DateTime(timezone=True), nullable=True)

    # Audit user tracking (references user id)
    created_by = Column(Integer, nullable=True)
    modified_by = Column(Integer, nullable=True)

    # Soft delete flag
    inactive = Column(Boolean, default=False, nullable=False, index=True)

    def soft_delete(self, user_id=None):
        """Soft delete the record"""
        self.inactive = True
        self.deleted_at = func.now()
        self.modified_by = user_id

    def restore(self, user_id=None):
        """Restore soft deleted record"""
        self.inactive = False
        self.deleted_at = None
        self.modified_by = user_id