# app/routes/vendor_payment_route.py

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional

from app.database import get_db
from app.models.user_m import User
from app.models.vendor_m import Vendor
from app.dependencies import get_current_active_user
from app.services.vendor_payment_service import VendorPaymentService
from app.schemas.vendor_payment_schema import (
    PaymentOverviewSchema,
    PaymentListResponse,
    PaymentInvoiceSchema
)

router = APIRouter(prefix="/vendor/payments", tags=["Vendor Payments"])


@router.get("/overview", response_model=PaymentOverviewSchema)
def get_payment_overview(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """
    Get payment overview stats for the vendor.
    Returns total earnings, pending amount, paid amount, and transaction counts.
    """
    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    if not vendor:
        raise HTTPException(status_code=403, detail="User is not a vendor")
    
    return VendorPaymentService.get_payment_overview(db, vendor.id)


@router.get("/list", response_model=PaymentListResponse)
def get_payment_list(
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(20, ge=1, le=100, description="Maximum number of records to return"),
    status: Optional[str] = Query(None, description="Filter by payment status (pending, completed, failed)"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """
    Get paginated list of payments/transactions for the vendor.
    """
    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    if not vendor:
        raise HTTPException(status_code=403, detail="User is not a vendor")
    
    return VendorPaymentService.get_payment_list(db, vendor.id, skip, limit, status)


@router.get("/{id}/invoice", response_model=PaymentInvoiceSchema)
def get_payment_invoice(
    id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """
    Get invoice details for a specific payment.
    Can be used to view or download the invoice.
    """
    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    if not vendor:
        raise HTTPException(status_code=403, detail="User is not a vendor")
    
    return VendorPaymentService.get_payment_invoice(db, id, vendor.id)
