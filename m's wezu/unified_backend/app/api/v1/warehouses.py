from typing import List, Any, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import and_, or_
from sqlmodel import Session, select

from app.api import deps
from app.api.deps import get_db
from app.models.order_trace import OrderLeg, OrderLegBattery, OrderLegEvent
from app.models.user import User
from app.schemas.common import DataResponse, CursorMeta
from app.schemas.warehouse import WarehouseCreate, WarehouseRead, WarehouseUpdate
from app.services.warehouse import warehouse_service
from app.utils.cursor_pagination import cursor_int, decode_cursor, encode_cursor

router = APIRouter()

@router.get("/", response_model=List[WarehouseRead])
def read_warehouses(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(deps.check_permission("warehouses", "view")),
) -> Any:
    """
    Retrieve warehouses.
    """
    warehouses = warehouse_service.get_warehouses(db, skip=skip, limit=limit)
    return warehouses

@router.post("/", response_model=WarehouseRead)
def create_warehouse(
    *,
    db: Session = Depends(get_db),
    warehouse_in: WarehouseCreate,
    current_user: User = Depends(deps.check_permission("warehouses", "create")),
) -> Any:
    """
    Create new warehouse.
    """
    warehouse = warehouse_service.create_warehouse(db=db, warehouse_in=warehouse_in)
    return warehouse

@router.get("/{id}", response_model=WarehouseRead)
def read_warehouse(
    *,
    db: Session = Depends(get_db),
    id: int,
    current_user: User = Depends(deps.check_permission("warehouses", "view")),
) -> Any:
    """
    Get warehouse by ID.
    """
    warehouse = warehouse_service.get_warehouse(db=db, warehouse_id=id)
    if not warehouse:
        raise HTTPException(status_code=404, detail="Warehouse not found")
    return warehouse

@router.put("/{id}", response_model=WarehouseRead)
def update_warehouse(
    *,
    db: Session = Depends(get_db),
    id: int,
    warehouse_in: WarehouseUpdate,
    current_user: User = Depends(deps.check_permission("warehouses", "edit")),
) -> Any:
    """
    Update a warehouse.
    """
    warehouse = warehouse_service.update_warehouse(db=db, warehouse_id=id, warehouse_in=warehouse_in)
    if not warehouse:
        raise HTTPException(status_code=404, detail="Warehouse not found")
    return warehouse

@router.delete("/{id}", response_model=WarehouseRead)
def delete_warehouse(
    *,
    db: Session = Depends(get_db),
    id: int,
    current_user: User = Depends(deps.check_permission("warehouses", "delete")),
) -> Any:
    """
    Delete a warehouse.
    """
    warehouse = warehouse_service.delete_warehouse(db=db, warehouse_id=id)
    if not warehouse:
        raise HTTPException(status_code=404, detail="Warehouse not found")
    return warehouse


@router.get("/{id}/movements", response_model=DataResponse[List[dict]])
def read_warehouse_movements(
    id: int,
    skip: int = Query(default=0, ge=0),
    limit: int = Query(default=100, ge=1, le=500),
    cursor: Optional[str] = Query(default=None),
    include_pagination: bool = Query(
        default=False,
        description="Compatibility flag accepted while migrating clients to cursor pagination.",
    ),
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.check_permission("warehouses", "view")),
) -> Any:
    """Warehouse movement timeline from immutable order leg events."""
    del current_user, include_pagination
    warehouse = warehouse_service.get_warehouse(db=db, warehouse_id=id)
    if not warehouse:
        raise HTTPException(status_code=404, detail="Warehouse not found")

    cursor_payload = decode_cursor(cursor)
    actual_skip = skip
    if cursor_payload:
        actual_skip = cursor_int(cursor_payload.get("offset"), field_name="offset")

    query = (
        select(OrderLegEvent, OrderLeg)
        .join(OrderLeg, OrderLeg.id == OrderLegEvent.order_leg_id)
        .where(
            or_(
                and_(
                    OrderLeg.source_location_type == "warehouse",
                    OrderLeg.source_location_id == id,
                ),
                and_(
                    OrderLeg.destination_location_type == "warehouse",
                    OrderLeg.destination_location_id == id,
                ),
            )
        )
        .order_by(OrderLegEvent.occurred_at.desc(), OrderLegEvent.id.desc())
        .offset(actual_skip)
        .limit(limit + 1)
    )
    rows = db.exec(query).all()
    has_more = len(rows) > limit
    rows = rows[:limit]

    leg_ids = sorted({int(leg.id) for _, leg in rows if leg and leg.id is not None})
    battery_rows = db.exec(
        select(OrderLegBattery).where(OrderLegBattery.order_leg_id.in_(leg_ids))
    ).all() if leg_ids else []
    batteries_by_leg: dict[int, list[str]] = {}
    for row in battery_rows:
        batteries_by_leg.setdefault(int(row.order_leg_id), []).append(row.battery_id)

    payload: List[dict] = []
    for event, leg in rows:
        direction = "internal"
        if leg.source_location_type == "warehouse" and leg.source_location_id == id:
            direction = "outbound"
        if leg.destination_location_type == "warehouse" and leg.destination_location_id == id:
            direction = "inbound" if direction != "outbound" else "internal"

        payload.append(
            {
                "event_id": event.id,
                "timestamp": event.occurred_at,
                "order_id": event.order_id,
                "leg_id": event.order_leg_id,
                "leg_sequence": leg.leg_sequence,
                "leg_type": leg.leg_type,
                "direction": direction,
                "event_type": event.event_type,
                "from_status": event.from_status,
                "to_status": event.to_status,
                "actor_id": event.actor_id,
                "source_location_type": leg.source_location_type,
                "source_location_id": leg.source_location_id,
                "destination_location_type": leg.destination_location_type,
                "destination_location_id": leg.destination_location_id,
                "battery_ids": sorted(batteries_by_leg.get(int(leg.id), [])),
                "metadata": event.metadata_json,
            }
        )

    next_cursor = None
    if has_more:
        next_cursor = encode_cursor({"offset": int(actual_skip) + len(payload)})
    return DataResponse(
        success=True,
        data=payload,
        meta=CursorMeta(limit=limit, has_more=has_more, next_cursor=next_cursor),
    )
