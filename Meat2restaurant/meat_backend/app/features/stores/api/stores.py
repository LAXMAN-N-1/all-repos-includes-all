"""
Store Location Master — REST API Endpoints
Prefix: /stores
"""
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session, joinedload
from datetime import datetime, time as dt_time, date as dt_date
import json
import re

from app.api import deps
from app.features.stores.models.store import (
    Store, StoreTiming, StoreSpecialHours, StoreService,
    StoreDeliveryZone, StoreWhatsappConfig, StoreMedia, StoreStaff, StoreAuditLog
)
from app.features.stores.schemas.store import (
    StoreCreate, StoreUpdate, StoreOut, StoreSummaryOut,
    StoreTimingOut, StoreSpecialHoursOut,
    StoreServiceOut, StoreDeliveryZoneCreate, StoreDeliveryZoneUpdate,
    StoreDeliveryZoneOut, StoreWhatsappConfigOut,
    StoreMediaOut, StoreStaffOut,
    PaginatedStoresResponse, StoreStatusUpdate, WhatsappBranchOut
)

router = APIRouter()


# ─── Helpers ───────────────────────────────────────────────────────────

def _slugify(text: str) -> str:
    text = text.lower().strip()
    text = re.sub(r'[^\w\s-]', '', text)
    return re.sub(r'[-\s]+', '-', text)


def _parse_time(t: Optional[str]) -> Optional[dt_time]:
    if not t:
        return None
    parts = t.split(":")
    return dt_time(int(parts[0]), int(parts[1]))


def _build_summary(store: Store) -> StoreSummaryOut:
    svc = store.services
    return StoreSummaryOut(
        id=store.id,
        name=store.name,
        store_code=store.store_code,
        store_type=store.store_type or "outlet",
        city=store.city,
        status=store.status or "active",
        display_order=store.display_order or 0,
        cover_image_url=store.cover_image_url,
        created_at=store.created_at,
        whatsapp_orders_enabled=svc.whatsapp_orders_enabled if svc else False,
        web_orders_enabled=svc.web_orders_enabled if svc else False,
        app_orders_enabled=svc.app_orders_enabled if svc else False,
    )


def _build_full(store: Store) -> dict:
    """Manually build the full response dict for a store with all nested entities."""
    timings = []
    for t in (store.timings or []):
        timings.append({
            "id": t.id,
            "day_of_week": t.day_of_week,
            "is_open": t.is_open,
            "open_time": t.open_time.strftime("%H:%M") if t.open_time else None,
            "close_time": t.close_time.strftime("%H:%M") if t.close_time else None,
        })

    special_hours = []
    for sh in (store.special_hours or []):
        special_hours.append({
            "id": sh.id,
            "date": sh.date.isoformat() if sh.date else None,
            "label": sh.label,
            "is_closed": sh.is_closed,
            "open_time": sh.open_time.strftime("%H:%M") if sh.open_time else None,
            "close_time": sh.close_time.strftime("%H:%M") if sh.close_time else None,
        })

    svc = store.services
    services = None
    if svc:
        services = {
            "id": svc.id,
            "web_orders_enabled": svc.web_orders_enabled,
            "app_orders_enabled": svc.app_orders_enabled,
            "whatsapp_orders_enabled": svc.whatsapp_orders_enabled,
            "walkin_enabled": svc.walkin_enabled,
            "home_delivery_enabled": svc.home_delivery_enabled,
            "pickup_enabled": svc.pickup_enabled,
            "bulk_orders_enabled": svc.bulk_orders_enabled,
            "cod_enabled": svc.cod_enabled,
            "card_on_delivery_enabled": svc.card_on_delivery_enabled,
            "online_payment_enabled": svc.online_payment_enabled,
        }

    zones = []
    for z in (store.delivery_zones or []):
        zones.append({
            "id": z.id,
            "store_id": z.store_id,
            "zone_name": z.zone_name,
            "polygon_geojson": z.polygon_geojson,
            "delivery_fee": z.delivery_fee,
            "min_order": z.min_order,
            "estimated_time_minutes": z.estimated_time_minutes,
            "priority": z.priority,
        })

    wa = store.whatsapp_config
    wa_config = None
    if wa:
        wa_config = {
            "id": wa.id,
            "whatsapp_phone": wa.whatsapp_phone,
            "business_account_id": wa.business_account_id,
            "greeting_template": wa.greeting_template,
            "default_language": wa.default_language,
            "keyword_triggers": wa.keyword_triggers,
        }

    media_list = [
        {"id": m.id, "media_url": m.media_url, "media_type": m.media_type,
         "display_order": m.display_order, "is_cover": m.is_cover}
        for m in (store.media or [])
    ]

    staff_list = [
        {"id": s.id, "name": s.name, "role": s.role, "phone": s.phone}
        for s in (store.staff or [])
    ]

    return {
        "id": store.id,
        "name": store.name,
        "store_code": store.store_code,
        "slug": store.slug,
        "store_type": store.store_type,
        "address_line1": store.address_line1,
        "address_line2": store.address_line2,
        "city": store.city,
        "state": store.state,
        "zip_code": store.zip_code,
        "country": store.country,
        "latitude": store.latitude,
        "longitude": store.longitude,
        "google_place_id": store.google_place_id,
        "display_order": store.display_order,
        "status": store.status,
        "cover_image_url": store.cover_image_url,
        "created_at": store.created_at.isoformat() if store.created_at else None,
        "updated_at": store.updated_at.isoformat() if store.updated_at else None,
        "timings": timings,
        "special_hours": special_hours,
        "services": services,
        "delivery_zones": zones,
        "whatsapp_config": wa_config,
        "media": media_list,
        "staff": staff_list,
    }


