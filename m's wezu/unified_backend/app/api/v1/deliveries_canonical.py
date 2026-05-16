from datetime import UTC, datetime
import json
import uuid
from typing import Any, Literal, Optional

from fastapi import APIRouter, Depends, Header, HTTPException, Query, Request
from sqlmodel import Session, select

from app.api import deps
from app.middleware.rate_limit import limiter
from app.models.battery import Battery
from app.models.custody import DealerMainInventoryBattery, StationInventoryBattery, BatteryCustodyEvent
from app.models.driver_profile import DriverProfile
from app.models.order import Order, OrderBattery
from app.models.station import Station
from app.models.user import User
from app.schemas.common import CursorMeta, DataResponse
from app.schemas.order import (
    DeliveryApproveAction,
    DeliveryCompleteAction,
    DeliveryDispatchAction,
    DeliveryRejectAction,
    OrderCreate,
    OrderRead,
)
from app.services.audit_service import AuditService
from app.services.battery_consistency import normalize_battery_serials
from app.services.custody_service import CustodyService
from app.services.delivery_workflow_service import (
    CANONICAL_ORDER_STATUS_APPROVED,
    CANONICAL_ORDER_STATUS_ASSIGNED_TO_WAREHOUSE,
    CANONICAL_ORDER_STATUS_DELIVERED,
    CANONICAL_ORDER_STATUS_OUT_FOR_DELIVERY,
    CANONICAL_ORDER_STATUS_PENDING_ADMIN_APPROVAL,
    CANONICAL_ORDER_STATUS_REJECTED,
    assign_admin_user_id,
    assert_valid_order_transition,
    canonicalize_order_status,
    select_source_warehouse_id,
)
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


def _resolve_order_or_404(
    session: Session,
    *,
    order_id: str,
    tenant_context: deps.TenantContext,
) -> Order:
    query = select(Order).where(Order.id == str(order_id), Order.is_active == True)  # noqa: E712
    if tenant_context.scope == "tenant" and tenant_context.tenant_id is not None:
        query = query.where(Order.tenant_id == int(tenant_context.tenant_id))
    order = session.exec(query.limit(1)).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order


def _require_actor_read_scope(
    query: Any,
    *,
    actor_context: deps.ActorContext,
) -> Any:
    if actor_context.role == "admin":
        return query
    if actor_context.role == "dealer":
        if actor_context.dealer_id is None:
            raise HTTPException(status_code=403, detail="dealer_scope_missing")
        return query.where(Order.dealer_id == int(actor_context.dealer_id))
    if actor_context.role == "warehouse_operator":
        if actor_context.warehouse_id is None:
            raise HTTPException(status_code=403, detail="warehouse_scope_missing")
        return query.where(Order.source_warehouse_id == int(actor_context.warehouse_id))
    if actor_context.role == "driver":
        if actor_context.driver_id is None:
            raise HTTPException(status_code=403, detail="driver_scope_missing")
        return query.where(Order.driver_id == int(actor_context.driver_id))
    if actor_context.role == "customer":
        if actor_context.customer_id is None:
            raise HTTPException(status_code=403, detail="customer_scope_missing")
        return query.where(Order.customer_id == int(actor_context.customer_id))
    raise HTTPException(status_code=403, detail="insufficient_permissions")


def _assert_mutation_scope(
    *,
    action: str,
    order: Order,
    actor_context: deps.ActorContext,
) -> None:
    if actor_context.role == "admin":
        if action in {"approve", "reject"} and int(order.assigned_admin_id or 0) != int(actor_context.admin_id or 0):
            raise HTTPException(status_code=403, detail="admin_assignment_mismatch")
        return

    if action == "create" and actor_context.role == "dealer":
        return

    if action == "dispatch" and actor_context.role == "warehouse_operator":
        if int(order.source_warehouse_id or 0) != int(actor_context.warehouse_id or 0):
            raise HTTPException(status_code=403, detail="warehouse_assignment_mismatch")
        return

    if action == "complete" and actor_context.role == "driver":
        if int(order.driver_id or 0) != int(actor_context.driver_id or 0):
            raise HTTPException(status_code=403, detail="driver_assignment_mismatch")
        return

    if action == "complete" and actor_context.role == "warehouse_operator":
        if int(order.source_warehouse_id or 0) != int(actor_context.warehouse_id or 0):
            raise HTTPException(status_code=403, detail="warehouse_assignment_mismatch")
        return

    raise HTTPException(status_code=403, detail="insufficient_permissions")


