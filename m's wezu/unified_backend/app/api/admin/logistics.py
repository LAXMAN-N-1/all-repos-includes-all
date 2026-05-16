from decimal import Decimal
from fastapi import APIRouter, Body, Depends, HTTPException, Query
from sqlmodel import Session, select, func, desc
from typing import Any, List, Optional
from datetime import datetime, UTC
from app.api import deps
from app.api.v1 import orders as orders_api
from app.core.database import get_db
from app.models.user import User
from app.models.logistics import DeliveryOrder
from app.models.driver_profile import DriverProfile
from app.models.delivery_route import DeliveryRoute, RouteStop
from app.models.order import Order
from app.models.return_request import ReturnRequest
from app.schemas.order import OrderCreate, StatusUpdate
from app.utils.runtime_cache import cached_call, invalidate_cache

router = APIRouter()

# ─── DELIVERY ORDERS ──────────────────────────────────────────────────────────


def _invalidate_order_stats_cache() -> None:
    invalidate_cache("admin-logistics-order-stats")


def _normalize_admin_order_type_for_storage(order_type: Optional[str]) -> Optional[str]:
    if not order_type:
        return None
    normalized = order_type.strip().lower()
    if normalized in {"reverse_logistics", "return", "returns"}:
        return "return"
    if normalized in {"dealer_restock", "customer_delivery", "delivery"}:
        return "delivery"
    return None


def _normalize_admin_order_type_for_legacy_storage(order_type: Optional[str]) -> str:
    if not order_type:
        return "customer_delivery"
    normalized = order_type.strip().lower()
    if normalized in {"reverse_logistics", "return", "returns"}:
        return "reverse_logistics"
    if normalized == "dealer_restock":
        return "dealer_restock"
    if normalized in {"delivery", "customer_delivery"}:
        return "customer_delivery"
    return "customer_delivery"


def _normalize_admin_order_type_for_display(order_type: Optional[str]) -> str:
    normalized = (order_type or "").strip().lower()
    if normalized == "return":
        return "reverse_logistics"
    return "customer_delivery"


def _legacy_order_type_filter_values(order_type: Optional[str]) -> Optional[list[str]]:
    if not order_type:
        return None
    normalized = order_type.strip().lower()
    if normalized in {"customer_delivery", "dealer_restock", "reverse_logistics"}:
        return [normalized]
    if normalized == "delivery":
        return ["customer_delivery", "dealer_restock"]
    if normalized in {"return", "returns"}:
        return ["reverse_logistics"]
    return [normalized]


def _legacy_status_filter_values(status: Optional[str]) -> Optional[list[str]]:
    if not status:
        return None
    normalized = status.strip().lower()
    if normalized in {"pending", "assigned", "in_transit", "delivered", "failed", "cancelled"}:
        return [normalized]

    canonical = orders_api._canonical_order_status(normalized)
    if canonical == "pending":
        return ["pending"]
    if canonical in {"in_transit", "delivered", "failed", "cancelled"}:
        return [canonical]
    return [normalized]


def _normalize_assigned_battery_ids(raw_ids: Any) -> Optional[List[str]]:
    if raw_ids is None:
        return None
    if isinstance(raw_ids, str):
        values = [item.strip() for item in raw_ids.split(",") if item.strip()]
        return values or None
    if isinstance(raw_ids, list):
        values = [str(item).strip() for item in raw_ids if str(item).strip()]
        return values or None
    return None


def _derive_origin_address_from_notes(notes: Optional[str]) -> str:
    raw_notes = (notes or "").strip()
    if raw_notes.lower().startswith("origin:"):
        parsed = raw_notes.split(":", 1)[1].strip()
        if parsed:
            return parsed
    return "Warehouse"


def _canonical_order_status_for_admin_display(order: Order) -> str:
    canonical_status = orders_api._canonical_order_status(order.status)
    if canonical_status == "pending" and order.assigned_driver_id:
        return "assigned"
    return canonical_status or str(order.status or "pending")


def _datetime_to_sort_epoch(value: Optional[datetime]) -> float:
    if value is None:
        return 0.0
    if value.tzinfo is None:
        value = value.replace(tzinfo=UTC)
    return value.timestamp()


