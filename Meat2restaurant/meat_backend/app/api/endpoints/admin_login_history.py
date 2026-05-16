"""
Admin Login History API — Login events, sessions, suspicious activity
"""
from typing import Optional
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, or_
from sqlalchemy.orm import Session

from app.api import deps
from app.models.user import User
from app.models.admin_models import AdminLoginHistory, AdminRefreshToken

router = APIRouter()


# ─── Stats ───────────────────────────────────────────────────────
@router.get("/stats")
def login_stats(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    thirty_days = datetime.utcnow() - timedelta(days=30)
    base = db.query(AdminLoginHistory).filter(AdminLoginHistory.created_at >= thirty_days)

    if not current_user.is_superuser:
        base = base.filter(AdminLoginHistory.admin_user_id == current_user.id)

    total = base.count()
    successful = base.filter(AdminLoginHistory.status == "success").count()
    failed = base.filter(AdminLoginHistory.status == "failed").count()
    blocked = base.filter(AdminLoginHistory.status == "blocked").count()
    unique_ips = base.with_entities(func.count(func.distinct(AdminLoginHistory.ip_address))).scalar() or 0

    return {
        "total_30d": total,
        "successful": successful,
        "failed": failed,
        "blocked": blocked,
        "unique_ips": unique_ips,
    }


# ─── List Login History ──────────────────────────────────────────
@router.get("/")
def list_login_history(
    admin_user_id: Optional[int] = None,
    status: Optional[str] = None,
    device_type: Optional[str] = None,
    ip_address: Optional[str] = None,
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    page: int = 1,
    limit: int = 25,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    q = db.query(AdminLoginHistory)

    if not current_user.is_superuser:
        q = q.filter(AdminLoginHistory.admin_user_id == current_user.id)
    elif admin_user_id:
        q = q.filter(AdminLoginHistory.admin_user_id == admin_user_id)

    if status:
        q = q.filter(AdminLoginHistory.status == status)
    if device_type:
        q = q.filter(AdminLoginHistory.device_type == device_type)
    if ip_address:
        q = q.filter(AdminLoginHistory.ip_address.ilike(f"%{ip_address}%"))
    if date_from:
        q = q.filter(AdminLoginHistory.created_at >= date_from)
    if date_to:
        q = q.filter(AdminLoginHistory.created_at <= date_to)

    total = q.count()
    items = q.order_by(AdminLoginHistory.created_at.desc()).offset((page - 1) * limit).limit(limit).all()

    results = []
    for l in items:
        user = db.query(User).filter(User.id == l.admin_user_id).first() if l.admin_user_id else None
        results.append({
            "id": l.id,
            "admin_user_id": l.admin_user_id,
            "admin_user_name": user.full_name if user else None,
            "email_attempted": l.email_attempted,
            "ip_address": l.ip_address,
            "country": l.country,
            "city": l.city,
            "device_type": l.device_type,
            "browser": l.browser,
            "os": l.os,
            "user_agent": l.user_agent,
            "status": l.status,
            "failure_reason": l.failure_reason,
            "session_duration_minutes": l.session_duration_minutes,
            "is_suspicious": l.is_suspicious,
            "created_at": l.created_at.isoformat() if l.created_at else None,
        })

    return {"items": results, "total": total, "page": page, "pages": (total + limit - 1) // limit}


# ─── Active Sessions ─────────────────────────────────────────────
@router.get("/my-sessions")
def my_sessions(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    tokens = (
        db.query(AdminRefreshToken)
        .filter(
            AdminRefreshToken.admin_user_id == current_user.id,
            AdminRefreshToken.revoked_at == None,
            AdminRefreshToken.expires_at > datetime.utcnow(),
        )
        .order_by(AdminRefreshToken.last_used_at.desc())
        .all()
    )
    return [
        {
            "id": t.id,
            "device_info": t.device_info,
            "ip_address": t.ip_address,
            "last_used_at": t.last_used_at.isoformat() if t.last_used_at else None,
            "created_at": t.created_at.isoformat() if t.created_at else None,
            "is_current": False,  # Client should match this
        }
        for t in tokens
    ]


# ─── Revoke Session ──────────────────────────────────────────────
@router.delete("/sessions/{token_id}")
def revoke_session(
    token_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    token = db.query(AdminRefreshToken).filter(
        AdminRefreshToken.id == token_id,
        AdminRefreshToken.admin_user_id == current_user.id,
    ).first()
    if not token:
        raise HTTPException(404, "Session not found")

    token.revoked_at = datetime.utcnow()
    db.commit()
    return {"message": "Session revoked"}


# ─── Revoke All Sessions ─────────────────────────────────────────
@router.delete("/sessions/all")
def revoke_all_sessions(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    db.query(AdminRefreshToken).filter(
        AdminRefreshToken.admin_user_id == current_user.id,
        AdminRefreshToken.revoked_at == None,
    ).update({"revoked_at": datetime.utcnow()})
    db.commit()
    return {"message": "All other sessions revoked"}


# ─── Suspicious Activity ─────────────────────────────────────────
@router.get("/suspicious")
def suspicious_activity(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    one_hour = datetime.utcnow() - timedelta(hours=1)

    # Failed attempts from same IP in last hour
    suspects = (
        db.query(AdminLoginHistory.ip_address, func.count(AdminLoginHistory.id).label("cnt"))
        .filter(
            AdminLoginHistory.created_at >= one_hour,
            AdminLoginHistory.status == "failed",
        )
        .group_by(AdminLoginHistory.ip_address)
        .having(func.count(AdminLoginHistory.id) >= 3)
        .all()
    )

    alerts = [
        {
            "message": f"{cnt} failed login attempts from IP {ip} in the last hour",
            "ip_address": ip,
            "count": cnt,
            "created_at": datetime.utcnow().isoformat(),
        }
        for ip, cnt in suspects
    ]

    # Flagged suspicious logins
    flagged = (
        db.query(AdminLoginHistory)
        .filter(AdminLoginHistory.is_suspicious == True, AdminLoginHistory.created_at >= one_hour)
        .limit(5).all()
    )
    for f in flagged:
        alerts.append({
            "message": f"Suspicious login from {f.country or 'unknown location'} ({f.ip_address})",
            "ip_address": f.ip_address,
            "count": 1,
            "created_at": f.created_at.isoformat() if f.created_at else None,
        })

    return alerts
