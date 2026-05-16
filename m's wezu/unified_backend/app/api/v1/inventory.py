from typing import Any, List, Optional
from datetime import UTC, datetime
import json

from fastapi import APIRouter, Depends, HTTPException, Query, Request, Response
from pydantic import BaseModel, Field
from sqlmodel import Session, select
from sqlalchemy import func
from app.api import deps
from app.core.rbac import canonical_role_name
from app.models.access_assignment import WarehouseUserAssignment
from app.models.battery import Battery, BatteryStatus, LocationType
from app.models.dealer_stock_request import DealerStockRequest, StockRequestStatus
from app.models.driver_profile import DriverProfile
from app.models.station import Station
from app.models.user import User
from app.models.logistics import BatteryTransfer
from app.models.inventory import InventoryTransfer, InventoryTransferItem, StockDiscrepancy
from app.models.inventory_audit import InventoryAuditLog
from app.models.warehouse import Warehouse
from app.schemas.inventory import AuditLogResponse
from app.services.inventory_service import InventoryService
import csv
import io

router = APIRouter()


def _tenant_scope_id(tenant_context: deps.TenantContext) -> Optional[int]:
    if tenant_context.scope == "tenant" and tenant_context.tenant_id is not None:
        return int(tenant_context.tenant_id)
    return None


def _inventory_actor_tenant_context(
    request: Request,
    session: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.require_driver_or_internal_operator),
) -> deps.TenantContext:
    if _is_driver_user(current_user):
        return deps.TenantContext(
            user=current_user,
            scope="global",
            auth_subject=getattr(request.state, "auth_subject", None),
        )
    return deps._resolve_tenant_context(session, current_user, request, allow_global=True)


def _apply_transfer_tenant_scope(
    statement: Any,
    tenant_context: deps.TenantContext,
) -> Any:
    tenant_id = _tenant_scope_id(tenant_context)
    if tenant_id is not None:
        return statement.where(InventoryTransfer.tenant_id == tenant_id)
    return statement


def _ensure_transfer_tenant_access(transfer: InventoryTransfer, tenant_context: deps.TenantContext) -> None:
    tenant_id = _tenant_scope_id(tenant_context)
    if tenant_id is None:
        return
    if int(getattr(transfer, "tenant_id", 0) or 0) != tenant_id:
        raise HTTPException(status_code=404, detail="Transfer not found")


def _assert_location_tenant_access(
    session: Session,
    *,
    location_type: str,
    location_id: int,
    tenant_context: deps.TenantContext,
) -> None:
    tenant_id = _tenant_scope_id(tenant_context)
    if tenant_id is None:
        return

    if location_type == "warehouse":
        warehouse = session.get(Warehouse, location_id)
        if not warehouse or not warehouse.is_active:
            raise HTTPException(status_code=404, detail="Location not found")
        return

    if location_type == "station":
        station = session.get(Station, location_id)
        if not station or int(getattr(station, "tenant_id", None) or getattr(station, "dealer_id", 0) or 0) != tenant_id:
            raise HTTPException(status_code=404, detail="Location not found")
        return

    if location_type == "driver":
        driver = session.get(DriverProfile, location_id)
        if not driver:
            raise HTTPException(status_code=404, detail="Location not found")
        driver_user = session.get(User, driver.user_id)
        driver_tenant_id = int(getattr(driver_user, "created_by_dealer_id", 0) or 0) if driver_user else 0
        if driver_tenant_id != tenant_id:
            raise HTTPException(status_code=404, detail="Location not found")
        return

    raise HTTPException(
        status_code=403,
        detail="tenant_scope_not_supported_for_location_type",
    )


class TransferCreateCompat(BaseModel):
    battery_id: Optional[int] = None
    battery_ids: Optional[List[str | int]] = None
    dealer_stock_request_id: Optional[int] = None
    from_location_type: str
    from_location_id: int
    to_location_type: str
    to_location_id: int
    driver_id: Optional[int] = None


