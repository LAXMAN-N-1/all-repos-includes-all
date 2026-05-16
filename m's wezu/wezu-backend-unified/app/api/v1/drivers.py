from __future__ import annotations

from datetime import UTC, datetime
import secrets
from typing import Any, List, Optional

from fastapi import APIRouter, Body, Depends, HTTPException, Query, Request, status
from pydantic import BaseModel, Field
from sqlmodel import Session, select

from app.api import deps
from app.core.security import get_password_hash
from app.db.session import get_session
from app.models.driver_profile import DriverProfile
from app.models.logistics import DeliveryOrder
from app.models.rbac import Role, UserRole
from app.models.user import User, UserStatus
from app.schemas.common import DataResponse
from app.services.driver_service import DriverService

router = APIRouter()

class DriverProfileCreate(BaseModel):
    license_number: str
    vehicle_type: str # e.g., "bike", "scooter", "truck"
    vehicle_plate: str


class DriverCompatCreate(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    phone_number: str = Field(min_length=5, max_length=32)
    vehicle_type: str = Field(min_length=1, max_length=128)
    vehicle_plate: str = Field(min_length=1, max_length=64)
    license_number: Optional[str] = Field(default=None, max_length=128)
    status: Optional[str] = Field(default="available", max_length=64)


class DriverCompatUpdate(BaseModel):
    name: Optional[str] = Field(default=None, min_length=1, max_length=255)
    phone_number: Optional[str] = Field(default=None, min_length=5, max_length=32)
    vehicle_type: Optional[str] = Field(default=None, min_length=1, max_length=128)
    vehicle_plate: Optional[str] = Field(default=None, min_length=1, max_length=64)
    license_number: Optional[str] = Field(default=None, min_length=1, max_length=128)
    status: Optional[str] = Field(default=None, min_length=1, max_length=64)


def _normalize_phone(phone_number: str) -> str:
    normalized = phone_number.strip().replace(" ", "")
    if normalized.startswith("+"):
        digits = normalized[1:]
        if digits.isdigit():
            return normalized
    if normalized.isdigit():
        return normalized
    return phone_number.strip()


def _is_online_status(raw_status: Optional[str]) -> bool:
    normalized = (raw_status or "").strip().lower().replace("-", "_")
    return normalized not in {"", "offline", "inactive", "suspended"}


def _frontend_status(profile: DriverProfile) -> str:
    profile_status = (profile.status or "").strip().lower().replace("-", "_")
    if profile_status in {"available", "on_route", "busy", "break_time", "offline"}:
        return profile_status
    if profile.is_online:
        return "available"
    return "offline"


def _serialize_driver(profile: DriverProfile, user: Optional[User]) -> dict[str, Any]:
    display_name = (
        (profile.name or "").strip()
        or (user.full_name.strip() if user and user.full_name else "")
        or f"Driver #{profile.id}"
    )
    phone_number = (
        (profile.phone_number or "").strip()
        or (user.phone_number.strip() if user and user.phone_number else "")
    )

    return {
        "id": profile.id,
        "name": display_name,
        "phone_number": phone_number,
        "status": _frontend_status(profile),
        "vehicle_type": profile.vehicle_type or "",
        "vehicle_plate": profile.vehicle_plate or "",
        "current_lat": float(profile.current_latitude or 0.0),
        "current_lng": float(profile.current_longitude or 0.0),
        "current_battery_level": int(profile.current_battery_level or 0),
        "completed_deliveries": int(profile.total_deliveries or 0),
        "rating": float(profile.rating or 0.0),
        "location_accuracy": float(profile.location_accuracy or 0.0),
    }


def _load_driver_user(session: Session, profile: DriverProfile) -> Optional[User]:
    if not profile.user_id:
        return None
    return session.get(User, profile.user_id)


def _get_driver_profile_or_404(session: Session, driver_id: int) -> DriverProfile:
    profile = session.get(DriverProfile, driver_id)
    if not profile:
        raise HTTPException(status_code=404, detail="Driver profile not found")
    return profile

@router.post("/onboard", response_model=DataResponse[DriverProfile])
def onboard_driver(
    profile_in: DriverProfileCreate,
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(get_session)
):
    """
    Onboard a new driver.
    Creates a DriverProfile linked to the current user.
    """
    # 1. Check if profile already exists
    existing_profile = DriverService.get_profile(session, current_user.id)
    if existing_profile:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail="Driver profile already exists for this user"
        )
    
    # 2. Create Profile
    try:
        profile = DriverService.create_profile(session, current_user.id, profile_in.model_dump())
        
        # 3. Assign 'Driver' role if not present
        from app.models.rbac import Role, UserRole
        
        driver_role = session.exec(select(Role).where(Role.name == "driver")).first()
        
        if driver_role:
            # Check existence in link table directly
            existing_link = session.exec(
                select(UserRole).where(
                    UserRole.user_id == current_user.id,
                    UserRole.role_id == driver_role.id
                )
            ).first()
            
            if not existing_link:
                # Add new link
                new_link = UserRole(user_id=current_user.id, role_id=driver_role.id)
                session.add(new_link)
                session.commit()
            
        return DataResponse(data=profile, message="Driver onboarded successfully")
        
    except Exception as e:
        # Check for unique violation (user already has profile)
        if "unique constraint" in str(e).lower() and "driver_profiles" in str(e).lower():
             raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST, 
                detail="Driver profile already exists"
            )
            
        # If it's the role uniqueness violation, we can ignore it as the goal is achieved
        if "unique constraint" in str(e).lower() and "user_roles" in str(e).lower():
            # Role already exists, which is fine
            return DataResponse(data=profile, message="Driver onboarded successfully (Role already assigned)")

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create driver profile"
        )

