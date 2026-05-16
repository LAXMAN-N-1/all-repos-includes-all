# app/routes/vendor_route.py

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.dependencies import get_db, get_current_user
from app.models.vendor_m import Vendor
from app.models.role_m import Role
from app.schemas.vendor_schema import (
    VendorProfileResponse,
    VendorProfileUpdate,
)

router = APIRouter(prefix="/vendor", tags=["Vendor"])


def ensure_vendor(current_user, db: Session):
    role = db.query(Role).filter(Role.id == current_user.role_id).first()
    if not role or role.code != "VENDOR":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only vendor accounts can access this resource",
        )


@router.get("/me", response_model=VendorProfileResponse)
def get_my_vendor_profile(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    ensure_vendor(current_user, db)

    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    if not vendor:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Vendor profile not found",
        )

    return vendor


@router.put("/me", response_model=VendorProfileResponse)
def update_my_vendor_profile(
    payload: VendorProfileUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    ensure_vendor(current_user, db)

    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    if not vendor:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Vendor profile not found",
        )

    data = payload.model_dump(exclude_unset=True)
    for field, value in data.items():
        setattr(vendor, field, value)

    # Update BaseModel tracking field
    vendor.modified_by = current_user.username

    db.add(vendor)
    db.commit()
    db.refresh(vendor)
    return vendor


@router.get("/{vendor_id}", response_model=VendorProfileResponse)
def get_public_vendor_profile(
    vendor_id: int,
    db: Session = Depends(get_db),
    # No auth dependency for public view, or optional/loose auth
):
    """
    Publicly accessible vendor profile details.
    """
    vendor = db.query(Vendor).filter(Vendor.id == vendor_id).first()
    if not vendor:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Vendor not found",
        )
    return vendor