class InventoryReconcileRequest(BaseModel):
    location_type: str = Field(min_length=1, max_length=64)
    location_id: int = Field(gt=0)
    physical_count: int = Field(ge=0)
    scanned_battery_ids: List[str] = Field(default_factory=list)
    notes: Optional[str] = None


def _normalize_transfer_status(status_value: str) -> str:
    normalized = (status_value or "").strip().lower().replace("-", "_")
    if normalized == "received":
        return "completed"
    if normalized == "assigned":
        return "in_transit"
    if normalized in {"pending", "in_transit", "completed", "cancelled"}:
        return normalized
    return "pending"


def _assigned_warehouse_ids(session: Session, user: User) -> set[int]:
    rows = session.exec(
        select(WarehouseUserAssignment.warehouse_id).where(
            WarehouseUserAssignment.user_id == user.id,
            WarehouseUserAssignment.is_active == True,  # noqa: E712
        )
    ).all()
    managed = session.exec(select(Warehouse.id).where(Warehouse.manager_id == user.id)).all()
    return {int(row) for row in rows} | {int(row) for row in managed}


def _explicit_role_names(user: User) -> set[str]:
    names: set[str] = set()
    for role in getattr(user, "roles", []) or []:
        name = canonical_role_name(getattr(role, "name", None))
        if name:
            names.add(name)
    role = getattr(user, "role", None)
    name = canonical_role_name(getattr(role, "name", None))
    if name:
        names.add(name)
    return names


def _is_global_transfer_operator(user: User) -> bool:
    role_names = _explicit_role_names(user)
    return bool(
        user.is_superuser
        or role_names & (deps.ADMIN_ROLE_NAMES | {"logistics_manager", "dispatcher"})
    )


def _is_driver_user(user: User) -> bool:
    return bool(_explicit_role_names(user) & deps.DRIVER_ROLE_NAMES)


def _driver_profile_id(session: Session, user: User) -> Optional[int]:
    driver = session.exec(select(DriverProfile).where(DriverProfile.user_id == user.id)).first()
    return driver.id if driver else None


def _ensure_warehouse_actor_access(session: Session, user: User, warehouse_id: int) -> None:
    if _is_global_transfer_operator(user):
        return
    if warehouse_id in _assigned_warehouse_ids(session, user):
        return
    raise HTTPException(status_code=404, detail="Warehouse not found")


def _transfer_visible_to_actor(session: Session, transfer: InventoryTransfer, user: User) -> bool:
    if _is_global_transfer_operator(user):
        return True
    if _is_driver_user(user):
        driver_id = _driver_profile_id(session, user)
        return driver_id is not None and transfer.driver_id == driver_id
    if "warehouse_manager" in _explicit_role_names(user):
        allowed = _assigned_warehouse_ids(session, user)
        return (
            transfer.from_location_type == "warehouse" and transfer.from_location_id in allowed
        ) or (
            transfer.to_location_type == "warehouse" and transfer.to_location_id in allowed
        )
    return False


def _ensure_transfer_actor_access(session: Session, transfer: InventoryTransfer, user: User) -> None:
    if not _transfer_visible_to_actor(session, transfer, user):
        raise HTTPException(status_code=404, detail="Transfer not found")


def _resolve_driver_profile_id(session: Session, driver_id: Optional[int]) -> Optional[int]:
    if driver_id is None:
        return None
    driver = session.get(DriverProfile, driver_id)
    if driver:
        return driver.id
    driver = session.exec(select(DriverProfile).where(DriverProfile.user_id == driver_id)).first()
    return driver.id if driver else None


