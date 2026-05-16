from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app import models, schemas
from app.api import deps

router = APIRouter()

@router.get("/", response_model=List[schemas.PartnerPrice])
def read_partner_prices(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Retrieve partner prices.
    """
    return db.query(models.PartnerPrice).offset(skip).limit(limit).all()

@router.post("/", response_model=schemas.PartnerPrice)
def create_partner_price(
    *,
    db: Session = Depends(deps.get_db),
    price_in: schemas.PartnerPriceCreate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Create new partner specific price.
    """
    # Check if exists
    existing = db.query(models.PartnerPrice).filter(
        models.PartnerPrice.partner_id == price_in.partner_id,
        models.PartnerPrice.product_id == price_in.product_id
    ).first()
    
    if existing:
        existing.custom_price = price_in.custom_price
        db.add(existing)
    else:
        db_obj = models.PartnerPrice(**price_in.dict())
        db.add(db_obj)
        
    db.commit()
    if existing:
        db.refresh(existing)
        return existing
    db.refresh(db_obj)
    return db_obj


@router.get("/{price_id}", response_model=schemas.PartnerPrice)
def read_partner_price(
    *,
    db: Session = Depends(deps.get_db),
    price_id: int,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get partner price by ID.
    """
    price = db.query(models.PartnerPrice).filter(models.PartnerPrice.id == price_id).first()
    if not price:
        raise HTTPException(status_code=404, detail="Partner price not found")
    return price


@router.put("/{price_id}", response_model=schemas.PartnerPrice)
def update_partner_price(
    *,
    db: Session = Depends(deps.get_db),
    price_id: int,
    price_in: schemas.PartnerPriceUpdate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update partner specific price.
    Only admin/staff can update partner pricing.
    """
    if current_user.role not in ["admin", "staff"]:
        raise HTTPException(
            status_code=403,
            detail="You do not have permission to update partner pricing."
        )
    
    price = db.query(models.PartnerPrice).filter(models.PartnerPrice.id == price_id).first()
    if not price:
        raise HTTPException(status_code=404, detail="Partner price not found")
    
    # Update price fields
    update_data = price_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(price, field, value)
    
    db.add(price)
    db.commit()
    db.refresh(price)
    return price

@router.delete("/{price_id}", response_model=schemas.PartnerPrice)
def delete_partner_price(
    *,
    db: Session = Depends(deps.get_db),
    price_id: int,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Delete partner price.
    """
    price = db.query(models.PartnerPrice).filter(models.PartnerPrice.id == price_id).first()
    if not price:
        raise HTTPException(status_code=404, detail="Price not found")
    db.delete(price)
    db.commit()
    return price
