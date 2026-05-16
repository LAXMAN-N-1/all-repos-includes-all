from datetime import UTC, datetime

from fastapi import APIRouter, Depends, Query, Response
from sqlmodel import Session

from app.api import deps
from app.models.user import User
from app.schemas.common import DataResponse
from app.services.analytics_dashboard_service import AnalyticsDashboardService
from app.services.analytics_service import AnalyticsService
from . import admin, dealer, logistics, customer, reports

router = APIRouter()
router.include_router(admin.router, prefix="/admin", tags=["analytics-admin"])
router.include_router(dealer.router, prefix="/dealer", tags=["analytics-dealer"])
router.include_router(logistics.router, prefix="/logistics", tags=["analytics-logistics"])
router.include_router(customer.router, prefix="/customer", tags=["analytics-customer"])
router.include_router(reports.router, tags=["analytics-reports"])


@router.get("/dashboard", include_in_schema=False, response_model=DataResponse[dict])
def legacy_dashboard_adapter(
    response: Response,
    current_user: User = Depends(deps.get_current_user),
    db: Session = Depends(deps.get_db),
    period: str = Query(default="30d"),
    timezone: str = Query(default="UTC"),
):
    """
    Deprecated adapter.
    Canonical endpoints:
    - /api/v1/admin/analytics/dashboard (internal operators)
    - /api/v1/customers/me/dashboard (customers)
    """
    role_names = deps.get_user_role_names(current_user)
    if role_names & deps.INTERNAL_OPERATOR_ROLE_NAMES:
        response.headers["Link"] = '</api/v1/admin/analytics/dashboard>; rel="successor-version"'
        payload = AnalyticsDashboardService.build_dashboard_payload(
            db,
            timezone_name=timezone,
        )
        if isinstance(payload, dict):
            payload.setdefault("meta", {})
            if isinstance(payload["meta"], dict):
                payload["meta"].setdefault("period", period)
                payload["meta"].setdefault("timezone", timezone)
        response.headers["Deprecation"] = "true"
        return DataResponse(success=True, data=payload)

    response.headers["Link"] = '</api/v1/customers/me/dashboard>; rel="successor-version"'
    response.headers["Deprecation"] = "true"
    payload = AnalyticsService.get_customer_dashboard(current_user.id, db) or {}
    return DataResponse(success=True, data=payload)


@router.get("/recent-activity", include_in_schema=False, response_model=DataResponse[dict])
def legacy_recent_activity_adapter(
    response: Response,
    current_user: User = Depends(deps.get_current_user),
    db: Session = Depends(deps.get_db),
    skip: int = Query(default=0, ge=0),
    limit: int = Query(default=10, ge=1, le=200),
    timezone: str = Query(default="UTC"),
):
    """
    Deprecated adapter.
    Canonical endpoints:
    - /api/v1/admin/analytics/recent-activity (internal operators)
    """
    role_names = deps.get_user_role_names(current_user)
    response.headers["Deprecation"] = "true"
    if role_names & deps.INTERNAL_OPERATOR_ROLE_NAMES:
        response.headers["Link"] = '</api/v1/admin/analytics/recent-activity>; rel="successor-version"'
        page = AnalyticsDashboardService.get_recent_activity(
            db,
            skip=skip,
            limit=limit,
            timezone_name=timezone,
        )
        if isinstance(page, dict):
            items = page.get("items")
            if isinstance(items, list):
                return DataResponse(success=True, data={"items": items})
        return DataResponse(success=True, data={"items": []})

    rental_history = AnalyticsService.get_rental_history_stats(current_user.id, db) or {}
    items = [
        {
            "id": f"user-{current_user.id}-rentals",
            "title": "Rental activity updated",
            "action": "rental_stats_updated",
            "timestamp": datetime.now(UTC).isoformat(),
            "meta": rental_history,
        }
    ]
    return DataResponse(success=True, data={"items": items})