def _ensure_unique_code(db: Session, code: str, exclude_id: Optional[int] = None) -> str:
    query = db.query(Store).filter(Store.store_code == code, Store.is_deleted == False)
    if exclude_id:
        query = query.filter(Store.id != exclude_id)
    if query.first():
        raise HTTPException(status_code=400, detail=f"Store code '{code}' already exists")
    return code


# ─── WhatsApp Branch Lookup (must be before /{id} to avoid route collision) ──

@router.get("/whatsapp-branches", response_model=List[WhatsappBranchOut])
def get_whatsapp_branches(
    city: Optional[str] = None,
    keyword: Optional[str] = None,
    db: Session = Depends(deps.get_db),
):
    """Lookup active stores with WhatsApp enabled — used by the WhatsApp bot."""
    query = (
        db.query(Store)
        .join(StoreService, StoreService.store_id == Store.id)
        .filter(
            Store.is_deleted == False,
            Store.status == "active",
            StoreService.whatsapp_orders_enabled == True,
        )
    )
    if city:
        query = query.filter(Store.city.ilike(f"%{city}%"))

    stores = query.all()

    results = []
    for s in stores:
        wa = s.whatsapp_config
        # keyword match
        if keyword and wa and wa.keyword_triggers:
            try:
                triggers = json.loads(wa.keyword_triggers)
            except Exception:
                triggers = []
            if not any(keyword.lower() in t.lower() for t in triggers):
                continue

        results.append(WhatsappBranchOut(
            store_id=s.id,
            display_name=s.name,
            whatsapp_phone=wa.whatsapp_phone if wa else None,
            greeting_template=wa.greeting_template if wa else None,
        ))

    return results


# ─── List Stores ───────────────────────────────────────────────────────

