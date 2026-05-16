from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional
from typing import Optional
from datetime import datetime
from app.database import get_db
from app.models.user import User, UserRole
from app.auth.deps import get_current_user
from app.services.audit_service import AuditService
from app.models.audit_log import AuditActionType

router = APIRouter(prefix="/api/v1/analytics", tags=["Analytics"])


def get_audit_service(db: Session = Depends(get_db)) -> AuditService:
    return AuditService(db)


@router.get("/audit")
async def get_audit_logs(
    entity_type: Optional[str] = Query(None),
    entity_id: Optional[int] = Query(None),
    user_id: Optional[int] = Query(None),
    action: Optional[str] = Query(None),
    store_id: Optional[int] = Query(None),
    date_from: Optional[datetime] = Query(None),
    date_to: Optional[datetime] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    service: AuditService = Depends(get_audit_service)
):
    """Get audit logs with filters. HQ Admin only."""
    if current_user.role.code != UserRole.HQ_ADMIN.value:
        raise HTTPException(status_code=403, detail="HQ Admin access required")
    
    action_enum = None
    if action:
        try:
            action_enum = AuditActionType(action)
        except ValueError:
            raise HTTPException(status_code=400, detail=f"Invalid action: {action}")
    
    logs, total = service.get_audit_trail(
        entity_type=entity_type, entity_id=entity_id, user_id=user_id,
        action=action_enum, store_id=store_id,
        date_from=date_from, date_to=date_to,
        page=page, page_size=page_size
    )
    
    return {
        "items": [{"id": str(log.id), "timestamp": log.created_at.isoformat() if log.created_at else None,
            "user_id": str(log.user_id) if log.user_id else None, "action": log.action.value if log.action else None,
            "entity_type": log.entity_type, "entity_id": str(log.entity_id) if log.entity_id else None,
            "description": log.description, "ip_address": log.ip_address
        } for log in logs],
        "total": total, "page": page, "page_size": page_size,
        "total_pages": (total + page_size - 1) // page_size
    }


@router.get("/audit/export")
async def export_audit_report(
    store_id: Optional[int] = Query(None),
    date_from: Optional[datetime] = Query(None),
    date_to: Optional[datetime] = Query(None),
    current_user: User = Depends(get_current_user),
    service: AuditService = Depends(get_audit_service)
):
    """Export audit report. HQ Admin only."""
    if current_user.role.code != UserRole.HQ_ADMIN.value:
        raise HTTPException(status_code=403, detail="HQ Admin access required")
    
    return service.export_audit_report(
        organization_id=current_user.organization_id,
        store_id=store_id, date_from=date_from, date_to=date_to
    )


@router.get("/audit/entity/{entity_type}/{entity_id}")
async def get_entity_history(
    entity_type: str, entity_id: int,
    page: int = Query(1, ge=1), page_size: int = Query(50, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    service: AuditService = Depends(get_audit_service)
):
    """Get complete history for a specific entity."""
    if current_user.role.code not in [UserRole.HQ_ADMIN.value, UserRole.STORE_ADMIN.value]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    logs, total = service.get_entity_history(entity_type, entity_id, page, page_size)
    return {
        "entity_type": entity_type, "entity_id": str(entity_id),
        "history": [{"id": str(log.id), "timestamp": log.created_at.isoformat() if log.created_at else None,
            "action": log.action.value if log.action else None, "user_id": str(log.user_id) if log.user_id else None,
            "old_values": log.old_values, "new_values": log.new_values
        } for log in logs],
        "total": total
    }


@router.get("/controlled-substances")
async def get_controlled_substance_audit(
    store_id: Optional[int] = Query(None),
    date_from: Optional[datetime] = Query(None),
    date_to: Optional[datetime] = Query(None),
    current_user: User = Depends(get_current_user),
    service: AuditService = Depends(get_audit_service)
):
    """Special audit report for controlled substances. For compliance."""
    if current_user.role.code not in [UserRole.HQ_ADMIN.value, UserRole.STORE_ADMIN.value]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    return service.get_controlled_substance_audit(store_id, date_from, date_to)
