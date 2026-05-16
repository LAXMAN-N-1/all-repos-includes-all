from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import models, schemas
from app.api import deps

router = APIRouter()

@router.post("/deposit", response_model=schemas.WalletTransaction)
def deposit_money(
    *,
    db: Session = Depends(deps.get_db),
    deposit_in: schemas.WalletDeposit,
    current_user: Any = Depends(deps.get_current_active_user),
) -> Any:
    """
    Deposit money into the current user's wallet.
    - If Partner: Deposits into their own wallet.
    - If Staff: Uses the customer_id provided (not implemented here, assuming partner context for now).
    """
    if getattr(current_user, "identity_type", None) != "partner":
         raise HTTPException(status_code=400, detail="Only customers can deposit money into their vault.")

    customer = db.query(models.Customer).filter(models.Customer.id == current_user.id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer profile not found")

    # Update wallet balance
    customer.wallet_balance += deposit_in.amount
    
    # Create transaction record
    transaction = models.WalletTransaction(
        customer_id=customer.id,
        amount=deposit_in.amount,
        transaction_type="deposit",
        notes=deposit_in.notes or "User deposit"
    )
    
    db.add(customer)
    db.add(transaction)
    db.commit()
    db.refresh(transaction)
    
    return transaction

@router.get("/balance", response_model=schemas.WalletBalance)
def get_wallet_balance(
    current_user: Any = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get current user's wallet balance.
    """
    if getattr(current_user, "identity_type", None) != "partner":
         raise HTTPException(status_code=400, detail="Only customers have a vault.")

    return {
        "customer_id": current_user.id,
        "wallet_balance": getattr(current_user, "wallet_balance", 0.0)
    }

@router.get("/transactions", response_model=List[schemas.WalletTransaction])
def get_wallet_transactions(
    db: Session = Depends(deps.get_db),
    current_user: Any = Depends(deps.get_current_active_user),
    skip: int = 0,
    limit: int = 100,
) -> Any:
    """
    Get current user's wallet transactions.
    """
    if getattr(current_user, "identity_type", None) != "partner":
         raise HTTPException(status_code=400, detail="Only customers have a vault.")

    transactions = (
        db.query(models.WalletTransaction)
        .filter(models.WalletTransaction.customer_id == current_user.id)
        .order_by(models.WalletTransaction.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )
    return transactions

