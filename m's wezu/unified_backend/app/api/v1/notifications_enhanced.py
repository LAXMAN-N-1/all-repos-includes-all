"""
Enhanced Notification Endpoints
Additional notification operations including read/unread management and device tokens.
"""
from datetime import UTC, datetime
from typing import List, Literal, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, Field, field_validator, model_validator
from sqlmodel import Session, select

from app.api import deps
from app.models.device import Device
from app.models.notification import Notification
from app.models.user import User
from app.repositories.notification_repository import notification_repository
from app.schemas.notification import (
    AdminNotificationSendRequest,
    NotificationResponse,
    UnreadCountResponse,
)
from app.schemas.common import DataResponse
from app.services.notification_service import NotificationService

router = APIRouter()
admin_router = APIRouter()


def _supports_app_scope(model_cls: type) -> bool:
    fields = getattr(model_cls, "model_fields", None)
    if isinstance(fields, dict):
        return "app_scope" in fields
    return hasattr(model_cls, "app_scope")


def _normalize_app_scope(value: Optional[str]) -> Optional[str]:
    if value is None:
        return None
    normalized = value.strip().lower().replace("-", "_").replace(" ", "_")
    return normalized or None


def _mark_all_notifications_read(
    db: Session,
    user_id: int,
    app_scope: Optional[str],
    include_global: bool,
) -> int:
    normalized_scope = _normalize_app_scope(app_scope)
    if normalized_scope and _supports_app_scope(Notification):
        query = select(Notification).where(
            Notification.user_id == user_id,
            Notification.is_read == False,  # noqa: E712
        )
        if include_global:
            query = query.where(
                (Notification.app_scope == normalized_scope)
                | (Notification.app_scope.is_(None))
            )
        else:
            query = query.where(Notification.app_scope == normalized_scope)

        notifications = db.exec(query).all()
        for notification in notifications:
            notification.is_read = True
            db.add(notification)
        db.commit()
        return len(notifications)

    return NotificationService.mark_all_read(db, user_id)


class DeviceTokenRequest(BaseModel):
    token: str = Field(min_length=20, max_length=4096)
    platform: Literal["ios", "android", "web"]
    device_id: Optional[str] = Field(default=None, min_length=1, max_length=255)
    app_scope: Optional[str] = Field(default=None, min_length=1, max_length=64)

    @field_validator("token")
    @classmethod
    def _normalize_token(cls, value: str) -> str:
        token = value.strip()
        if not token:
            raise ValueError("token cannot be blank")
        return token

    @field_validator("device_id")
    @classmethod
    def _normalize_device_id(cls, value: Optional[str]) -> Optional[str]:
        if value is None:
            return None
        device_id = value.strip()
        return device_id or None

    @field_validator("app_scope")
    @classmethod
    def _normalize_scope(cls, value: Optional[str]) -> Optional[str]:
        return _normalize_app_scope(value)


class DeviceTokenUnregisterRequest(BaseModel):
    token: Optional[str] = Field(default=None, min_length=20, max_length=4096)
    device_id: Optional[str] = Field(default=None, min_length=1, max_length=255)
    app_scope: Optional[str] = Field(default=None, min_length=1, max_length=64)

    @field_validator("token")
    @classmethod
    def _normalize_token(cls, value: Optional[str]) -> Optional[str]:
        if value is None:
            return None
        token = value.strip()
        return token or None

    @field_validator("device_id")
    @classmethod
    def _normalize_device_id(cls, value: Optional[str]) -> Optional[str]:
        if value is None:
            return None
        device_id = value.strip()
        return device_id or None

    @field_validator("app_scope")
    @classmethod
    def _normalize_scope(cls, value: Optional[str]) -> Optional[str]:
        return _normalize_app_scope(value)

    @model_validator(mode="after")
    def _normalize_empty_selector(self) -> "DeviceTokenUnregisterRequest":
        # Be permissive for clients that call unregister during logout even when
        # no token/device id has been stored locally yet.
        return self


