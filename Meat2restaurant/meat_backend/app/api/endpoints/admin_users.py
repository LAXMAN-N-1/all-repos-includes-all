"""
Admin Users API — CRUD, Invite, Status Toggle, Stats
"""
import hashlib
import secrets
from datetime import datetime, timedelta
from typing import Optional, List

from fastapi import APIRouter, Depends, HTTPException, Query, Request
from sqlalchemy import func, or_
from sqlalchemy.orm import Session

from app.api import deps
from app.core import security
from app.models.user import User
from app.models.admin_models import (
    AdminRole, AdminRolePermission, AdminActivityLog,
    AdminLoginHistory, AdminRefreshToken
)
from app.schemas.admin_schemas import (
    AdminUserOut, AdminUserDetail, AdminUserStats,
    AdminUserInvite, StatusUpdate, AcceptInvite, PermissionOut
)

router = APIRouter()

MODULES_LIST = [
    "dashboard", "customers", "orders", "products", "inventory",
    "invoices", "delivery", "reports", "store_locations",
    "support", "promotions", "admin_users"
]


def _log_action(db: Session, user_id: int, module: str, action: str,
                label: str, target_id=None, target_label=None,
                before=None, after=None, ip=None, status="success", code=200):
    log = AdminActivityLog(
        admin_user_id=user_id, module=module, action_type=action,
        action_label=label, target_id=str(target_id) if target_id else None,
        target_label=target_label, before_data=before, after_data=after,
        ip_address=ip, status=status, status_code=code
    )
    db.add(log)
    db.commit()


def _user_to_dict(u: User) -> dict:
    role = u.admin_role
    return {
        "id": u.id,
        "full_name": u.full_name,
        "email": u.email,
        "phone": u.phone,
        "avatar_url": u.avatar_url,
        "role": u.role,
        "role_id": u.role_id,
        "role_name": role.display_name if role else u.role,
        "role_color": role.color if role else "#6B7280",
        "status": u.status or ("active" if u.is_active else "inactive"),
        "is_superuser": u.is_superuser,
        "last_login_at": u.last_login_at.isoformat() if u.last_login_at else None,
        "last_login_ip": u.last_login_ip,
        "created_at": u.created_at.isoformat() if u.created_at else None,
    }