@router.get("/me", response_model=DataResponse[DriverProfile])
def get_my_driver_profile(
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(get_session)
):
    """Get current user's driver profile."""
    profile = DriverService.get_profile(session, current_user.id)
    if not profile:
        raise HTTPException(status_code=404, detail="Driver profile not found")
        
    return DataResponse(data=profile)

@router.get("/routes")
def get_assigned_routes(
    request: Request,
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(get_session)
):
    """Get driver's assigned routes."""
    from app.models.delivery_route import DeliveryRoute
    from app.models.roles import RoleEnum
    
    # Check driver profile existence
    profile = DriverService.get_profile(session, current_user.id)
    if not profile:
        raise HTTPException(status_code=404, detail="Driver profile not found")
        
    query = select(DeliveryRoute)
    
    # Auto-filter: Driver context can ONLY see assigned routes
    user_role = getattr(request.state, 'user_role', None)
    if user_role == RoleEnum.DRIVER:
        query = query.where(DeliveryRoute.driver_id == profile.id)
        
    routes = session.exec(query).all()
    # Safe dump since we do not have a response model here setup yet
    return DataResponse(data=routes)


@router.get("/", response_model=DataResponse[List[dict]])
def list_drivers_compat(
    status: Optional[str] = Query(default=None),
    skip: int = Query(default=0, ge=0),
    limit: int = Query(default=50, ge=1, le=500),
    include_pagination: bool = Query(default=False),
    current_user: User = Depends(deps.require_internal_operator),
    session: Session = Depends(get_session),
):
    query = select(DriverProfile).offset(skip).limit(limit)
    normalized_status = (status or "").strip().lower().replace("-", "_")
    if normalized_status:
        if normalized_status in {"offline", "inactive"}:
            query = query.where(DriverProfile.is_online == False)  # noqa: E712
        elif normalized_status in {"available", "on_route", "busy", "break_time"}:
            query = query.where(DriverProfile.is_online == True)  # noqa: E712
        else:
            query = query.where(DriverProfile.status == normalized_status)

    profiles = session.exec(query).all()
    data = [_serialize_driver(profile, _load_driver_user(session, profile)) for profile in profiles]
    if include_pagination:
        return DataResponse(
            data=data,
            message="ok",
        )
    return DataResponse(data=data)


