from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import models, schemas
from app.api import deps

router = APIRouter()

@router.get("/", response_model=List[schemas.Notification])
def read_notifications(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: Any = Depends(deps.get_current_active_user),
) -> Any:
    """
    Retrieve notifications for the current user/customer.
    """
    query = db.query(models.Notification)
    
    if getattr(current_user, "identity_type", None) == "partner":
        query = query.filter(models.Notification.customer_id == current_user.id)
    
    notifications = query.order_by(models.Notification.created_at.desc()).offset(skip).limit(limit).all()
    return notifications

@router.put("/{notification_id}", response_model=schemas.Notification)
def update_notification(
    notification_id: int,
    notification_in: schemas.NotificationUpdate,
    db: Session = Depends(deps.get_db),
    current_user: Any = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update notification status (mark as read/delivered).
    """
    notification = db.query(models.Notification).filter(models.Notification.id == notification_id).first()
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")
    
    # Ownership Check
    if getattr(current_user, "identity_type", None) == "partner":
        if notification.customer_id != current_user.id:
            raise HTTPException(status_code=403, detail="Not authorized")

    update_data = notification_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(notification, field, value)
    
    db.add(notification)
    db.commit()
    db.refresh(notification)
    return notification
