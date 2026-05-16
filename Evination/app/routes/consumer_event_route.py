from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import Optional, List

from app.database import get_db
from app.services.consumer_event_service import ConsumerEventService
from app.models.user_m import User
from app.dependencies import get_current_active_user

from app.schemas.event_schema import (
    EventCreateSchema,
    EventServiceResponse,
    ConsumerEventListSchema
)

router = APIRouter(prefix="/consumer/events", tags=["Consumer Events"])


# --------------------------------------------------
# CREATE EVENT (CONSUMER)
# --------------------------------------------------
@router.post(
    "/",
    status_code=status.HTTP_201_CREATED,
    response_model=dict,
)
async def create_event(
    event_data: EventCreateSchema,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """
    Consumer creates a new event with required services.
    Automatically notifies matched vendors.
    """
    return ConsumerEventService.create_event(db, event_data, current_user)


# --------------------------------------------------
# GET MY EVENTS
# --------------------------------------------------
@router.get(
    "/my-events",
    response_model=List[ConsumerEventListSchema],
)
async def get_my_events(
    status: Optional[str] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """
    Get all events created by the current consumer.
    Optional filter by bidding status.
    """
    return ConsumerEventService.get_my_events(
        db=db,
        consumer_user=current_user,
        status=status,
        skip=skip,
        limit=limit
    )

