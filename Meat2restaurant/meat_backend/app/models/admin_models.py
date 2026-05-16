"""
Admin Users Master — Database Models
Tables: admin_roles, admin_role_permissions, admin_activity_logs,
        admin_login_history, admin_refresh_tokens
"""
from sqlalchemy import (
    Boolean, Column, Integer, String, Float, Text, ForeignKey,
    DateTime, JSON, Index
)
from sqlalchemy.orm import relationship
from datetime import datetime

from app.db.base_class import Base, TimestampMixin


# ═══════════════════════════════════════════════════════════════════
# ADMIN ROLES
# ═══════════════════════════════════════════════════════════════════

class AdminRole(Base, TimestampMixin):
    __tablename__ = "admin_roles"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, nullable=False, index=True)
    display_name = Column(String(150), nullable=False)
    description = Column(Text, nullable=True)
    color = Column(String(20), default="#F97316")  # Hex color for UI badge
    is_system_role = Column(Boolean, default=False)  # Cannot delete system roles
    is_active = Column(Boolean, default=True)

    permissions = relationship("AdminRolePermission", back_populates="role", cascade="all, delete-orphan")
    users = relationship("User", back_populates="admin_role", foreign_keys="User.role_id")


class AdminRolePermission(Base, TimestampMixin):
    __tablename__ = "admin_role_permissions"

    id = Column(Integer, primary_key=True, index=True)
    role_id = Column(Integer, ForeignKey("admin_roles.id", ondelete="CASCADE"), nullable=False, index=True)
    module = Column(String(100), nullable=False)  # e.g. "orders", "products", "admin_users"
    can_view = Column(Boolean, default=False)
    can_create = Column(Boolean, default=False)
    can_edit = Column(Boolean, default=False)
    can_delete = Column(Boolean, default=False)
    can_export = Column(Boolean, default=False)

    role = relationship("AdminRole", back_populates="permissions")

    __table_args__ = (
        Index("ix_role_module", "role_id", "module", unique=True),
    )


# ═══════════════════════════════════════════════════════════════════
# ADMIN ACTIVITY LOGS (append-only audit trail)
# ═══════════════════════════════════════════════════════════════════

class AdminActivityLog(Base):
    __tablename__ = "admin_activity_logs"

    id = Column(Integer, primary_key=True, index=True)
    admin_user_id = Column(Integer, ForeignKey("users.id"), nullable=True, index=True)
    module = Column(String(100), nullable=False, index=True)
    action_type = Column(String(50), nullable=False, index=True)  # create, update, delete, export, login, etc.
    action_label = Column(String(500), nullable=True)  # Human-readable: "Created store Dallas Branch"
    target_id = Column(String(100), nullable=True)  # ID of affected record
    target_label = Column(String(255), nullable=True)  # Name of affected record
    before_data = Column(JSON, nullable=True)  # Snapshot before change
    after_data = Column(JSON, nullable=True)  # Snapshot after change
    ip_address = Column(String(45), nullable=True)
    user_agent = Column(Text, nullable=True)
    status = Column(String(20), default="success")  # success, failed, warning
    status_code = Column(Integer, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)

    admin_user = relationship("User", foreign_keys=[admin_user_id])


# ═══════════════════════════════════════════════════════════════════
# ADMIN LOGIN HISTORY
# ═══════════════════════════════════════════════════════════════════

class AdminLoginHistory(Base, TimestampMixin):
    __tablename__ = "admin_login_history"

    id = Column(Integer, primary_key=True, index=True)
    admin_user_id = Column(Integer, ForeignKey("users.id"), nullable=True, index=True)
    email_attempted = Column(String(255), nullable=True)  # For failed logins where user not found
    ip_address = Column(String(45), nullable=True)
    country = Column(String(100), nullable=True)
    city = Column(String(100), nullable=True)
    device_type = Column(String(50), nullable=True)  # desktop, mobile, tablet
    browser = Column(String(100), nullable=True)
    os = Column(String(100), nullable=True)
    user_agent = Column(Text, nullable=True)
    status = Column(String(20), nullable=False, default="success", index=True)  # success, failed, blocked
    failure_reason = Column(String(255), nullable=True)
    session_duration_minutes = Column(Integer, nullable=True)
    is_suspicious = Column(Boolean, default=False)

    admin_user = relationship("User", foreign_keys=[admin_user_id])


# ═══════════════════════════════════════════════════════════════════
# ADMIN REFRESH TOKENS (session tracking)
# ═══════════════════════════════════════════════════════════════════

class AdminRefreshToken(Base, TimestampMixin):
    __tablename__ = "admin_refresh_tokens"

    id = Column(Integer, primary_key=True, index=True)
    admin_user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    token_hash = Column(String(255), nullable=False, unique=True, index=True)
    device_info = Column(String(500), nullable=True)
    ip_address = Column(String(45), nullable=True)
    expires_at = Column(DateTime, nullable=False)
    revoked_at = Column(DateTime, nullable=True)
    last_used_at = Column(DateTime, nullable=True)

    admin_user = relationship("User", foreign_keys=[admin_user_id])