@router.post("/", response_model=DataResponse[dict])
def create_driver_compat(
    payload: DriverCompatCreate,
    current_user: User = Depends(deps.require_internal_operator),
    session: Session = Depends(get_session),
):
    normalized_phone = _normalize_phone(payload.phone_number)
    user = session.exec(select(User).where(User.phone_number == normalized_phone)).first()

    if user is None:
        temporary_password = get_password_hash(secrets.token_urlsafe(24))
        user = User(
            full_name=payload.name.strip(),
            phone_number=normalized_phone,
            hashed_password=temporary_password,
            status=UserStatus.ACTIVE,
            force_password_change=True,
        )
        session.add(user)
        session.commit()
        session.refresh(user)

    existing_profile = session.exec(
        select(DriverProfile).where(DriverProfile.user_id == user.id)
    ).first()
    if existing_profile:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Driver profile already exists for this user",
        )

    driver_role = session.exec(select(Role).where(Role.name == "driver")).first()
    if driver_role:
        user_role_link = session.exec(
            select(UserRole).where(
                UserRole.user_id == user.id,
                UserRole.role_id == driver_role.id,
            )
        ).first()
        if not user_role_link:
            session.add(UserRole(user_id=user.id, role_id=driver_role.id))
        if user.role_id != driver_role.id:
            user.role_id = driver_role.id
            session.add(user)
        session.commit()
        session.refresh(user)

    profile = DriverProfile(
        user_id=user.id,
        name=payload.name.strip(),
        phone_number=normalized_phone,
        status=(payload.status or "available").strip().lower().replace("-", "_"),
        license_number=(payload.license_number or f"TEMP-{user.id}").strip().upper(),
        vehicle_type=payload.vehicle_type.strip(),
        vehicle_plate=payload.vehicle_plate.strip().upper(),
        is_online=_is_online_status(payload.status),
    )
    session.add(profile)
    session.commit()
    session.refresh(profile)

    return DataResponse(
        data=_serialize_driver(profile, user),
        message="Driver created successfully",
    )


@router.get("/{driver_id}", response_model=DataResponse[dict])
def get_driver_compat(
    driver_id: int,
    current_user: User = Depends(deps.require_internal_operator),
    session: Session = Depends(get_session),
):
    profile = _get_driver_profile_or_404(session, driver_id)
    user = _load_driver_user(session, profile)
    return DataResponse(data=_serialize_driver(profile, user))


@router.patch("/{driver_id}", response_model=DataResponse[dict])
def update_driver_compat(
    driver_id: int,
    payload: DriverCompatUpdate,
    current_user: User = Depends(deps.require_internal_operator),
    session: Session = Depends(get_session),
):
    profile = _get_driver_profile_or_404(session, driver_id)
    user = _load_driver_user(session, profile)

    if payload.name is not None:
        profile.name = payload.name.strip()
        if user is not None:
            user.full_name = payload.name.strip()
            session.add(user)
    if payload.phone_number is not None:
        normalized_phone = _normalize_phone(payload.phone_number)
        profile.phone_number = normalized_phone
        if user is not None:
            user.phone_number = normalized_phone
            session.add(user)
    if payload.vehicle_type is not None:
        profile.vehicle_type = payload.vehicle_type.strip()
    if payload.vehicle_plate is not None:
        profile.vehicle_plate = payload.vehicle_plate.strip().upper()
    if payload.license_number is not None:
        profile.license_number = payload.license_number.strip().upper()
    if payload.status is not None:
        normalized_status = payload.status.strip().lower().replace("-", "_")
        profile.status = normalized_status
        profile.is_online = _is_online_status(normalized_status)

    session.add(profile)
    session.commit()
    session.refresh(profile)
    if user is not None:
        session.refresh(user)

    return DataResponse(data=_serialize_driver(profile, user))


@router.put("/{driver_id}/status", response_model=DataResponse[dict])
def update_driver_status_compat(
    driver_id: int,
    payload: dict[str, Any] = Body(...),
    current_user: User = Depends(deps.require_internal_operator),
    session: Session = Depends(get_session),
):
    profile = _get_driver_profile_or_404(session, driver_id)
    raw_status = payload.get("status")
    if raw_status is None:
        raise HTTPException(status_code=422, detail="status is required")

    normalized_status = str(raw_status).strip().lower().replace("-", "_")
    profile.status = normalized_status
    profile.is_online = _is_online_status(normalized_status)
    session.add(profile)
    session.commit()
    session.refresh(profile)

    user = _load_driver_user(session, profile)
    return DataResponse(data=_serialize_driver(profile, user))


@router.put("/{driver_id}/location", response_model=DataResponse[dict])
def update_driver_location_compat(
    driver_id: int,
    payload: dict[str, Any] = Body(...),
    current_user: User = Depends(deps.require_driver_or_internal_operator),
    session: Session = Depends(get_session),
):
    profile = _get_driver_profile_or_404(session, driver_id)
    deps.require_driver_or_internal_operator(current_user)

    try:
        lat = float(payload.get("lat"))
        lng = float(payload.get("lng"))
    except (TypeError, ValueError):
        raise HTTPException(status_code=422, detail="lat and lng must be valid numbers")

    accuracy_raw = payload.get("accuracy")
    battery_level_raw = payload.get("current_battery_level")

    DriverService.update_location(session, profile.id, lat, lng)
    session.refresh(profile)

    if accuracy_raw is not None:
        try:
            profile.location_accuracy = float(accuracy_raw)
        except (TypeError, ValueError):
            pass
    if battery_level_raw is not None:
        try:
            profile.current_battery_level = float(battery_level_raw)
        except (TypeError, ValueError):
            pass
    profile.last_location_update = datetime.now(UTC)
    session.add(profile)
    session.commit()
    session.refresh(profile)

    user = _load_driver_user(session, profile)
    return DataResponse(data=_serialize_driver(profile, user))


