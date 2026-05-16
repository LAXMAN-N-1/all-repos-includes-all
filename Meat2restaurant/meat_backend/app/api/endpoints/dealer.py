from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session

from app import models, schemas
from app.api import deps
from app.api.endpoints import auth, settings, notifications, users
from app.features.orders.api import order_issues
from app.features.stores.api import stores

router = APIRouter()

# --- Dealer Portal Auth Compatibility ---

@router.post("/auth/login", response_model=schemas.Token)
async def dealer_login(
    request: Request,
    db: Session = Depends(deps.get_db),
    username: Optional[str] = None,
    password: Optional[str] = None,
    identity_type: Optional[str] = None
) -> Any:
    """Proxy login to unified auth."""
    return await auth.login(request=request, db=db, username=username, password=password, identity_type=identity_type)

# --- Dealer Portal Settings Compatibility ---

@router.get("/portal/settings/notifications", response_model=schemas.NotificationPreferences)
def get_dealer_notification_prefs(db: Session = Depends(deps.get_db)):
    return settings.get_notification_prefs(db=db)

# --- Dealer Portal Tickets Compatibility ---

@router.get("/portal/tickets", response_model=List[schemas.OrderIssueOut])
def list_dealer_tickets(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    status_filter: Optional[str] = None,
):
    return order_issues.list_order_issues(db=db, skip=skip, limit=limit, status_filter=status_filter)

# --- Dealer Portal Profile Compatibility ---

@router.get("/portal/profile", response_model=schemas.User)
def get_dealer_profile(current_user: models.User = Depends(deps.get_current_active_user)):
    return current_user

# --- Dealer Portal Stations Compatibility ---

@router.get("/portal/stations", response_model=stores.PaginatedStoresResponse)
def list_dealer_stations(
    db: Session = Depends(deps.get_db),
    page: int = 1,
    limit: int = 20,
):
    return stores.list_stores(db=db, page=page, limit=limit)
