from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime

from app.database import get_db
from app.services.bidding_service import BiddingService
from app.models.user_m import User
from app.dependencies import get_current_user as get_current_active_user, PermissionChecker

router = APIRouter(
    prefix="/bidding",
    tags=["Bidding System"]
)

# SCHEMAS
class EventRequestCreate(BaseModel):
    event_type: str
    event_date: str
    city: str
    budget: float
    guest_count: int
    requirements: Optional[str] = None
    sub_category: Optional[str] = None
    location: Optional[str] = None

class BidCreate(BaseModel):
    amount: float
    proposal: str

class CurateAction(BaseModel):
    action: str # 'shortlist' or 'reject'

# ROUTES

# 1. Customer: Create Request
@router.post("/request")
def create_request(
    data: EventRequestCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = BiddingService(db)
    return service.create_event_request(current_user.id, data.dict())

@router.get("/admin/request/{booking_id}/bids", dependencies=[Depends(PermissionChecker(["admin.access"]))])
def get_admin_request_bids(
    booking_id: int,
    db: Session = Depends(get_db)
):
    from app.models.vendor_bid_m import VendorBid
    from app.models.service_request_m import ServiceRequest
    
    srs = db.query(ServiceRequest).filter(ServiceRequest.booking_id == booking_id).all()
    sr_ids = [sr.id for sr in srs]
    
    bids = db.query(VendorBid).filter(
        VendorBid.service_request_id.in_(sr_ids)
    ).all()
    
    return bids

@router.get("/request/{booking_id}/bids")
def get_request_bids(
    booking_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Get bids that are 'sent_to_customer' or 'selected'
    # Link via ServiceRequest?
    # BiddingService helper needed? Or direct query.
    from app.models.vendor_bid_m import VendorBid
    from app.models.service_request_m import ServiceRequest
    
    # 1. Find ServiceRequests for this booking
    srs = db.query(ServiceRequest).filter(ServiceRequest.booking_id == booking_id).all()
    sr_ids = [sr.id for sr in srs]
    
    bids = db.query(VendorBid).filter(
        VendorBid.service_request_id.in_(sr_ids),
        VendorBid.status.in_(['sent_to_customer', 'selected'])
    ).all()
    
    return bids

# 2. Vendor: Get Leads
@router.get("/leads")
def get_leads(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user) # Should be vendor linked
):
    # Mock: return all awaiting bookings
    from app.models.booking_m import Booking, BookingStatus
    return db.query(Booking).filter(Booking.status == BookingStatus.awaiting_vendors).all()

# 3. Vendor: Submit Bid
@router.post("/leads/{booking_id}/bid")
def submit_bid(
    booking_id: int,
    bid: BidCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Determine vendor_id from user
    if not current_user.vendor:
        raise HTTPException(status_code=400, detail="User is not a vendor")
        
    service = BiddingService(db)
    return service.submit_bid(current_user.vendor.id, booking_id, bid.amount, bid.proposal)

# 4. Admin: Curate Bid
@router.post("/bids/{bid_id}/curate", dependencies=[Depends(PermissionChecker(["admin.access"]))])
def curate_bid(
    bid_id: int,
    action: CurateAction,
    db: Session = Depends(get_db)
):
    service = BiddingService(db)
    return service.curate_bid(bid_id, action.action)

# 5. Customer: Select Bid
@router.post("/bids/{bid_id}/select")
def select_bid(
    bid_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = BiddingService(db)
    return service.select_bid(bid_id)
