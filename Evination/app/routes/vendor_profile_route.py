from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List

from app.dependencies import get_current_active_user, get_db
from app.models.vendor_m import Vendor
from app.models.review_m import Review
from app.models.user_m import User
from app.models.event_m import Event
from app.schemas.vendor_profile_schema import (
    VendorProfileResponse,
    VendorProfileUpdateRequest,
    PortfolioUploadRequest,
    PortfolioResponse,
    VendorReviewItem,
    VendorReviewSummary,
    VendorReviewsResponse
)

router = APIRouter(
    prefix="/vendor/profile",
    tags=["Vendor Profile"]
)


@router.get("/me", response_model=VendorProfileResponse)
def get_my_vendor_profile(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_active_user)
):
    vendor = db.query(Vendor).filter(
        Vendor.user_id == current_user.id
    ).first()

    if not vendor:
        raise HTTPException(404, "Vendor profile not found")

    return vendor


@router.put("/update", response_model=VendorProfileResponse)
def update_vendor(
    payload: VendorProfileUpdateRequest,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_active_user)
):
    vendor = db.query(Vendor).filter(
        Vendor.user_id == current_user.id
    ).first()

    if not vendor:
        raise HTTPException(404, "Vendor profile not found")

    for field, value in payload.dict(exclude_unset=True).items():
        setattr(vendor, field, value)

    db.commit()
    db.refresh(vendor)

    return vendor


@router.post("/portfolio", response_model=PortfolioResponse)
def upload_portfolio(
    payload: PortfolioUploadRequest,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_active_user)
):
    """
    Upload/add portfolio images for the vendor.
    Appends new URLs to existing portfolio.
    """
    vendor = db.query(Vendor).filter(
        Vendor.user_id == current_user.id
    ).first()

    if not vendor:
        raise HTTPException(404, "Vendor profile not found")

    # Get existing portfolio or initialize empty list
    existing_portfolio = vendor.portfolio_urls or []
    
    # Append new URLs (avoid duplicates)
    for url in payload.portfolio_urls:
        if url not in existing_portfolio:
            existing_portfolio.append(url)
    
    vendor.portfolio_urls = existing_portfolio
    db.commit()
    db.refresh(vendor)

    return PortfolioResponse(
        message="Portfolio updated successfully",
        portfolio_urls=vendor.portfolio_urls or []
    )


@router.get("/reviews", response_model=VendorReviewsResponse)
def get_my_reviews(
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(20, ge=1, le=100, description="Maximum number of records"),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_active_user)
):
    """
    Get reviews received by the authenticated vendor.
    Includes summary stats (average rating, total count).
    """
    vendor = db.query(Vendor).filter(
        Vendor.user_id == current_user.id
    ).first()

    if not vendor:
        raise HTTPException(404, "Vendor profile not found")

    # Calculate summary stats
    avg_rating = (
        db.query(func.avg(Review.rating))
        .filter(Review.vendor_id == vendor.id)
        .scalar()
    ) or 0.0

    total_reviews = (
        db.query(func.count(Review.id))
        .filter(Review.vendor_id == vendor.id)
        .scalar()
    ) or 0

    summary = VendorReviewSummary(
        average_rating=round(float(avg_rating), 2),
        total_reviews=total_reviews
    )

    # Get paginated reviews
    reviews = (
        db.query(Review)
        .filter(Review.vendor_id == vendor.id)
        .order_by(Review.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )

    review_items = []
    for r in reviews:
        # Get consumer name
        consumer = db.query(User).filter(User.id == r.consumer_id).first()
        consumer_name = "Anonymous"
        if consumer:
            consumer_name = f"{consumer.first_name} {consumer.last_name}".strip() or consumer.email

        # Get event name if available
        event_name = None
        if r.event_id:
            event = db.query(Event).filter(Event.id == r.event_id).first()
            if event:
                event_name = event.name

        review_items.append(VendorReviewItem(
            id=r.id,
            consumer_name=consumer_name,
            rating=r.rating,
            comment=r.comment,
            event_name=event_name,
            created_at=r.created_at.strftime("%b %d, %Y")
        ))

    return VendorReviewsResponse(
        summary=summary,
        reviews=review_items,
        skip=skip,
        limit=limit
    )