def _persist_order_batteries(
    session: Session,
    *,
    order: Order,
    battery_ids: list[str],
) -> None:
    existing_rows = session.exec(select(OrderBattery).where(OrderBattery.order_id == order.id)).all()
    for row in existing_rows:
        session.delete(row)
    for battery_id in battery_ids:
        session.add(
            OrderBattery(
                order_id=order.id,
                tenant_id=order.tenant_id,
                battery_id=battery_id,
            )
        )


def _load_order_battery_ids(session: Session, order: Order) -> list[str]:
    indexed = session.exec(
        select(OrderBattery.battery_id)
        .where(OrderBattery.order_id == order.id)
        .order_by(OrderBattery.id.asc())
    ).all()
    if indexed:
        return [str(item) for item in indexed]
    raw = str(order.assigned_battery_ids or "").strip()
    if not raw:
        return []
    try:
        parsed = json.loads(raw)
    except json.JSONDecodeError:
        return []
    if not isinstance(parsed, list):
        return []
    normalized = normalize_battery_serials(parsed, field_name="assigned_battery_ids", require_non_empty=False)
    return normalized


def _resolve_driver_profile(session: Session, *, driver_ref: int) -> DriverProfile:
    profile = session.get(DriverProfile, int(driver_ref))
    if profile is not None:
        return profile
    profile = session.exec(
        select(DriverProfile).where(DriverProfile.user_id == int(driver_ref)).limit(1)
    ).first()
    if profile is None:
        raise HTTPException(status_code=404, detail="Driver not found")
    return profile


@router.get("/", response_model=DataResponse[list[OrderRead]], response_model_exclude_none=True)
def list_orders(
    request: Request,
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=500),
    status: Optional[str] = Query(None),
    sort_order: Literal["asc", "desc"] = Query("desc"),
    actor_context: deps.ActorContext = Depends(deps.get_actor_context),
    tenant_context: deps.TenantContext = Depends(deps.require_tenant_context(allow_global=True)),
    session: Session = Depends(deps.get_db),
):
    del request
    query = select(Order).where(Order.is_active == True)  # noqa: E712
    if tenant_context.scope == "tenant" and tenant_context.tenant_id is not None:
        query = query.where(Order.tenant_id == int(tenant_context.tenant_id))
    query = _require_actor_read_scope(query, actor_context=actor_context)
    if status:
        query = query.where(Order.status == canonicalize_order_status(status))
    if sort_order == "asc":
        query = query.order_by(Order.order_date.asc(), Order.id.asc())
    else:
        query = query.order_by(Order.order_date.desc(), Order.id.desc())
    rows = session.exec(query.offset(skip).limit(limit + 1)).all()
    has_more = len(rows) > limit
    payload = rows[:limit]
    meta = CursorMeta(limit=limit, has_more=has_more, next_cursor=None)
    return DataResponse(success=True, data=payload, meta=meta)


@router.get("/{order_id}", response_model=DataResponse[OrderRead], response_model_exclude_none=True)
def get_order(
    order_id: str,
    request: Request,
    actor_context: deps.ActorContext = Depends(deps.get_actor_context),
    tenant_context: deps.TenantContext = Depends(deps.require_tenant_context(allow_global=True)),
    session: Session = Depends(deps.get_db),
):
    del request
    order = _resolve_order_or_404(session, order_id=order_id, tenant_context=tenant_context)
    scoped_query = _require_actor_read_scope(select(Order).where(Order.id == order.id), actor_context=actor_context)
    scoped_order = session.exec(scoped_query.limit(1)).first()
    if not scoped_order:
        raise HTTPException(status_code=404, detail="Order not found")
    return DataResponse(success=True, data=order)


