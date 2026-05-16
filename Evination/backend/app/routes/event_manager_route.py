from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.schemas.event_manager_schema import (
    EventManagerProfileCreate,
    EventManagerProfileUpdate
)
from app.services.event_manager_service import EventManagerService
from app.dependencies import get_current_active_user, PermissionChecker
from app.models.user_m import User

router = APIRouter(prefix="/event-managers", tags=["Event Managers"])


@router.post(
    "/",
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(PermissionChecker(["event.manager.create"]))]
)
async def create_event_manager_profile(
    profile: EventManagerProfileCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Create event manager profile for a user"""
    return EventManagerService.create_profile(db, profile, current_user)


@router.get(
    "/",
    dependencies=[Depends(PermissionChecker(["event.manager.view"]))]
)
async def get_event_managers(
    availability_status: str = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get all event managers with stats"""
    return EventManagerService.get_managers_with_stats(
        db, current_user.organization_id, availability_status, skip, limit
    )


@router.get(
    "/available",
    dependencies=[Depends(PermissionChecker(["event.manager.view"]))]
)
async def get_available_managers(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get only available event managers"""
    return EventManagerService.get_available_managers(db, current_user.organization_id)


@router.get(
    "/{manager_id}",
    dependencies=[Depends(PermissionChecker(["event.manager.view"]))]
)
async def get_event_manager(
    manager_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get event manager details"""
    manager = EventManagerService.get_manager_by_id(db, manager_id)
    if not manager:
        raise HTTPException(status_code=404, detail="Event manager not found")
    return manager


@router.put(
    "/{manager_id}",
    dependencies=[Depends(PermissionChecker(["event.manager.update"]))]
)
async def update_event_manager_profile(
    manager_id: int,
    profile_update: EventManagerProfileUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Update event manager profile"""
    return EventManagerService.update_profile(db, manager_id, profile_update, current_user)


@router.get(
    "/{manager_id}/events",
    dependencies=[Depends(PermissionChecker(["event.manager.view"]))]
)
async def get_manager_events(
    manager_id: int,
    status: str = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get events assigned to a manager"""
    return EventManagerService.get_manager_events(db, manager_id, status)