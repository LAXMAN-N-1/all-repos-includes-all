from datetime import UTC, datetime, timedelta
from typing import Any, Optional

from fastapi import APIRouter, Depends, Header, HTTPException, Query, Request
from sqlmodel import Session, select

from app.api import deps
from app.middleware.rate_limit import limiter
from app.models.battery import Battery
from app.models.custody import BatteryCustodyEvent, StationInventoryBattery
from app.models.rental import Rental
from app.models.rental_event import RentalEvent
from app.models.station import Station
from app.models.user import User
from app.schemas.common import CursorMeta, DataResponse
from app.schemas.rental import RentalInitiateRequest, RentalReturnRequest, RentalResponse
from app.services.audit_service import AuditService
from app.services.custody_service import CustodyService
from app.services.idempotency_service import (
    build_request_fingerprint,
    get_idempotent_replay,
    normalize_idempotency_key,
    record_idempotent_response,
)

router = APIRouter()


def _legacy_tombstone(surface: str, canonical_surface: str) -> None:
    raise HTTPException(
        status_code=410,
        detail=f"'{surface}' is deprecated. Use '{canonical_surface}' instead.",
    )


def _resolve_rental_or_404(
    session: Session,
    *,
    rental_id: int,
    tenant_context: deps.TenantContext,
) -> Rental:
    query = select(Rental).where(Rental.id == int(rental_id), Rental.is_active == True)  # noqa: E712
    if tenant_context.scope == "tenant" and tenant_context.tenant_id is not None:
        query = query.where(
            Rental.start_station_id.in_(
                select(Station.id).where(Station.tenant_id == int(tenant_context.tenant_id))
            )
        )
    rental = session.exec(query.limit(1)).first()
    if rental is None:
        raise HTTPException(status_code=404, detail="Rental not found")
    return rental


def _resolve_station_or_404(
    session: Session,
    *,
    station_id: int,
    tenant_context: deps.TenantContext,
) -> Station:
    station = session.get(Station, int(station_id))
    if station is None:
        raise HTTPException(status_code=404, detail="Station not found")
    if (
        tenant_context.scope == "tenant"
        and tenant_context.tenant_id is not None
        and int(station.tenant_id or 0) != int(tenant_context.tenant_id)
    ):
        raise HTTPException(status_code=403, detail="tenant_scope_mismatch")
    return station


def _select_station_battery_for_rental(
    session: Session,
    *,
    station_id: int,
) -> tuple[Battery, Optional[StationInventoryBattery]]:
    station_row = session.exec(
        select(StationInventoryBattery)
        .where(StationInventoryBattery.station_id == int(station_id))
        .where(StationInventoryBattery.is_active == True)  # noqa: E712
        .where(StationInventoryBattery.status == "IN_STOCK")
        .order_by(StationInventoryBattery.updated_at.asc(), StationInventoryBattery.id.asc())
        .with_for_update(skip_locked=True)
        .limit(1)
    ).first()

    if station_row is not None:
        battery = None
        if station_row.battery_pk is not None:
            battery = session.get(Battery, int(station_row.battery_pk))
        if battery is None:
            battery = session.exec(
                select(Battery).where(Battery.serial_number == station_row.battery_id).limit(1)
            ).first()
        if battery is None:
            raise HTTPException(status_code=409, detail="Station inventory battery reference is stale")
        return battery, station_row

    battery_fallback = session.exec(
        select(Battery)
        .where(Battery.station_id == int(station_id))
        .where(Battery.status.in_(["available", "ready"]))
        .where(Battery.is_active == True)  # noqa: E712
        .order_by(Battery.updated_at.asc(), Battery.id.asc())
        .with_for_update(skip_locked=True)
        .limit(1)
    ).first()
    if battery_fallback is None:
        raise HTTPException(status_code=409, detail="No available station battery found")
    return battery_fallback, None


