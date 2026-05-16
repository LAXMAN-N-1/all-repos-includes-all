"""Security Settings Admin API endpoints."""
from datetime import UTC, datetime, timedelta
import logging
from typing import Any, List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import text
from sqlmodel import Session, func, select

from app.core.database import get_db
from app.api.deps import get_current_active_admin
from app.models.user import User
from app.models.audit_log import AuditLog, SecurityEvent
from app.models.rbac import Role
from app.models.session import UserSession
from app.models.system import SystemConfig
from app.models.user_identity import UserIdentity

router = APIRouter()
logger = logging.getLogger(__name__)


def _table_exists(session: Session, schema: str, table: str) -> bool:
    return bool(
        session.execute(
            text(
                """
                SELECT EXISTS (
                    SELECT 1
                    FROM information_schema.tables
                    WHERE table_schema = :schema
                      AND table_name = :table
                )
                """
            ),
            {"schema": schema, "table": table},
        ).scalar()
    )


def _table_columns(session: Session, schema: str, table: str) -> set[str]:
    rows = session.execute(
        text(
            """
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = :schema
              AND table_name = :table
            """
        ),
        {"schema": schema, "table": table},
    ).fetchall()
    return {str(row[0]) for row in rows}


def _serialize_login_activity_item(
    *,
    record_id: str,
    timestamp: Any,
    user_key: str,
    user_name: str,
    email: str,
    role_name: str,
    status: str,
    ip_address: str,
    device_browser: Optional[str],
    is_success: bool,
) -> dict[str, Any]:
    return {
        "id": record_id,
        "timestamp": timestamp,
        "user_id": user_key,
        "user_name": user_name,
        "email": email,
        "role_name": role_name,
        "status": status,
        "ip_address": ip_address,
        "device_browser": device_browser,
        "is_success": is_success,
    }


def _load_user_context(
    session: Session,
    *,
    user_ids: set[int],
) -> tuple[dict[int, User], dict[int, str]]:
    if not user_ids:
        return {}, {}

    users = session.exec(select(User).where(User.id.in_(user_ids))).all()
    user_map = {user.id: user for user in users if user.id is not None}

    role_ids = {user.role_id for user in users if user.role_id is not None}
    role_map: dict[int, str] = {}
    if role_ids:
        roles = session.exec(select(Role).where(Role.id.in_(role_ids))).all()
        role_map = {role.id: role.name for role in roles if role.id is not None}

    return user_map, role_map


def _list_local_user_sessions(
    session: Session,
    *,
    skip: int,
    limit: int,
) -> dict[str, Any]:
    total = int(session.exec(select(func.count(UserSession.id))).one() or 0)
    rows = session.exec(
        select(UserSession)
        .order_by(UserSession.created_at.desc())
        .offset(skip)
        .limit(limit)
    ).all()

    user_ids = {row.user_id for row in rows}
    user_map, role_map = _load_user_context(session, user_ids=user_ids)

    items = []
    for row in rows:
        user = user_map.get(row.user_id)
        role_name = role_map.get(user.role_id, "") if user and user.role_id is not None else ""
        user_name = (user.full_name or "").strip() if user else ""
        email = (user.email or "").strip() if user else ""
        user_key = str(user.id) if user and user.id is not None else str(row.user_id)
        status = "revoked" if row.is_revoked else ("active" if row.is_active else "inactive")
        items.append(
            _serialize_login_activity_item(
                record_id=f"local-session:{row.id}",
                timestamp=row.created_at,
                user_key=user_key,
                user_name=user_name or email or f"User {user_key}",
                email=email,
                role_name=role_name,
                status=status,
                ip_address=row.ip_address or "",
                device_browser=row.user_agent or row.device_name,
                is_success=True,
            )
        )

    return {
        "items": items,
        "total_count": total,
        "skip": skip,
        "limit": limit,
        "source": "local_user_sessions",
    }