@router.post("/", response_model=DataResponse[OrderRead], response_model_exclude_none=True)
@limiter.limit("30/minute")
def create_order(
    request: Request,
    payload: OrderCreate,
    current_user: User = Depends(deps.get_current_user),
    actor_context: deps.ActorContext = Depends(deps.get_actor_context),
    tenant_context: deps.TenantContext = Depends(deps.require_tenant_context(allow_global=True)),
    session: Session = Depends(deps.get_db),
    idempotency_key: Optional[str] = Header(default=None, alias="Idempotency-Key"),
):
    request_payload = payload.model_dump(exclude_none=True)
    idempotency_key = normalize_idempotency_key(idempotency_key)
    request_fingerprint = build_request_fingerprint(request_payload)

    replay = get_idempotent_replay(
        session,
        user_id=current_user.id,
        idempotency_key=idempotency_key,
        request_method="POST",
        request_path="/deliveries",
        request_fingerprint=request_fingerprint,
    )
    if replay is not None:
        return DataResponse(**replay)

    if actor_context.role not in {"admin", "dealer", "warehouse_operator"}:
        raise HTTPException(status_code=403, detail="insufficient_permissions")

    dealer_id = int(payload.dealer_id or 0)
    if actor_context.role == "dealer":
        if actor_context.dealer_id is None:
            raise HTTPException(status_code=403, detail="dealer_scope_missing")
        dealer_id = int(actor_context.dealer_id)
    if dealer_id <= 0:
        raise HTTPException(status_code=400, detail="dealer_id is required")

    if actor_context.role == "warehouse_operator":
        if actor_context.warehouse_id is None:
            raise HTTPException(status_code=403, detail="warehouse_scope_missing")
        if (
            payload.source_warehouse_id is not None
            and int(payload.source_warehouse_id) != int(actor_context.warehouse_id)
        ):
            raise HTTPException(status_code=403, detail="warehouse_assignment_mismatch")
        source_warehouse_id = int(actor_context.warehouse_id)
    else:
        source_warehouse_id = select_source_warehouse_id(
            session,
            dealer_id=dealer_id,
            explicit_warehouse_id=payload.source_warehouse_id,
        )
    assigned_admin_id = assign_admin_user_id(
        session,
        tenant_id=(int(tenant_context.tenant_id) if tenant_context.scope == "tenant" and tenant_context.tenant_id is not None else None),
    )

    order_id = str(payload.id or f"ORD-{uuid.uuid4().hex[:8].upper()}")
    existing = session.exec(select(Order.id).where(Order.id == order_id).limit(1)).first()
    if existing:
        raise HTTPException(status_code=409, detail="order_id_already_exists")

    battery_ids = normalize_battery_serials(
        payload.assigned_battery_ids or [],
        field_name="assigned_battery_ids",
        require_non_empty=False,
    )
    if payload.units <= 0:
        raise HTTPException(status_code=400, detail="units must be greater than 0")
    if battery_ids and len(battery_ids) != int(payload.units):
        raise HTTPException(status_code=400, detail="units must match assigned_battery_ids length")

    order = Order(
        id=order_id,
        tenant_id=(int(tenant_context.tenant_id) if tenant_context.scope == "tenant" and tenant_context.tenant_id is not None else None),
        status=CANONICAL_ORDER_STATUS_PENDING_ADMIN_APPROVAL,
        priority=str(payload.priority or "normal").lower(),
        units=int(payload.units),
        destination=str(payload.destination).strip(),
        notes=(str(payload.notes).strip() if payload.notes else None),
        customer_name=str(payload.customer_name or "Walk-in Customer").strip(),
        customer_phone=(str(payload.customer_phone).strip() if payload.customer_phone else None),
        total_value=payload.total_value or 0,
        tracking_number=(str(payload.tracking_number).strip().upper() if payload.tracking_number else f"TRK-{order_id}"),
        dealer_id=dealer_id,
        source_warehouse_id=source_warehouse_id,
        created_by_user_id=current_user.id,
        created_by_role=actor_context.role,
        approval_status="pending",
        assigned_admin_id=assigned_admin_id,
        customer_id=None,
        order_date=payload.order_date or datetime.now(UTC),
        updated_at=datetime.now(UTC),
        assigned_battery_ids=(json.dumps(battery_ids) if battery_ids else None),
    )
    session.add(order)
    session.flush()

    _persist_order_batteries(session, order=order, battery_ids=battery_ids)

    for serial in battery_ids:
        battery = session.exec(select(Battery).where(Battery.serial_number == serial).limit(1)).first()
        CustodyService.record_battery_event(
            session,
            tenant_id=order.tenant_id,
            order_id=order.id,
            battery_id=serial,
            battery_pk=(int(battery.id) if battery and battery.id is not None else None),
            event_type="ORDER_CREATED",
            actor_id=current_user.id,
            actor_role=actor_context.role,
            dealer_id=dealer_id,
            warehouse_id=source_warehouse_id,
            admin_id=assigned_admin_id,
            from_location_type=(battery.location_type if battery is not None else None),
            from_location_id=(battery.location_id if battery is not None else None),
            to_location_type="warehouse",
            to_location_id=source_warehouse_id,
            metadata={"status": order.status},
        )

    AuditService.log_action(
        session,
        action="ORDER_CREATED",
        resource_type="LOGISTICS_ORDER",
        user_id=current_user.id,
        actor_id=current_user.id,
        actor_role=actor_context.role,
        target_table="logistics_orders",
        resource_id=order.id,
        old_value=None,
        new_value={
            "status": order.status,
            "assigned_admin_id": order.assigned_admin_id,
            "warehouse_id": order.source_warehouse_id,
        },
        old_state=None,
        new_state={
            "status": order.status,
            "assigned_admin_id": order.assigned_admin_id,
            "warehouse_id": order.source_warehouse_id,
        },
        auto_commit=False,
    )

    response = DataResponse(success=True, data=order)
    record_idempotent_response(
        session,
        user_id=current_user.id,
        idempotency_key=idempotency_key,
        request_method="POST",
        request_path="/deliveries",
        request_fingerprint=request_fingerprint,
        response_status_code=200,
        response_payload=response,
    )
    session.commit()
    session.refresh(order)
    return response