def _inventory_transfer_to_payload(session: Session, transfer: InventoryTransfer) -> dict[str, Any]:
    normalized_status = _normalize_transfer_status(transfer.status)
    items = session.exec(
        select(InventoryTransferItem).where(InventoryTransferItem.transfer_id == transfer.id)
    ).all()
    return {
        "id": transfer.id,
        "battery_id": items[0].battery_pk if items else None,
        "from_location_type": transfer.from_location_type,
        "from_location_id": transfer.from_location_id,
        "to_location_type": transfer.to_location_type,
        "to_location_id": transfer.to_location_id,
        "status": normalized_status,
        "items": [item.battery_id for item in items],
        "battery_ids": [item.battery_pk for item in items if item.battery_pk is not None],
        "driver_id": transfer.driver_id,
        "dealer_stock_request_id": transfer.dealer_stock_request_id,
        "created_at": transfer.created_at,
        "updated_at": transfer.updated_at,
        "dispatched_at": transfer.dispatched_at,
        "completed_at": transfer.completed_at,
    }


def _legacy_transfer_to_payload(transfer: BatteryTransfer) -> dict[str, Any]:
    normalized_status = _normalize_transfer_status(transfer.status)
    completed_at = transfer.updated_at if normalized_status == "completed" else None
    return {
        "id": transfer.id,
        "battery_id": transfer.battery_id,
        "from_location_type": transfer.from_location_type,
        "from_location_id": transfer.from_location_id,
        "to_location_type": transfer.to_location_type,
        "to_location_id": transfer.to_location_id,
        "status": normalized_status,
        "items": [str(transfer.battery_id)],
        "driver_id": None,
        "manifest_id": transfer.manifest_id,
        "created_at": transfer.created_at,
        "updated_at": transfer.updated_at,
        "completed_at": completed_at,
    }


def _resolve_battery_id_from_token(session: Session, token: str | int) -> Optional[int]:
    if isinstance(token, int):
        battery = session.get(Battery, token)
        return battery.id if battery else None

    raw = str(token).strip()
    if not raw:
        return None
    if raw.isdigit():
        battery = session.get(Battery, int(raw))
        if battery:
            return battery.id

    battery = session.exec(
        select(Battery).where(func.lower(Battery.serial_number) == raw.lower())
    ).first()
    return battery.id if battery else None


def _resolved_batteries_from_tokens(session: Session, raw_tokens: list[str | int]) -> list[Battery]:
    batteries: list[Battery] = []
    seen: set[int] = set()
    for raw_token in raw_tokens:
        battery_id = _resolve_battery_id_from_token(session, raw_token)
        if battery_id is None:
            raise HTTPException(status_code=400, detail=f"Battery not found for token '{raw_token}'")
        if battery_id in seen:
            continue
        battery = session.get(Battery, battery_id)
        if not battery:
            raise HTTPException(status_code=400, detail=f"Battery not found for token '{raw_token}'")
        batteries.append(battery)
        seen.add(battery_id)
    return batteries


