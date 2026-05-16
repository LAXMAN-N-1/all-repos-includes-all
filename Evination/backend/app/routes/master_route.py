from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.dependencies import get_current_active_user, PermissionChecker
from app.models.user_m import User
from app.models.tax_commission_m import TaxCommissionMaster
from app.models.expense_m import Expense
from pydantic import BaseModel
from datetime import date

router = APIRouter(prefix="/masters", tags=["Masters"])

# Schema
class TaxMasterCreate(BaseModel):
    name: str
    rate: float
    type: str # commission, tax, tds
    effective_date: date

class ExpenseCreate(BaseModel):
    title: str
    amount: float
    category: str
    expense_date: date
    reference_id: str = None

# Tax Routes
@router.post("/taxes", dependencies=[Depends(PermissionChecker(["organization.update"]))])
async def create_tax_master(
    tax: TaxMasterCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    new_tax = TaxCommissionMaster(**tax.dict(), is_active=True)
    db.add(new_tax)
    db.commit()
    db.refresh(new_tax)
    return new_tax

@router.get("/taxes")
async def get_taxes(db: Session = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    return db.query(TaxCommissionMaster).all()

# Expense Routes
@router.post("/expenses", dependencies=[Depends(PermissionChecker(["report.view"]))]) # Typically admin
async def create_expense(
    expense: ExpenseCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    new_expense = Expense(**expense.dict(), created_by_id=current_user.id)
    db.add(new_expense)
    db.commit()
    db.refresh(new_expense)
    return new_expense

@router.get("/expenses")
async def get_expenses(db: Session = Depends(get_db), current_user: User = Depends(get_current_active_user)):
    return db.query(Expense).all()