@router.get("", response_model=PaginatedStoresResponse)
def list_stores(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    search: Optional[str] = None,
    status: Optional[str] = None,
    city: Optional[str] = None,
    channel: Optional[str] = None,
    db: Session = Depends(deps.get_db),
):
    query = (
        db.query(Store)
        .options(joinedload(Store.services))
        .filter(Store.is_deleted == False)
    )

    if search:
        query = query.filter(
            (Store.name.ilike(f"%{search}%")) | (Store.store_code.ilike(f"%{search}%"))
        )
    if status:
        query = query.filter(Store.status == status)
    if city:
        query = query.filter(Store.city.ilike(f"%{city}%"))
    if channel:
        query = query.join(StoreService, StoreService.store_id == Store.id)
        channel_col = {
            "web": StoreService.web_orders_enabled,
            "app": StoreService.app_orders_enabled,
            "whatsapp": StoreService.whatsapp_orders_enabled,
            "walkin": StoreService.walkin_enabled,
            "delivery": StoreService.home_delivery_enabled,
            "pickup": StoreService.pickup_enabled,
            "bulk": StoreService.bulk_orders_enabled,
        }.get(channel)
        if channel_col is not None:
            query = query.filter(channel_col == True)

    total = query.count()
    stores = (
        query.order_by(Store.display_order.asc(), Store.name.asc())
        .offset((page - 1) * limit)
        .limit(limit)
        .all()
    )

    items = [_build_summary(s) for s in stores]
    return PaginatedStoresResponse(total=total, page=page, limit=limit, items=items)


# ─── Create Store ──────────────────────────────────────────────────────

@router.post("", response_model=dict)
def create_store(
    payload: StoreCreate,
    db: Session = Depends(deps.get_db),
    current_user=Depends(deps.get_current_active_superuser),
):
    # Generate store code if not provided
    code = payload.store_code or _slugify(payload.name).upper().replace("-", "")[:10]
    _ensure_unique_code(db, code)

    store = Store(
        name=payload.name,
        store_code=code,
        slug=_slugify(payload.name),
        store_type=payload.store_type,
        address_line1=payload.address_line1,
        address_line2=payload.address_line2,
        city=payload.city,
        state=payload.state,
        zip_code=payload.zip_code,
        country=payload.country,
        latitude=payload.latitude,
        longitude=payload.longitude,
        google_place_id=payload.google_place_id,
        display_order=payload.display_order,
        status=payload.status,
        cover_image_url=payload.cover_image_url,
    )
    db.add(store)
    db.flush()  # get store.id

    # Timings
    if payload.timings:
        for t in payload.timings:
            db.add(StoreTiming(
                store_id=store.id,
                day_of_week=t.day_of_week,
                is_open=t.is_open,
                open_time=_parse_time(t.open_time),
                close_time=_parse_time(t.close_time),
            ))

    # Special hours
    if payload.special_hours:
        for sh in payload.special_hours:
            db.add(StoreSpecialHours(
                store_id=store.id,
                date=dt_date.fromisoformat(sh.date),
                label=sh.label,
                is_closed=sh.is_closed,
                open_time=_parse_time(sh.open_time),
                close_time=_parse_time(sh.close_time),
            ))

    # Services
    svc_data = payload.services
    if svc_data:
        db.add(StoreService(store_id=store.id, **svc_data.dict()))
    else:
        db.add(StoreService(store_id=store.id))  # default all-off

    # Delivery zones
    if payload.delivery_zones:
        for z in payload.delivery_zones:
            db.add(StoreDeliveryZone(store_id=store.id, **z.dict()))

    # WhatsApp config
    if payload.whatsapp_config:
        db.add(StoreWhatsappConfig(store_id=store.id, **payload.whatsapp_config.dict()))

    # Media
    if payload.media:
        for m in payload.media:
            db.add(StoreMedia(store_id=store.id, **m.dict()))

    # Staff
    if payload.staff:
        for s in payload.staff:
            db.add(StoreStaff(store_id=store.id, **s.dict()))

    # Audit log
    db.add(StoreAuditLog(
        store_id=store.id,
        admin_user_id=current_user.id if current_user else None,
        action="create",
        changes_json=json.dumps({"created": payload.dict()}),
    ))

    db.commit()
    db.refresh(store)

    # Reload with all relationships
    store = (
        db.query(Store)
        .options(
            joinedload(Store.timings),
            joinedload(Store.special_hours),
            joinedload(Store.services),
            joinedload(Store.delivery_zones),
            joinedload(Store.whatsapp_config),
            joinedload(Store.media),
            joinedload(Store.staff),
        )
        .filter(Store.id == store.id)
        .first()
    )

    return _build_full(store)


# ─── Get Single Store ──────────────────────────────────────────────────

