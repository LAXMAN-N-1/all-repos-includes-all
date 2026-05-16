from typing import Any, List, Optional, Dict
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime
import json
import secrets
import hashlib

from app import schemas, models
from app.api import deps
from app.models.settings import Configuration, ShippingMethod, DeliveryZone, ApiAccessKey, SettingsActivity

router = APIRouter()

# --- Utility for Config JSON ---
def get_config_json(db: Session, key: str, default: dict) -> dict:
    conf = db.query(Configuration).filter(Configuration.key == key).first()
    if not conf:
        return default
    try:
        return json.loads(conf.value)
    except:
        return default

def set_config_json(db: Session, key: str, value: dict):
    conf = db.query(Configuration).filter(Configuration.key == key).first()
    if not conf:
        conf = Configuration(key=key, value=json.dumps(value))
        db.add(conf)
    else:
        conf.value = json.dumps(value)
    db.commit()

# --- Configurations ---

@router.get("/configs")
def read_configs(db: Session = Depends(deps.get_db)):
    return {c.key: c.value for c in db.query(Configuration).all()}

@router.get("/configs/details", response_model=List[schemas.ConfigOut])
def read_config_details(db: Session = Depends(deps.get_db)):
    return db.query(Configuration).all()

@router.put("/configs")
def update_config(config: schemas.ConfigUpdate, db: Session = Depends(deps.get_db), current_user = Depends(deps.get_current_active_superuser)):
    db_obj = db.query(Configuration).filter(Configuration.key == config.key).first()
    if not db_obj:
        db_obj = Configuration(key=config.key, value=config.value, description=config.description)
        db.add(db_obj)
    else:
        db_obj.value = config.value
        if config.description:
            db_obj.description = config.description
    db.commit()
    return {"status": "success"}

# --- Specific Settings ---

@router.get("/configs/store-info")
def get_store_info(db: Session = Depends(deps.get_db)):
    return get_config_json(db, "store_info", {
        "name": "B2B Meat Platform",
        "email": "admin@meat-platform.com",
        "phone": "+91 9154345918",
        "address": "Hyderabad, India"
    })

@router.put("/configs/store-info")
def update_store_info(info: dict, db: Session = Depends(deps.get_db), current_user = Depends(deps.get_current_active_superuser)):
    set_config_json(db, "store_info", info)
    return {"status": "success"}

@router.get("/notifications/preferences", response_model=schemas.NotificationPreferences)
def get_notification_prefs(db: Session = Depends(deps.get_db)):
    return get_config_json(db, "notification_prefs", schemas.NotificationPreferences().dict())

@router.put("/notifications/preferences")
def update_notification_prefs(prefs: schemas.NotificationPreferences, db: Session = Depends(deps.get_db), current_user = Depends(deps.get_current_active_superuser)):
    set_config_json(db, "notification_prefs", prefs.dict())
    return {"status": "success"}

@router.get("/tax/preferences", response_model=schemas.TaxPreferences)
def get_tax_prefs(db: Session = Depends(deps.get_db)):
    return get_config_json(db, "tax_prefs", schemas.TaxPreferences().dict())

@router.put("/tax/preferences")
def update_tax_prefs(prefs: schemas.TaxPreferences, db: Session = Depends(deps.get_db), current_user = Depends(deps.get_current_active_superuser)):
    set_config_json(db, "tax_prefs", prefs.dict())
    return {"status": "success"}

@router.get("/payments/preferences", response_model=schemas.PaymentPreferences)
def get_payment_prefs(db: Session = Depends(deps.get_db)):
    return get_config_json(db, "payment_prefs", schemas.PaymentPreferences().dict())

@router.put("/payments/preferences")
def update_payment_prefs(prefs: schemas.PaymentPreferences, db: Session = Depends(deps.get_db), current_user = Depends(deps.get_current_active_superuser)):
    set_config_json(db, "payment_prefs", prefs.dict())
    return {"status": "success"}

# --- Overview & Activity ---

