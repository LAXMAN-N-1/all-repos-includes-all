from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from app.database import get_db
from app.models.user_m import User
from app.models.vendor_m import Vendor
from app.dependencies import get_current_active_user
from app.services.vendor_order_service import VendorOrderService
from app.schemas.vendor_order_schema import (
    VendorOrderListSchema,
    VendorOrderDetailSchema,
    VendorOrderStatusUpdateSchema,
    VendorOrderStatsSchema
)

router = APIRouter(prefix="/vendor/orders", tags=["Vendor Orders"])

@router.get("/stats", response_model=VendorOrderStatsSchema)
def get_order_stats(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """
    Get summary stats for vendor orders.
    """
    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    if not vendor:
        raise HTTPException(status_code=403, detail="User is not a vendor")
        
    return VendorOrderService.get_order_stats(db, vendor.id)

@router.get("/", response_model=List[VendorOrderListSchema])
def get_orders(
    status: Optional[str] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """
    List all orders for the vendor.
    """
    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    if not vendor:
        raise HTTPException(status_code=403, detail="User is not a vendor")
        
    return VendorOrderService.get_orders(db, vendor.id, status, skip, limit)

@router.get("/{id}", response_model=VendorOrderDetailSchema)
def get_order_detail(
    id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """
    Get detailed view of a specific order.
    """
    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    if not vendor:
        raise HTTPException(status_code=403, detail="User is not a vendor")
        
    return VendorOrderService.get_order_detail(db, id, vendor.id)

@router.put("/{id}/status", response_model=dict)
def update_order_status(
    id: int,
    data: VendorOrderStatusUpdateSchema,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """
    Update order status.
    """
    vendor = db.query(Vendor).filter(Vendor.user_id == current_user.id).first()
    if not vendor:
        raise HTTPException(status_code=403, detail="User is not a vendor")
        
    return VendorOrderService.update_order_status(db, id, vendor.id, data)