# ─── Stats ──────────────────────────────────────────────────────
@router.get("/stats")
def admin_user_stats(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    base = db.query(User).filter(User.is_deleted == False)
    total = base.count()
    active = base.filter(User.status == "active").count()
    inactive = base.filter(User.status == "inactive").count()
    suspended = base.filter(User.status == "suspended").count()
    return {"total": total, "active": active, "inactive": inactive, "suspended": suspended}


# ─── List ────────────────────────────────────────────────────────
@router.get("/")
def list_admin_users(
    search: Optional[str] = None,
    status: Optional[str] = None,
    role_id: Optional[int] = None,
    page: int = 1,
    limit: int = 25,
    sort_by: str = "created_at",
    sort_dir: str = "desc",
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    q = db.query(User).filter(User.is_deleted == False)
    if search:
        q = q.filter(or_(User.full_name.ilike(f"%{search}%"), User.email.ilike(f"%{search}%")))
    if status:
        q = q.filter(User.status == status)
    if role_id:
        q = q.filter(User.role_id == role_id)

    total = q.count()
    col = getattr(User, sort_by, User.created_at)
    q = q.order_by(col.desc() if sort_dir == "desc" else col.asc())
    users = q.offset((page - 1) * limit).limit(limit).all()

    return {
        "items": [_user_to_dict(u) for u in users],
        "total": total,
        "page": page,
        "pages": (total + limit - 1) // limit,
    }


# ─── Detail ──────────────────────────────────────────────────────
@router.get("/{user_id}")
def get_admin_user(
    user_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    u = db.query(User).filter(User.id == user_id, User.is_deleted == False).first()
    if not u:
        raise HTTPException(404, "User not found")

    data = _user_to_dict(u)

    # Recent activity
    logs = (
        db.query(AdminActivityLog)
        .filter(AdminActivityLog.admin_user_id == user_id)
        .order_by(AdminActivityLog.created_at.desc())
        .limit(5).all()
    )
    data["recent_activity"] = [
        {"id": l.id, "action_label": l.action_label, "module": l.module,
         "status": l.status, "created_at": l.created_at.isoformat() if l.created_at else None}
        for l in logs
    ]

    # Recent logins
    logins = (
        db.query(AdminLoginHistory)
        .filter(AdminLoginHistory.admin_user_id == user_id)
        .order_by(AdminLoginHistory.created_at.desc())
        .limit(3).all()
    )
    data["recent_logins"] = [
        {"id": l.id, "ip_address": l.ip_address, "status": l.status,
         "device_type": l.device_type, "browser": l.browser,
         "created_at": l.created_at.isoformat() if l.created_at else None}
        for l in logins
    ]

    # Permissions summary
    if u.role_id:
        perms = db.query(AdminRolePermission).filter(AdminRolePermission.role_id == u.role_id).all()
        data["permissions_summary"] = [
            {"id": p.id, "module": p.module, "can_view": p.can_view, "can_create": p.can_create,
             "can_edit": p.can_edit, "can_delete": p.can_delete, "can_export": p.can_export}
            for p in perms
        ]
    else:
        data["permissions_summary"] = []

    return data


# ─── Invite ──────────────────────────────────────────────────────
@router.post("/invite")
def invite_admin(
    body: AdminUserInvite,
    request: Request,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    # Check email uniqueness
    existing = db.query(User).filter(User.email == body.email, User.is_deleted == False).first()
    if existing:
        raise HTTPException(409, "Email already in use")

    # Verify role exists
    role = db.query(AdminRole).filter(AdminRole.id == body.role_id).first()
    if not role:
        raise HTTPException(404, "Role not found")

    # Generate invite token
    raw_token = secrets.token_urlsafe(32)
    token_hash = hashlib.sha256(raw_token.encode()).hexdigest()

    user = User(
        full_name=body.full_name,
        email=body.email,
        phone=body.phone,
        hashed_password="",  # Not set until invite accepted
        role_id=body.role_id,
        role=role.name,
        status="pending",
        is_active=False,
        invite_token=token_hash,
        invite_expires_at=datetime.utcnow() + timedelta(hours=48),
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    _log_action(db, current_user.id, "admin_users", "invite",
                f"Invited {body.full_name} ({body.email})",
                user.id, body.full_name, ip=request.client.host if request.client else None)

    return {
        "id": user.id,
        "email": user.email,
        "invite_token": raw_token,  # In production, send this via email only
        "expires_at": user.invite_expires_at.isoformat(),
        "message": f"Invite sent to {body.email}. Link expires in 48 hours.",
    }


# ─── Accept Invite ──────────────────────────────────────────────
@router.post("/accept-invite")
def accept_invite(
    body: AcceptInvite,
    db: Session = Depends(deps.get_db),
):
    token_hash = hashlib.sha256(body.token.encode()).hexdigest()
    user = db.query(User).filter(User.invite_token == token_hash).first()

    if not user:
        raise HTTPException(400, "Invalid or expired invite token")
    if user.invite_expires_at and user.invite_expires_at < datetime.utcnow():
        raise HTTPException(400, "Invite token has expired")

    # Validate password strength
    pwd = body.password
    if len(pwd) < 8:
        raise HTTPException(400, "Password must be at least 8 characters")

    user.hashed_password = security.get_password_hash(pwd)
    user.status = "active"
    user.is_active = True
    user.invite_token = None
    user.invite_expires_at = None
    user.invite_accepted_at = datetime.utcnow()
    db.commit()

    # Return JWT so user is immediately logged in
    from app.core.security import create_access_token
    token = create_access_token(data={"sub": str(user.id), "type": "staff"}, expires_delta=timedelta(minutes=30))

    return {
        "access_token": token,
        "token_type": "bearer",
        "user": _user_to_dict(user),
        "message": "Account activated successfully",
    }


# ─── Resend Invite ───────────────────────────────────────────────
@router.post("/resend-invite/{user_id}")
def resend_invite(
    user_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    user = db.query(User).filter(User.id == user_id, User.is_deleted == False).first()
    if not user:
        raise HTTPException(404, "User not found")
    if user.status != "pending":
        raise HTTPException(400, "User is not in pending state")

    raw_token = secrets.token_urlsafe(32)
    user.invite_token = hashlib.sha256(raw_token.encode()).hexdigest()
    user.invite_expires_at = datetime.utcnow() + timedelta(hours=48)
    db.commit()

    return {
        "invite_token": raw_token,
        "expires_at": user.invite_expires_at.isoformat(),
        "message": f"Invite resent to {user.email}",
    }


# ─── Status Toggle ───────────────────────────────────────────────
@router.patch("/{user_id}/status")
def update_user_status(
    user_id: int,
    body: StatusUpdate,
    request: Request,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    user = db.query(User).filter(User.id == user_id, User.is_deleted == False).first()
    if not user:
        raise HTTPException(404, "User not found")

    # Super admin protection
    if user.is_superuser and body.status != "active":
        active_supers = db.query(User).filter(
            User.is_superuser == True, User.status == "active",
            User.is_deleted == False, User.id != user_id
        ).count()
        if active_supers == 0:
            raise HTTPException(409, "Cannot deactivate the last super admin")

    old_status = user.status
    user.status = body.status
    user.is_active = body.status == "active"

    # On suspend — revoke all refresh tokens
    if body.status == "suspended":
        db.query(AdminRefreshToken).filter(
            AdminRefreshToken.admin_user_id == user_id,
            AdminRefreshToken.revoked_at == None
        ).update({"revoked_at": datetime.utcnow()})

    db.commit()

    _log_action(db, current_user.id, "admin_users", "status_change",
                f"Changed {user.full_name} status: {old_status} → {body.status}",
                user_id, user.full_name,
                before={"status": old_status}, after={"status": body.status},
                ip=request.client.host if request.client else None)

    return {"message": f"User status updated to {body.status}", "user": _user_to_dict(user)}


# ─── Delete (Soft) ───────────────────────────────────────────────
@router.delete("/{user_id}")
def delete_admin_user(
    user_id: int,
    request: Request,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    if user_id == current_user.id:
        raise HTTPException(400, "Cannot delete yourself")

    user = db.query(User).filter(User.id == user_id, User.is_deleted == False).first()
    if not user:
        raise HTTPException(404, "User not found")

    # Super admin protection
    if user.is_superuser:
        active_supers = db.query(User).filter(
            User.is_superuser == True, User.status == "active",
            User.is_deleted == False, User.id != user_id
        ).count()
        if active_supers == 0:
            raise HTTPException(409, "Cannot delete the last super admin")

    user.is_deleted = True
    user.status = "inactive"
    user.is_active = False

    # Revoke all sessions
    db.query(AdminRefreshToken).filter(
        AdminRefreshToken.admin_user_id == user_id,
        AdminRefreshToken.revoked_at == None
    ).update({"revoked_at": datetime.utcnow()})

    db.commit()

    _log_action(db, current_user.id, "admin_users", "delete",
                f"Deleted admin user {user.full_name}",
                user_id, user.full_name,
                ip=request.client.host if request.client else None)

    return {"message": f"User {user.full_name} deleted"}