def _receive_inventory_transfer(
    session: Session,
    transfer_id: int,
    current_user: User,
    tenant_context: deps.TenantContext,
) -> dict[str, Any]:
    transfer = session.get(InventoryTransfer, transfer_id)
    if not transfer:
        legacy = session.get(BatteryTransfer, transfer_id)
        if legacy:
            try:
                received = InventoryService.confirm_receipt(
                    session,
                    transfer_id,
                    current_user.id,
                    tenant_id=_tenant_scope_id(tenant_context),
                )
                return _legacy_transfer_to_payload(received)
            except ValueError as exc:
                raise HTTPException(status_code=400, detail=str(exc))
        raise HTTPException(status_code=404, detail="Transfer not found")

    _ensure_transfer_tenant_access(transfer, tenant_context)
    _ensure_transfer_actor_access(session, transfer, current_user)
    normalized_status = _normalize_transfer_status(transfer.status)
    if normalized_status == "cancelled":
        raise HTTPException(status_code=400, detail="Cancelled transfer cannot be received")
    if normalized_status == "completed":
        return _inventory_transfer_to_payload(session, transfer)

    now = datetime.now(UTC)
    items = session.exec(
        select(InventoryTransferItem).where(InventoryTransferItem.transfer_id == transfer.id)
    ).all()
    received_count = 0
    for item in items:
        battery = session.get(Battery, item.battery_pk) if item.battery_pk else None
        if not battery:
            continue
        battery.station_id = transfer.to_location_id if transfer.to_location_type == "station" else None
        if transfer.to_location_type == "station":
            battery.location_type = LocationType.STATION
        elif transfer.to_location_type == "warehouse":
            battery.location_type = LocationType.WAREHOUSE
        battery.location_id = transfer.to_location_id
        battery.status = BatteryStatus.AVAILABLE
        battery.updated_at = now
        session.add(battery)
        received_count += 1

    transfer.status = "completed"
    transfer.completed_at = now
    transfer.received_by_user_id = current_user.id
    transfer.updated_at = now
    session.add(transfer)

    if transfer.dealer_stock_request_id:
        req = session.get(DealerStockRequest, transfer.dealer_stock_request_id)
        if req:
            req.fulfilled_quantity = received_count
            if received_count >= req.quantity:
                req.status = StockRequestStatus.FULFILLED
                req.fulfilled_at = now
            req.updated_at = now
            req.assigned_transfer_id = transfer.id
            session.add(req)

    session.commit()
    session.refresh(transfer)

    try:
        for item in items:
            if item.battery_pk:
                InventoryService.log_inventory_change(
                    db=session,
                    battery_id=item.battery_pk,
                    action_type="transfer_completed",
                    from_loc_type=transfer.from_location_type,
                    from_loc_id=transfer.from_location_id,
                    to_loc_type=transfer.to_location_type,
                    to_loc_id=transfer.to_location_id,
                    actor_id=current_user.id,
                    notes=f"InventoryTransfer {transfer.id} received",
                )
    except Exception:
        session.rollback()

    return _inventory_transfer_to_payload(session, transfer)

