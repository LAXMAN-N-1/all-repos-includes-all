"""Reports routes for exporting data to Excel and PDF"""
from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from typing import Optional, Literal
from datetime import date

from app.database import get_db
from app.models.user import User, UserRole
from app.auth.deps import get_current_user
from app.services.reports_service import ReportsService

router = APIRouter(prefix="/api/v1/reports", tags=["Reports"])


def get_reports_service(db: Session = Depends(get_db)) -> ReportsService:
    """Dependency to get reports service instance"""
    return ReportsService(db)


# ============= Inventory Report =============

@router.get("/inventory/export")
async def export_inventory_report(
    format: Literal["excel", "pdf"] = Query("excel", description="Export format"),
    store_id: Optional[int] = Query(None, description="Filter by store ID"),
    current_user: User = Depends(get_current_user),
    service: ReportsService = Depends(get_reports_service)
):
    """
    Export inventory report to Excel or PDF.
    
    - **HQ_ADMIN**: Can export all stores
    - **STORE_ADMIN**: Can export assigned stores only
    """
    if current_user.role.code not in [UserRole.HQ_ADMIN, UserRole.STORE_ADMIN]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    # Store admins can only export their assigned stores
    if current_user.role.code == UserRole.STORE_ADMIN:
        assigned_store_ids = [s.id for s in current_user.assigned_stores]
        if store_id and store_id not in assigned_store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this store")
        if not store_id and assigned_store_ids:
            store_id = assigned_store_ids[0]
    
    try:
        output = service.export_inventory_report(store_id=store_id, format=format)
        
        if format == "pdf":
            return StreamingResponse(
                output,
                media_type="application/pdf",
                headers={"Content-Disposition": "attachment; filename=inventory_report.pdf"}
            )
        return StreamingResponse(
            output,
            media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            headers={"Content-Disposition": "attachment; filename=inventory_report.xlsx"}
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Export failed: {str(e)}")


# ============= Orders Report =============

@router.get("/orders/export")
async def export_orders_report(
    format: Literal["excel", "pdf"] = Query("excel", description="Export format"),
    store_id: Optional[int] = Query(None, description="Filter by store ID"),
    date_from: Optional[date] = Query(None, description="Start date"),
    date_to: Optional[date] = Query(None, description="End date"),
    status: Optional[str] = Query(None, description="Order status filter"),
    current_user: User = Depends(get_current_user),
    service: ReportsService = Depends(get_reports_service)
):
    """
    Export orders report to Excel or PDF.
    
    - **HQ_ADMIN**: Can export all stores
    - **STORE_ADMIN**: Can export assigned stores only
    """
    if current_user.role.code not in [UserRole.HQ_ADMIN, UserRole.STORE_ADMIN]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    # Store admins can only export their assigned stores
    if current_user.role.code == UserRole.STORE_ADMIN:
        assigned_store_ids = [s.id for s in current_user.assigned_stores]
        if store_id and store_id not in assigned_store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this store")
        if not store_id and assigned_store_ids:
            store_id = assigned_store_ids[0]
    
    try:
        output = service.export_orders_report(
            store_id=store_id,
            date_from=date_from,
            date_to=date_to,
            status=status,
            format=format
        )
        
        if format == "pdf":
            return StreamingResponse(
                output,
                media_type="application/pdf",
                headers={"Content-Disposition": "attachment; filename=orders_report.pdf"}
            )
        return StreamingResponse(
            output,
            media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            headers={"Content-Disposition": "attachment; filename=orders_report.xlsx"}
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Export failed: {str(e)}")


# ============= Prescriptions Report =============

@router.get("/prescriptions/export")
async def export_prescriptions_report(
    store_id: Optional[int] = Query(None, description="Filter by store ID"),
    date_from: Optional[date] = Query(None, description="Start date"),
    date_to: Optional[date] = Query(None, description="End date"),
    current_user: User = Depends(get_current_user),
    service: ReportsService = Depends(get_reports_service)
):
    """
    Export prescriptions report to PDF.
    
    - **HQ_ADMIN**: Can export all stores
    - **STORE_ADMIN, PHARMACIST**: Can export assigned stores only
    
    Note: Prescriptions are always exported as PDF for regulatory compliance.
    """
    if current_user.role.code not in [UserRole.HQ_ADMIN, UserRole.STORE_ADMIN, UserRole.PHARMACIST]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    # Non-HQ users can only export their assigned stores
    if current_user.role.code != UserRole.HQ_ADMIN:
        assigned_store_ids = [s.id for s in current_user.assigned_stores]
        if store_id and store_id not in assigned_store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this store")
        if not store_id and assigned_store_ids:
            store_id = assigned_store_ids[0]
    
    try:
        output = service.export_prescriptions_report(
            store_id=store_id,
            date_from=date_from,
            date_to=date_to
        )
        
        return StreamingResponse(
            output,
            media_type="application/pdf",
            headers={"Content-Disposition": "attachment; filename=prescriptions_report.pdf"}
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Export failed: {str(e)}")


# ============= Sales Report =============

@router.get("/sales/export")
async def export_sales_report(
    format: Literal["excel", "pdf"] = Query("excel", description="Export format"),
    store_id: Optional[int] = Query(None, description="Filter by store ID"),
    date_from: Optional[date] = Query(None, description="Start date"),
    date_to: Optional[date] = Query(None, description="End date"),
    current_user: User = Depends(get_current_user),
    service: ReportsService = Depends(get_reports_service)
):
    """
    Export sales report to Excel or PDF.
    
    - **HQ_ADMIN**: Can export all stores
    - **STORE_ADMIN**: Can export assigned stores only
    
    Includes summary totals for sales, tax, and discounts.
    """
    if current_user.role.code not in [UserRole.HQ_ADMIN, UserRole.STORE_ADMIN]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    # Store admins can only export their assigned stores
    if current_user.role.code == UserRole.STORE_ADMIN:
        assigned_store_ids = [s.id for s in current_user.assigned_stores]
        if store_id and store_id not in assigned_store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this store")
        if not store_id and assigned_store_ids:
            store_id = assigned_store_ids[0]
    
    try:
        output = service.export_sales_report(
            store_id=store_id,
            date_from=date_from,
            date_to=date_to,
            format=format
        )
        
        if format == "pdf":
            return StreamingResponse(
                output,
                media_type="application/pdf",
                headers={"Content-Disposition": "attachment; filename=sales_report.pdf"}
            )
        return StreamingResponse(
            output,
            media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            headers={"Content-Disposition": "attachment; filename=sales_report.xlsx"}
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Export failed: {str(e)}")