@router.get("/", response_model=DataResponse[list[RentalResponse]], response_model_exclude_none=True)
def list_rentals(
    request: Request,
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=200),
    status: Optional[str] = Query(default=None),
    actor_context: deps.ActorContext = Depends(deps.get_actor_context),
    tenant_context: deps.TenantContext = Depends(deps.require_tenant_context(allow_global=True)),
    session: Session = Depends(deps.get_db),
):
    del request
    query = select(Rental).where(Rental.is_active == True)  # noqa: E712
    if status:
        query = query.where(Rental.status == str(status).lower())

    if actor_context.role == "customer":
        query = query.where(Rental.user_id == int(actor_context.customer_id or 0))
    elif actor_context.role != "admin":
        raise HTTPException(status_code=403, detail="insufficient_permissions")

    if tenant_context.scope == "tenant" and tenant_context.tenant_id is not None:
        query = query.where(
            Rental.start_station_id.in_(
                select(Station.id).where(Station.tenant_id == int(tenant_context.tenant_id))
            )
        )

    query = query.order_by(Rental.created_at.desc(), Rental.id.desc())
    rows = session.exec(query.offset(skip).limit(limit + 1)).all()
    has_more = len(rows) > limit
    payload = rows[:limit]
    meta = CursorMeta(limit=limit, has_more=has_more, next_cursor=None)
    return DataResponse(success=True, data=payload, meta=meta)


@router.post("/", response_model=DataResponse[RentalResponse], response_model_exclude_none=True)
@limiter.limit("20/minute")
def initiate_rental(
    request: Request,
    payload: RentalInitiateRequest,
    current_user: User = Depends(deps.get_current_user),
    actor_context: deps.ActorContext = Depends(deps.require_actor_role("customer")),
    tenant_context: deps.TenantContext = Depends(deps.require_tenant_context(allow_global=True)),
    session: Session = Depends(deps.get_db),
    idempotency_key: Optional[str] = Header(default=None, alias="Idempotency-Key"),
):
    del request
    body = payload.model_dump(exclude_none=True)
    idempotency_key = normalize_idempotency_key(idempotency_key)
    request_fingerprint = build_request_fingerprint(body)
    request_path = "/rentals"

    replay = get_idempotent_replay(
        session,
        user_id=current_user.id,
        idempotency_key=idempotency_key,
        request_method="POST",
        request_path=request_path,
        request_fingerprint=request_fingerprint,
    )
    if replay is not None:
        return DataResponse(**replay)

    customer_id = int(current_user.id)
    if int(actor_context.customer_id or 0) != customer_id:
        raise HTTPException(status_code=403, detail="customer_scope_mismatch")

    _resolve_station_or_404(
        session,
        station_id=int(payload.station_id),
        tenant_context=tenant_context,
    )

    battery, station_row = _select_station_battery_for_rental(session, station_id=int(payload.station_id))

    if battery.status not in {"available", "ready"}:
        raise HTTPException(status_code=409, detail="Selected battery is no longer available")

    rental = Rental(
        user_id=customer_id,
        battery_id=int(battery.id),
        start_station_id=int(payload.station_id),
        start_time=datetime.now(UTC),
        expected_end_time=datetime.now(UTC) + timedelta(days=max(1, int(payload.duration_days))),
        status="active",
        total_amount=0.0,
        security_deposit=0.0,
    )
    session.add(rental)
    session.flush()

    battery.status = "rented"
    battery.current_user_id = customer_id
    battery.station_id = None
    battery.location_type = "customer"
    battery.location_id = None
    battery.updated_at = datetime.now(UTC)
    session.add(battery)

    if station_row is not None:
        station_row.status = "RENTED"
        station_row.is_active = False
        station_row.deleted_at = datetime.now(UTC)
        station_row.updated_at = datetime.now(UTC)
        session.add(station_row)

    session.add(
        RentalEvent(
            rental_id=int(rental.id),
            event_type="rental_started",
            station_id=int(payload.station_id),
            battery_id=int(battery.id),
            description="Rental initiated with station-driven auto allocation",
        )
    )

    CustodyService.record_battery_event(
        session,
        tenant_id=(int(tenant_context.tenant_id) if tenant_context.scope == "tenant" and tenant_context.tenant_id is not None else None),
        rental_id=int(rental.id),
        battery_id=str(battery.serial_number),
        battery_pk=int(battery.id),
        event_type="RENTAL_STARTED",
        actor_id=customer_id,
        actor_role=actor_context.role,
        customer_id=customer_id,
        station_id=int(payload.station_id),
        from_location_type="station_inventory",
        from_location_id=int(payload.station_id),
        to_location_type="customer",
        to_location_id=customer_id,
        metadata={"duration_days": int(payload.duration_days)},
    )

    AuditService.log_action(
        session,
        action="RENTAL_STARTED",
        resource_type="RENTAL",
        user_id=customer_id,
        actor_id=customer_id,
        actor_role=actor_context.role,
        target_table="rentals",
        target_id=int(rental.id),
        old_value=None,
        new_value={
            "station_id": int(payload.station_id),
            "battery_id": int(battery.id),
            "status": "active",
        },
        old_state=None,
        new_state={
            "station_id": int(payload.station_id),
            "battery_id": int(battery.id),
            "status": "active",
        },
        auto_commit=False,
    )

    response = DataResponse(success=True, data=rental)
    record_idempotent_response(
        session,
        user_id=current_user.id,
        idempotency_key=idempotency_key,
        request_method="POST",
        request_path=request_path,
        request_fingerprint=request_fingerprint,
        response_status_code=200,
        response_payload=response,
    )
    session.commit()
    session.refresh(rental)
    return response


