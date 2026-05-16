from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.dependencies import get_current_active_user, get_db
from app.models.vendor_m import Vendor
from app.schemas.vendor_profile_schema import (
    VendorProfileResponse,
    VendorProfileUpdateRequest
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