@router.post("/transfers", response_model=dict)
def create_transfer_order(
    *,
    session: Session = Depends(deps.get_db),
    transfer_in: TransferCreateCompat,
    current_user: User = Depends(deps.require_internal_operator),
    tenant_context: deps.TenantContext = Depends(_inventory_actor_tenant_context),
) -> Any:
    """Create a canonical multi-battery inventory transfer."""
    raw_tokens: list[str | int] = []
    if transfer_in.battery_id is not None:
        raw_tokens.append(transfer_in.battery_id)
    if transfer_in.battery_ids:
        raw_tokens.extend(transfer_in.battery_ids)

    if not raw_tokens:
        raise HTTPException(status_code=400, detail="battery_id or battery_ids is required")

    from_type = transfer_in.from_location_type.strip().lower()
    to_type = transfer_in.to_location_type.strip().lower()
    if from_type != "warehouse" or to_type != "station":
        raise HTTPException(status_code=400, detail="Only warehouse-to-station transfers are supported for dealer replenishment")

    _ensure_warehouse_actor_access(session, current_user, transfer_in.from_location_id)
    station = session.get(Station, transfer_in.to_location_id)
    if not station:
        raise HTTPException(status_code=404, detail="Destination station not found")
    _assert_location_tenant_access(
        session,
        location_type=from_type,
        location_id=transfer_in.from_location_id,
        tenant_context=tenant_context,
    )
    _assert_location_tenant_access(
        session,
        location_type=to_type,
        location_id=transfer_in.to_location_id,
        tenant_context=tenant_context,
    )

    stock_request = None
    if transfer_in.dealer_stock_request_id is not None:
        stock_request = session.get(DealerStockRequest, transfer_in.dealer_stock_request_id)
        if not stock_request:
            raise HTTPException(status_code=404, detail="stock_request_not_found")
        if stock_request.status != StockRequestStatus.APPROVED:
            raise HTTPException(status_code=409, detail="stock_request_not_approved")
        if stock_request.source_warehouse_id != transfer_in.from_location_id:
            raise HTTPException(status_code=409, detail="source_warehouse_mismatch")
        if stock_request.station_id != transfer_in.to_location_id:
            raise HTTPException(status_code=409, detail="destination_station_mismatch")

    batteries = _resolved_batteries_from_tokens(session, raw_tokens)
    for battery in batteries:
        if str(getattr(battery.location_type, "value", battery.location_type)) != "warehouse" or battery.location_id != transfer_in.from_location_id:
            raise HTTPException(
                status_code=409,
                detail=f"Battery '{battery.serial_number}' is not in source warehouse",
            )

    driver_profile_id = _resolve_driver_profile_id(session, transfer_in.driver_id)
    if transfer_in.driver_id is not None and driver_profile_id is None:
        raise HTTPException(status_code=404, detail="driver_not_found")

    now = datetime.now(UTC)
    transfer = InventoryTransfer(
        tenant_id=_tenant_scope_id(tenant_context) or (stock_request.tenant_id if stock_request else None),
        dealer_stock_request_id=stock_request.id if stock_request else None,
        from_location_type=from_type,
        from_location_id=transfer_in.from_location_id,
        to_location_type=to_type,
        to_location_id=transfer_in.to_location_id,
        driver_id=driver_profile_id,
        items=json.dumps([battery.serial_number for battery in batteries]),
        status="pending",
        created_by_user_id=current_user.id,
        created_at=now,
        updated_at=now,
    )
    session.add(transfer)
    session.commit()
    session.refresh(transfer)

    for battery in batteries:
        session.add(
            InventoryTransferItem(
                tenant_id=transfer.tenant_id,
                transfer_id=transfer.id,
                battery_id=battery.serial_number,
                battery_pk=battery.id,
                created_at=now,
            )
        )
        try:
            InventoryService.log_inventory_change(
                db=session,
                battery_id=battery.id,
                action_type="transfer_created",
                from_loc_type=from_type,
                from_loc_id=transfer_in.from_location_id,
                to_loc_type=to_type,
                to_loc_id=transfer_in.to_location_id,
                actor_id=current_user.id,
                notes=f"InventoryTransfer {transfer.id} created",
            )
        except Exception:
            session.rollback()
    if stock_request:
        stock_request.assigned_transfer_id = transfer.id
        stock_request.status = StockRequestStatus.IN_FULFILLMENT
        stock_request.updated_at = now
        session.add(stock_request)
    session.commit()
    session.refresh(transfer)
    return _inventory_transfer_to_payload(session, transfer)

@router.get("/transfers", response_model=List[dict])
def list_transfers(
    *,
    session: Session = Depends(deps.get_db),
    status: Optional[str] = None,
    battery_id: Optional[int] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=200),
    current_user: User = Depends(deps.require_driver_or_internal_operator),
    tenant_context: deps.TenantContext = Depends(_inventory_actor_tenant_context),
) -> Any:
    """List all transfer orders with status"""
    statement = _apply_transfer_tenant_scope(select(InventoryTransfer), tenant_context)
    if status:
        statement = statement.where(InventoryTransfer.status == status)
    if battery_id:
        item_transfer_ids = session.exec(
            select(InventoryTransferItem.transfer_id).where(
                InventoryTransferItem.battery_pk == battery_id
            )
        ).all()
        statement = statement.where(InventoryTransfer.id.in_(item_transfer_ids or [-1]))
    transfers = session.exec(statement.order_by(InventoryTransfer.created_at.desc()).offset(skip).limit(limit)).all()
    visible = [transfer for transfer in transfers if _transfer_visible_to_actor(session, transfer, current_user)]
    return [_inventory_transfer_to_payload(session, transfer) for transfer in visible]

