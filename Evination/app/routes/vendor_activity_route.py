# app/routes/vendor_activity_route.py

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.user_m import User
from app.models.vendor_m import Vendor
from app.dependencies import get_current_active_user
from app.services.vendor_activity_service import VendorActivityService
from app.schemas.vendor_activity_schema import ActivityFeedResponse

router = APIRouter(prefix="/vendor/activity", tags=["Vendor Activity"])


@router.get("", response_model=ActivityFeedResponse)
def get_activity_feed(
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(20, ge=1, le=100, description="Maximum number of records"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """
    Get activity feed for the authenticated vendor.
    Aggregates activities from: Login, Bid Submissions, Orders Received, Payments.
    """
    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    if not vendor:
        raise HTTPException(status_code=403, detail="User is not a vendor")
    
    return VendorActivityService.get_activity_feed(
        db=db,
        vendor_id=vendor.id,
        user_id=current_user.id,
        skip=skip,
        limit=limit
    )
