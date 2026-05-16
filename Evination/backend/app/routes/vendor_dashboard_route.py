from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.vendor_dashboard_schema import VendorDashboardResponse
from app.services.vendor_dashboard_service import get_vendor_dashboard
from app.dependencies_vendor import get_current_vendor


router = APIRouter(prefix="/vendor", tags=["Vendor Dashboard"])


@router.get("/dashboard", response_model=VendorDashboardResponse)
def vendor_dashboard(
    db: Session = Depends(get_db),
    vendor = Depends(get_current_vendor)
):
    return get_vendor_dashboard(db, vendor.id)
