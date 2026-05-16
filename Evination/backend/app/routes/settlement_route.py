from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.services.settlement_service import SettlementService
from app.dependencies import get_current_active_user
from app.models.user_m import User

router = APIRouter(prefix="/settlements", tags=["Settlements"])

@router.post("/generate")
async def generate_settlements(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Admin only
    service = SettlementService(db)
    return service.generate_weekly_settlements()

@router.get("/")
async def get_settlements(
    vendor_id: Optional[int] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = SettlementService(db)
    return service.get_settlements(vendor_id, skip, limit)
