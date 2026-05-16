from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from app.api import deps
from app import models, schemas
from datetime import datetime

router = APIRouter()

# --- Shipments ---

@router.get("/shipments", response_model=List[schemas.Shipment])
def read_shipments(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
):
    return db.query(models.Shipment).offset(skip).limit(limit).all()

@router.post("/shipments", response_model=schemas.Shipment)
def create_shipment(
    shipment_in: schemas.ShipmentCreate,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_user),
):
    """Create a new shipment. Admin/staff only."""
    if current_user.role not in ["admin", "staff"]:
        raise HTTPException(status_code=403, detail="Permission denied")
    
    db_obj = models.Shipment(**shipment_in.dict())
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

@router.get("/shipments/{shipment_id}", response_model=schemas.Shipment)
def read_shipment(
    shipment_id: int,
    db: Session = Depends(deps.get_db),
):
    """Get shipment by ID."""
    shipment = db.query(models.Shipment).filter(models.Shipment.id == shipment_id).first()
    if not shipment:
        raise HTTPException(status_code=404, detail="Shipment not found")
    return shipment

@router.put("/shipments/{shipment_id}", response_model=schemas.Shipment)
def update_shipment(
    shipment_id: int,
    shipment_in: schemas.ShipmentUpdate,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_user),
):
    """Update a shipment (tracking, status, dates). Admin/staff only."""
    if current_user.role not in ["admin", "staff"]:
        raise HTTPException(status_code=403, detail="Permission denied")
    
    shipment = db.query(models.Shipment).filter(models.Shipment.id == shipment_id).first()
    if not shipment:
        raise HTTPException(status_code=404, detail="Shipment not found")
    
    update_data = shipment_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(shipment, field, value)
    
    db.add(shipment)
    db.commit()
    db.refresh(shipment)
    return shipment

@router.delete("/shipments/{shipment_id}", response_model=schemas.Shipment)
def delete_shipment(
    shipment_id: int,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_superuser),
):
    """Cancel/delete a shipment. Superuser only."""
    shipment = db.query(models.Shipment).filter(models.Shipment.id == shipment_id).first()
    if not shipment:
        raise HTTPException(status_code=404, detail="Shipment not found")
    
    db.delete(shipment)
    db.commit()
    return shipment

# --- Gift Cards ---

@router.get("/gift-cards", response_model=List[schemas.GiftCard])
def read_gift_cards(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
):
    return db.query(models.GiftCard).offset(skip).limit(limit).all()

@router.post("/gift-cards", response_model=schemas.GiftCard)
def create_gift_card(
    gift_card_in: schemas.GiftCardCreate,
    db: Session = Depends(deps.get_db),
):
    # Check for duplicate code
    existing = db.query(models.GiftCard).filter(models.GiftCard.code == gift_card_in.code).first()
    if existing:
        raise HTTPException(status_code=400, detail="Gift card code already exists")
    
    db_obj = models.GiftCard(**gift_card_in.dict())
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

@router.post("/gift-cards/redeem", response_model=schemas.GiftCard)
def redeem_gift_card(
    redeem_in: schemas.GiftCardRedeem,
    db: Session = Depends(deps.get_db),
):
    """
    Redeem an amount from a gift card.
    Reduces current_balance or fails if invalid/insufficient funds.
    """
    card = db.query(models.GiftCard).filter(models.GiftCard.code == redeem_in.code).first()
    if not card:
        raise HTTPException(status_code=404, detail="Gift card not found")
    
    if not card.is_active:
        raise HTTPException(status_code=400, detail="Gift card is inactive")
    
    if card.expiry_date and card.expiry_date < datetime.utcnow():
        raise HTTPException(status_code=400, detail="Gift card has expired")
        
    if card.current_balance < redeem_in.amount:
        raise HTTPException(status_code=400, detail="Insufficient balance")
    
    card.current_balance -= redeem_in.amount
    db.commit()
    db.refresh(card)
    
    return card

@router.get("/gift-cards/{gift_card_id}", response_model=schemas.GiftCard)
def read_gift_card(
    gift_card_id: int,
    db: Session = Depends(deps.get_db),
):
    """Get gift card by ID."""
    card = db.query(models.GiftCard).filter(models.GiftCard.id == gift_card_id).first()
    if not card:
        raise HTTPException(status_code=404, detail="Gift card not found")
    return card

@router.put("/gift-cards/{gift_card_id}", response_model=schemas.GiftCard)
def update_gift_card(
    gift_card_id: int,
    gift_card_in: schemas.GiftCardUpdate,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_user),
):
    """Update a gift card (balance, expiry, status). Admin/staff only."""
    if current_user.role not in ["admin", "staff"]:
        raise HTTPException(status_code=403, detail="Permission denied")
    
    card = db.query(models.GiftCard).filter(models.GiftCard.id == gift_card_id).first()
    if not card:
        raise HTTPException(status_code=404, detail="Gift card not found")
    
    update_data = gift_card_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(card, field, value)
    
    db.add(card)
    db.commit()
    db.refresh(card)
    return card

@router.delete("/gift-cards/{gift_card_id}", response_model=schemas.GiftCard)
def delete_gift_card(
    gift_card_id: int,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_superuser),
):
    """Deactivate a gift card. Superuser only."""
    card = db.query(models.GiftCard).filter(models.GiftCard.id == gift_card_id).first()
    if not card:
        raise HTTPException(status_code=404, detail="Gift card not found")
    
    # Soft delete by deactivating
    card.is_active = False
    db.add(card)
    db.commit()
    db.refresh(card)
    return card