@router.post("/{order_id}/actions/approve", response_model=DataResponse[OrderRead])
@limiter.limit("20/minute")
def approve_order(
    request: Request,
    order_id: str,
    action: DeliveryApproveAction,
    current_user: User = Depends(deps.get_current_user),
    actor_context: deps.ActorContext = Depends(deps.require_actor_role("admin")),
    tenant_context: deps.TenantContext = Depends(deps.require_tenant_context(allow_global=True)),
    session: Session = Depends(deps.get_db),
    idempotency_key: Optional[str] = Header(default=None, alias="Idempotency-Key"),
):
    body = action.model_dump(exclude_none=True)
    idempotency_key = normalize_idempotency_key(idempotency_key)
    request_fingerprint = build_request_fingerprint(body)
    request_path = f"/deliveries/{order_id}/actions/approve"

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

    order = _resolve_order_or_404(session, order_id=order_id, tenant_context=tenant_context)
    _assert_mutation_scope(action="approve", order=order, actor_context=actor_context)

    current_status = canonicalize_order_status(order.status)
    if current_status == CANONICAL_ORDER_STATUS_ASSIGNED_TO_WAREHOUSE:
        return DataResponse(success=True, data=order)

    assert_valid_order_transition(current_status, CANONICAL_ORDER_STATUS_APPROVED)
    assert_valid_order_transition(CANONICAL_ORDER_STATUS_APPROVED, CANONICAL_ORDER_STATUS_ASSIGNED_TO_WAREHOUSE)

    warehouse_id = (
        select_source_warehouse_id(
            session,
            dealer_id=int(order.dealer_id or 0),
            explicit_warehouse_id=action.warehouse_id,
        )
        if action.warehouse_id is not None
        else int(order.source_warehouse_id or select_source_warehouse_id(session, dealer_id=int(order.dealer_id or 0), explicit_warehouse_id=None))
    )

    previous_approval_status = order.approval_status
    
    # Step 1: Transition to APPROVED
    order.status = CANONICAL_ORDER_STATUS_APPROVED
    order.approval_status = "approved"
    order.approved_by_user_id = current_user.id
    order.approved_at = datetime.now(UTC)
    order.approval_notes = (str(action.notes).strip() if action.notes else None)
    session.add(order)
    session.flush()

    # Step 2: Transition to ASSIGNED_TO_WAREHOUSE
    order.status = CANONICAL_ORDER_STATUS_ASSIGNED_TO_WAREHOUSE
    order.source_warehouse_id = warehouse_id
    order.updated_at = datetime.now(UTC)
    session.add(order)
    session.flush()

    AuditService.log_action(
        session,
        action="ORDER_APPROVED",
        resource_type="LOGISTICS_ORDER",
        user_id=current_user.id,
        actor_id=current_user.id,
        actor_role=actor_context.role,
        target_table="logistics_orders",
        resource_id=order.id,
        old_value={"status": current_status, "approval_status": previous_approval_status},
        new_value={"status": order.status, "approval_status": "approved"},
        old_state={"status": current_status, "approval_status": previous_approval_status},
        new_state={"status": order.status, "approval_status": "approved"},
        auto_commit=False,
    )

    response = DataResponse(success=True, data=order)
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
    session.refresh(order)
    return response


