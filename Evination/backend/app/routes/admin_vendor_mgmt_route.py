from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.dependencies import get_db, PermissionChecker, get_current_user
from app.services.admin_vendor_service import AdminVendorService
from app.models.user_m import User
from app.schemas.vendor_schema import VendorRegistrationRequest
from pydantic import BaseModel

router = APIRouter(prefix="/admin/vendors", tags=["Admin Vendor Management"])

class VerifyDocRequest(BaseModel):
    status: str # verified, rejected
    reason: str = None

class TierUpdate(BaseModel):
    tier: str

class CommissionConfig(BaseModel):
    percentage: float
    category_id: int = None

@router.get("/pending", dependencies=[Depends(PermissionChecker(["admin.access"]))])
def get_pending_applications(db: Session = Depends(get_db)):
    service = AdminVendorService(db)
    return service.get_pending_vendors()

@router.get("/", dependencies=[Depends(PermissionChecker(["admin.access"]))])
def get_vendors(status: str = "active", category_id: int = None, db: Session = Depends(get_db)):
    service = AdminVendorService(db)
    return service.get_vendors_by_status(status, category_id)

@router.post("/{vendor_id}/documents/{doc_id}/verify", dependencies=[Depends(PermissionChecker(["admin.access"]))])
def verify_document(
    vendor_id: int,
    doc_id: int,
    data: VerifyDocRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = AdminVendorService(db)
    return service.verify_document(doc_id, data.status, current_user.id, data.reason)

@router.post("/{vendor_id}/approve", dependencies=[Depends(PermissionChecker(["admin.access"]))])
def approve_vendor(
    vendor_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = AdminVendorService(db)
    return service.approve_vendor(vendor_id, current_user.id)

@router.put("/{vendor_id}/tier", dependencies=[Depends(PermissionChecker(["admin.access"]))])
def update_tier(vendor_id: int, data: TierUpdate, db: Session = Depends(get_db)):
    service = AdminVendorService(db)
    return service.update_vendor_tier(vendor_id, data.tier)

@router.put("/{vendor_id}/commission", dependencies=[Depends(PermissionChecker(["admin.access"]))])
def configure_commission(vendor_id: int, data: CommissionConfig, db: Session = Depends(get_db)):
    service = AdminVendorService(db)
    service.configure_commission(vendor_id, data.percentage, data.category_id)
    return {"message": "Commission updated"}

@router.post("/", dependencies=[Depends(PermissionChecker(["admin.access"]))])
def create_vendor(
    data: VendorRegistrationRequest, 
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = AdminVendorService(db)
    return service.create_vendor(data)
