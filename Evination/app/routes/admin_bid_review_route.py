from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.services.admin_bid_review_service import AdminBidReviewService
from app.models.user_m import User
from app.dependencies import get_current_active_user, PermissionChecker

from app.schemas.event_schema import ConsumerEventListSchema
from app.schemas.vendor_bid_schema import (
    AdminEventBidReviewResponse,
    AdminShortlistSchema,
    AdminScoreUpdateSchema,
)

router = APIRouter(
    prefix="/admin/bids",
    tags=["Admin Bid Review"]
)

# ---------------------------------------------------------
# EVENTS WITH SUBMITTED BIDS
# ---------------------------------------------------------
@router.get(
    "/events",
    response_model=List[ConsumerEventListSchema],
    dependencies=[Depends(PermissionChecker(["admin.bid.view"]))],
)
async def get_events_for_review(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """
    Get all events with submitted bids awaiting admin review.
    """
    return AdminBidReviewService.get_events_for_review(
        db=db,
        skip=skip,
        limit=limit,
    )

# ---------------------------------------------------------
# BIDS FOR SINGLE EVENT
# ---------------------------------------------------------
@router.get(
    "/events/{event_id}/bids",
    response_model=AdminEventBidReviewResponse,
    dependencies=[Depends(PermissionChecker(["admin.bid.view"]))],
)
async def get_bids_for_event(
    event_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """
    Get all bids for a specific event with vendor details and auto scores.
    """
    return AdminBidReviewService.get_bids_for_event(
        db=db,
        event_id=event_id,
    )

# ---------------------------------------------------------
# SHORTLIST TOP 3 BIDS
# ---------------------------------------------------------
@router.post(
    "/events/{event_id}/shortlist",
    status_code=status.HTTP_200_OK,
    dependencies=[Depends(PermissionChecker(["admin.bid.update"]))],
)
async def shortlist_top_3_bids(
    event_id: int,
    data: AdminShortlistSchema,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """
    Shortlist top 3 bids for an event.
    Exactly 3 bid IDs must be provided.
    """
    return AdminBidReviewService.shortlist_top_3(
        db=db,
        event_id=event_id,
        data=data,
        admin_user=current_user,
    )

# ---------------------------------------------------------
# UPDATE ADMIN SCORE
# ---------------------------------------------------------
@router.put(
    "/bid/{bid_id}/score",
    status_code=status.HTTP_200_OK,
    dependencies=[Depends(PermissionChecker(["admin.bid.update"]))],
)
async def update_admin_score(
    bid_id: int,
    data: AdminScoreUpdateSchema,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """
    Update admin score and notes for a bid.
    Score must be between 0 and 100.
    """
    return AdminBidReviewService.update_admin_score(
        db=db,
        bid_id=bid_id,
        data=data,
        admin_user=current_user,
    )