def _list_supabase_auth_sessions(
    session: Session,
    *,
    skip: int,
    limit: int,
) -> Optional[dict[str, Any]]:
    if not _table_exists(session, "auth", "sessions"):
        return None

    columns = _table_columns(session, "auth", "sessions")
    if not {"id", "user_id"} <= columns:
        return None

    timestamp_column = "created_at" if "created_at" in columns else None
    if timestamp_column is None and "updated_at" in columns:
        timestamp_column = "updated_at"
    if timestamp_column is None:
        return None

    ip_expr = "CAST(s.ip AS TEXT)" if "ip" in columns else (
        "CAST(s.ip_address AS TEXT)" if "ip_address" in columns else "NULL"
    )
    user_agent_expr = "s.user_agent" if "user_agent" in columns else (
        "s.tag" if "tag" in columns else "NULL"
    )

    total = int(
        session.execute(text("SELECT COUNT(*) FROM auth.sessions")).scalar() or 0
    )
    rows = session.execute(
        text(
            f"""
            SELECT
                CAST(s.id AS TEXT) AS session_id,
                CAST(s.user_id AS TEXT) AS external_subject,
                s.{timestamp_column} AS timestamp,
                {ip_expr} AS ip_address,
                {user_agent_expr} AS user_agent
            FROM auth.sessions AS s
            ORDER BY s.{timestamp_column} DESC NULLS LAST
            OFFSET :skip
            LIMIT :limit
            """
        ),
        {"skip": skip, "limit": limit},
    ).mappings().all()

    external_subjects = {
        str(row["external_subject"])
        for row in rows
        if row.get("external_subject") not in (None, "")
    }
    if not external_subjects:
        return {
            "items": [],
            "total_count": total,
            "skip": skip,
            "limit": limit,
            "source": "supabase_auth_sessions",
        }

    identities = session.exec(
        select(UserIdentity).where(
            UserIdentity.provider == "supabase",
            UserIdentity.external_subject.in_(external_subjects),
        )
    ).all()
    identity_map = {
        identity.external_subject: identity
        for identity in identities
        if identity.external_subject
    }

    user_ids = {identity.user_id for identity in identities if identity.user_id is not None}
    user_map, role_map = _load_user_context(session, user_ids=user_ids)

    items = []
    for row in rows:
        external_subject = str(row.get("external_subject") or "")
        identity = identity_map.get(external_subject)
        user = user_map.get(identity.user_id) if identity else None
        role_name = role_map.get(user.role_id, "") if user and user.role_id is not None else ""
        email = (
            (user.email or "").strip()
            if user
            else (getattr(identity, "email_snapshot", None) or "").strip()
        )
        user_name = (user.full_name or "").strip() if user else ""
        user_key = str(user.id) if user and user.id is not None else external_subject
        items.append(
            _serialize_login_activity_item(
                record_id=f"supabase-session:{row['session_id']}",
                timestamp=row.get("timestamp"),
                user_key=user_key,
                user_name=user_name or email or f"Subject {external_subject[:8]}",
                email=email,
                role_name=role_name,
                status="session",
                ip_address=str(row.get("ip_address") or ""),
                device_browser=str(row.get("user_agent")) if row.get("user_agent") else None,
                is_success=True,
            )
        )

    return {
        "items": items,
        "total_count": total,
        "skip": skip,
        "limit": limit,
        "source": "supabase_auth_sessions",
    }


@router.get("/login-activity")
def list_login_activity(
    session: Session = Depends(get_db),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    current_user: User = Depends(get_current_active_admin),
):
    """
    List login activity for all users. Admin-only.

    In Supabase auth mode, prefer ``auth.sessions`` because it reflects the
    browser/device sessions created by direct Supabase sign-ins. Fall back to
    local ``user_sessions`` for legacy or non-Supabase deployments.
    """
    del current_user

    try:
        supabase_payload = _list_supabase_auth_sessions(
            session,
            skip=skip,
            limit=limit,
        )
        if supabase_payload is not None:
            return supabase_payload
    except Exception:
        logger.warning("admin.security.login_activity.supabase_query_failed", exc_info=True)

    return _list_local_user_sessions(session, skip=skip, limit=limit)

# ============================================================================
# Audit Logs (enhanced)
# ============================================================================

@router.get("/audit-logs")
def list_audit_logs(
    session: Session = Depends(get_db),
    action: Optional[str] = None,
    resource_type: Optional[str] = None,
    user_id: Optional[int] = None,
    days: int = Query(30, description="Days of history"),
    skip: int = 0,
    limit: int = 50,
    current_user: User = Depends(get_current_active_admin),
):
    since = datetime.now(UTC) - timedelta(days=days)
    query = select(AuditLog).where(AuditLog.timestamp >= since)
    if action:
        query = query.where(AuditLog.action == action)
    if resource_type:
        query = query.where(AuditLog.resource_type == resource_type)
    if user_id:
        query = query.where(AuditLog.user_id == user_id)

    total = session.exec(select(func.count(AuditLog.id)).where(AuditLog.timestamp >= since)).one()
    logs = session.exec(query.order_by(AuditLog.timestamp.desc()).offset(skip).limit(limit)).all()

    return {
        "items": [
            {
                "id": log.id, "user_id": log.user_id, "action": log.action,
                "resource_type": log.resource_type, "resource_id": log.resource_id,
                "details": log.details, "ip_address": log.ip_address,
                "user_agent": log.user_agent, "timestamp": log.timestamp,
                "old_value": log.old_value, "new_value": log.new_value,
            }
            for log in logs
        ],
        "total_count": total,
    }


