"""
Admin Users Master — Pydantic Schemas
"""
from typing import Optional, List, Any
from pydantic import BaseModel, EmailStr, Field
from datetime import datetime


# ═══════════════════════════════════════════════════════════════════
# ROLE SCHEMAS
# ═══════════════════════════════════════════════════════════════════

class PermissionItem(BaseModel):
    module: str
    can_view: bool = False
    can_create: bool = False
    can_edit: bool = False
    can_delete: bool = False
    can_export: bool = False

class RoleCreate(BaseModel):
    name: str
    display_name: str
    description: Optional[str] = None
    color: str = "#F97316"
    permissions: List[PermissionItem] = []

class RoleUpdate(BaseModel):
    name: Optional[str] = None
    display_name: Optional[str] = None
    description: Optional[str] = None
    color: Optional[str] = None
    permissions: Optional[List[PermissionItem]] = None

class PermissionOut(BaseModel):
    id: int
    module: str
    can_view: bool
    can_create: bool
    can_edit: bool
    can_delete: bool
    can_export: bool
    class Config:
        from_attributes = True

class RoleOut(BaseModel):
    id: int
    name: str
    display_name: str
    description: Optional[str] = None
    color: str
    is_system_role: bool
    is_active: bool
    permissions: List[PermissionOut] = []
    user_count: int = 0
    class Config:
        from_attributes = True

class ModuleInfo(BaseModel):
    key: str
    label: str
    icon: str = ""


# ═══════════════════════════════════════════════════════════════════
# ADMIN USER SCHEMAS
# ═══════════════════════════════════════════════════════════════════

class AdminUserInvite(BaseModel):
    full_name: str
    email: str
    phone: Optional[str] = None
    role_id: int
    assigned_stores: List[int] = []

class AdminUserOut(BaseModel):
    id: int
    full_name: Optional[str] = None
    email: str
    phone: Optional[str] = None
    avatar_url: Optional[str] = None
    role: Optional[str] = None
    role_id: Optional[int] = None
    role_name: Optional[str] = None
    role_color: Optional[str] = None
    status: Optional[str] = "active"
    is_superuser: bool = False
    last_login_at: Optional[datetime] = None
    last_login_ip: Optional[str] = None
    created_at: Optional[datetime] = None
    class Config:
        from_attributes = True

class AdminUserDetail(AdminUserOut):
    recent_activity: List[Any] = []
    recent_logins: List[Any] = []
    permissions_summary: List[PermissionOut] = []

class AdminUserStats(BaseModel):
    total: int = 0
    active: int = 0
    inactive: int = 0
    suspended: int = 0

class StatusUpdate(BaseModel):
    status: str  # active, inactive, suspended

class AcceptInvite(BaseModel):
    token: str
    password: str


# ═══════════════════════════════════════════════════════════════════
# ACTIVITY LOG SCHEMAS
# ═══════════════════════════════════════════════════════════════════

class ActivityLogOut(BaseModel):
    id: int
    admin_user_id: Optional[int] = None
    admin_user_name: Optional[str] = None
    module: str
    action_type: str
    action_label: Optional[str] = None
    target_id: Optional[str] = None
    target_label: Optional[str] = None
    before_data: Optional[Any] = None
    after_data: Optional[Any] = None
    ip_address: Optional[str] = None
    status: str = "success"
    status_code: Optional[int] = None
    created_at: Optional[datetime] = None
    class Config:
        from_attributes = True

class ActivityLogSummary(BaseModel):
    total_today: int = 0
    most_active_user: Optional[str] = None
    most_active_user_count: int = 0
    most_used_module: Optional[str] = None
    failed_count: int = 0
    by_module: List[Any] = []
    by_action_type: List[Any] = []


# ═══════════════════════════════════════════════════════════════════
# LOGIN HISTORY SCHEMAS
# ═══════════════════════════════════════════════════════════════════

class LoginHistoryOut(BaseModel):
    id: int
    admin_user_id: Optional[int] = None
    admin_user_name: Optional[str] = None
    email_attempted: Optional[str] = None
    ip_address: Optional[str] = None
    country: Optional[str] = None
    city: Optional[str] = None
    device_type: Optional[str] = None
    browser: Optional[str] = None
    os: Optional[str] = None
    user_agent: Optional[str] = None
    status: str = "success"
    failure_reason: Optional[str] = None
    session_duration_minutes: Optional[int] = None
    is_suspicious: bool = False
    created_at: Optional[datetime] = None
    class Config:
        from_attributes = True

class LoginHistoryStats(BaseModel):
    total_30d: int = 0
    successful: int = 0
    failed: int = 0
    blocked: int = 0
    unique_ips: int = 0

class SessionOut(BaseModel):
    id: int
    device_info: Optional[str] = None
    ip_address: Optional[str] = None
    last_used_at: Optional[datetime] = None
    created_at: Optional[datetime] = None
    is_current: bool = False
    class Config:
        from_attributes = True

class SuspiciousAlert(BaseModel):
    message: str
    ip_address: Optional[str] = None
    count: int = 0
    created_at: Optional[datetime] = None
