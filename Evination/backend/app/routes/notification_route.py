from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.dependencies import get_current_active_user
from app.models.user_m import User
from app.models.vendor_m import Vendor
from app.services.notification_service import NotificationService

router = APIRouter(prefix="/notifications", tags=["Notifications"])

@router.get("/my")
def get_my_notifications(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = NotificationService(db)
    
    # Check if user is a vendor
    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    
    recipient_type = "VENDOR" if vendor else "USER"
    recipient_id = vendor.id if vendor else current_user.id
    
    notifications = service.get_my_notifications(recipient_type, recipient_id)
    return notifications

@router.post("/{notification_id}/read")
def mark_read(
    notification_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = NotificationService(db)
    notif = service.mark_as_read(notification_id)
    if not notif:
        raise HTTPException(status_code=404, detail="Notification not found")
    return {"message": "Marked as read"}
