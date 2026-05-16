from datetime import UTC, datetime, timedelta
from typing import Any

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.api import deps
from app.models.user import User
from app.schemas.analytics.logistics import LogisticsOverviewResponse
from app.services.analytics.logistics_service import analytics_logistics_service

router = APIRouter()

def _to_legacy_logistics_dashboard_payload(overview: Any) -> dict[str, Any]:
    if hasattr(overview, "model_dump"):
        raw = overview.model_dump()
    elif isinstance(overview, dict):
        raw = overview
    else:
        raw = {}

    delivery = raw.get("delivery_analytics") if isinstance(raw.get("delivery_analytics"), dict) else {}
    route = raw.get("route_analytics") if isinstance(raw.get("route_analytics"), dict) else {}
    driver = raw.get("driver_analytics") if isinstance(raw.get("driver_analytics"), dict) else {}
    order = raw.get("order_analytics") if isinstance(raw.get("order_analytics"), dict) else {}
    charts = raw.get("charts") if isinstance(raw.get("charts"), dict) else {}
    trend_source = charts.get("delivery_time_trend") if isinstance(charts.get("delivery_time_trend"), list) else []

    trend_points: list[dict[str, Any]] = []
    today = datetime.now(UTC).date()
    point_count = len(trend_source)
    for idx, point in enumerate(trend_source):
        if isinstance(point, dict):
            value = point.get("y", 0)
        else:
            value = 0
        day = today - timedelta(days=max(point_count - 1 - idx, 0))
        trend_points.append(
            {
                "date": day.isoformat(),
                "count": float(value or 0),
            }
        )

    return {
        "onTimeRate": float(order.get("delivery_success_rate") or 0.0),
        "avgDeliveryTime": float(route.get("average_delivery_time_min") or 0.0),
        "failedCount": int(delivery.get("failed_deliveries") or 0),
        "fleetRating": float(driver.get("driver_rating_avg") or 0.0),
        "deliveryTrend": trend_points,
    }


@router.get("", include_in_schema=False)
async def get_logistics_overview_legacy(
    period: str = Query("30d", description="Filter period: 7d, 30d, 90d, 365d, weekly, monthly, yearly"),
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.require_driver_or_internal_operator),
):
    """
    Legacy logistics analytics route used by existing dashboard screens.
    Canonical route: /api/v1/analytics/logistics/overview
    """
    overview = await analytics_logistics_service.get_overview(db, period)
    return _to_legacy_logistics_dashboard_payload(overview)


@router.get("/overview", response_model=LogisticsOverviewResponse)
async def get_logistics_overview(
    period: str = Query("30d", description="Filter period: 7d, 30d, 90d, 365d, weekly, monthly, yearly"),
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.require_driver_or_internal_operator)
):
    return await analytics_logistics_service.get_overview(db, period)
