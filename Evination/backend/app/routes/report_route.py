from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.services.report_service import ReportService
from app.dependencies import PermissionChecker, get_current_active_user
from app.models.user_m import User

router = APIRouter(prefix="/reports", tags=["Reports"])

@router.get(
    "/dashboard-stats",
    dependencies=[Depends(PermissionChecker(["report.view"]))]
)
async def get_dashboard_stats(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = ReportService(db)
    # Fix Schema typo mapping
    stats = service.get_dashboard_stats(current_user.organization_id)
    return {
        "totalEvents": stats["totalEvents"],
        "activeEvents": stats["activeEvents"],
        "completedEvents": stats["completedEvents"],
        "totalBudget": stats["totalBudget"],
        "totalRefenue": stats["totalRevenue"], # Mapping to Schema Typo 'totalRefenue' or fixing schema next
        "totalVendors": stats["totalVendors"],
        "pendingBids": stats["pendingBids"]
    }

@router.get(
    "/dashboard-charts",
    dependencies=[Depends(PermissionChecker(["report.view"]))]
)
async def get_dashboard_charts(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = ReportService(db)
    return service.get_dashboard_charts(current_user.organization_id)

@router.get(
    "/performance",
    dependencies=[Depends(PermissionChecker(["report.view"]))]
)
async def get_performance_report(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = ReportService(db)
    return service.get_performance_report(current_user.organization_id)

@router.get(
    "/financial-analysis",
    dependencies=[Depends(PermissionChecker(["report.view"]))]
)
async def get_financial_report(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = ReportService(db)
    return service.get_financial_report(current_user.organization_id)

@router.get(
    "/profit-loss",
    dependencies=[Depends(PermissionChecker(["report.view"]))]
)
async def get_profit_loss(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = ReportService(db)
    return service.get_profit_report(current_user.organization_id)