@router.get("/overview", response_model=schemas.SettingsOverview)
def get_settings_overview(db: Session = Depends(deps.get_db)):
    return schemas.SettingsOverview(
        store_profile_complete=True,
        config_entries=db.query(Configuration).count(),
        shipping_methods_total=db.query(ShippingMethod).count(),
        shipping_methods_active=db.query(ShippingMethod).filter(ShippingMethod.is_active == True).count(),
        delivery_zones_total=db.query(DeliveryZone).count(),
        staff_users_total=db.query(models.User).count(),
        staff_users_active=db.query(models.User).filter(models.User.is_active == True).count(),
        api_keys_total=db.query(ApiAccessKey).count(),
        api_keys_active=db.query(ApiAccessKey).filter(ApiAccessKey.is_active == True).count()
    )

@router.get("/activity", response_model=List[schemas.SettingsActivityOut])
def get_settings_activity(limit: int = 20, db: Session = Depends(deps.get_db)):
    activities = db.query(SettingsActivity).order_by(SettingsActivity.created_at.desc()).limit(limit).all()
    return [
        schemas.SettingsActivityOut(
            id=a.id,
            section=a.section,
            event=a.event,
            subject=a.subject,
            timestamp=a.created_at,
            actor=a.actor,
            metadata=json.loads(a.metadata_json) if a.metadata_json else {}
        ) for a in activities
    ]

# --- Roles ---

@router.get("/roles", response_model=List[schemas.RoleDefinitionOut])
def get_roles_catalog():
    return [
        schemas.RoleDefinitionOut(role="admin", permissions=["all"]),
        schemas.RoleDefinitionOut(role="manager", permissions=["orders", "products", "customers"]),
        schemas.RoleDefinitionOut(role="staff", permissions=["orders", "customers"]),
        schemas.RoleDefinitionOut(role="driver", permissions=["delivery"])
    ]

# --- API Keys ---

def generate_api_key():
    token = secrets.token_urlsafe(32)
    prefix = token[:8]
    hashed = hashlib.sha256(token.encode()).hexdigest()
    return token, prefix, hashed

@router.get("/api-keys", response_model=List[schemas.ApiAccessKeyOut])
def list_api_keys(include_inactive: bool = True, db: Session = Depends(deps.get_db)):
    query = db.query(ApiAccessKey)
    if not include_inactive:
        query = query.filter(ApiAccessKey.is_active == True)
    keys = query.order_by(ApiAccessKey.created_at.desc()).all()
    
    return [
        schemas.ApiAccessKeyOut(
            id=k.id,
            name=k.name,
            key_prefix=k.key_prefix,
            scopes=k.scopes.split(",") if k.scopes else [],
            is_active=k.is_active,
            is_expired=k.expires_at < datetime.utcnow() if k.expires_at else False,
            last_used_at=k.last_used_at,
            expires_at=k.expires_at,
            created_at=k.created_at
        ) for k in keys
    ]

@router.post("/api-keys", response_model=schemas.ApiAccessKeyCreateResult)
def create_api_key(key_in: schemas.ApiAccessKeyCreate, db: Session = Depends(deps.get_db), current_user = Depends(deps.get_current_active_superuser)):
    raw_key, prefix, hashed = generate_api_key()
    db_obj = ApiAccessKey(
        name=key_in.name,
        key_prefix=prefix,
        key_hash=hashed,
        scopes=",".join(key_in.scopes),
        expires_at=key_in.expires_at
    )
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    
    out_key = schemas.ApiAccessKeyOut(
        id=db_obj.id,
        name=db_obj.name,
        key_prefix=db_obj.key_prefix,
        scopes=key_in.scopes,
        is_active=db_obj.is_active,
        is_expired=False,
        created_at=db_obj.created_at,
        expires_at=db_obj.expires_at
    )
    return schemas.ApiAccessKeyCreateResult(api_key=raw_key, key=out_key)

