from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.auth.deps import get_current_user
from app.models.user import User
from app.models.notification import Alert, AlertSeverity
from app.schemas.alert_schema import AlertResponse

router = APIRouter(prefix="/api/v1/alerts", tags=["Alerts"])

@router.get("", response_model=List[AlertResponse])
async def list_alerts(
    severity: Optional[AlertSeverity] = Query(None),
    limit: int = Query(20, le=100),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Fetch system alerts.
    - HQ Admins see all alerts.
    - Org Admins see org-specific alerts.
    """
    query = db.query(Alert)
    
    # Filter by severity if provided
    if severity:
        query = query.filter(Alert.severity == severity)
        
    # Security filtering: non-super-admins only see relevant alerts
    from app.models.user import UserRole
    if current_user.role.code != UserRole.SAAS_SUPER_ADMIN.value:
        query = query.filter(
            (Alert.organization_id == current_user.organization_id) | 
            (Alert.organization_id == None) # Also show global system notifications
        )
        
    return query.order_by(Alert.created_at.desc()).limit(limit).all()
