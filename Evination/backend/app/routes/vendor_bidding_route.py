from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.schemas.vendor_bidding_schema import VendorBidCreate, VendorBidResponse
from app.services.vendor_bidding_service import VendorBiddingService
from app.dependencies import PermissionChecker, get_current_active_user
from app.models.user_m import User
from app.models.vendor_m import Vendor

router = APIRouter(prefix="/vendor/bids", tags=["Vendor - Bids"])

@router.post(
    "/",
    response_model=VendorBidResponse,
    status_code=status.HTTP_201_CREATED
)
async def submit_bid(
    bid_data: VendorBidCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Role check
    if current_user.role.code != "VENDOR":
        raise HTTPException(status_code=403, detail="Vendor access only")
        
    # Resolve vendor_id from current_user
    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    if not vendor:
        raise HTTPException(status_code=400, detail="User is not a vendor")
        
    service = VendorBiddingService(db)
    return service.submit_bid(vendor.id, bid_data)

@router.get(
    "/my-bids",
    response_model=List[VendorBidResponse]
)
async def get_my_bids(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Role check
    if current_user.role.code != "VENDOR":
        raise HTTPException(status_code=403, detail="Vendor access only")
        
    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    if not vendor:
        raise HTTPException(status_code=400, detail="User is not a vendor")
        
    service = VendorBiddingService(db)
    return service.get_my_bids(vendor.id)
@router.get(
    "/marketplace",
    response_model=List[dict]
)
async def get_marketplace(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Role check
    if current_user.role.code != "VENDOR":
        raise HTTPException(status_code=403, detail="Vendor access only")
        
    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    if not vendor:
        raise HTTPException(status_code=400, detail="User is not a vendor")
        
    service = VendorBiddingService(db)
    return service.get_marketplace_events(vendor.id)
@router.get(
    "/lead/{event_id}",
    response_model=dict
)
async def get_lead_detail(
    event_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Role check
    if current_user.role.code != "VENDOR":
        raise HTTPException(status_code=403, detail="Vendor access only")
        
    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    if not vendor:
        raise HTTPException(status_code=400, detail="User is not a vendor")
        
    service = VendorBiddingService(db)
    return service.get_lead_details(vendor.id, event_id)
