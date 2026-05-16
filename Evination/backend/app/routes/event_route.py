from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.schemas.event_schema import EventCreate, EventUpdate
from app.services.event_service import EventService
from app.dependencies import get_current_active_user, PermissionChecker
from app.models.user_m import User

router = APIRouter(prefix="/events", tags=["Events"])


@router.post(
    "/",
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(PermissionChecker(["event.create"]))]
)
async def create_event(
    event: EventCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Create new event"""
    return EventService.create_event(db, event, current_user)


@router.get(
    "/",
    dependencies=[Depends(PermissionChecker(["event.view"]))]
)
async def get_events(
    status: Optional[str] = None,
    category_id: Optional[int] = None,
    event_type_id: Optional[int] = None,
    manager_id: Optional[int] = None,
    search: Optional[str] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get all events with filters"""
    return EventService.get_events_with_filters(
        db, current_user.organization_id, status, category_id, 
        event_type_id, manager_id, search, skip, limit
    )


@router.get(
    "/stats",
    dependencies=[Depends(PermissionChecker(["event.view"]))]
)
async def get_event_stats(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get event statistics"""
    return EventService.get_event_stats(db, current_user.organization_id)


@router.get(
    "/{event_id}",
    dependencies=[Depends(PermissionChecker(["event.view"]))]
)
async def get_event(
    event_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get event by ID"""
    event = EventService.get_event_by_id(db, event_id, current_user.organization_id)
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    return event


@router.put(
    "/{event_id}",
    dependencies=[Depends(PermissionChecker(["event.update"]))]
)
async def update_event(
    event_id: int,
    event_update: EventUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Update event"""
    return EventService.update_event(db, event_id, event_update, current_user)


@router.delete(
    "/{event_id}",
    dependencies=[Depends(PermissionChecker(["event.delete"]))]
)
async def delete_event(
    event_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Soft delete event"""
    EventService.delete_event(db, event_id, current_user)
    return {"message": "Event deleted successfully"}


@router.post(
    "/{event_id}/assign-manager",
    dependencies=[Depends(PermissionChecker(["event.update"]))]
)
async def assign_manager(
    event_id: int,
    manager_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Assign event manager to event"""
    EventService.assign_manager(db, event_id, manager_id, current_user)
    return {"message": "Manager assigned successfully"}