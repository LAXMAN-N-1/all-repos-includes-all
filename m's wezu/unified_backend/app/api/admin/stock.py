from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
from sqlmodel import Session, select, func
from typing import List, Optional
from datetime import datetime, UTC, timedelta
import uuid

from app.api.deps import get_db, get_current_active_admin
from app.core.rbac import canonical_role_name
from app.models.battery import Battery, BatteryStatus, LocationType
from app.models.dealer import DealerProfile
from app.models.dealer_stock_request import DealerStockRequest, StockRequestStatus
from app.models.station import Station
from app.models.station_stock import StationStockConfig, ReorderRequest, StockAlertDismissal
from app.models.user import User
from app.models.warehouse import Warehouse
from app.schemas.station_stock import (
    StockOverviewResponse, StationStockResponse, StationStockConfigResponse,
    StationStockConfigUpdate, ReorderRequestCreate, ReorderRequestResponse,
    StockAlertResponse, StationStockDetailResponse, StockForecastResponse,
    LocationStockResponse
)

router = APIRouter()


class DealerStockRequestApprove(BaseModel):
    source_warehouse_id: int
    notes: Optional[str] = None


class DealerStockRequestReject(BaseModel):
    reason: str


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


def _assert_stock_request_view_admin(current_user: User) -> None:
    role_names = _explicit_role_names(current_user)
    if current_user.is_superuser or role_names & {"super_admin", "operations_admin", "security_admin"}:
        return
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="insufficient_permissions")


def _assert_stock_request_mutation_admin(current_user: User) -> None:
    role_names = _explicit_role_names(current_user)
    if current_user.is_superuser or role_names & {"super_admin", "operations_admin"}:
        return
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="insufficient_permissions")


def _serialize_dealer_stock_request(db: Session, req: DealerStockRequest) -> dict:
    dealer = db.get(DealerProfile, req.dealer_id) if req.dealer_id else None
    station = db.get(Station, req.station_id) if req.station_id else None
    warehouse = db.get(Warehouse, req.source_warehouse_id) if req.source_warehouse_id else None
    return {
        "id": req.id,
        "tenant_id": req.tenant_id,
        "dealer_id": req.dealer_id,
        "dealer_name": dealer.business_name if dealer else None,
        "station_id": req.station_id,
        "station_name": station.name if station else None,
        "source_warehouse_id": req.source_warehouse_id,
        "source_warehouse_name": warehouse.name if warehouse else None,
        "assigned_transfer_id": req.assigned_transfer_id,
        "model_id": req.model_id,
        "model_name": req.model_name,
        "quantity": req.quantity,
        "delivery_date": req.delivery_date.isoformat() if req.delivery_date else None,
        "priority": req.priority.value if hasattr(req.priority, "value") else str(req.priority),
        "reason": req.reason,
        "notes": req.notes,
        "status": req.status.value if hasattr(req.status, "value") else str(req.status),
        "admin_notes": req.admin_notes,
        "approved_by": req.approved_by,
        "approved_at": req.approved_at.isoformat() if req.approved_at else None,
        "rejected_reason": req.rejected_reason,
        "fulfilled_quantity": req.fulfilled_quantity,
        "fulfilled_at": req.fulfilled_at.isoformat() if req.fulfilled_at else None,
        "created_by": req.created_by,
        "created_at": req.created_at.isoformat() if req.created_at else None,
        "updated_at": req.updated_at.isoformat() if req.updated_at else None,
    }


@router.get("/dealer-requests", response_model=dict)
def list_dealer_stock_requests(
    status_filter: Optional[str] = Query(None, alias="status"),
    dealer_id: Optional[int] = None,
    station_id: Optional[int] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=200),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_admin),
):
    _assert_stock_request_view_admin(current_user)
    query = select(DealerStockRequest)
    if status_filter:
        query = query.where(DealerStockRequest.status == status_filter.strip().lower())
    if dealer_id:
        query = query.where(DealerStockRequest.dealer_id == dealer_id)
    if station_id:
        query = query.where(DealerStockRequest.station_id == station_id)
    query = query.order_by(DealerStockRequest.created_at.desc())
    total = db.exec(select(func.count()).select_from(query.subquery())).one()
    rows = db.exec(query.offset(skip).limit(limit)).all()
    return {
        "items": [_serialize_dealer_stock_request(db, req) for req in rows],
        "total": int(total or 0),
        "skip": skip,
        "limit": limit,
    }


