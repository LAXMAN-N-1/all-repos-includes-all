from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.services.refund_service import RefundService
from app.dependencies import get_current_active_user
from app.models.user_m import User
from pydantic import BaseModel

class RefundApproveRequest(BaseModel):
    notes: str

router = APIRouter(prefix="/refunds", tags=["Refunds"])

@router.get("/")
async def get_refunds(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Check Admin Permission (omitted for brevity, assume admin)
    service = RefundService(db)
    return service.get_refunds(skip, limit)

@router.post("/{refund_id}/approve")
async def approve_refund(
    refund_id: int,
    request: RefundApproveRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = RefundService(db)
    refund = service.approve_refund(refund_id, request.notes)
    if not refund:
        raise HTTPException(status_code=404, detail="Refund not found")
    return refund