@router.post("/{order_id}/actions/reject", response_model=DataResponse[OrderRead])
@limiter.limit("20/minute")
def reject_order(
    request: Request,
    order_id: str,
    action: DeliveryRejectAction,
    current_user: User = Depends(deps.get_current_user),
    actor_context: deps.ActorContext = Depends(deps.require_actor_role("admin")),
    tenant_context: deps.TenantContext = Depends(deps.require_tenant_context(allow_global=True)),
    session: Session = Depends(deps.get_db),
    idempotency_key: Optional[str] = Header(default=None, alias="Idempotency-Key"),
):
    body = action.model_dump(exclude_none=True)
    idempotency_key = normalize_idempotency_key(idempotency_key)
    request_fingerprint = build_request_fingerprint(body)
    request_path = f"/deliveries/{order_id}/actions/reject"

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

    order = _resolve_order_or_404(session, order_id=order_id, tenant_context=tenant_context)
    _assert_mutation_scope(action="reject", order=order, actor_context=actor_context)

    current_status = canonicalize_order_status(order.status)
    if current_status == CANONICAL_ORDER_STATUS_REJECTED:
        return DataResponse(success=True, data=order)

    assert_valid_order_transition(current_status, CANONICAL_ORDER_STATUS_REJECTED)

    previous_approval_status = order.approval_status
    order.status = CANONICAL_ORDER_STATUS_REJECTED
    order.approval_status = "rejected"
    order.approved_by_user_id = current_user.id
    order.approved_at = datetime.now(UTC)
    order.approval_notes = (str(action.reason).strip() if action.reason else "Rejected by assigned admin")
    order.updated_at = datetime.now(UTC)
    session.add(order)

    AuditService.log_action(
        session,
        action="ORDER_REJECTED",
        resource_type="LOGISTICS_ORDER",
        user_id=current_user.id,
        actor_id=current_user.id,
        actor_role=actor_context.role,
        target_table="logistics_orders",
        resource_id=order.id,
        old_value={"status": current_status, "approval_status": previous_approval_status},
        new_value={"status": order.status, "reason": order.approval_notes},
        old_state={"status": current_status, "approval_status": previous_approval_status},
        new_state={"status": order.status, "approval_status": order.approval_status, "reason": order.approval_notes},
        auto_commit=False,
    )

    response = DataResponse(success=True, data=order)
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
    session.refresh(order)
    return response


@router.post("/{order_id}/actions/dispatch", response_model=DataResponse[OrderRead])
@limiter.limit("25/minute")
def dispatch_order(
    request: Request,
    order_id: str,
    action: DeliveryDispatchAction,
    current_user: User = Depends(deps.get_current_user),
    actor_context: deps.ActorContext = Depends(deps.get_actor_context),
    tenant_context: deps.TenantContext = Depends(deps.require_tenant_context(allow_global=True)),
    session: Session = Depends(deps.get_db),
    idempotency_key: Optional[str] = Header(default=None, alias="Idempotency-Key"),
):
    body = action.model_dump(exclude_none=True)
    idempotency_key = normalize_idempotency_key(idempotency_key)
    request_fingerprint = build_request_fingerprint(body)
    request_path = f"/deliveries/{order_id}/actions/dispatch"

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

    if actor_context.role not in {"warehouse_operator", "admin"}:
        raise HTTPException(status_code=403, detail="insufficient_permissions")

    order = _resolve_order_or_404(session, order_id=order_id, tenant_context=tenant_context)
    if actor_context.role == "warehouse_operator":
        _assert_mutation_scope(action="dispatch", order=order, actor_context=actor_context)

    current_status = canonicalize_order_status(order.status)
    if current_status == CANONICAL_ORDER_STATUS_OUT_FOR_DELIVERY:
        return DataResponse(success=True, data=order)

    assert_valid_order_transition(current_status, CANONICAL_ORDER_STATUS_OUT_FOR_DELIVERY)

    driver = _resolve_driver_profile(session, driver_ref=action.driver_id)
    order.assigned_driver_id = int(driver.id)
    order.driver_id = int(driver.user_id or action.driver_id)
    order.warehouse_operator_id = int(action.warehouse_operator_id or current_user.id)
    order.status = CANONICAL_ORDER_STATUS_OUT_FOR_DELIVERY
    order.dispatch_date = datetime.now(UTC)
    order.updated_at = datetime.now(UTC)
    session.add(order)

    battery_ids = _load_order_battery_ids(session, order)
    for serial in battery_ids:
        battery = session.exec(select(Battery).where(Battery.serial_number == serial).limit(1)).first()
        CustodyService.record_battery_event(
            session,
            tenant_id=order.tenant_id,
            order_id=order.id,
            battery_id=serial,
            battery_pk=(int(battery.id) if battery and battery.id is not None else None),
            event_type="ORDER_DISPATCHED",
            actor_id=current_user.id,
            actor_role=actor_context.role,
            dealer_id=order.dealer_id,
            warehouse_id=order.source_warehouse_id,
            admin_id=order.assigned_admin_id,
            warehouse_operator_id=order.warehouse_operator_id,
            driver_id=order.driver_id,
            from_location_type="warehouse",
            from_location_id=order.source_warehouse_id,
            to_location_type="transit",
            to_location_id=None,
            metadata={"note": action.notes},
        )

    AuditService.log_action(
        session,
        action="ORDER_DISPATCHED",
        resource_type="LOGISTICS_ORDER",
        user_id=current_user.id,
        actor_id=current_user.id,
        actor_role=actor_context.role,
        target_table="logistics_orders",
        resource_id=order.id,
        old_value={"status": current_status},
        new_value={"status": order.status, "driver_id": order.driver_id},
        old_state={"status": current_status},
        new_state={"status": order.status, "driver_id": order.driver_id},
        auto_commit=False,
    )

    response = DataResponse(success=True, data=order)
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
    session.refresh(order)
    return response


