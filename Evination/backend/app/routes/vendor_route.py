from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.models.vendor_m import Vendor
from app.models.user_m import User
from app.models.role_m import Role
from app.schemas.vendor_schema import VendorProfileResponse, VendorProfileUpdate
from app.dependencies import get_current_user, PermissionChecker, get_current_active_user
from app.services.vendor_service import VendorService

router = APIRouter(prefix="/vendor", tags=["Vendor"])

def ensure_vendor(current_user, db: Session):
    role = db.query(Role).filter(Role.id == current_user.role_id).first()
    if not role or role.code != "VENDOR":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only vendor accounts can access this resource",
        )

# ============================
# VENDOR'S OWN PROFILE
# ============================

@router.get("/me", response_model=VendorProfileResponse)
def get_my_vendor_profile(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    ensure_vendor(current_user, db)
    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    if not vendor:
        raise HTTPException(status_code=404, detail="Vendor profile not found")
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
        raise HTTPException(status_code=404, detail="Vendor profile not found")

    data = payload.model_dump(exclude_unset=True)
    for field, value in data.items():
        setattr(vendor, field, value)

    vendor.modified_by = current_user.username
    db.add(vendor)
    db.commit()
    db.refresh(vendor)
    return vendor

# ============================
# ADMIN MANAGEMENT ENDPOINTS
# ============================

@router.get(
    "/list",  # Changed from root to avoid conflict or confusion
    response_model=List[VendorProfileResponse],
    dependencies=[Depends(PermissionChecker(["vendor.view"]))]
)
async def get_all_vendors(
    status: Optional[str] = None,
    business_type: Optional[str] = None,
    category_id: Optional[int] = None,
    search: Optional[str] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Admin endpoint to list vendors"""
    vendor_service = VendorService(db)
    return vendor_service.get_vendors(status, business_type, category_id, search, skip, limit)

@router.get(
    "/{vendor_id}",
    response_model=VendorProfileResponse,
    dependencies=[Depends(PermissionChecker(["vendor.view"]))]
)
async def get_vendor_details(
    vendor_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Admin endpoint to get vendor details"""
    vendor_service = VendorService(db)
    return vendor_service.get_vendor(vendor_id)

@router.put(
    "/{vendor_id}/status",
    dependencies=[Depends(PermissionChecker(["vendor.update"]))]
)
async def update_vendor_status(
    vendor_id: int,
    status: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Admin endpoint to approve/reject vendor"""
    vendor_service = VendorService(db)
    vendor = vendor_service.update_vendor_status(vendor_id, status, current_user.username)
    return {"message": f"Vendor status updated to {status}", "id": vendor.id}

@router.delete(
    "/{vendor_id}",
    dependencies=[Depends(PermissionChecker(["vendor.delete"]))]
)
async def delete_vendor(
    vendor_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Admin endpoint to delete vendor"""
    vendor_service = VendorService(db)
    vendor_service.delete_vendor(vendor_id, current_user.username)
    return {"message": "Vendor deleted successfully"}