@router.get("/low-stock", response_model=List[dict])
def get_low_stock_alerts(
    threshold: int = Query(5, description="Low stock threshold"),
    session: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_superuser),
):
    """Admin: stations or warehouses with battery counts below threshold"""
    from app.models.station import Station, StationSlot
    from sqlmodel import func
    
    # Query stations with few 'ready' batteries
    stmt = select(Station.id, Station.name, func.count(StationSlot.id).label("ready_count")).join(StationSlot).where(StationSlot.status == "ready").group_by(Station.id).having(func.count(StationSlot.id) < threshold)
    results = session.execute(stmt).all()
    
    return [
        {"location_id": r[0], "location_name": r[1], "count": r[2], "type": "station"}
        for r in results
    ]

@router.get("/transfers/{id}", response_model=dict)
def get_transfer_detail(
    *,
    session: Session = Depends(deps.get_db),
    id: int,
    current_user: User = Depends(deps.require_driver_or_internal_operator),
    tenant_context: deps.TenantContext = Depends(_inventory_actor_tenant_context),
) -> Any:
    """Transfer order detail"""
    transfer = session.get(InventoryTransfer, id)
    if not transfer:
        legacy = session.get(BatteryTransfer, id)
        if legacy:
            return _legacy_transfer_to_payload(legacy)
        raise HTTPException(status_code=404, detail="Transfer not found")
    _ensure_transfer_tenant_access(transfer, tenant_context)
    _ensure_transfer_actor_access(session, transfer, current_user)
    return _inventory_transfer_to_payload(session, transfer)


@router.post("/transfers/{id}/dispatch", response_model=dict)
def dispatch_transfer(
    *,
    session: Session = Depends(deps.get_db),
    id: int,
    current_user: User = Depends(deps.require_internal_operator),
    tenant_context: deps.TenantContext = Depends(deps.require_tenant_context(allow_global=True)),
) -> Any:
    transfer = session.get(InventoryTransfer, id)
    if not transfer:
        raise HTTPException(status_code=404, detail="Transfer not found")
    _ensure_transfer_tenant_access(transfer, tenant_context)
    _ensure_transfer_actor_access(session, transfer, current_user)
    if transfer.from_location_type == "warehouse":
        _ensure_warehouse_actor_access(session, current_user, transfer.from_location_id)

    normalized_status = _normalize_transfer_status(transfer.status)
    if normalized_status == "completed":
        raise HTTPException(status_code=400, detail="Completed transfer cannot be dispatched")
    if normalized_status == "cancelled":
        raise HTTPException(status_code=400, detail="Cancelled transfer cannot be dispatched")
    if normalized_status == "in_transit":
        return _inventory_transfer_to_payload(session, transfer)

    now = datetime.now(UTC)
    items = session.exec(
        select(InventoryTransferItem).where(InventoryTransferItem.transfer_id == transfer.id)
    ).all()
    for item in items:
        battery = session.get(Battery, item.battery_pk) if item.battery_pk else None
        if not battery:
            continue
        if str(getattr(battery.location_type, "value", battery.location_type)) != transfer.from_location_type or battery.location_id != transfer.from_location_id:
            raise HTTPException(status_code=409, detail=f"Battery '{item.battery_id}' is not at transfer source")
        battery.status = BatteryStatus.IN_TRANSIT
        battery.location_type = LocationType.TRANSIT
        battery.location_id = transfer.id
        battery.station_id = None
        battery.updated_at = now
        session.add(battery)

    transfer.status = "in_transit"
    transfer.dispatched_at = now
    transfer.updated_at = now
    session.add(transfer)
    session.commit()
    session.refresh(transfer)
    return _inventory_transfer_to_payload(session, transfer)

@router.put("/transfers/{id}/confirm", response_model=dict)
def confirm_transfer_receipt(
    *,
    session: Session = Depends(deps.get_db),
    id: int,
    current_user: User = Depends(deps.require_driver_or_internal_operator),
    tenant_context: deps.TenantContext = Depends(_inventory_actor_tenant_context),
) -> Any:
    """Confirm batteries received at destination station"""
    return _receive_inventory_transfer(session, id, current_user, tenant_context)


