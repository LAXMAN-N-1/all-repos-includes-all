from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.schemas.event_type_schema import EventTypeCreate, EventTypeUpdate
from app.services.event_type_service import EventTypeService
from app.dependencies import get_current_active_user, PermissionChecker
from app.models.user_m import User

router = APIRouter(prefix="/event-types", tags=["Event Types"])


@router.post(
    "/",
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(PermissionChecker(["event.type.create"]))]
)
async def create_event_type(
    event_type: EventTypeCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Create new event type"""
    return EventTypeService.create_event_type(db, event_type, current_user)


@router.get(
    "/",
    dependencies=[Depends(PermissionChecker(["event.type.view"]))]
)
async def get_event_types(
    category_id: int = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get all event types, optionally filtered by category"""
    return EventTypeService.get_event_types(db, category_id, skip, limit)


@router.get(
    "/{type_id}",
    dependencies=[Depends(PermissionChecker(["event.type.view"]))]
)
async def get_event_type(
    type_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get event type by ID"""
    event_type = EventTypeService.get_event_type_by_id(db, type_id)
    if not event_type:
        raise HTTPException(status_code=404, detail="Event type not found")
    return event_type


@router.put(
    "/{type_id}",
    dependencies=[Depends(PermissionChecker(["event.type.update"]))]
)
async def update_event_type(
    type_id: int,
    type_update: EventTypeUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Update event type"""
    return EventTypeService.update_event_type(db, type_id, type_update, current_user)


@router.delete(
    "/{type_id}",
    dependencies=[Depends(PermissionChecker(["event.type.delete"]))]
)
async def delete_event_type(
    type_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Soft delete event type"""
    EventTypeService.delete_event_type(db, type_id, current_user)
    return {"message": "Event type deleted successfully"}