def _parse_iso_datetime(value: Optional[str]) -> Optional[datetime]:
    if not value:
        return None
    raw = value.strip()
    if not raw:
        return None
    if raw.endswith("Z"):
        raw = raw[:-1] + "+00:00"
    parsed = datetime.fromisoformat(raw)
    if parsed.tzinfo is None:
        return parsed.replace(tzinfo=UTC)
    return parsed.astimezone(UTC)


def _timeline_event_from_order(order: DeliveryOrder) -> dict[str, Any]:
    status_value = str(getattr(order.status, "value", order.status)).lower()
    type_map = {
        "pending": "order_created",
        "assigned": "driver_assigned",
        "in_transit": "order_in_transit",
        "delivered": "order_delivered",
        "failed": "order_failed",
        "cancelled": "order_cancelled",
    }
    title_map = {
        "pending": f"Order {order.id} created",
        "assigned": f"Order {order.id} assigned",
        "in_transit": f"Order {order.id} in transit",
        "delivered": f"Order {order.id} delivered",
        "failed": f"Order {order.id} failed",
        "cancelled": f"Order {order.id} cancelled",
    }

    timestamp = (
        order.updated_at
        or order.completed_at
        or order.started_at
        or order.scheduled_at
        or order.created_at
        or datetime.now(UTC)
    )
    if timestamp.tzinfo is None:
        timestamp = timestamp.replace(tzinfo=UTC)

    event_type = type_map.get(status_value, "order_created")
    title = title_map.get(status_value, f"Order {order.id} updated")
    return {
        "id": f"order-{order.id}-{int(timestamp.timestamp())}",
        "type": event_type,
        "title": title,
        "timestamp": timestamp.isoformat(),
        "reference_id": str(order.id),
        "status": status_value,
        "meta": {
            "order_type": str(getattr(order.order_type, "value", order.order_type)),
            "origin_address": order.origin_address,
            "destination_address": order.destination_address,
        },
    }


@router.get("/{driver_id}/timeline", response_model=DataResponse[dict])
def get_driver_timeline_compat(
    driver_id: int,
    skip: int = Query(default=0, ge=0),
    limit: int = Query(default=20, ge=1, le=200),
    from_: Optional[str] = Query(default=None, alias="from"),
    to: Optional[str] = Query(default=None),
    timezone: Optional[str] = Query(default=None),
    event_types: Optional[str] = Query(default=None),
    current_user: User = Depends(deps.require_internal_operator),
    session: Session = Depends(get_session),
):
    profile = _get_driver_profile_or_404(session, driver_id)
    start_at = _parse_iso_datetime(from_)
    end_at = _parse_iso_datetime(to)
    if start_at and end_at and start_at > end_at:
        raise HTTPException(status_code=400, detail="from must be earlier than to")

    allowed_event_types = {
        item.strip().lower()
        for item in (event_types or "").split(",")
        if item.strip()
    }

    orders = session.exec(
        select(DeliveryOrder)
        .where(DeliveryOrder.assigned_driver_id == profile.user_id)
        .order_by(DeliveryOrder.updated_at.desc(), DeliveryOrder.created_at.desc())
    ).all()

    events: list[dict[str, Any]] = []
    for order in orders:
        event = _timeline_event_from_order(order)
        event_time = _parse_iso_datetime(event["timestamp"])
        if start_at and event_time and event_time < start_at:
            continue
        if end_at and event_time and event_time > end_at:
            continue
        if allowed_event_types and event["type"].lower() not in allowed_event_types:
            continue
        events.append(event)

    total = len(events)
    items = events[skip : skip + limit]
    has_more = skip + len(items) < total
    return DataResponse(
        data={
            "driver_id": str(driver_id),
            "items": items,
            "total": total,
            "skip": skip,
            "limit": limit,
            "has_more": has_more,
            "timezone": timezone or "UTC",
        }
    )
