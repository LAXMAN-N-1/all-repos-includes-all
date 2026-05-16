from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.services.vendor_notification_service import VendorNotificationService
from app.models.user_m import User
from app.models.vendor_m import Vendor
from app.dependencies import get_current_active_user
from app.schemas.vendor_notification_schema import VendorNotificationListItem

router = APIRouter(
    prefix="/vendor/notifications",
    tags=["Vendor Notifications"]
)

@router.get(
    "/",
    response_model=List[VendorNotificationListItem],
)
async def get_my_notifications(
    unread_only: bool = False,
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """
    Get notifications for the current vendor
    """
    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    if not vendor:
        raise HTTPException(status_code=403, detail="User is not a vendor")

    return VendorNotificationService.get_my_notifications(
        db=db,
        vendor_id=vendor.id,
        unread_only=unread_only,
        skip=skip,
        limit=limit
    )

@router.get(
    "/unread-count",
    response_model=dict,
)
async def get_unread_count(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """
    Get count of unread notifications
    """
    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    if not vendor:
        raise HTTPException(status_code=403, detail="User is not a vendor")

    count = VendorNotificationService.get_unread_count(db, vendor.id)
    return {"unread_count": count}

@router.put(
    "/{notification_id}/read",
    status_code=status.HTTP_200_OK,
)
async def mark_as_read(
    notification_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """
    Mark a notification as read
    """
    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    if not vendor:
        raise HTTPException(status_code=403, detail="User is not a vendor")

    return VendorNotificationService.mark_as_read(
        db=db,
        notification_id=notification_id,
        vendor_id=vendor.id
    )

@router.put(
    "/mark-all-read",
    status_code=status.HTTP_200_OK,
)
async def mark_all_as_read(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """
    Mark all notifications as read
    """
    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    if not vendor:
        raise HTTPException(status_code=403, detail="User is not a vendor")

    return VendorNotificationService.mark_all_as_read(
        db=db,
        vendor_id=vendor.id
    )

