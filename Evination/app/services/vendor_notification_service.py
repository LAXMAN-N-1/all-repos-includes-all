# app/services/vendor_notification_service.py

from sqlalchemy.orm import Session
from sqlalchemy import desc
from fastapi import HTTPException
from datetime import datetime
from typing import List

from app.models.vendor_notification_m import VendorNotification
from app.schemas.vendor_notification_schema import VendorNotificationListItem

class VendorNotificationService:

    @staticmethod
    def get_my_notifications(
        db: Session,
        vendor_id: int,
        unread_only: bool = False,
        skip: int = 0,
        limit: int = 50
    ) -> List[VendorNotificationListItem]:
        
        query = db.query(VendorNotification).filter(
            VendorNotification.vendor_id == vendor_id
        )

        if unread_only:
            query = query.filter(VendorNotification.is_read == False)

        notifications = query.order_by(
            VendorNotification.created_at.desc()
        ).offset(skip).limit(limit).all()

        return notifications

    @staticmethod
    def mark_as_read(
        db: Session,
        notification_id: int,
        vendor_id: int
    ):
        notification = db.query(VendorNotification).filter(
            VendorNotification.id == notification_id,
            VendorNotification.vendor_id == vendor_id
        ).first()

        if not notification:
            raise HTTPException(404, "Notification not found")

        if not notification.is_read:
            notification.is_read = True
            notification.read_at = datetime.utcnow()
            db.commit()
            db.refresh(notification)
        
        return {"message": "Notification marked as read"}

    @staticmethod
    def mark_all_as_read(
        db: Session,
        vendor_id: int
    ):
        db.query(VendorNotification).filter(
            VendorNotification.vendor_id == vendor_id,
            VendorNotification.is_read == False
        ).update(
            {
                "is_read": True,
                "read_at": datetime.utcnow()
            },
            synchronize_session=False
        )
        
        db.commit()
        return {"message": "All notifications marked as read"}

    @staticmethod
    def get_unread_count(
        db: Session,
        vendor_id: int
    ) -> int:
        return db.query(VendorNotification).filter(
            VendorNotification.vendor_id == vendor_id,
            VendorNotification.is_read == False
        ).count()