@router.put("/api-keys/{key_id}/revoke")
def revoke_api_key(key_id: int, db: Session = Depends(deps.get_db), current_user = Depends(deps.get_current_active_superuser)):
    key = db.query(ApiAccessKey).filter(ApiAccessKey.id == key_id).first()
    if not key:
        raise HTTPException(status_code=404, detail="API Key not found")
    key.is_active = False
    db.commit()
    return {"status": "success"}

@router.put("/api-keys/{key_id}/activate")
def activate_api_key(key_id: int, db: Session = Depends(deps.get_db), current_user = Depends(deps.get_current_active_superuser)):
    key = db.query(ApiAccessKey).filter(ApiAccessKey.id == key_id).first()
    if not key:
        raise HTTPException(status_code=404, detail="API Key not found")
    key.is_active = True
    db.commit()
    return {"status": "success"}

# --- Shipping & Delivery (Keep Existing) ---

@router.get("/shipping", response_model=List[schemas.ShippingMethodOut])
def read_shipping_methods(db: Session = Depends(deps.get_db)):
    return db.query(ShippingMethod).all()

@router.post("/shipping", response_model=schemas.ShippingMethodOut)
def create_shipping_method(
    method_in: schemas.ShippingMethodCreate, 
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_superuser)
):
    db_obj = ShippingMethod(**method_in.dict())
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

@router.get("/shipping/{shipping_id}", response_model=schemas.ShippingMethodOut)
def read_shipping_method(
    shipping_id: int, 
    db: Session = Depends(deps.get_db)
):
    """Get shipping method by ID."""
    method = db.query(ShippingMethod).filter(ShippingMethod.id == shipping_id).first()
    if not method:
        raise HTTPException(status_code=404, detail="Shipping method not found")
    return method

@router.put("/shipping/{shipping_id}", response_model=schemas.ShippingMethodOut)
def update_shipping_method(
    shipping_id: int,
    method_in: schemas.ShippingMethodUpdate,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_superuser)
):
    """Update a shipping method."""
    method = db.query(ShippingMethod).filter(ShippingMethod.id == shipping_id).first()
    if not method:
        raise HTTPException(status_code=404, detail="Shipping method not found")
    
    update_data = method_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(method, field, value)
    
    db.add(method)
    db.commit()
    db.refresh(method)
    return method

@router.delete("/shipping/{shipping_id}", response_model=schemas.ShippingMethodOut)
def delete_shipping_method(
    shipping_id: int,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_superuser)
):
    """Delete a shipping method."""
    method = db.query(ShippingMethod).filter(ShippingMethod.id == shipping_id).first()
    if not method:
        raise HTTPException(status_code=404, detail="Shipping method not found")
    
    db.delete(method)
    db.commit()
    return method

@router.get("/delivery-zones", response_model=List[schemas.DeliveryZoneOut])
def read_delivery_zones(db: Session = Depends(deps.get_db)):
    return db.query(DeliveryZone).all()

@router.post("/delivery-zones", response_model=schemas.DeliveryZoneOut)
def create_delivery_zone(
    zone_in: schemas.DeliveryZoneCreate,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_superuser),
):
    db_obj = DeliveryZone(**zone_in.dict())
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

@router.put("/delivery-zones/{zone_id}", response_model=schemas.DeliveryZoneOut)
def update_delivery_zone(
    zone_id: int,
    zone_in: schemas.DeliveryZoneUpdate,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_superuser),
):
    zone = db.query(DeliveryZone).filter(DeliveryZone.id == zone_id).first()
    if not zone:
        raise HTTPException(status_code=404, detail="Delivery zone not found")
    
    update_data = zone_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(zone, field, value)
    
    db.add(zone)
    db.commit()
    db.refresh(zone)
    return zone

@router.delete("/delivery-zones/{zone_id}", response_model=schemas.DeliveryZoneOut)
def delete_delivery_zone(
    zone_id: int,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_superuser),
):
    zone = db.query(DeliveryZone).filter(DeliveryZone.id == zone_id).first()
    if not zone:
        raise HTTPException(status_code=404, detail="Delivery zone not found")
    
    db.delete(zone)
    db.commit()
    return zone
