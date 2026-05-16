from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.services.admin_dashboard_service import AdminDashboardService
from app.schemas.admin_dashboard_schema import FinancialStatsResponse, ActivityFeedResponse
# from app.auth.dependencies import get_current_admin_user # Assuming we have auth

router = APIRouter(prefix="/api/admin/dashboard", tags=["Admin Dashboard"])

@router.get("/financials", response_model=FinancialStatsResponse)
def get_financial_stats(db: Session = Depends(get_db)):
    """
    Get financial statistics (Total Revenue, Total Orders Value)
    """
    return AdminDashboardService.get_financial_stats(db)

@router.get("/activity", response_model=ActivityFeedResponse)
def get_recent_activity(limit: int = 10, db: Session = Depends(get_db)):
    """
    Get recent activity feed (New Events, Orders, Vendors)
    """
    return AdminDashboardService.get_recent_activity(db, limit)
