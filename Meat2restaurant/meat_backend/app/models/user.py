from sqlalchemy import Boolean, Column, Integer, String, JSON, ForeignKey, DateTime
from sqlalchemy.orm import relationship

from app.db.base_class import Base, TimestampMixin


class User(Base, TimestampMixin):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String(255), index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=True)  # Nullable for invited users who haven't set password
    phone = Column(String(50), nullable=True)
    avatar_url = Column(String(500), nullable=True)
    is_active = Column(Boolean(), default=True)
    is_superuser = Column(Boolean(), default=False)
    role = Column(String(50), default="staff")  # Legacy field: admin, manager, staff
    
    # New: FK to admin_roles for structured RBAC
    role_id = Column(Integer, ForeignKey("admin_roles.id"), nullable=True, index=True)
    admin_role = relationship("AdminRole", back_populates="users", foreign_keys=[role_id])

    # Permissions for internal management (legacy JSON, kept for backward compat)
    permissions = Column(JSON, nullable=True)

    # Status: active, inactive, suspended, pending
    status = Column(String(20), default="active", index=True)

    # Invite flow
    invite_token = Column(String(255), nullable=True)  # SHA-256 hash of raw token
    invite_expires_at = Column(DateTime, nullable=True)
    invite_accepted_at = Column(DateTime, nullable=True)

    # Security / lockout
    failed_login_count = Column(Integer, default=0)
    locked_until = Column(DateTime, nullable=True)
    last_login_at = Column(DateTime, nullable=True)
    last_login_ip = Column(String(45), nullable=True)

    # Soft delete
    is_deleted = Column(Boolean, default=False)

    # No B2B fields here. Management only.