def _parse_optional_datetime(value: Any) -> Optional[datetime]:
    if value is None or isinstance(value, datetime):
        return value
    if isinstance(value, str):
        raw = value.strip()
        if not raw:
            return None
        try:
            return datetime.fromisoformat(raw.replace("Z", "+00:00"))
        except ValueError:
            raise HTTPException(status_code=422, detail="Invalid datetime format")
    raise HTTPException(status_code=422, detail="Invalid datetime value")


def _build_driver_name_map(db: Session, driver_profile_ids: set[int]) -> dict[int, str]:
    if not driver_profile_ids:
        return {}

    driver_profiles = db.exec(
        select(DriverProfile).where(DriverProfile.id.in_(driver_profile_ids))
    ).all()
    user_ids = {profile.user_id for profile in driver_profiles if profile.user_id}
    user_map = (
        {u.id: u for u in db.exec(select(User).where(User.id.in_(user_ids))).all()}
        if user_ids
        else {}
    )

    result: dict[int, str] = {}
    for profile in driver_profiles:
        if profile.id is None:
            continue
        user = user_map.get(profile.user_id)
        name = (profile.name or "").strip() or (user.full_name if user else "Unknown")
        result[profile.id] = name
    return result

def _parse_battery_ids(raw: Optional[str]) -> List[str]:
    if not raw:
        return []
    raw_str = str(raw).strip()
    if raw_str.startswith('[') and raw_str.endswith(']'):
        try:
            import json
            parsed = json.loads(raw_str)
            if isinstance(parsed, list):
                return [str(x) for x in parsed]
        except Exception:
            pass
    return [x.strip() for x in raw_str.split(',') if x.strip()]