@router.get("/audit-logs/stats")
def audit_stats(
    session: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_admin),
):
    today = datetime.now(UTC).replace(hour=0, minute=0, second=0, microsecond=0)
    week_ago = today - timedelta(days=7)

    total = session.exec(select(func.count(AuditLog.id))).one()
    today_count = session.exec(
        select(func.count(AuditLog.id)).where(AuditLog.timestamp >= today)
    ).one()
    week_count = session.exec(
        select(func.count(AuditLog.id)).where(AuditLog.timestamp >= week_ago)
    ).one()

    # Action breakdown
    actions = {}
    logs = session.exec(select(AuditLog.action, func.count(AuditLog.id)).group_by(AuditLog.action)).all()
    for action, count in logs:
        actions[action] = count

    return {
        "total": total,
        "today": today_count,
        "this_week": week_count,
        "by_action": actions,
    }


# ============================================================================
# Security Events
# ============================================================================

@router.get("/security-events")
def list_security_events(
    session: Session = Depends(get_db),
    severity: Optional[str] = None,
    event_type: Optional[str] = None,
    is_resolved: Optional[bool] = None,
    skip: int = 0,
    limit: int = 50,
    current_user: User = Depends(get_current_active_admin),
):
    query = select(SecurityEvent)
    if severity:
        query = query.where(SecurityEvent.severity == severity)
    if event_type:
        query = query.where(SecurityEvent.event_type == event_type)
    if is_resolved is not None:
        query = query.where(SecurityEvent.is_resolved == is_resolved)

    events = session.exec(query.order_by(SecurityEvent.timestamp.desc()).offset(skip).limit(limit)).all()
    total = session.exec(select(func.count(SecurityEvent.id))).one()

    return {
        "items": [
            {
                "id": e.id, "event_type": e.event_type, "severity": e.severity,
                "details": e.details, "source_ip": e.source_ip,
                "user_id": e.user_id, "timestamp": e.timestamp,
                "is_resolved": e.is_resolved,
            }
            for e in events
        ],
        "total_count": total,
    }


@router.patch("/security-events/{event_id}/resolve")
def resolve_security_event(
    event_id: int,
    session: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_admin),
):
    event = session.get(SecurityEvent, event_id)
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    event.is_resolved = True
    session.add(event)
    session.commit()
    return {"message": "Security event resolved"}


# ============================================================================
# Security Settings
# ============================================================================

@router.get("/security-settings")
def get_security_settings(
    session: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_admin),
):
    """Get platform security configuration."""
    # Read from SystemConfig or return defaults
    keys = ["2fa_enabled", "session_timeout_minutes", "max_login_attempts",
            "ip_whitelist_enabled", "password_min_length", "password_expiry_days"]
    configs = session.exec(select(SystemConfig).where(SystemConfig.key.in_(keys))).all()
    config_map = {c.key: c.value for c in configs}

    return {
        "two_factor_auth": {
            "enabled": config_map.get("2fa_enabled", "false") == "true",
            "enforcement": "optional",
        },
        "session_management": {
            "timeout_minutes": int(config_map.get("session_timeout_minutes", "60")),
            "max_concurrent_sessions": 3,
        },
        "login_security": {
            "max_attempts": int(config_map.get("max_login_attempts", "5")),
            "lockout_duration_minutes": 30,
        },
        "password_policy": {
            "min_length": int(config_map.get("password_min_length", "8")),
            "require_uppercase": True,
            "require_numbers": True,
            "require_special_chars": True,
            "expiry_days": int(config_map.get("password_expiry_days", "90")),
        },
        "ip_whitelist": {
            "enabled": config_map.get("ip_whitelist_enabled", "false") == "true",
            "addresses": [],
        },
    }


@router.patch("/security-settings")
def update_security_settings(
    session: Session = Depends(get_db),
    two_factor_enabled: Optional[bool] = None,
    session_timeout: Optional[int] = None,
    max_login_attempts: Optional[int] = None,
    password_min_length: Optional[int] = None,
    current_user: User = Depends(get_current_active_admin),
):
    updates = {}
    if two_factor_enabled is not None:
        updates["2fa_enabled"] = str(two_factor_enabled).lower()
    if session_timeout is not None:
        updates["session_timeout_minutes"] = str(session_timeout)
    if max_login_attempts is not None:
        updates["max_login_attempts"] = str(max_login_attempts)
    if password_min_length is not None:
        updates["password_min_length"] = str(password_min_length)

    for key, value in updates.items():
        config = session.exec(select(SystemConfig).where(SystemConfig.key == key)).first()
        if config:
            config.value = value
            session.add(config)
        else:
            session.add(SystemConfig(key=key, value=value, description=f"Security: {key}"))

    session.commit()
    return {"message": "Security settings updated", "updated_keys": list(updates.keys())}