@router.post("/transfers/{id}/receive", response_model=dict)
def receive_transfer_alias(
    *,
    session: Session = Depends(deps.get_db),
    id: int,
    current_user: User = Depends(deps.require_driver_or_internal_operator),
    tenant_context: deps.TenantContext = Depends(_inventory_actor_tenant_context),
) -> Any:
    """Alias for transfer receipt confirmation used by logistics frontend."""
    return _receive_inventory_transfer(session, id, current_user, tenant_context)


@router.post("/transfers/{id}/cancel", response_model=dict)
def cancel_transfer(
    *,
    session: Session = Depends(deps.get_db),
    id: int,
    current_user: User = Depends(deps.require_internal_operator),
    tenant_context: deps.TenantContext = Depends(deps.require_tenant_context(allow_global=True)),
) -> Any:
    transfer = session.get(InventoryTransfer, id)
    if not transfer:
        raise HTTPException(status_code=404, detail="Transfer not found")
    _ensure_transfer_tenant_access(transfer, tenant_context)
    _ensure_transfer_actor_access(session, transfer, current_user)

    normalized_status = _normalize_transfer_status(transfer.status)
    if normalized_status == "completed":
        raise HTTPException(status_code=400, detail="Completed transfer cannot be cancelled")
    if normalized_status == "cancelled":
        return _inventory_transfer_to_payload(session, transfer)

    transfer.status = "cancelled"
    transfer.updated_at = datetime.now(UTC)
    session.add(transfer)
    if transfer.dealer_stock_request_id:
        req = session.get(DealerStockRequest, transfer.dealer_stock_request_id)
        if req and req.status == StockRequestStatus.IN_FULFILLMENT:
            req.status = StockRequestStatus.APPROVED
            req.assigned_transfer_id = None
            req.updated_at = datetime.now(UTC)
            session.add(req)
    session.commit()
    session.refresh(transfer)

    try:
        items = session.exec(
            select(InventoryTransferItem).where(InventoryTransferItem.transfer_id == transfer.id)
        ).all()
        for item in items:
            if item.battery_pk:
                InventoryService.log_inventory_change(
                    db=session,
                    battery_id=item.battery_pk,
                    action_type="transfer_cancelled",
                    from_loc_type=transfer.from_location_type,
                    from_loc_id=transfer.from_location_id,
                    to_loc_type=transfer.to_location_type,
                    to_loc_id=transfer.to_location_id,
                    actor_id=current_user.id,
                    notes=f"InventoryTransfer {transfer.id} cancelled",
                )
    except Exception:
        # Do not fail cancellation if audit logging experiences an issue.
        session.rollback()

    return _inventory_transfer_to_payload(session, transfer)


@router.get("/locations/{location_type}/{location_id}/batteries", response_model=List[dict])
def get_location_batteries(
    *,
    session: Session = Depends(deps.get_db),
    location_type: str,
    location_id: int,
    status: Optional[str] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    current_user: User = Depends(deps.require_internal_operator),
    tenant_context: deps.TenantContext = Depends(deps.require_tenant_context(allow_global=True)),
) -> Any:
    normalized_type = location_type.strip().lower()
    if normalized_type not in {"warehouse", "station", "shelf", "driver"}:
        raise HTTPException(status_code=400, detail="Unsupported location_type")
    if normalized_type == "warehouse":
        _ensure_warehouse_actor_access(session, current_user, location_id)
    _assert_location_tenant_access(
        session,
        location_type=normalized_type,
        location_id=location_id,
        tenant_context=tenant_context,
    )

    statement = select(Battery).where(
        Battery.location_type == normalized_type,
        Battery.location_id == location_id,
    )
    batteries = session.exec(statement.offset(skip).limit(limit)).all()
    if status:
        requested_status = status.strip().lower().replace("-", "_")
        batteries = [
            battery
            for battery in batteries
            if str(getattr(getattr(battery, "status", None), "value", battery.status)).lower().replace("-", "_")
            == requested_status
        ]
    return [battery.model_dump() for battery in batteries]