@router.post("/dealer-requests/{request_id}/approve", response_model=dict)
def approve_dealer_stock_request(
    request_id: int,
    payload: DealerStockRequestApprove,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_admin),
):
    _assert_stock_request_mutation_admin(current_user)
    req = db.get(DealerStockRequest, request_id)
    if not req:
        raise HTTPException(status_code=404, detail="stock_request_not_found")
    if req.status != StockRequestStatus.PENDING:
        raise HTTPException(status_code=409, detail="stock_request_not_pending")

    warehouse = db.get(Warehouse, payload.source_warehouse_id)
    if not warehouse or not warehouse.is_active:
        raise HTTPException(status_code=404, detail="warehouse_not_found_or_inactive")
    station = db.get(Station, req.station_id) if req.station_id else None
    if not station or station.dealer_id != req.dealer_id:
        raise HTTPException(status_code=409, detail="stock_request_station_invalid")

    req.status = StockRequestStatus.APPROVED
    req.source_warehouse_id = warehouse.id
    req.approved_by = current_user.id
    req.approved_at = datetime.now(UTC)
    req.admin_notes = payload.notes
    req.tenant_id = req.tenant_id or station.tenant_id or req.dealer_id
    req.updated_at = datetime.now(UTC)
    db.add(req)
    db.commit()
    db.refresh(req)
    return {"success": True, "data": _serialize_dealer_stock_request(db, req)}


@router.post("/dealer-requests/{request_id}/reject", response_model=dict)
def reject_dealer_stock_request(
    request_id: int,
    payload: DealerStockRequestReject,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_admin),
):
    _assert_stock_request_mutation_admin(current_user)
    req = db.get(DealerStockRequest, request_id)
    if not req:
        raise HTTPException(status_code=404, detail="stock_request_not_found")
    if req.status != StockRequestStatus.PENDING:
        raise HTTPException(status_code=409, detail="stock_request_not_pending")
    req.status = StockRequestStatus.REJECTED
    req.rejected_reason = payload.reason
    req.admin_notes = payload.reason
    req.updated_at = datetime.now(UTC)
    db.add(req)
    db.commit()
    db.refresh(req)
    return {"success": True, "data": _serialize_dealer_stock_request(db, req)}

def get_station_stock_stats(db: Session, station_id: int):
    batteries = db.exec(select(Battery).where(Battery.station_id == station_id)).all()
    
    total = len(batteries)
    available = sum(1 for b in batteries if b.status == BatteryStatus.AVAILABLE)
    rented = sum(1 for b in batteries if b.status == BatteryStatus.RENTED)
    maintenance = sum(1 for b in batteries if b.status == BatteryStatus.MAINTENANCE)
    
    utilization = (rented / total * 100) if total > 0 else 0.0
    
    config = db.exec(select(StationStockConfig).where(StationStockConfig.station_id == station_id)).first()
    max_capacity = config.max_capacity if config else 50
    reorder_point = config.reorder_point if config else int(max_capacity * 0.1)
    
    is_low_stock = available < reorder_point
    
    return {
        "total": total,
        "available": available,
        "rented": rented,
        "maintenance": maintenance,
        "utilization": utilization,
        "is_low_stock": is_low_stock,
        "config": config,
        "batteries": batteries
    }