@router.get("", response_model=List[NotificationResponse])
def list_notifications(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    unread_only: bool = Query(False),
    app_scope: Optional[str] = Query(default=None),
    include_global: bool = Query(default=True),
    current_user: User = Depends(deps.get_current_user),
    db: Session = Depends(deps.get_db),
):
    """List user notifications with pagination and filtering."""
    return NotificationService.get_user_notifications(
        db,
        current_user.id,
        skip=skip,
        limit=limit,
        unread_only=unread_only,
        app_scope=app_scope,
        include_global=include_global,
    )


@router.get("/me", response_model=List[NotificationResponse])
def read_notifications(
    current_user: User = Depends(deps.get_current_user),
    db: Session = Depends(deps.get_db),
):
    """Customer: fetch in-app notification inbox."""
    return NotificationService.get_user_notifications(db, current_user.id)


@router.patch("/{notification_id:int}/read")
def mark_notification_read(
    notification_id: int,
    current_user: User = Depends(deps.get_current_user),
    db: Session = Depends(deps.get_db),
):
    """Mark a single notification as read."""
    notification = notification_repository.get(db, notification_id)

    if not notification or notification.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="Notification not found")

    notification_repository.mark_as_read(db, notification_id)

    return {"message": "Notification marked as read"}


@router.patch("/read-all")
def mark_all_notifications_read(
    app_scope: Optional[str] = Query(default=None, description="Limit read-all to a specific app scope"),
    include_global: bool = Query(default=True, description="Include app-agnostic notifications"),
    current_user: User = Depends(deps.get_current_user),
    db: Session = Depends(deps.get_db),
):
    """Mark all notifications as read."""
    count = _mark_all_notifications_read(
        db,
        current_user.id,
        app_scope=app_scope,
        include_global=include_global,
    )

    return {"message": f"{count} notifications marked as read", "count": count}


@router.post("/device-token")
def register_device_token(
    request: DeviceTokenRequest,
    current_user: User = Depends(deps.get_current_user),
    db: Session = Depends(deps.get_db),
):
    """Register device token for push notifications."""
    now = datetime.now(UTC)
    resolved_device_id = request.device_id or f"token:{request.token[:48]}"
    supports_app_scope = _supports_app_scope(Device)

    # One token should not stay active across multiple users.
    same_token_any_user = db.exec(
        select(Device).where(Device.fcm_token == request.token)
    ).all()
    for device in same_token_any_user:
        if device.user_id != current_user.id and device.is_active:
            device.is_active = False
            device.last_active_at = now
            db.add(device)

    existing_for_user = db.exec(
        select(Device).where(
            Device.user_id == current_user.id,
            Device.device_id == resolved_device_id,
        )
    ).first()

    if existing_for_user:
        existing_for_user.fcm_token = request.token
        existing_for_user.device_type = request.platform
        if supports_app_scope:
            existing_for_user.app_scope = request.app_scope
        existing_for_user.is_active = True
        existing_for_user.last_active_at = now
        db.add(existing_for_user)
    else:
        existing_same_token = db.exec(
            select(Device).where(
                Device.user_id == current_user.id,
                Device.fcm_token == request.token,
            )
        ).first()
        if existing_same_token:
            existing_same_token.device_id = resolved_device_id
            existing_same_token.device_type = request.platform
            if supports_app_scope:
                existing_same_token.app_scope = request.app_scope
            existing_same_token.is_active = True
            existing_same_token.last_active_at = now
            db.add(existing_same_token)
        else:
            create_kwargs = {
                "user_id": current_user.id,
                "fcm_token": request.token,
                "device_type": request.platform,
                "device_id": resolved_device_id,
                "is_active": True,
                "last_active_at": now,
            }
            if supports_app_scope:
                create_kwargs["app_scope"] = request.app_scope
            db.add(Device(**create_kwargs))

    db.commit()

    return {
        "message": "Device token registered successfully",
        "platform": request.platform,
        "device_id": resolved_device_id,
        "app_scope": request.app_scope if supports_app_scope else None,
    }


