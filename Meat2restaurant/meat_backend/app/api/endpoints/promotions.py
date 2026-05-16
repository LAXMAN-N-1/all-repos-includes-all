from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from datetime import datetime
from app import schemas
from app.api import deps
from app.models.promotion import Promotion

router = APIRouter()

@router.get("/", response_model=List[schemas.PromotionOut])
def read_promotions(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
):
    return db.query(Promotion).offset(skip).limit(limit).all()

@router.post("/validate", response_model=schemas.PromotionOut)
def validate_promotion(
    code: str = Body(..., embed=True),
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_user),
):
    """Validate a promotion code."""
    promotion = db.query(Promotion).filter(
        Promotion.code == code,
        Promotion.is_active == True
    ).first()
    
    if not promotion:
        raise HTTPException(status_code=404, detail="Invalid promo code")
        
    now = datetime.utcnow()
    if promotion.start_date and promotion.start_date > now:
        raise HTTPException(status_code=400, detail="Promotion not yet active")
    if promotion.end_date and promotion.end_date < now:
        raise HTTPException(status_code=400, detail="Promotion expired")
    if promotion.usage_limit and promotion.usage_count >= promotion.usage_limit:
        raise HTTPException(status_code=400, detail="Promotion usage limit reached")
        
    return promotion


@router.post("/", response_model=schemas.PromotionOut)
def create_promotion(
    promotion_in: schemas.PromotionCreate,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_superuser),
):
    db_obj = Promotion(**promotion_in.dict())
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

@router.get("/{promotion_id}", response_model=schemas.PromotionOut)
def read_promotion(
    promotion_id: int,
    db: Session = Depends(deps.get_db),
):
    """Get promotion by ID."""
    promotion = db.query(Promotion).filter(Promotion.id == promotion_id).first()
    if not promotion:
        raise HTTPException(status_code=404, detail="Promotion not found")
    return promotion

@router.put("/{promotion_id}", response_model=schemas.PromotionOut)
def update_promotion(
    promotion_id: int,
    promotion_in: schemas.PromotionUpdate,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_superuser),
):
    """Update a promotion."""
    promotion = db.query(Promotion).filter(Promotion.id == promotion_id).first()
    if not promotion:
        raise HTTPException(status_code=404, detail="Promotion not found")
    
    # Validate dates if both are provided
    update_data = promotion_in.dict(exclude_unset=True)
    if 'start_date' in update_data and 'end_date' in update_data:
        if update_data['start_date'] and update_data['end_date']:
            if update_data['start_date'] >= update_data['end_date']:
                raise HTTPException(status_code=400, detail="Start date must be before end date")
    
    for field, value in update_data.items():
        setattr(promotion, field, value)
    
    db.add(promotion)
    db.commit()
    db.refresh(promotion)
    return promotion

@router.delete("/{promotion_id}", response_model=schemas.PromotionOut)
def delete_promotion(
    promotion_id: int,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_active_superuser),
):
    """Delete a promotion."""
    promotion = db.query(Promotion).filter(Promotion.id == promotion_id).first()
    if not promotion:
        raise HTTPException(status_code=404, detail="Promotion not found")
    
    db.delete(promotion)
    db.commit()
    return promotion
