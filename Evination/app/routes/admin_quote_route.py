from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.dependencies import get_current_active_user, PermissionChecker
from app.models.user_m import User
from app.services.admin_quote_service import AdminQuoteService
from app.schemas.admin_quote_schema import (
    AdminQuoteDetailSchema,
    QuoteListSchema,
    QuoteComparisonRequestSchema,
    QuoteComparisonResponseSchema
)
from typing import List

router = APIRouter(
    prefix="/admin/quotes",
    tags=["Admin Quotes"]
)

@router.get(
    "",
    response_model=List[QuoteListSchema],
    dependencies=[Depends(PermissionChecker(["admin.bid.view"]))],
)
async def get_all_quotes(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """
    List all quotes (Vendor Bids) with pagination.
    """
    return AdminQuoteService.get_all_quotes(db, skip, limit)

@router.post(
    "/compare",
    response_model=QuoteComparisonResponseSchema,
    dependencies=[Depends(PermissionChecker(["admin.bid.view"]))],
)
async def compare_quotes(
    data: QuoteComparisonRequestSchema,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """
    Compare selected quotes side-by-side.
    """
    return AdminQuoteService.compare_quotes(db, data.quote_ids)

@router.get(
    "/{id}",
    response_model=AdminQuoteDetailSchema,
    dependencies=[Depends(PermissionChecker(["admin.bid.view"]))],
)
async def get_quote_details(
    id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """
    Get detailed Quote (Vendor Bid) information by ID (e.g., 'QT-123' or '123').
    """
    return AdminQuoteService.get_quote_details(db, id)