@router.delete("/device-token")
def unregister_device_token(
    request: DeviceTokenUnregisterRequest,
    current_user: User = Depends(deps.get_current_user),
    db: Session = Depends(deps.get_db),
):
    """Unregister device token."""
    if not request.token and not request.device_id:
        return {
            "message": "No device selector provided; nothing to unregister",
            "count": 0,
        }

    statement = select(Device).where(Device.user_id == current_user.id)
    if request.token:
        statement = statement.where(Device.fcm_token == request.token)
    if request.device_id:
        statement = statement.where(Device.device_id == request.device_id)
    if request.app_scope and _supports_app_scope(Device):
        statement = statement.where(Device.app_scope == request.app_scope)
    matched_devices = db.exec(statement).all()

    now = datetime.now(UTC)
    for device in matched_devices:
        device.is_active = False
        device.last_active_at = now
        db.add(device)
    db.commit()

    return {
        "message": "Device token unregistered successfully",
        "count": len(matched_devices),
    }


@router.delete("/{notification_id:int}")
def delete_notification(
    notification_id: int,
    current_user: User = Depends(deps.get_current_user),
    db: Session = Depends(deps.get_db),
):
    """Delete a single notification."""
    notification = notification_repository.get(db, notification_id)

    if not notification or notification.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="Notification not found")

    db.delete(notification)
    db.commit()

    return {"message": "Notification deleted"}


@router.delete("")
def clear_all_notifications(
    app_scope: Optional[str] = Query(default=None, description="Limit clear-all to a specific app scope"),
    include_global: bool = Query(default=True, description="Include app-agnostic notifications"),
    current_user: User = Depends(deps.get_current_user),
    db: Session = Depends(deps.get_db),
):
    """Clear notifications for the current user."""
    normalized_scope = _normalize_app_scope(app_scope)
    query = select(Notification).where(Notification.user_id == current_user.id)

    if normalized_scope and _supports_app_scope(Notification):
        if include_global:
            query = query.where(
                (Notification.app_scope == normalized_scope)
                | (Notification.app_scope.is_(None))
            )
        else:
            query = query.where(Notification.app_scope == normalized_scope)

    notifications = db.exec(query).all()

    for notification in notifications:
        db.delete(notification)

    db.commit()

    return {"message": f"{len(notifications)} notifications cleared", "count": len(notifications)}


@admin_router.post("/send", response_model=DataResponse[dict])
def admin_send_notification(
    request: AdminNotificationSendRequest,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_superuser),
):
    """Admin: send push/SMS/email notification to a specific user."""
    if not request.user_id:
        raise HTTPException(status_code=400, detail="user_id is required")

    user = db.get(User, request.user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    NotificationService.send_notification(
        db,
        user,
        request.title,
        request.message,
        request.type,
        request.channel,
    )
    return DataResponse(success=True, data={"message": "Notification sent successfully"})


@admin_router.post("/bulk", response_model=DataResponse[dict])
def admin_bulk_notification(
    request: AdminNotificationSendRequest,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_superuser),
):
    """Admin: bulk notification to filtered user segments."""
    count = NotificationService.send_bulk_notification(
        db,
        request.segment or "all",
        request.title,
        request.message,
        request.type,
        request.channel,
    )
    return DataResponse(success=True, data={"message": f"Broadcasted to {count} users", "recipient_count": count})


@router.get("/unread-count", response_model=UnreadCountResponse)
def get_my_unread_count(
    current_user: User = Depends(deps.get_current_user),
    db: Session = Depends(deps.get_db),
):
    """Get badge count for unread notifications."""
    count = NotificationService.get_unread_count(db, current_user.id)
    return {"unread_count": count}