@router.post("/{order_id}/actions/complete", response_model=DataResponse[OrderRead])
@limiter.limit("25/minute")
def complete_order(
    request: Request,
    order_id: str,
    action: DeliveryCompleteAction,
    current_user: User = Depends(deps.get_current_user),
    actor_context: deps.ActorContext = Depends(deps.get_actor_context),
    tenant_context: deps.TenantContext = Depends(deps.require_tenant_context(allow_global=True)),
    session: Session = Depends(deps.get_db),
    idempotency_key: Optional[str] = Header(default=None, alias="Idempotency-Key"),
):
    body = action.model_dump(exclude_none=True)
    idempotency_key = normalize_idempotency_key(idempotency_key)
    request_fingerprint = build_request_fingerprint(body)
    request_path = f"/deliveries/{order_id}/actions/complete"

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

    order = _resolve_order_or_404(session, order_id=order_id, tenant_context=tenant_context)
    if actor_context.role != "admin":
        _assert_mutation_scope(action="complete", order=order, actor_context=actor_context)

    current_status = canonicalize_order_status(order.status)
    if current_status == CANONICAL_ORDER_STATUS_DELIVERED:
        return DataResponse(success=True, data=order)

    assert_valid_order_transition(current_status, CANONICAL_ORDER_STATUS_DELIVERED)

    order.status = CANONICAL_ORDER_STATUS_DELIVERED
    order.delivered_at = datetime.now(UTC)
    order.updated_at = datetime.now(UTC)
    if action.proof_of_delivery_url:
        order.proof_of_delivery_url = str(action.proof_of_delivery_url).strip()
    if action.proof_of_delivery_signature_url:
        order.proof_of_delivery_signature_url = str(action.proof_of_delivery_signature_url).strip()
    if action.recipient_name:
        order.recipient_name = str(action.recipient_name).strip()
    if action.notes:
        order.proof_of_delivery_notes = str(action.notes).strip()
    session.add(order)

    battery_ids = _load_order_battery_ids(session, order)
    for serial in battery_ids:
        battery = session.exec(select(Battery).where(Battery.serial_number == serial).limit(1)).first()
        battery_pk = int(battery.id) if battery and battery.id is not None else None
        CustodyService.land_battery_in_dealer_main_inventory(
            session,
            tenant_id=order.tenant_id,
            dealer_id=int(order.dealer_id or 0),
            battery_id=serial,
            battery_pk=battery_pk,
        )
        CustodyService.record_battery_event(
            session,
            tenant_id=order.tenant_id,
            order_id=order.id,
            battery_id=serial,
            battery_pk=battery_pk,
            event_type="ORDER_DELIVERED",
            actor_id=current_user.id,
            actor_role=actor_context.role,
            dealer_id=order.dealer_id,
            warehouse_id=order.source_warehouse_id,
            admin_id=order.assigned_admin_id,
            warehouse_operator_id=order.warehouse_operator_id,
            driver_id=order.driver_id,
            to_location_type="dealer_main_inventory",
            to_location_id=order.dealer_id,
            metadata={"proof": order.proof_of_delivery_url},
        )
        if battery is not None:
            battery.status = "available"
            battery.updated_at = datetime.now(UTC)
            session.add(battery)

    AuditService.log_action(
        session,
        action="ORDER_DELIVERED",
        resource_type="LOGISTICS_ORDER",
        user_id=current_user.id,
        actor_id=current_user.id,
        actor_role=actor_context.role,
        target_table="logistics_orders",
        resource_id=order.id,
        old_value={"status": current_status},
        new_value={"status": order.status, "delivered_at": order.delivered_at.isoformat()},
        old_state={"status": current_status},
        new_state={"status": order.status, "delivered_at": order.delivered_at.isoformat()},
        auto_commit=False,
    )

    response = DataResponse(success=True, data=order)
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
    session.refresh(order)
    return response