@router.post("/{rental_id}/return", response_model=DataResponse[RentalResponse], response_model_exclude_none=True)
@limiter.limit("20/minute")
def return_rental(
    request: Request,
    rental_id: int,
    payload: RentalReturnRequest,
    current_user: User = Depends(deps.get_current_user),
    actor_context: deps.ActorContext = Depends(deps.require_actor_role("customer")),
    tenant_context: deps.TenantContext = Depends(deps.require_tenant_context(allow_global=True)),
    session: Session = Depends(deps.get_db),
    idempotency_key: Optional[str] = Header(default=None, alias="Idempotency-Key"),
):
    del request
    body = payload.model_dump(exclude_none=True)
    idempotency_key = normalize_idempotency_key(idempotency_key)
    request_fingerprint = build_request_fingerprint(body)
    request_path = f"/rentals/{int(rental_id)}/return"

    replay = get_idempotent_replay(
        session,
        user_id=current_user.id,
        idempotency_key=idempotency_key,
        request_method="POST",
        request_path=request_path,
        request_fingerprint=request_fingerprint,
    )
    if replay is not None:
        return DataResponse(**replay)

    rental = _resolve_rental_or_404(session, rental_id=int(rental_id), tenant_context=tenant_context)
    if rental.status != "active":
        raise HTTPException(status_code=409, detail="Rental is not active")

    if int(actor_context.customer_id or 0) != int(rental.user_id):
        raise HTTPException(status_code=403, detail="customer_scope_mismatch")

    battery = session.exec(
        select(Battery)
        .where(Battery.id == int(rental.battery_id))
        .with_for_update()
        .limit(1)
    ).first()
    if battery is None:
        raise HTTPException(status_code=404, detail="Battery not found")

    return_station_id = int(payload.return_station_id)
    return_station = _resolve_station_or_404(
        session,
        station_id=return_station_id,
        tenant_context=tenant_context,
    )
    old_status = str(rental.status)

    rental.status = "completed"
    rental.end_station_id = return_station_id
    rental.end_time = datetime.now(UTC)
    rental.updated_at = datetime.now(UTC)
    session.add(rental)

    battery.status = "available"
    battery.current_user_id = None
    battery.station_id = return_station_id
    battery.location_type = "station"
    battery.location_id = return_station_id
    battery.updated_at = datetime.now(UTC)
    session.add(battery)

    station_inv = session.exec(
        select(StationInventoryBattery)
        .where(StationInventoryBattery.station_id == return_station_id)
        .where(StationInventoryBattery.battery_id == str(battery.serial_number))
        .limit(1)
    ).first()
    if station_inv is None:
        station_inv = StationInventoryBattery(
            tenant_id=(int(tenant_context.tenant_id) if tenant_context.scope == "tenant" and tenant_context.tenant_id is not None else None),
            station_id=return_station_id,
            source_dealer_id=return_station.dealer_id,
            battery_id=str(battery.serial_number),
            battery_pk=int(battery.id),
            status="IN_STOCK",
            is_active=True,
        )
    else:
        station_inv.source_dealer_id = return_station.dealer_id
        station_inv.battery_pk = int(battery.id)
        station_inv.status = "IN_STOCK"
        station_inv.is_active = True
        station_inv.deleted_at = None
        station_inv.updated_at = datetime.now(UTC)
    session.add(station_inv)

    session.add(
        RentalEvent(
            rental_id=int(rental.id),
            event_type="rental_returned",
            station_id=return_station_id,
            battery_id=int(battery.id),
            description="Rental returned to station",
        )
    )

    CustodyService.record_battery_event(
        session,
        tenant_id=(int(tenant_context.tenant_id) if tenant_context.scope == "tenant" and tenant_context.tenant_id is not None else None),
        rental_id=int(rental.id),
        battery_id=str(battery.serial_number),
        battery_pk=int(battery.id),
        event_type="RENTAL_RETURNED",
        actor_id=int(current_user.id),
        actor_role=actor_context.role,
        customer_id=int(rental.user_id),
        station_id=return_station_id,
        from_location_type="customer",
        from_location_id=int(rental.user_id),
        to_location_type="station_inventory",
        to_location_id=return_station_id,
    )

    AuditService.log_action(
        session,
        action="RENTAL_RETURNED",
        resource_type="RENTAL",
        user_id=int(current_user.id),
        actor_id=int(current_user.id),
        actor_role=actor_context.role,
        target_table="rentals",
        target_id=int(rental.id),
        old_value={"status": old_status},
        new_value={"status": "completed", "return_station_id": return_station_id},
        old_state={"status": old_status},
        new_state={"status": "completed", "return_station_id": return_station_id},
        auto_commit=False,
    )

    response = DataResponse(success=True, data=rental)
    record_idempotent_response(
        session,
        user_id=current_user.id,
        idempotency_key=idempotency_key,
        request_method="POST",
        request_path=request_path,
        request_fingerprint=request_fingerprint,
        response_status_code=200,
        response_payload=response,
    )
    session.commit()
    session.refresh(rental)
    return response


