from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime

from app import models, schemas
from app.api import deps

router = APIRouter()

@router.post("/record", response_model=schemas.Payment)
def record_payment(
    *,
    db: Session = Depends(deps.get_db),
    payment_in: schemas.PaymentCreate,
    current_user: models.User = Depends(deps.get_current_active_staff),
) -> Any:
    """
    Record an external or internal payment.
    - Status starts as 'pending'.
    - If 'Vault' is the method, it will be validated and confirming later will deduct balance.
    """
    payment = models.Payment(
        customer_id=payment_in.customer_id,
        combined_invoice_id=payment_in.combined_invoice_id,
        invoice_id=payment_in.invoice_id,
        amount=payment_in.amount,
        payment_method=payment_in.payment_method,
        reference_id=payment_in.reference_id,
        payment_date=payment_in.payment_date or datetime.utcnow(),
        status="pending",
        notes=payment_in.notes
    )
    db.add(payment)
    db.commit()
    db.refresh(payment)
    return payment

@router.post("/{payment_id}/confirm", response_model=schemas.Payment)
def confirm_payment(
    payment_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_staff),
) -> Any:
    """
    Confirm a payment and trigger financial settlement / credit liberation.
    """
    payment = db.query(models.Payment).filter(models.Payment.id == payment_id).first()
    if not payment:
        raise HTTPException(status_code=404, detail="Payment record not found")
    
    if payment.status == "confirmed":
        return payment

    # Transactional Settlement
    combined_invoice = payment.combined_invoice
    individual_invoice = payment.invoice
    customer = payment.customer

    # 1. Vault Logic Integration
    if payment.payment_method.upper() == "VAULT":
        if customer.wallet_balance < payment.amount:
            raise HTTPException(
                status_code=400, 
                detail=f"Insufficient Vault balance. Required: ${payment.amount}, Available: ${customer.wallet_balance}"
            )
        
        # Deduct from Wallet
        customer.wallet_balance -= payment.amount
        db.add(models.WalletTransaction(
            customer_id=customer.id,
            amount=-payment.amount,
            transaction_type="payment",
            reference_id=f"Settlement (P-{payment.id})",
            notes=f"ERP Settlement: {payment.payment_method} for {'Combined' if combined_invoice else 'Individual'} Invoice"
        ))

    # 2. Update Statuses & Liberate Credit
    payment.status = "confirmed"
    # Audit log in notes
    audit_msg = f"Confirmed by {current_user.email} (ID: {current_user.id}) at {datetime.utcnow().isoformat()}"
    payment.notes = (payment.notes + " | " + audit_msg) if payment.notes else audit_msg

    # Settlement logic
    if combined_invoice:
        # Check total confirmed payments
        total_paid = sum(p.amount for p in combined_invoice.payments if p.status == "confirmed")
        # Include current payment if not yet committed to DB relationship (it is committed above but let's be safe)
        # Actually combined_invoice.payments will include this 'payment' object because of relationship loading
        # And we just set payment.status = 'confirmed'
        
        if total_paid >= combined_invoice.total_amount:
            combined_invoice.status = "paid"
            # Update linked sub-invoices
            for inv in combined_invoice.invoices:
                inv.status = "paid"
                db.add(inv)
            db.add(combined_invoice)

    if individual_invoice:
        individual_invoice.status = "paid"
        db.add(individual_invoice)

    # ERP Requirement 6: Liberate Credit immediately
    customer.current_balance -= payment.amount
    if customer.current_balance < 0:
        customer.current_balance = 0

    db.add(customer)
    db.commit()
    db.refresh(payment)
    return payment

@router.get("/", response_model=List[schemas.Payment])
@router.get("/transactions", response_model=List[schemas.Payment])
def read_payments(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(deps.get_current_active_staff),
) -> Any:
    return db.query(models.Payment).offset(skip).limit(limit).all()
