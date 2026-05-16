from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.schemas.admin_bidding_schema import CustomerViewResponse, BidActionRequest
from app.services.admin_bidding_service import AdminBiddingService
from app.dependencies import get_current_active_user
from app.models.user_m import User

router = APIRouter(prefix="/customer/bidding", tags=["Customer - Bidding"])

@router.get("/{event_id}", response_model=CustomerViewResponse)
def get_shortlisted_bids(
    event_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Customer views bids shortlisted by admin for their event."""
    service = AdminBiddingService(db)
    # Note: In a real app, verify event_id belongs to current_user
    return service.get_customer_view(event_id)

@router.post("/{bid_id}/accept")
def customer_accept_bid(
    bid_id: int,
    req: BidActionRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Customer accepts a specific shortlisted bid."""
    service = AdminBiddingService(db)
    service.approve_bid(bid_id, req.notes, current_user.username)
    return {"message": "Bid accepted successfully"}
