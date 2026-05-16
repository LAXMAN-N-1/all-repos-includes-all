from typing import Any, List, Optional
from datetime import UTC, datetime
import json

from fastapi import APIRouter, Body, Depends, HTTPException, Query, Response
from pydantic import BaseModel, Field
from sqlmodel import Session, select
from sqlalchemy import func
from app.api import deps
from app.models.battery import Battery
from app.models.user import User
from app.models.logistics import BatteryTransfer
from app.models.inventory import StockDiscrepancy
from app.models.inventory_audit import InventoryAuditLog
from app.schemas.inventory import TransferCreate, TransferResponse, AuditLogResponse
from app.services.inventory_service import InventoryService
import csv
import io

router = APIRouter()


class TransferCreateCompat(BaseModel):
    battery_id: Optional[int] = None
    battery_ids: Optional[List[str | int]] = None
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


def _transfer_to_payload(transfer: BatteryTransfer) -> dict[str, Any]:
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

@router.post("/transfers", response_model=dict)
def create_transfer_order(
    *,
    session: Session = Depends(deps.get_db),
    transfer_in: TransferCreateCompat,
    current_user: User = Depends(deps.require_internal_operator),
) -> Any:
    """Create one or more transfer orders; compatible with legacy and logistics app payloads."""
    raw_tokens: list[str | int] = []
    if transfer_in.battery_id is not None:
        raw_tokens.append(transfer_in.battery_id)
    if transfer_in.battery_ids:
        raw_tokens.extend(transfer_in.battery_ids)

    if not raw_tokens:
        raise HTTPException(status_code=400, detail="battery_id or battery_ids is required")

    created_transfers: list[BatteryTransfer] = []
    resolved_tokens: list[str] = []
    for raw_token in raw_tokens:
        battery_id = _resolve_battery_id_from_token(session, raw_token)
        if battery_id is None:
            raise HTTPException(status_code=400, detail=f"Battery not found for token '{raw_token}'")

        payload = TransferCreate(
            battery_id=battery_id,
            from_location_type=transfer_in.from_location_type,
            from_location_id=transfer_in.from_location_id,
            to_location_type=transfer_in.to_location_type,
            to_location_id=transfer_in.to_location_id,
        )
        try:
            created = InventoryService.create_transfer(session, payload, current_user.id)
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc))
        created_transfers.append(created)
        resolved_tokens.append(str(raw_token).strip())

    primary = created_transfers[0]
    response_payload = _transfer_to_payload(primary)
    response_payload["driver_id"] = transfer_in.driver_id
    if len(resolved_tokens) > 1:
        response_payload["items"] = resolved_tokens
        response_payload["batched_transfer_ids"] = [transfer.id for transfer in created_transfers]
    return response_payload

@router.get("/transfers", response_model=List[dict])
def list_transfers(
    *,
    session: Session = Depends(deps.get_db),
    status: Optional[str] = None,
    battery_id: Optional[int] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=200),
    current_user: User = Depends(deps.require_internal_operator),
) -> Any:
    """List all transfer orders with status"""
    statement = select(BatteryTransfer)
    if status:
        statement = statement.where(BatteryTransfer.status == status)
    if battery_id:
        statement = statement.where(BatteryTransfer.battery_id == battery_id)
    transfers = session.exec(statement.offset(skip).limit(limit)).all()
    return [_transfer_to_payload(transfer) for transfer in transfers]

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
    current_user: User = Depends(deps.require_internal_operator),
) -> Any:
    """Transfer order detail"""
    transfer = session.get(BatteryTransfer, id)
    if not transfer:
        raise HTTPException(status_code=404, detail="Transfer not found")
    return _transfer_to_payload(transfer)

@router.put("/transfers/{id}/confirm", response_model=dict)
def confirm_transfer_receipt(
    *,
    session: Session = Depends(deps.get_db),
    id: int,
    current_user: User = Depends(deps.require_internal_operator),
) -> Any:
    """Confirm batteries received at destination station"""
    try:
        transfer = InventoryService.confirm_receipt(session, id, current_user.id)
        return _transfer_to_payload(transfer)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/transfers/{id}/receive", response_model=dict)
def receive_transfer_alias(
    *,
    session: Session = Depends(deps.get_db),
    id: int,
    current_user: User = Depends(deps.require_internal_operator),
) -> Any:
    """Alias for transfer receipt confirmation used by logistics frontend."""
    try:
        transfer = InventoryService.confirm_receipt(session, id, current_user.id)
        return _transfer_to_payload(transfer)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc))


@router.post("/transfers/{id}/cancel", response_model=dict)
def cancel_transfer(
    *,
    session: Session = Depends(deps.get_db),
    id: int,
    current_user: User = Depends(deps.require_internal_operator),
) -> Any:
    transfer = session.get(BatteryTransfer, id)
    if not transfer:
        raise HTTPException(status_code=404, detail="Transfer not found")

    normalized_status = _normalize_transfer_status(transfer.status)
    if normalized_status == "completed":
        raise HTTPException(status_code=400, detail="Completed transfer cannot be cancelled")
    if normalized_status == "cancelled":
        return _transfer_to_payload(transfer)

    transfer.status = "cancelled"
    transfer.updated_at = datetime.now(UTC)
    session.add(transfer)
    session.commit()
    session.refresh(transfer)

    try:
        InventoryService.log_inventory_change(
            db=session,
            battery_id=transfer.battery_id,
            action_type="transfer_cancelled",
            from_loc_type=transfer.from_location_type,
            from_loc_id=transfer.from_location_id,
            to_loc_type=transfer.to_location_type,
            to_loc_id=transfer.to_location_id,
            actor_id=current_user.id,
            notes=f"Transfer {transfer.id} cancelled",
        )
    except Exception:
        # Do not fail cancellation if audit logging experiences an issue.
        session.rollback()

    return _transfer_to_payload(transfer)


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
) -> Any:
    normalized_type = location_type.strip().lower()
    if normalized_type not in {"warehouse", "station", "shelf", "driver"}:
        raise HTTPException(status_code=400, detail="Unsupported location_type")

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
) -> Any:
    normalized_type = payload.location_type.strip().lower()
    if normalized_type not in {"warehouse", "station"}:
        raise HTTPException(status_code=400, detail="location_type must be warehouse or station")

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