@router.get("/overview", response_model=StockOverviewResponse)
def get_stock_overview(db: Session = Depends(get_db)):
    """Fleet-wide stock summary"""
    stations_count = db.exec(select(func.count(Station.id))).first() or 0
    total_batteries = db.exec(select(func.count(Battery.id))).first() or 0
    
    total_rented = db.exec(select(func.count(Battery.id)).where(Battery.status == BatteryStatus.RENTED)).first() or 0
    total_available = db.exec(select(func.count(Battery.id)).where(Battery.status == BatteryStatus.AVAILABLE)).first() or 0
    total_maintenance = db.exec(select(func.count(Battery.id)).where(Battery.status == BatteryStatus.MAINTENANCE)).first() or 0
    avg_utilization = (total_rented / total_batteries * 100) if total_batteries > 0 else 0.0
    
    warehouse_count = db.exec(select(func.count(Battery.id)).where(Battery.location_type == LocationType.WAREHOUSE)).first() or 0
    service_count = db.exec(select(func.count(Battery.id)).where(Battery.location_type == LocationType.SERVICE_CENTER)).first() or 0
    
    # Grouped battery stats by station ID
    b_stats = db.exec(
        select(Battery.station_id, Battery.status, func.count(Battery.id))
        .where(Battery.station_id.is_not(None)).group_by(Battery.station_id, Battery.status)
    ).all()
    
    station_avail = {}
    for s_id, status, count in b_stats:
        if s_id not in station_avail: station_avail[s_id] = 0
        if status == BatteryStatus.AVAILABLE:
            station_avail[s_id] += count

    configs = db.exec(select(StationStockConfig)).all()
    config_map = {c.station_id: c.reorder_point if c.reorder_point else int(c.max_capacity * 0.1) for c in configs}

    active_dismissals = {d.station_id for d in db.exec(select(StockAlertDismissal).where(StockAlertDismissal.is_active == True)).all()}

    low_stock_alerts = 0
    stations = db.exec(select(Station)).all()
    for station in stations:
        if station.id:
            avail = station_avail.get(station.id, 0)
            reorder = config_map.get(station.id, 5) # Default 5 (50 * 0.1)
            
            if avail < reorder and station.id not in active_dismissals:
                low_stock_alerts += 1

    return StockOverviewResponse(
        total_batteries=total_batteries,
        total_stations=stations_count,
        avg_utilization=avg_utilization,
        low_stock_alerts=low_stock_alerts,
        warehouse_count=warehouse_count,
        service_count=service_count,
        available_count=total_available,
        rented_count=total_rented,
        maintenance_count=total_maintenance
    )

@router.get("/stations", response_model=List[StationStockResponse])
def get_stations_stock(
    alert_only: bool = False,
    sort_by: str = "utilization", # 'name', 'utilization', 'available'
    db: Session = Depends(get_db)
):
    """List all stations with calculated stock health"""
    # Optimized query using group by to get stats
    stations = db.exec(select(Station)).all()
    results = []
    
    configs = {c.station_id: c for c in db.exec(select(StationStockConfig)).all()}
    counts = db.exec(
        select(Battery.station_id, Battery.status, func.count(Battery.id))
        .where(Battery.station_id.is_not(None))
        .group_by(Battery.station_id, Battery.status)
    ).all()
    
    count_map = {}
    for s_id, status, count in counts:
        if s_id not in count_map: count_map[s_id] = {"AVAILABLE": 0, "RENTED": 0, "MAINTENANCE": 0}
        if status == BatteryStatus.AVAILABLE: count_map[s_id]["AVAILABLE"] = count
        elif status == BatteryStatus.RENTED: count_map[s_id]["RENTED"] = count
        elif status == BatteryStatus.MAINTENANCE: count_map[s_id]["MAINTENANCE"] = count
    
    for station in stations:
        if not station.id: continue
        
        config = configs.get(station.id)
        stat = count_map.get(station.id, {"AVAILABLE": 0, "RENTED": 0, "MAINTENANCE": 0})
        
        available = stat["AVAILABLE"]
        rented = stat["RENTED"]
        maintenance = stat["MAINTENANCE"]
            
        total = available + rented + maintenance
        utilization = (rented / total * 100) if total > 0 else 0.0
        
        reorder_point = config.reorder_point if config else int((config.max_capacity if config else 50) * 0.1)
        is_low_stock = available < reorder_point
        
        if alert_only and not is_low_stock:
            continue
            
        results.append(StationStockResponse(
            station_id=station.id,
            station_name=station.name,
            address=station.address,
            latitude=station.latitude,
            longitude=station.longitude,
            available_count=available,
            rented_count=rented,
            maintenance_count=maintenance,
            total_assigned=total,
            utilization_percentage=utilization,
            is_low_stock=is_low_stock,
            config=config
        ))
        
    if sort_by == "utilization":
        results.sort(key=lambda x: x.utilization_percentage, reverse=True)
    elif sort_by == "available":
        results.sort(key=lambda x: x.available_count)
    else:
        results.sort(key=lambda x: x.station_name)
        
    return results