@router.get("/drivers/me/assigned", response_model=DataResponse[list[OrderRead]])
def list_driver_assigned_orders(
    request: Request,
    actor_context: deps.ActorContext = Depends(deps.require_actor_role("driver")),
    tenant_context: deps.TenantContext = Depends(deps.require_tenant_context(allow_global=True)),
    session: Session = Depends(deps.get_db),
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
):
    del request
    query = (
        select(Order)
        .where(Order.is_active == True)  # noqa: E712
        .where(Order.driver_id == int(actor_context.driver_id or 0))
        .where(Order.status.in_([CANONICAL_ORDER_STATUS_ASSIGNED_TO_WAREHOUSE, CANONICAL_ORDER_STATUS_OUT_FOR_DELIVERY]))
        .order_by(Order.updated_at.desc())
    )
    if tenant_context.scope == "tenant" and tenant_context.tenant_id is not None:
        query = query.where(Order.tenant_id == int(tenant_context.tenant_id))
    rows = session.exec(query.offset(skip).limit(limit)).all()
    return DataResponse(success=True, data=rows)


@router.post("/inventory/dealers/{dealer_id}/assign-to-station", response_model=DataResponse[dict[str, Any]])
def assign_dealer_main_battery_to_station(
    dealer_id: int,
    request: Request,
    station_id: int = Query(..., ge=1),
    battery_id: str = Query(...),
    current_user: User = Depends(deps.get_current_user),
    actor_context: deps.ActorContext = Depends(deps.require_actor_role("dealer", "admin")),
    tenant_context: deps.TenantContext = Depends(deps.require_tenant_context(allow_global=True)),
    session: Session = Depends(deps.get_db),
):
    del request
    normalized = normalize_battery_serials([battery_id], field_name="battery_id", require_non_empty=True)[0]
    if actor_context.role == "dealer" and int(actor_context.dealer_id or 0) != int(dealer_id):
        raise HTTPException(status_code=403, detail="dealer_scope_mismatch")

    station = session.get(Station, int(station_id))
    if not station or int(station.dealer_id or 0) != int(dealer_id):
        raise HTTPException(status_code=404, detail="station_not_found_for_dealer")

    dealer_row = session.exec(
        select(DealerMainInventoryBattery)
        .where(DealerMainInventoryBattery.dealer_id == int(dealer_id))
        .where(DealerMainInventoryBattery.battery_id == normalized)
        .where(DealerMainInventoryBattery.is_active == True)  # noqa: E712
        .limit(1)
    ).first()
    if dealer_row is None:
        raise HTTPException(status_code=404, detail="battery_not_found_in_dealer_main_inventory")

    CustodyService.assign_battery_to_station(
        session,
        tenant_id=(int(tenant_context.tenant_id) if tenant_context.scope == "tenant" and tenant_context.tenant_id is not None else None),
        dealer_id=int(dealer_id),
        station_id=int(station_id),
        battery_id=normalized,
        battery_pk=dealer_row.battery_pk,
    )
    CustodyService.record_battery_event(
        session,
        tenant_id=dealer_row.tenant_id,
        battery_id=normalized,
        battery_pk=dealer_row.battery_pk,
        event_type="DEALER_STATION_ASSIGNMENT",
        actor_id=current_user.id,
        actor_role=actor_context.role,
        dealer_id=int(dealer_id),
        station_id=int(station_id),
        from_location_type="dealer_main_inventory",
        from_location_id=int(dealer_id),
        to_location_type="station_inventory",
        to_location_id=int(station_id),
    )
    session.commit()

    return DataResponse(
        success=True,
        data={
            "dealer_id": int(dealer_id),
            "station_id": int(station_id),
            "battery_id": normalized,
            "status": "ASSIGNED_TO_STATION",
        },
    )