@router.post("/reconcile", response_model=dict)
def reconcile_inventory(
    *,
    session: Session = Depends(deps.get_db),
    payload: InventoryReconcileRequest,
    current_user: User = Depends(deps.require_internal_operator),
    tenant_context: deps.TenantContext = Depends(deps.require_tenant_context(allow_global=True)),
) -> Any:
    normalized_type = payload.location_type.strip().lower()
    if normalized_type not in {"warehouse", "station"}:
        raise HTTPException(status_code=400, detail="location_type must be warehouse or station")
    if normalized_type == "warehouse":
        _ensure_warehouse_actor_access(session, current_user, payload.location_id)
    _assert_location_tenant_access(
        session,
        location_type=normalized_type,
        location_id=payload.location_id,
        tenant_context=tenant_context,
    )

    batteries = session.exec(
        select(Battery).where(
            Battery.location_type == normalized_type,
            Battery.location_id == payload.location_id,
        )
    ).all()
    system_serials = {
        str(battery.serial_number).strip().upper()
        for battery in batteries
        if battery.serial_number
    }
    scanned_serials = {
        str(serial).strip().upper()
        for serial in payload.scanned_battery_ids
        if str(serial).strip()
    }

    missing_items = sorted(system_serials - scanned_serials)
    extra_items = sorted(scanned_serials - system_serials)
    discrepancy = StockDiscrepancy(
        tenant_id=_tenant_scope_id(tenant_context),
        location_type=normalized_type,
        location_id=payload.location_id,
        system_count=len(system_serials),
        physical_count=payload.physical_count,
        missing_items=json.dumps(missing_items),
        extra_items=json.dumps(extra_items),
        notes=payload.notes,
        status="resolved" if not missing_items and not extra_items else "open",
        reported_by_id=current_user.id,
    )
    session.add(discrepancy)
    session.commit()
    session.refresh(discrepancy)

    return {
        "success": True,
        "discrepancy_id": discrepancy.id,
        "status": discrepancy.status,
        "system_count": discrepancy.system_count,
        "physical_count": discrepancy.physical_count,
        "missing_items": missing_items,
        "extra_items": extra_items,
    }

@router.get("/audit-trail", response_model=List[AuditLogResponse])
def get_inventory_audit_trail(
    *,
    session: Session = Depends(deps.get_db),
    battery_id: Optional[int] = None,
    action: Optional[str] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=200),
    current_user: User = Depends(deps.get_current_active_superuser),
) -> Any:
    """Full audit log of inventory changes with filters"""
    statement = select(InventoryAuditLog)
    if battery_id:
        statement = statement.where(InventoryAuditLog.battery_id == battery_id)
    if action:
        statement = statement.where(InventoryAuditLog.action_type == action)
    
    statement = statement.order_by(InventoryAuditLog.timestamp.desc())
    return session.exec(statement.offset(skip).limit(limit)).all()

@router.post("/audit-trail/export")
def export_inventory_audit(
    *,
    session: Session = Depends(deps.get_db),
    battery_id: Optional[int] = None,
    current_user: User = Depends(deps.get_current_active_superuser),
):
    """Export audit trail as CSV"""
    statement = select(InventoryAuditLog)
    if battery_id:
        statement = statement.where(InventoryAuditLog.battery_id == battery_id)
        
    logs = session.exec(statement.order_by(InventoryAuditLog.timestamp.desc()).limit(10000)).all()
    
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(["ID", "Battery ID", "Action", "From Type", "From ID", "To Type", "To ID", "Actor ID", "Timestamp", "Notes"])
    
    for log in logs:
        writer.writerow([
            log.id, log.battery_id, log.action_type,
            log.from_location_type, log.from_location_id,
            log.to_location_type, log.to_location_id,
            log.actor_id, log.timestamp.isoformat(), log.notes
        ])
        
    return Response(
        content=output.getvalue(),
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=inventory_audit_trail.csv"}
    )