@router.get("/locations", response_model=List[LocationStockResponse])
def get_locations_stock(db: Session = Depends(get_db)):
    """Returns summaries for non-station locations (Warehouse, Service Center)"""
    results = []
    # Identify non-station types in use
    location_types = [LocationType.WAREHOUSE, LocationType.SERVICE_CENTER]
    
    counts = db.exec(
        select(Battery.location_type, Battery.status, func.count(Battery.id))
        .where(Battery.location_type.in_(location_types))
        .group_by(Battery.location_type, Battery.status)
    ).all()
    
    count_map = {}
    for l_type, status, count in counts:
        if l_type not in count_map: count_map[l_type] = {"AVAILABLE": 0, "RENTED": 0, "MAINTENANCE": 0}
        if status == BatteryStatus.AVAILABLE: count_map[l_type]["AVAILABLE"] = count
        elif status == BatteryStatus.RENTED: count_map[l_type]["RENTED"] = count
        elif status == BatteryStatus.MAINTENANCE: count_map[l_type]["MAINTENANCE"] = count
    
    for loc_type in location_types:
        stat = count_map.get(loc_type, {"AVAILABLE": 0, "RENTED": 0, "MAINTENANCE": 0})
        
        available = stat["AVAILABLE"]
        rented = stat["RENTED"]
        maintenance = stat["MAINTENANCE"]
            
        total = available + rented + maintenance
        if total > 0:
            name = "Warehouse Central" if loc_type == LocationType.WAREHOUSE else "Service Center 1"
            results.append(LocationStockResponse(
                location_name=name,
                location_type=loc_type.value,
                available_count=available,
                rented_count=rented,
                maintenance_count=maintenance,
                total_assigned=total,
                utilization_percentage=(rented/total*100)
            ))
            
    return results

@router.get("/stations/{station_id}", response_model=StationStockDetailResponse)
def get_station_stock_detail(station_id: int, db: Session = Depends(get_db)):
    """Deep detail for a specific station including 30-day forecast mock"""
    station = db.get(Station, station_id)
    if not station:
        raise HTTPException(status_code=404, detail="Station not found")
        
    stats = get_station_stock_stats(db, station_id)
    
    station_resp = StationStockResponse(
        station_id=station.id,
        station_name=station.name,
        address=station.address,
        latitude=station.latitude,
        longitude=station.longitude,
        available_count=stats["available"],
        rented_count=stats["rented"],
        maintenance_count=stats["maintenance"],
        total_assigned=stats["total"],
        utilization_percentage=stats["utilization"],
        is_low_stock=stats["is_low_stock"],
        config=stats["config"]
    )
    
    # Logic for FR-ADMIN-INV-003 requirements - Spread demand evenly over 30 days
    # Default avg 0.5 if no history, otherwise use a realistic rate based on rented
    avg_rentals_per_day = 0.5 if stats["rented"] == 0 else (stats["rented"] / 3.0)
    projected_demand = int(avg_rentals_per_day * 30)
    
    reorder_qty = stats["config"].reorder_quantity if stats["config"] else 20
    
    stockout_days = None
    if stats["available"] < projected_demand:
        stockout_days = int(stats["available"] / avg_rentals_per_day) if avg_rentals_per_day > 0 else None
        
    recommended_date = None
    if stockout_days is not None:
        recommended_date = datetime.now(UTC) + timedelta(days=stockout_days)

    forecast = StockForecastResponse(
        avg_rentals_per_day=avg_rentals_per_day,
        projected_demand_30d=projected_demand,
        recommended_reorder=reorder_qty,
        recommended_date=recommended_date,
        predicted_stockout_days=stockout_days
    )
    
    # Serialize batteries manually to avoid deep circular references in generic dict conversion
    battery_list = [{
        "id": str(b.id),
        "serial_number": b.serial_number,
        "status": b.status,
        "health_percentage": b.health_percentage,
        "type": "Li-ion",
        "updated_at": b.updated_at.isoformat() if hasattr(b, 'updated_at') else None
    } for b in stats["batteries"]]
    
    # Mocking a realistic 7-day utilization trend ending at current utilization
    base_util = stats["utilization"]
    trend = [max(0.0, min(100.0, base_util + (i * 5) - 15)) for i in range(6)]
    trend.append(base_util)

    return StationStockDetailResponse(
        station=station_resp,
        forecast=forecast,
        batteries=battery_list,
        utilization_trend=trend
    )