@router.get("/inventory/stations/{station_id}", response_model=DataResponse[list[dict[str, Any]]])
def list_station_inventory(
    station_id: int,
    request: Request,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=200),
    actor_context: deps.ActorContext = Depends(deps.require_actor_role("admin", "dealer")),
    tenant_context: deps.TenantContext = Depends(deps.require_tenant_context(allow_global=True)),
    session: Session = Depends(deps.get_db),
):
    del request
    query = (
        select(StationInventoryBattery)
        .where(StationInventoryBattery.station_id == int(station_id))
        .where(StationInventoryBattery.is_active == True)  # noqa: E712
        .order_by(StationInventoryBattery.updated_at.desc(), StationInventoryBattery.id.desc())
    )
    if actor_context.role == "dealer":
        if actor_context.dealer_id is None:
            raise HTTPException(status_code=403, detail="dealer_scope_missing")
        query = query.where(StationInventoryBattery.source_dealer_id == int(actor_context.dealer_id))
    if tenant_context.scope == "tenant" and tenant_context.tenant_id is not None:
        query = query.where(StationInventoryBattery.tenant_id == int(tenant_context.tenant_id))
    rows = session.exec(query.offset(skip).limit(limit)).all()
    payload = [
        {
            "id": row.id,
            "station_id": row.station_id,
            "battery_id": row.battery_id,
            "battery_pk": row.battery_pk,
            "status": row.status,
            "source_dealer_id": row.source_dealer_id,
            "updated_at": row.updated_at,
        }
        for row in rows
    ]
    return DataResponse(success=True, data=payload)


@router.get("/stations/activity", response_model=DataResponse[list[dict[str, Any]]])
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
    query = select(BatteryCustodyEvent).where(BatteryCustodyEvent.is_active == True)  # noqa: E712
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
            "occurred_at": row.occurred_at,
            "metadata": row.metadata_json,
        }
        for row in rows
    ]
    return DataResponse(success=True, data=payload)


# --- Legacy delivery mutations tombstoned after hard cutover ---
@router.post("/{order_id}/approval", include_in_schema=False)
def tombstone_legacy_approval(order_id: str):
    del order_id
    _legacy_tombstone("/api/v1/deliveries/{order_id}/approval", "/api/v1/deliveries/{order_id}/actions/approve|reject")


@router.patch("/{order_id}", include_in_schema=False)
def tombstone_legacy_patch(order_id: str):
    del order_id
    _legacy_tombstone("/api/v1/deliveries/{order_id}", "/api/v1/deliveries/{order_id}/actions/dispatch|complete")


@router.post("/{order_id}/delivery-proofs", include_in_schema=False)
def tombstone_legacy_delivery_proof(order_id: str):
    del order_id
    _legacy_tombstone("/api/v1/deliveries/{order_id}/delivery-proofs", "/api/v1/deliveries/{order_id}/actions/complete")


@router.post("/{order_id}/driver", include_in_schema=False)
def tombstone_legacy_driver_assign(order_id: str):
    del order_id
    _legacy_tombstone("/api/v1/deliveries/{order_id}/driver", "/api/v1/deliveries/{order_id}/actions/dispatch")


@router.delete("/{order_id}/driver", include_in_schema=False)
def tombstone_legacy_driver_unassign(order_id: str):
    del order_id
    _legacy_tombstone("/api/v1/deliveries/{order_id}/driver", "/api/v1/deliveries/{order_id}/actions/dispatch")


@router.put("/{order_id}/schedule", include_in_schema=False)
def tombstone_legacy_schedule(order_id: str):
    del order_id
    _legacy_tombstone("/api/v1/deliveries/{order_id}/schedule", "/api/v1/deliveries/{order_id}/actions/dispatch")


@router.post("/{order_id}/confirm-request", include_in_schema=False)
def tombstone_legacy_confirm_request(order_id: str):
    del order_id
    _legacy_tombstone("/api/v1/deliveries/{order_id}/confirm-request", "/api/v1/deliveries/{order_id}/actions/dispatch")


@router.post("/{order_id}/notify", include_in_schema=False)
def tombstone_legacy_notify(order_id: str):
    del order_id
    _legacy_tombstone("/api/v1/deliveries/{order_id}/notify", "/api/v1/deliveries/{order_id}")


@router.post("/{order_id}/return", include_in_schema=False)
def tombstone_legacy_return(order_id: str):
    del order_id
    _legacy_tombstone("/api/v1/deliveries/{order_id}/return", "/api/v1/rentals/{rental_id}/return")


@router.post("/{order_id}/refund", include_in_schema=False)
def tombstone_legacy_refund(order_id: str):
    del order_id
    _legacy_tombstone("/api/v1/deliveries/{order_id}/refund", "/api/v1/payments/refunds")
