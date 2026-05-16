from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.services.review_service import ReviewService
from app.models.user_m import User
from app.dependencies import get_current_active_user, PermissionChecker

from app.schemas.review_schema import (
    ReviewCreate,
    ReviewResponse,
    VendorReviewList
)

router = APIRouter(prefix="/reviews", tags=["Reviews"])

@router.post(
    "/",
    status_code=status.HTTP_201_CREATED,
    response_model=ReviewResponse,
    dependencies=[Depends(PermissionChecker(["review.create"]))], # Assuming this permission exists or is generic
)
async def create_review(
    review_data: ReviewCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """
    Consumer submits a review for a vendor.
    """
    return ReviewService.create_review(db, review_data, current_user.id)

@router.get(
    "/vendor/{vendor_id}",
    response_model=List[VendorReviewList]
)
async def get_vendor_reviews(
    vendor_id: int,
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """
    Get public reviews for a vendor.
    """
    return ReviewService.get_vendor_reviews(db, vendor_id, skip, limit)