@router.get("/orders")
def list_delivery_orders(
    skip: int = 0, limit: int = 50,
    status: Optional[str] = None,
    order_type: Optional[str] = None,
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    canonical_statement = select(Order)
    normalized_status = (status or "").strip().lower()
    canonical_status = orders_api._canonical_order_status(status) if status else ""
    if status:
        if normalized_status == "assigned":
            canonical_statement = canonical_statement.where(
                Order.status.in_(orders_api._status_aliases_for("pending"))
            ).where(Order.assigned_driver_id.is_not(None))
        elif canonical_status == "pending":
            canonical_statement = canonical_statement.where(
                Order.status.in_(orders_api._status_aliases_for("pending"))
            ).where(Order.assigned_driver_id.is_(None))
        else:
            canonical_statement = canonical_statement.where(
                Order.status.in_(orders_api._status_aliases_for(canonical_status))
            )
    normalized_order_type = _normalize_admin_order_type_for_storage(order_type)
    if normalized_order_type:
        canonical_statement = canonical_statement.where(Order.type == normalized_order_type)

    legacy_statement = select(DeliveryOrder)
    legacy_status_values = _legacy_status_filter_values(status)
    if legacy_status_values:
        legacy_statement = legacy_statement.where(DeliveryOrder.status.in_(legacy_status_values))
    legacy_order_type_values = _legacy_order_type_filter_values(order_type)
    if legacy_order_type_values:
        legacy_statement = legacy_statement.where(DeliveryOrder.order_type.in_(legacy_order_type_values))

    canonical_total = int(
        db.exec(select(func.count()).select_from(canonical_statement.subquery())).one() or 0
    )
    legacy_total = int(
        db.exec(select(func.count()).select_from(legacy_statement.subquery())).one() or 0
    )
    total = canonical_total + legacy_total

    fetch_size = max(skip + limit, 1)
    canonical_orders = db.exec(
        canonical_statement.order_by(desc(Order.order_date)).limit(fetch_size)
    ).all()
    legacy_orders = db.exec(
        legacy_statement.order_by(desc(DeliveryOrder.created_at)).limit(fetch_size)
    ).all()

    canonical_driver_profile_ids = {
        order.assigned_driver_id for order in canonical_orders if order.assigned_driver_id
    }
    canonical_driver_name_map = _build_driver_name_map(db, canonical_driver_profile_ids)

    legacy_driver_user_ids = {
        order.assigned_driver_id for order in legacy_orders if order.assigned_driver_id
    }
    legacy_driver_user_map = (
        {u.id: u for u in db.exec(select(User).where(User.id.in_(legacy_driver_user_ids))).all()}
        if legacy_driver_user_ids
        else {}
    )

    merged_orders = []
    for order in canonical_orders:
        created_at = order.order_date or order.updated_at
        merged_orders.append(
            {
                "__sort_epoch": _datetime_to_sort_epoch(created_at),
                "id": order.id,
                "order_type": _normalize_admin_order_type_for_display(order.type),
                "status": _canonical_order_status_for_admin_display(order),
                "origin_address": _derive_origin_address_from_notes(order.notes),
                "destination_address": order.destination,
                "assigned_driver_id": order.assigned_driver_id,
                "driver_name": (
                    canonical_driver_name_map.get(order.assigned_driver_id, "Unknown")
                    if order.assigned_driver_id
                    else "Unassigned"
                ),
                "scheduled_at": (
                    order.scheduled_slot_start.isoformat()
                    if order.scheduled_slot_start
                    else None
                ),
                "started_at": order.dispatch_date.isoformat() if order.dispatch_date else None,
                "completed_at": order.delivered_at.isoformat() if order.delivered_at else None,
                "otp_verified": bool(order.proof_of_delivery_url),
                "created_at": created_at.isoformat() if created_at else None,
                "priority": order.priority,
                "units": order.units,
                "customer_name": order.customer_name,
                "customer_phone": order.customer_phone,
                "total_value": float(order.total_value) if order.total_value is not None else 0.0,
                "tracking_number": order.tracking_number,
                "proof_of_delivery_url": order.proof_of_delivery_url,
                "proof_of_delivery_notes": order.proof_of_delivery_notes,
                "notes": order.notes,
                "assigned_battery_ids": _parse_battery_ids(order.assigned_battery_ids),
            }
        )

    for order in legacy_orders:
        status_text = order.status.value if hasattr(order.status, "value") else str(order.status)
        order_type_text = (
            order.order_type.value if hasattr(order.order_type, "value") else str(order.order_type)
        )
        created_at = order.created_at or order.updated_at
        merged_orders.append(
            {
                "__sort_epoch": _datetime_to_sort_epoch(created_at),
                "id": order.id,
                "order_type": order_type_text,
                "status": status_text,
                "origin_address": order.origin_address,
                "destination_address": order.destination_address,
                "assigned_driver_id": order.assigned_driver_id,
                "driver_name": (
                    legacy_driver_user_map.get(order.assigned_driver_id).full_name
                    if order.assigned_driver_id and legacy_driver_user_map.get(order.assigned_driver_id)
                    else ("Unknown" if order.assigned_driver_id else "Unassigned")
                ),
                "scheduled_at": order.scheduled_at.isoformat() if order.scheduled_at else None,
                "started_at": order.started_at.isoformat() if order.started_at else None,
                "completed_at": order.completed_at.isoformat() if order.completed_at else None,
                "otp_verified": order.otp_verified,
                "created_at": created_at.isoformat() if created_at else None,
                "priority": "normal",
                "units": 1,
                "customer_name": "Unknown",
                "customer_phone": None,
                "total_value": 0.0,
                "tracking_number": None,
                "proof_of_delivery_url": None,
                "proof_of_delivery_notes": None,
                "notes": order.notes if hasattr(order, 'notes') else None,
                "assigned_battery_ids": _parse_battery_ids(order.battery_ids_json if hasattr(order, 'battery_ids_json') else None),
            }
        )

    merged_orders.sort(key=lambda item: item["__sort_epoch"], reverse=True)
    paged_orders = merged_orders[skip : skip + max(limit, 0)] if limit > 0 else []
    for order in paged_orders:
        order.pop("__sort_epoch", None)
    return {"orders": paged_orders, "total_count": total}

@router.get("/orders/stats")
def get_order_stats(
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    def _load_stats() -> dict[str, int]:
        total_canonical = int(db.exec(select(func.count(Order.id))).one() or 0)
        total_legacy = int(db.exec(select(func.count(DeliveryOrder.id))).one() or 0)

        pending_canonical = int(
            db.exec(
                select(func.count(Order.id))
                .where(Order.status.in_(orders_api._status_aliases_for("pending")))
                .where(Order.assigned_driver_id.is_(None))
            ).one()
            or 0
        )
        pending_legacy = int(
            db.exec(
                select(func.count(DeliveryOrder.id)).where(DeliveryOrder.status == "pending")
            ).one()
            or 0
        )

        in_transit = int(
            db.exec(
                select(func.count(Order.id)).where(
                    Order.status.in_(orders_api._status_aliases_for("in_transit"))
                )
            ).one()
            or 0
        ) + int(
            db.exec(
                select(func.count(DeliveryOrder.id)).where(DeliveryOrder.status == "in_transit")
            ).one()
            or 0
        )
        delivered = int(
            db.exec(
                select(func.count(Order.id)).where(
                    Order.status.in_(orders_api._status_aliases_for("delivered"))
                )
            ).one()
            or 0
        ) + int(
            db.exec(
                select(func.count(DeliveryOrder.id)).where(DeliveryOrder.status == "delivered")
            ).one()
            or 0
        )
        failed = int(
            db.exec(
                select(func.count(Order.id)).where(
                    Order.status.in_(orders_api._status_aliases_for("failed"))
                )
            ).one()
            or 0
        ) + int(
            db.exec(
                select(func.count(DeliveryOrder.id)).where(DeliveryOrder.status == "failed")
            ).one()
            or 0
        )

        return {
            "total_orders": total_canonical + total_legacy,
            "pending": pending_canonical + pending_legacy,
            "in_transit": in_transit,
            "delivered": delivered,
            "failed": failed,
        }

    return cached_call(
        "admin-logistics-order-stats",
        ttl_seconds=30,
        call=_load_stats,
    )

@router.post("/orders")
def create_delivery_order(
    payload: Optional[dict] = Body(default=None),
    order_type: str = "customer_delivery",
    origin_address: str = "Warehouse",
    destination_address: str = "",
    origin_lat: Optional[float] = None,
    origin_lng: Optional[float] = None,
    dest_lat: Optional[float] = None,
    dest_lng: Optional[float] = None,
    driver_id: Optional[int] = None,
    assigned_battery_ids: Optional[List[str]] = Query(default=None),
    units: int = 1,
    customer_name: str = "Walk-in Customer",
    customer_phone: Optional[str] = None,
    priority: str = "normal",
    total_value: float = 0.0,
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    _invalidate_order_stats_cache()
    candidate = dict(payload) if payload else {}
    if "assigned_battery_ids" not in candidate and assigned_battery_ids:
        candidate["assigned_battery_ids"] = assigned_battery_ids
    if isinstance(candidate.get("assigned_battery_ids"), str):
        candidate["assigned_battery_ids"] = _normalize_assigned_battery_ids(
            candidate.get("assigned_battery_ids")
        )

    requested_order_type = (
        candidate.get("order_type")
        or candidate.get("type")
        or order_type
    )
    normalized_storage_order_type = (
        _normalize_admin_order_type_for_storage(str(requested_order_type))
        if requested_order_type is not None
        else None
    )
    normalized_battery_ids = _normalize_assigned_battery_ids(candidate.get("assigned_battery_ids"))

    should_use_canonical_create = bool(normalized_battery_ids) and normalized_storage_order_type == "delivery"
    if should_use_canonical_create:
        if "destination" not in candidate and candidate.get("destination_address"):
            candidate["destination"] = candidate.get("destination_address")
        if "destination" not in candidate and destination_address:
            candidate["destination"] = destination_address
        if not candidate.get("destination"):
            raise HTTPException(status_code=400, detail="destination_address is required")

        if "type" not in candidate:
            candidate["type"] = "delivery"
        if "units" not in candidate:
            candidate["units"] = units
        if "customer_name" not in candidate:
            candidate["customer_name"] = customer_name
        if "customer_phone" not in candidate:
            candidate["customer_phone"] = customer_phone
        if "priority" not in candidate:
            candidate["priority"] = priority
        if "total_value" not in candidate:
            candidate["total_value"] = Decimal(str(total_value))
        if "assigned_driver_id" not in candidate and candidate.get("driver_id") is not None:
            candidate["assigned_driver_id"] = candidate.get("driver_id")
        if "assigned_driver_id" not in candidate and driver_id is not None:
            candidate["assigned_driver_id"] = driver_id
        if "latitude" not in candidate:
            candidate["latitude"] = (
                candidate.get("dest_lat")
                if candidate.get("dest_lat") is not None
                else (dest_lat if dest_lat is not None else origin_lat)
            )
        if "longitude" not in candidate:
            candidate["longitude"] = (
                candidate.get("dest_lng")
                if candidate.get("dest_lng") is not None
                else (dest_lng if dest_lng is not None else origin_lng)
            )
        if "notes" not in candidate and (candidate.get("origin_address") or origin_address):
            origin_for_note = candidate.get("origin_address") or origin_address
            candidate["notes"] = f"Origin: {origin_for_note}"
        candidate["assigned_battery_ids"] = normalized_battery_ids

        order_data = OrderCreate.model_validate(candidate)
        created = orders_api.create_order(
            order_data=order_data,
            current_user=current_user,
            tenant_context=deps.TenantContext(
                user=current_user,
                scope="global",
                tenant_id=None,
                auth_subject=None,
            ),
            session=db,
            idempotency_key=None,
        )
        return created.data

    destination = (
        candidate.get("destination_address")
        or candidate.get("destination")
        or destination_address
    )
    if not destination:
        raise HTTPException(status_code=400, detail="destination_address is required")
    origin = candidate.get("origin_address") or origin_address or "Warehouse"

    resolved_driver_id = candidate.get("driver_id")
    if resolved_driver_id is None:
        resolved_driver_id = candidate.get("assigned_driver_id")
    if resolved_driver_id is None:
        resolved_driver_id = driver_id
    if resolved_driver_id is not None:
        try:
            resolved_driver_id = int(resolved_driver_id)
        except (TypeError, ValueError):
            raise HTTPException(status_code=422, detail="driver_id must be an integer")

    legacy_order = DeliveryOrder(
        order_type=_normalize_admin_order_type_for_legacy_storage(str(requested_order_type or "")),
        status="assigned" if resolved_driver_id else "pending",
        origin_address=origin,
        origin_lat=candidate.get("origin_lat", origin_lat),
        origin_lng=candidate.get("origin_lng", origin_lng),
        destination_address=destination,
        destination_lat=(
            candidate.get("dest_lat")
            if candidate.get("dest_lat") is not None
            else candidate.get("destination_lat", dest_lat)
        ),
        destination_lng=(
            candidate.get("dest_lng")
            if candidate.get("dest_lng") is not None
            else candidate.get("destination_lng", dest_lng)
        ),
        assigned_driver_id=resolved_driver_id,
        battery_ids_json=None,
        scheduled_at=_parse_optional_datetime(candidate.get("scheduled_at")),
        otp_verified=bool(candidate.get("otp_verified", False)),
    )
    db.add(legacy_order)
    db.commit()
    db.refresh(legacy_order)
    return legacy_order

@router.put("/orders/{order_id}/status")
def update_order_status(
    order_id: str,
    new_status: str,
    failure_reason: Optional[str] = None,
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    _invalidate_order_stats_cache()
    if order_id.isdigit():
        legacy_order = db.get(DeliveryOrder, int(order_id))
        if legacy_order:
            legacy_status = str(new_status).strip().lower()
            legacy_order.status = legacy_status
            if legacy_status == "in_transit":
                legacy_order.started_at = datetime.now(UTC)
            elif legacy_status == "delivered":
                legacy_order.completed_at = datetime.now(UTC)
            legacy_order.updated_at = datetime.now(UTC)
            db.add(legacy_order)
            db.commit()
            return {"status": "success"}

    raw_status = str(new_status).strip().lower()
    canonical_status = orders_api._canonical_order_status(new_status)
    if raw_status == "assigned":
        order = db.get(Order, order_id)
        if not order:
            raise HTTPException(404, "Order not found")
        order.status = "assigned" if order.assigned_driver_id else "pending"
        order.updated_at = datetime.now(UTC)
        db.add(order)
        db.commit()
        return {"status": "success"}

    resolved_failure_reason = failure_reason
    if canonical_status == "failed" and not resolved_failure_reason:
        resolved_failure_reason = "Failed via admin logistics endpoint"

    try:
        orders_api.update_order_status(
            order_id=order_id,
            status_update=StatusUpdate(
                status=canonical_status,
                failure_reason=resolved_failure_reason,
            ),
            current_user=current_user,
            session=db,
            idempotency_key=None,
        )
    except HTTPException as exc:
        # Backward compatibility fallback: legacy admin endpoint historically forced status updates.
        if exc.status_code != 400:
            raise
        order = db.get(Order, order_id)
        if not order:
            raise
        order.status = canonical_status
        if canonical_status == "in_transit" and order.dispatch_date is None:
            order.dispatch_date = datetime.now(UTC)
        elif canonical_status == "delivered":
            order.delivered_at = datetime.now(UTC)
        elif canonical_status == "failed":
            order.failure_reason = resolved_failure_reason
        order.updated_at = datetime.now(UTC)
        db.add(order)
        db.commit()
    return {"status": "success"}


# ─── DRIVERS ──────────────────────────────────────────────────────────────────

@router.get("/drivers")
def list_drivers(
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    drivers = db.exec(select(DriverProfile)).all()
    user_ids = {d.user_id for d in drivers if d.user_id}
    user_map = {u.id: u for u in db.exec(select(User).where(User.id.in_(user_ids))).all()} if user_ids else {}

    result = []
    for d in drivers:
        user = user_map.get(d.user_id)
        result.append({
            "id": d.id,
            "user_id": d.user_id,
            "name": user.full_name if user else "Unknown",
            "phone": user.phone_number if user else "",
            "license_number": d.license_number,
            "vehicle_type": d.vehicle_type,
            "vehicle_plate": d.vehicle_plate,
            "is_online": d.is_online,
            "current_latitude": d.current_latitude,
            "current_longitude": d.current_longitude,
            "rating": d.rating,
            "total_deliveries": d.total_deliveries,
            "on_time_deliveries": d.on_time_deliveries,
            "created_at": d.created_at.isoformat(),
        })
    return result

@router.get("/drivers/stats")
def get_driver_stats(
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    total = db.exec(select(func.count(DriverProfile.id))).one()
    online = db.exec(select(func.count(DriverProfile.id)).where(DriverProfile.is_online == True)).one()
    avg_rating = db.exec(select(func.coalesce(func.avg(DriverProfile.rating), 0))).one()
    total_deliveries = db.exec(select(func.coalesce(func.sum(DriverProfile.total_deliveries), 0))).one()

    return {
        "total_drivers": total,
        "online_drivers": online,
        "offline_drivers": total - online,
        "avg_rating": round(float(avg_rating), 1),
        "total_deliveries": total_deliveries,
    }


# ─── ROUTES ───────────────────────────────────────────────────────────────────

@router.get("/routes")
def list_routes(
    status: Optional[str] = None,
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    statement = select(DeliveryRoute)
    if status:
        statement = statement.where(DeliveryRoute.status == status)
    routes = db.exec(statement.order_by(desc(DeliveryRoute.created_at))).all()

    driver_profile_ids = {r.driver_id for r in routes if r.driver_id}
    driver_profiles = db.exec(select(DriverProfile).where(DriverProfile.id.in_(driver_profile_ids))).all() if driver_profile_ids else []
    dp_user_map = {dp.id: dp.user_id for dp in driver_profiles}

    d_user_ids = {uid for uid in dp_user_map.values() if uid}
    driver_user_map = {u.id: u for u in db.exec(select(User).where(User.id.in_(d_user_ids))).all()} if d_user_ids else {}
    
    route_ids = [r.id for r in routes]
    all_stops = db.exec(select(RouteStop).where(RouteStop.route_id.in_(route_ids)).order_by(RouteStop.stop_sequence)).all() if route_ids else []
    stops_map = {}
    for s in all_stops:
        if s.route_id not in stops_map: stops_map[s.route_id] = []
        stops_map[s.route_id].append(s)

    result = []
    for r in routes:
        driver_name = "Unknown"
        dp_uid = dp_user_map.get(r.driver_id)
        if dp_uid:
            user = driver_user_map.get(dp_uid)
            driver_name = user.full_name if user else "Unknown"

        stops = stops_map.get(r.id, [])
        result.append({
            "id": r.id,
            "route_name": r.route_name,
            "driver_id": r.driver_id,
            "driver_name": driver_name,
            "status": r.status,
            "total_stops": r.total_stops,
            "completed_stops": r.completed_stops,
            "estimated_distance_km": r.estimated_distance_km,
            "estimated_duration_minutes": r.estimated_duration_minutes,
            "created_at": r.created_at.isoformat(),
            "stops": [{"id": s.id, "sequence": s.stop_sequence, "address": s.address, "status": s.status, "type": s.stop_type} for s in stops],
        })
    return result


# ─── RETURNS ──────────────────────────────────────────────────────────────────

@router.get("/returns")
def list_returns(
    status: Optional[str] = None,
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    statement = select(ReturnRequest)
    if status:
        statement = statement.where(ReturnRequest.status == status)
    returns = db.exec(statement.order_by(desc(ReturnRequest.created_at))).all()

    user_ids = {r.user_id for r in returns if r.user_id}
    user_map = {u.id: u for u in db.exec(select(User).where(User.id.in_(user_ids))).all()} if user_ids else {}

    result = []
    for r in returns:
        user = user_map.get(r.user_id)
        result.append({
            "id": r.id,
            "order_id": r.order_id,
            "user_id": r.user_id,
            "user_name": user.full_name if user else "Unknown",
            "reason": r.reason,
            "status": r.status.value if hasattr(r.status, 'value') else str(r.status),
            "refund_amount": r.refund_amount,
            "inspection_notes": r.inspection_notes,
            "created_at": r.created_at.isoformat(),
        })
    return result

@router.get("/returns/stats")
def get_return_stats(
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    total = db.exec(select(func.count(ReturnRequest.id))).one()
    pending = db.exec(select(func.count(ReturnRequest.id)).where(ReturnRequest.status == "pending")).one()
    completed = db.exec(select(func.count(ReturnRequest.id)).where(ReturnRequest.status == "completed")).one()
    total_refund = db.exec(select(func.coalesce(func.sum(ReturnRequest.refund_amount), 0))).one()

    return {
        "total_returns": total,
        "pending": pending,
        "completed": completed,
        "total_refund_amount": round(float(total_refund), 2),
    }

@router.put("/returns/{return_id}/status")
def update_return_status(
    return_id: int,
    new_status: str,
    notes: Optional[str] = None,
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    ret = db.get(ReturnRequest, return_id)
    if not ret:
        raise HTTPException(404, "Return request not found")
    ret.status = new_status
    if notes:
        ret.inspection_notes = notes
    ret.updated_at = datetime.now(UTC)
    db.add(ret)
    db.commit()
    return {"status": "success"}


# ─── LIVE TRACKING ────────────────────────────────────────────────────────────

@router.get("/tracking")
def get_live_tracking(
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    """Get all active deliveries with driver GPS positions."""
    active_orders = db.exec(
        select(DeliveryOrder).where(DeliveryOrder.status.in_(["assigned", "in_transit"]))
    ).all()

    driver_ids = {o.assigned_driver_id for o in active_orders if o.assigned_driver_id}
    driver_user_map = {u.id: u for u in db.exec(select(User).where(User.id.in_(driver_ids))).all()} if driver_ids else {}
    dp_map = {dp.user_id: dp for dp in db.exec(select(DriverProfile).where(DriverProfile.user_id.in_(driver_ids))).all()} if driver_ids else {}

    tracking = []
    for o in active_orders:
        driver_data = None
        if o.assigned_driver_id:
            driver_user = driver_user_map.get(o.assigned_driver_id)
            dp = dp_map.get(o.assigned_driver_id)
            driver_data = {
                "name": driver_user.full_name if driver_user else "Unknown",
                "phone": driver_user.phone_number if driver_user else "",
                "is_online": dp.is_online if dp else False,
                "latitude": dp.current_latitude if dp else None,
                "longitude": dp.current_longitude if dp else None,
                "vehicle_plate": dp.vehicle_plate if dp else "",
            }

        tracking.append({
            "order_id": o.id,
            "order_type": o.order_type.value if hasattr(o.order_type, 'value') else str(o.order_type),
            "status": o.status.value if hasattr(o.status, 'value') else str(o.status),
            "origin": o.origin_address,
            "destination": o.destination_address,
            "origin_lat": o.origin_lat,
            "origin_lng": o.origin_lng,
            "dest_lat": o.destination_lat,
            "dest_lng": o.destination_lng,
            "driver": driver_data,
            "started_at": o.started_at.isoformat() if o.started_at else None,
        })
    return tracking
