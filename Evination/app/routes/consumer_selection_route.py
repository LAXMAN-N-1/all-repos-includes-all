from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.services.consumer_selection_service import ConsumerSelectionService
from app.models.user_m import User
from app.dependencies import get_current_active_user, PermissionChecker

from app.schemas.consumer_schema import (
    ConsumerShortlistedBidResponse,
    ConsumerBidSelectionResponse
)

router = APIRouter(
    prefix="/consumer/selection",
    tags=["Consumer Selection"]
)

# --------------------------------------------------
# GET SHORTLISTED BIDS (TOP 3)
# --------------------------------------------------
@router.get(
    "/events/{event_id}/shortlisted-bids",
    response_model=ConsumerShortlistedBidResponse,
    dependencies=[Depends(PermissionChecker(["event.view"]))],
)
async def get_shortlisted_bids(
    event_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """
    Consumer views top 3 shortlisted vendor bids for an event.
    """
    return ConsumerSelectionService.get_shortlisted_bids(
        db=db,
        event_id=event_id,
        consumer_user=current_user
    )


# --------------------------------------------------
# SELECT WINNING BID
# --------------------------------------------------
@router.post(
    "/events/{event_id}/select/{bid_id}",
    status_code=status.HTTP_200_OK,
    response_model=ConsumerBidSelectionResponse,
    dependencies=[Depends(PermissionChecker(["event.update"]))],
)
async def select_winning_bid(
    event_id: int,
    bid_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """
    Consumer selects the winning vendor bid.
    This confirms the event and creates a vendor order.
    """
    return ConsumerSelectionService.select_winning_bid(
        db=db,
        event_id=event_id,
        bid_id=bid_id,
        consumer_user=current_user
    )