@router.get("/{store_id}", response_model=dict)
def get_store(store_id: int, db: Session = Depends(deps.get_db)):
    store = (
        db.query(Store)
        .options(
            joinedload(Store.timings),
            joinedload(Store.special_hours),
            joinedload(Store.services),
            joinedload(Store.delivery_zones),
            joinedload(Store.whatsapp_config),
            joinedload(Store.media),
            joinedload(Store.staff),
        )
        .filter(Store.id == store_id, Store.is_deleted == False)
        .first()
    )
    if not store:
        raise HTTPException(status_code=404, detail="Store not found")
    return _build_full(store)


# ─── Update Store (Partial) ───────────────────────────────────────────

@router.patch("/{store_id}", response_model=dict)
def update_store(
    store_id: int,
    payload: StoreUpdate,
    db: Session = Depends(deps.get_db),
    current_user=Depends(deps.get_current_active_superuser),
):
    store = db.query(Store).filter(Store.id == store_id, Store.is_deleted == False).first()
    if not store:
        raise HTTPException(status_code=404, detail="Store not found")

    update_data = payload.dict(exclude_unset=True)
    changes = {}

    # Scalar fields
    scalar_fields = [
        "name", "store_type", "address_line1", "address_line2", "city", "state",
        "zip_code", "country", "latitude", "longitude", "google_place_id",
        "display_order", "status", "cover_image_url",
    ]
    for field in scalar_fields:
        if field in update_data:
            old = getattr(store, field)
            new = update_data[field]
            if old != new:
                changes[field] = {"old": str(old), "new": str(new)}
            setattr(store, field, new)

    # Update slug if name changed
    if "name" in update_data:
        store.slug = _slugify(update_data["name"])

    # Replace timings
    if "timings" in update_data and update_data["timings"] is not None:
        db.query(StoreTiming).filter(StoreTiming.store_id == store_id).delete()
        for t in payload.timings:
            db.add(StoreTiming(
                store_id=store_id,
                day_of_week=t.day_of_week,
                is_open=t.is_open,
                open_time=_parse_time(t.open_time),
                close_time=_parse_time(t.close_time),
            ))
        changes["timings"] = "replaced"

    # Replace special hours
    if "special_hours" in update_data and update_data["special_hours"] is not None:
        db.query(StoreSpecialHours).filter(StoreSpecialHours.store_id == store_id).delete()
        for sh in payload.special_hours:
            db.add(StoreSpecialHours(
                store_id=store_id,
                date=dt_date.fromisoformat(sh.date),
                label=sh.label,
                is_closed=sh.is_closed,
                open_time=_parse_time(sh.open_time),
                close_time=_parse_time(sh.close_time),
            ))
        changes["special_hours"] = "replaced"

    # Replace services
    if "services" in update_data and update_data["services"] is not None:
        db.query(StoreService).filter(StoreService.store_id == store_id).delete()
        db.add(StoreService(store_id=store_id, **payload.services.dict()))
        changes["services"] = "replaced"

    # Replace whatsapp config
    if "whatsapp_config" in update_data and update_data["whatsapp_config"] is not None:
        db.query(StoreWhatsappConfig).filter(StoreWhatsappConfig.store_id == store_id).delete()
        db.add(StoreWhatsappConfig(store_id=store_id, **payload.whatsapp_config.dict()))
        changes["whatsapp_config"] = "replaced"

    # Replace media
    if "media" in update_data and update_data["media"] is not None:
        db.query(StoreMedia).filter(StoreMedia.store_id == store_id).delete()
        for m in payload.media:
            db.add(StoreMedia(store_id=store_id, **m.dict()))
        changes["media"] = "replaced"

    # Replace staff
    if "staff" in update_data and update_data["staff"] is not None:
        db.query(StoreStaff).filter(StoreStaff.store_id == store_id).delete()
        for s in payload.staff:
            db.add(StoreStaff(store_id=store_id, **s.dict()))
        changes["staff"] = "replaced"

    # Audit log
    if changes:
        db.add(StoreAuditLog(
            store_id=store_id,
            admin_user_id=current_user.id if current_user else None,
            action="update",
            changes_json=json.dumps(changes),
        ))

    db.commit()

    # Reload
    store = (
        db.query(Store)
        .options(
            joinedload(Store.timings),
            joinedload(Store.special_hours),
            joinedload(Store.services),
            joinedload(Store.delivery_zones),
            joinedload(Store.whatsapp_config),
            joinedload(Store.media),
            joinedload(Store.staff),
        )
        .filter(Store.id == store_id)
        .first()
    )
    return _build_full(store)


