from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.schemas.admin_bidding_schema import (
    BidSummaryResponse,
    BidDetailResponse,
    BidActionRequest,
    BidPricingRequest,
)
import app.schemas.admin_bidding_schema as admin_schemas
from app.services.admin_bidding_service import AdminBiddingService
from app.dependencies import PermissionChecker, get_current_active_user
from app.models.user_m import User

router = APIRouter(prefix="/admin/bidding", tags=["Admin - Bidding"])

@router.get("/customer-view/{event_id}", response_model=admin_schemas.CustomerViewResponse)
def get_customer_view(
    event_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = AdminBiddingService(db)
    return service.get_customer_view(event_id)

@router.get("/events/{event_id}", response_model=admin_schemas.BiddingEventDetailResponse)
def get_event_details(
    event_id: int,
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_active_user)
):
    service = AdminBiddingService(db)
    return service.get_event_details(event_id)

@router.get("/event-bids/{event_id}", response_model=List[admin_schemas.BidDetailResponse])
def get_event_bids(
    event_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = AdminBiddingService(db)
    return service.get_event_bids(event_id)

@router.get("/events", response_model=List[admin_schemas.BiddingDashboardEventResponse])
def get_dashboard_events(
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_active_user)
):
    service = AdminBiddingService(db)
    return service.get_dashboard_events()

@router.get(
    "/", 
    response_model=List[admin_schemas.BidSummaryResponse],
    dependencies=[Depends(PermissionChecker(["bidding.view"]))]
)
def list_bids(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Return all vendor bids for admin dashboard."""
    service = AdminBiddingService(db)
    return service.get_bids(skip, limit)

@router.get(
    "/{bid_id}", 
    response_model=BidDetailResponse,
    dependencies=[Depends(PermissionChecker(["bidding.view"]))]
)
def get_bid_details(
    bid_id: int, 
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Return full details for a single bid."""
    service = AdminBiddingService(db)
    return service.get_bid(bid_id)

@router.post(
    "/{bid_id}/accept",
    dependencies=[Depends(PermissionChecker(["bidding.update"]))]
)
def accept_bid(
    bid_id: int, 
    req: BidActionRequest, 
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Admin accepts a vendor's bid."""
    service = AdminBiddingService(db)
    service.approve_bid(bid_id, req.notes, current_user.username)
    return {"message": "Bid accepted successfully"}

@router.post(
    "/{bid_id}/reject",
    dependencies=[Depends(PermissionChecker(["bidding.update"]))]
)
def reject_bid(
    bid_id: int, 
    req: BidActionRequest, 
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Admin rejects a vendor's bid."""
    service = AdminBiddingService(db)
    service.reject_bid(bid_id, req.notes, current_user.username)
    return {"message": "Bid rejected successfully"}

@router.post(
    "/push-to-customer",
    dependencies=[Depends(PermissionChecker(["bidding.update"]))]
)
def push_bids_to_customer(
    req: admin_schemas.PushBidsRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Admin pushes selected bids to the customer."""
    service = AdminBiddingService(db)
    service.push_bids_to_customer(req.event_id, req.bid_ids)
    return {"message": "Bids pushed to customer successfully"}

@router.put(
    "/{bid_id}/pricing",
    dependencies=[Depends(PermissionChecker(["bidding.update"]))]
)
def update_bid_pricing(
    bid_id: int,
    req: BidPricingRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Update bid pricing (markup/commission) before pushing to customer."""
    service = AdminBiddingService(db)
    service.update_bid_pricing(bid_id, req.final_price, req.platform_commission, req.notes)
    return {"message": "Bid pricing updated"}

@router.post(
    "/finalize-selection/{bid_id}",
    dependencies=[Depends(PermissionChecker(["bidding.update"]))]
)
def finalize_customer_selection(
    bid_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Admin finalizes customer's bid selection and notifies the winning vendor with full event details."""
    service = AdminBiddingService(db)
    service.finalize_customer_selection(bid_id)
    return {"message": "Selection finalized and vendor notified with event details"}