@router.put("/stations/{station_id}/config", response_model=StationStockConfigResponse)
def update_station_stock_config(
    station_id: int, 
    update_data: StationStockConfigUpdate,
    db: Session = Depends(get_db),
    admin_user = Depends(get_current_active_admin)
):
    """Update reorder triggers and capacity"""
    station = db.get(Station, station_id)
    if not station:
        raise HTTPException(status_code=404, detail="Station not found")
        
    config = db.exec(select(StationStockConfig).where(StationStockConfig.station_id == station_id)).first()
    
    if not config:
        config = StationStockConfig(station_id=station_id, updated_by=admin_user.id)
        db.add(config)
        
    data = update_data.model_dump(exclude_unset=True)
    for key, value in data.items():
        setattr(config, key, value)
        
    config.updated_by = admin_user.id
    config.updated_at = datetime.now(UTC)
    
    # Check if this resolves an existing alert
    if config.reorder_point and update_data.reorder_point:
        stats = get_station_stock_stats(db, station_id)
        if stats["available"] >= config.reorder_point:
            # Dismiss active alerts
            active_dismissals = db.exec(select(StockAlertDismissal).where(
                StockAlertDismissal.station_id == station_id,
                StockAlertDismissal.is_active == True
            )).all()
            for d in active_dismissals:
                d.is_active = False
                db.add(d)

    db.commit()
    db.refresh(config)
    return config

@router.post("/reorder", response_model=ReorderRequestResponse)
def create_reorder_request(
    request_in: ReorderRequestCreate,
    db: Session = Depends(get_db),
    admin_user = Depends(get_current_active_admin)
):
    """Create a reorder request for a station (FR-ADMIN-INV-003)"""
    new_request = ReorderRequest(
        station_id=request_in.station_id,
        requested_quantity=request_in.requested_quantity,
        reason=request_in.reason,
        created_by=admin_user.id
    )
    db.add(new_request)
    db.commit()
    db.refresh(new_request)
    # Background task would send SMS/Email here
    return new_request

@router.get("/alerts", response_model=List[StockAlertResponse])
def get_active_stock_alerts(db: Session = Depends(get_db)):
    """Return all active low-stock alerts"""
    b_stats = db.exec(select(Battery.station_id, Battery.status, func.count(Battery.id)).where(Battery.station_id.is_not(None)).group_by(Battery.station_id, Battery.status)).all()
    
    s_stats_map = {}
    for s_id, status, count in b_stats:
        if s_id not in s_stats_map: s_stats_map[s_id] = {"total": 0, "available": 0, "rented": 0, "maintenance": 0}
        s_stats_map[s_id]["total"] += count
        if status == BatteryStatus.AVAILABLE: s_stats_map[s_id]["available"] += count
        elif status == BatteryStatus.RENTED: s_stats_map[s_id]["rented"] += count
        elif status == BatteryStatus.MAINTENANCE: s_stats_map[s_id]["maintenance"] += count
            
    configs = db.exec(select(StationStockConfig)).all()
    config_map = {c.station_id: c for c in configs}
    active_dismissals = {d.station_id for d in db.exec(select(StockAlertDismissal).where(StockAlertDismissal.is_active == True)).all()}

    stations = db.exec(select(Station)).all()
    alerts = []
    
    for station in stations:
        if not station.id: continue
        
        stat = s_stats_map.get(station.id, {"total": 0, "available": 0, "rented": 0})
        utilization = (stat["rented"] / max(stat["total"], 1)) * 100
        config = config_map.get(station.id)
        reorder_point = config.reorder_point if config else int((config.max_capacity if config else 50) * 0.1)
        
        if stat["available"] < reorder_point and station.id not in active_dismissals:
            alerts.append(StockAlertResponse(
                station_id=station.id,
                station_name=station.name,
                current_count=stat["available"],
                capacity=config.max_capacity if config else 50,
                threshold=reorder_point,
                utilization_percentage=utilization
            ))
    return alerts

@router.post("/alerts/{station_id}/dismiss")
def dismiss_stock_alert(
    station_id: int,
    reason: str,
    db: Session = Depends(get_db),
    admin_user = Depends(get_current_active_admin)
):
    """Dismiss a low stock alert"""
    dismissal = StockAlertDismissal(
        station_id=station_id,
        reason=reason,
        dismissed_by=admin_user.id
    )
    db.add(dismissal)
    db.commit()
    return {"status": "success", "message": "Alert dismissed"}
