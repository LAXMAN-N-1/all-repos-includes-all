"""
Admin Activity Logs API — Paginated, filterable, with summary stats
"""
from typing import Optional
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, or_, and_, cast, Date
from sqlalchemy.orm import Session

from app.api import deps
from app.models.user import User
from app.models.admin_models import AdminActivityLog

router = APIRouter()


# ─── Summary Stats ───────────────────────────────────────────────
@router.get("/summary")
def activity_summary(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    now = datetime.utcnow()
    today = now.replace(hour=0, minute=0, second=0, microsecond=0)
    thirty_days = now - timedelta(days=30)

    # Total today
    total_today = db.query(AdminActivityLog).filter(AdminActivityLog.created_at >= today).count()

    # Failed count
    failed = db.query(AdminActivityLog).filter(
        AdminActivityLog.created_at >= thirty_days, AdminActivityLog.status == "failed"
    ).count()

    # Most active user (30 days)
    top_user = (
        db.query(AdminActivityLog.admin_user_id, func.count(AdminActivityLog.id).label("cnt"))
        .filter(AdminActivityLog.created_at >= thirty_days, AdminActivityLog.admin_user_id != None)
        .group_by(AdminActivityLog.admin_user_id)
        .order_by(func.count(AdminActivityLog.id).desc())
        .first()
    )
    most_active_user = None
    most_active_count = 0
    if top_user:
        user = db.query(User).filter(User.id == top_user[0]).first()
        most_active_user = user.full_name if user else None
        most_active_count = top_user[1]

    # Most used module (30 days)
    top_mod = (
        db.query(AdminActivityLog.module, func.count(AdminActivityLog.id).label("cnt"))
        .filter(AdminActivityLog.created_at >= thirty_days)
        .group_by(AdminActivityLog.module)
        .order_by(func.count(AdminActivityLog.id).desc())
        .first()
    )

    # By module
    by_module = (
        db.query(AdminActivityLog.module, func.count(AdminActivityLog.id))
        .filter(AdminActivityLog.created_at >= thirty_days)
        .group_by(AdminActivityLog.module).all()
    )

    # By action type
    by_action = (
        db.query(AdminActivityLog.action_type, func.count(AdminActivityLog.id))
        .filter(AdminActivityLog.created_at >= thirty_days)
        .group_by(AdminActivityLog.action_type).all()
    )

    return {
        "total_today": total_today,
        "most_active_user": most_active_user,
        "most_active_user_count": most_active_count,
        "most_used_module": top_mod[0] if top_mod else None,
        "failed_count": failed,
        "by_module": [{"module": m, "count": c} for m, c in by_module],
        "by_action_type": [{"action_type": a, "count": c} for a, c in by_action],
    }


# ─── List Logs ───────────────────────────────────────────────────
@router.get("/")
def list_activity_logs(
    admin_user_id: Optional[int] = None,
    module: Optional[str] = None,
    action_type: Optional[str] = None,
    status: Optional[str] = None,
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    search: Optional[str] = None,
    page: int = 1,
    limit: int = 25,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    q = db.query(AdminActivityLog)

    # Non-super admins see only their own logs
    if not current_user.is_superuser:
        q = q.filter(AdminActivityLog.admin_user_id == current_user.id)
    elif admin_user_id:
        q = q.filter(AdminActivityLog.admin_user_id == admin_user_id)

    if module:
        q = q.filter(AdminActivityLog.module == module)
    if action_type:
        q = q.filter(AdminActivityLog.action_type == action_type)
    if status:
        q = q.filter(AdminActivityLog.status == status)
    if date_from:
        q = q.filter(AdminActivityLog.created_at >= date_from)
    if date_to:
        q = q.filter(AdminActivityLog.created_at <= date_to)
    if search:
        q = q.filter(or_(
            AdminActivityLog.action_label.ilike(f"%{search}%"),
            AdminActivityLog.target_label.ilike(f"%{search}%"),
        ))

    total = q.count()
    logs = q.order_by(AdminActivityLog.created_at.desc()).offset((page - 1) * limit).limit(limit).all()

    items = []
    for l in logs:
        user = db.query(User).filter(User.id == l.admin_user_id).first() if l.admin_user_id else None
        items.append({
            "id": l.id,
            "admin_user_id": l.admin_user_id,
            "admin_user_name": user.full_name if user else None,
            "module": l.module,
            "action_type": l.action_type,
            "action_label": l.action_label,
            "target_id": l.target_id,
            "target_label": l.target_label,
            "before_data": l.before_data,
            "after_data": l.after_data,
            "ip_address": l.ip_address,
            "status": l.status,
            "status_code": l.status_code,
            "created_at": l.created_at.isoformat() if l.created_at else None,
        })

    return {"items": items, "total": total, "page": page, "pages": (total + limit - 1) // limit}


# ─── Single Log Detail ──────────────────────────────────────────
@router.get("/{log_id}")
def get_activity_log(
    log_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    l = db.query(AdminActivityLog).filter(AdminActivityLog.id == log_id).first()
    if not l:
        raise HTTPException(404, "Log not found")

    # Non-super admins can only see their own
    if not current_user.is_superuser and l.admin_user_id != current_user.id:
        raise HTTPException(403, "Access denied")

    user = db.query(User).filter(User.id == l.admin_user_id).first() if l.admin_user_id else None
    return {
        "id": l.id,
        "admin_user_id": l.admin_user_id,
        "admin_user_name": user.full_name if user else None,
        "module": l.module,
        "action_type": l.action_type,
        "action_label": l.action_label,
        "target_id": l.target_id,
        "target_label": l.target_label,
        "before_data": l.before_data,
        "after_data": l.after_data,
        "ip_address": l.ip_address,
        "user_agent": l.user_agent,
        "status": l.status,
        "status_code": l.status_code,
        "created_at": l.created_at.isoformat() if l.created_at else None,
    }