@router.get("/admin/stations/activity", response_model=DataResponse[list[dict[str, Any]]])
def admin_station_activity(
    request: Request,
    station_id: Optional[int] = Query(default=None),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=200),
    actor_context: deps.ActorContext = Depends(deps.require_actor_role("admin")),
    tenant_context: deps.TenantContext = Depends(deps.require_tenant_context(allow_global=True)),
    session: Session = Depends(deps.get_db),
):
    del request, actor_context
    query = select(BatteryCustodyEvent).where(BatteryCustodyEvent.event_type.in_(["RENTAL_STARTED", "RENTAL_RETURNED"]))
    if station_id is not None:
        query = query.where(BatteryCustodyEvent.station_id == int(station_id))
    if tenant_context.scope == "tenant" and tenant_context.tenant_id is not None:
        query = query.where(BatteryCustodyEvent.tenant_id == int(tenant_context.tenant_id))
    query = query.order_by(BatteryCustodyEvent.occurred_at.desc(), BatteryCustodyEvent.id.desc())
    rows = session.exec(query.offset(skip).limit(limit)).all()
    payload = [
        {
            "id": row.id,
            "station_id": row.station_id,
            "battery_id": row.battery_id,
            "event_type": row.event_type,
            "actor_id": row.actor_id,
            "actor_role": row.actor_role,
            "customer_id": row.customer_id,
            "occurred_at": row.occurred_at,
            "metadata": row.metadata_json,
        }
        for row in rows
    ]
    return DataResponse(success=True, data=payload)


# --- Legacy rental surfaces tombstoned after hard cutover ---
@router.get("/active", include_in_schema=False)
def tombstone_active_rentals():
    _legacy_tombstone("/api/v1/rentals/active", "/api/v1/rentals?status=active")


@router.get("/active/current", include_in_schema=False)
def tombstone_active_current():
    _legacy_tombstone("/api/v1/rentals/active/current", "/api/v1/rentals?status=active")


@router.get("/history", include_in_schema=False)
def tombstone_history():
    _legacy_tombstone("/api/v1/rentals/history", "/api/v1/rentals")


@router.post("/{rental_id}/extend", include_in_schema=False)
def tombstone_extend(rental_id: int):
    del rental_id
    _legacy_tombstone("/api/v1/rentals/{rental_id}/extend", "/api/v1/rentals/{rental_id}/return")


@router.post("/{rental_id}/pause", include_in_schema=False)
def tombstone_pause(rental_id: int):
    del rental_id
    _legacy_tombstone("/api/v1/rentals/{rental_id}/pause", "/api/v1/rentals/{rental_id}/return")


@router.post("/{rental_id}/resume", include_in_schema=False)
def tombstone_resume(rental_id: int):
    del rental_id
    _legacy_tombstone("/api/v1/rentals/{rental_id}/resume", "/api/v1/rentals/{rental_id}/return")


@router.get("/{rental_id}/swap-suggestions", include_in_schema=False)
def tombstone_swap_suggestions(rental_id: int):
    del rental_id
    _legacy_tombstone("/api/v1/rentals/{rental_id}/swap-suggestions", "/api/v1/stations")


@router.post("/{rental_id}/swap-request", include_in_schema=False)
def tombstone_swap_request(rental_id: int):
    del rental_id
    _legacy_tombstone("/api/v1/rentals/{rental_id}/swap-request", "/api/v1/rentals/{rental_id}/return")
