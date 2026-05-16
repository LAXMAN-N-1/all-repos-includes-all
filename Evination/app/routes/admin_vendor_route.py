# app/routes/admin_vendor_route.py

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Optional
from pydantic import BaseModel

from app.database import get_db
from app.services.admin_vendor_service import AdminVendorService
from app.dependencies import get_current_active_user, PermissionChecker
from app.models.user_m import User


router = APIRouter(prefix="/admin/vendors", tags=["Admin - Vendor Management"])


# Schemas
class VendorApprovalRequest(BaseModel):
    """Empty body for approval"""
    pass


class VendorRejectionRequest(BaseModel):
    """Rejection with reason"""
    reason: str


# Routes
@router.get(
    "/pending",
    dependencies=[Depends(PermissionChecker(["vendor.approve"]))]
)
async def get_pending_vendors(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get all pending vendor registrations for admin review"""
    return AdminVendorService.get_pending_vendors(db, skip, limit)


@router.get(
    "/{vendor_id}",
    dependencies=[Depends(PermissionChecker(["vendor.view"]))]
)
async def get_vendor_details(
    vendor_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get detailed vendor information"""
    return AdminVendorService.get_vendor_details(db, vendor_id)


@router.put(
    "/{vendor_id}/approve",
    dependencies=[Depends(PermissionChecker(["vendor.approve"]))]
)
async def approve_vendor(
    vendor_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Approve a pending vendor registration"""
    return AdminVendorService.approve_vendor(db, vendor_id, current_user)


@router.put(
    "/{vendor_id}/reject",
    dependencies=[Depends(PermissionChecker(["vendor.approve"]))]
)
async def reject_vendor(
    vendor_id: int,
    rejection: VendorRejectionRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Reject a pending vendor registration"""
    return AdminVendorService.reject_vendor(db, vendor_id, rejection.reason, current_user)


@router.get(
    "/",
    dependencies=[Depends(PermissionChecker(["vendor.view"]))]
)
async def get_all_vendors(
    status: Optional[str] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get all vendors with optional status filter"""
    from app.models.vendor_m import Vendor
    from app.models.user_m import User as UserModel
    from app.models.service_m import Service
    
    query = db.query(Vendor).filter(Vendor.inactive == False)
    
    if status:
        query = query.filter(Vendor.status == status)
    
    vendors = query.offset(skip).limit(limit).all()
    
    result = []
    for vendor in vendors:
        user = db.query(UserModel).filter(UserModel.id == vendor.user_id).first()
        
        # Get service names
        services = []
        if vendor.offered_services:
            service_objs = db.query(Service).filter(
                Service.id.in_(vendor.offered_services)
            ).all()
            services = [{"id": s.id, "name": s.name} for s in service_objs]
        
        result.append({
            "id": vendor.id,
            "companyName": vendor.company_name,
            "email": user.email if user else None,
            "phone": vendor.phone,
            "city": vendor.city,
            "state": vendor.state,
            "offeredServices": services,
            "status": vendor.status,
            "rating": float(vendor.rating) if vendor.rating else 0,
            "createdAt": vendor.created_at
        })
    
    return result
