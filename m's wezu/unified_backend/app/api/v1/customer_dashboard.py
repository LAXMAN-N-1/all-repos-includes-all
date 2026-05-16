"""Customer Dashboard — Aggregated stats for the customer home screen."""

from fastapi import APIRouter, Depends, Response
from sqlmodel import Session, select, func
from app.api import deps
from app.models.user import User
from app.models.rental import Rental
from app.models.financial import Wallet
from app.schemas.common import DataResponse

router = APIRouter()


def _build_customer_dashboard_stats(
    *,
    db: Session,
    user_id: int,
) -> dict:
    """
    Canonical customer dashboard stats payload.
    """
    # Active rental count
    active_count = db.exec(
        select(func.count(Rental.id)).where(
            Rental.user_id == user_id,
            Rental.status == "active",
        )
    ).one() or 0

    # Total rentals (all statuses)
    total_count = db.exec(
        select(func.count(Rental.id)).where(
            Rental.user_id == user_id,
        )
    ).one() or 0

    # Wallet balance
    wallet = db.exec(
        select(Wallet).where(Wallet.user_id == user_id)
    ).first()

    # Carbon savings estimate (~120g CO2 saved per km vs petrol 2-wheeler)
    # Using total_amount as proxy: avg ₹3/km → distance = total / 3
    total_amount_sum = db.exec(
        select(func.sum(Rental.total_amount)).where(
            Rental.user_id == user_id,
            Rental.status == "completed",
        )
    ).one() or 0.0

    # Rough estimate: ₹149/day = ~40km/day → 0.27 km per rupee → 0.12 kg CO2 per km
    estimated_distance_km = float(total_amount_sum) / 3.7  # avg ₹3.7/km
    carbon_saved_kg = round(estimated_distance_km * 0.12, 1)

    return {
        "active_rentals": active_count,
        "total_rentals": total_count,
        "wallet_balance": round(wallet.balance, 2) if wallet else 0.0,
        "reward_points": 0,  # Placeholder for MVP — no loyalty system yet
        "carbon_saved_kg": carbon_saved_kg,
    }


@router.get("/", response_model=DataResponse[dict])
async def get_customer_dashboard(
    current_user: User = Depends(deps.get_current_user),
    db: Session = Depends(deps.get_db),
):
    """
    Canonical customer dashboard endpoint.
    Path: /api/v1/customers/me/dashboard
    """
    data = _build_customer_dashboard_stats(db=db, user_id=current_user.id)
    return DataResponse(success=True, data=data)


@router.get("/stats", deprecated=True)
async def dashboard_stats_legacy(
    response: Response,
    current_user: User = Depends(deps.get_current_user),
    db: Session = Depends(deps.get_db),
):
    """
    Deprecated adapter for legacy clients.
    Successor: /api/v1/customers/me/dashboard
    """
    response.headers["Deprecation"] = "true"
    response.headers["Link"] = '</api/v1/customers/me/dashboard>; rel="successor-version"'
    return _build_customer_dashboard_stats(db=db, user_id=current_user.id)