# ─── Toggle Status ─────────────────────────────────────────────────────

@router.patch("/{store_id}/status")
def toggle_store_status(
    store_id: int,
    body: StoreStatusUpdate,
    db: Session = Depends(deps.get_db),
    current_user=Depends(deps.get_current_active_superuser),
):
    store = db.query(Store).filter(Store.id == store_id, Store.is_deleted == False).first()
    if not store:
        raise HTTPException(status_code=404, detail="Store not found")

    old_status = store.status
    store.status = body.status
    db.add(StoreAuditLog(
        store_id=store_id,
        admin_user_id=current_user.id if current_user else None,
        action="status_change",
        changes_json=json.dumps({"old": old_status, "new": body.status}),
    ))
    db.commit()
    return {"status": "success", "new_status": body.status}


# ─── Soft Delete ───────────────────────────────────────────────────────

@router.delete("/{store_id}")
def delete_store(
    store_id: int,
    db: Session = Depends(deps.get_db),
    current_user=Depends(deps.get_current_active_superuser),
):
    store = db.query(Store).filter(Store.id == store_id, Store.is_deleted == False).first()
    if not store:
        raise HTTPException(status_code=404, detail="Store not found")

    store.is_deleted = True
    db.add(StoreAuditLog(
        store_id=store_id,
        admin_user_id=current_user.id if current_user else None,
        action="delete",
        changes_json=json.dumps({"deleted": True}),
    ))
    db.commit()
    return {"status": "success"}


# ─── Delivery Zone Sub-Endpoints ───────────────────────────────────────

@router.post("/{store_id}/zones", response_model=StoreDeliveryZoneOut)
def add_delivery_zone(
    store_id: int,
    zone_in: StoreDeliveryZoneCreate,
    db: Session = Depends(deps.get_db),
    current_user=Depends(deps.get_current_active_superuser),
):
    store = db.query(Store).filter(Store.id == store_id, Store.is_deleted == False).first()
    if not store:
        raise HTTPException(status_code=404, detail="Store not found")

    zone = StoreDeliveryZone(store_id=store_id, **zone_in.dict())
    db.add(zone)
    db.commit()
    db.refresh(zone)
    return zone


@router.put("/{store_id}/zones/{zone_id}", response_model=StoreDeliveryZoneOut)
def update_delivery_zone(
    store_id: int,
    zone_id: int,
    zone_in: StoreDeliveryZoneUpdate,
    db: Session = Depends(deps.get_db),
    current_user=Depends(deps.get_current_active_superuser),
):
    zone = db.query(StoreDeliveryZone).filter(
        StoreDeliveryZone.id == zone_id,
        StoreDeliveryZone.store_id == store_id,
    ).first()
    if not zone:
        raise HTTPException(status_code=404, detail="Zone not found")

    for field, value in zone_in.dict(exclude_unset=True).items():
        setattr(zone, field, value)
    db.commit()
    db.refresh(zone)
    return zone


@router.delete("/{store_id}/zones/{zone_id}")
def delete_delivery_zone(
    store_id: int,
    zone_id: int,
    db: Session = Depends(deps.get_db),
    current_user=Depends(deps.get_current_active_superuser),
):
    zone = db.query(StoreDeliveryZone).filter(
        StoreDeliveryZone.id == zone_id,
        StoreDeliveryZone.store_id == store_id,
    ).first()
    if not zone:
        raise HTTPException(status_code=404, detail="Zone not found")

    db.delete(zone)
    db.commit()
    return {"status": "success"}
