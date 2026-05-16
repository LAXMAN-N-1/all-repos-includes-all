from datetime import datetime, timedelta
from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload

from app import models, schemas
from app.api import deps
from app.features.orders.models.recurring_order import RecurringOrder, RecurringOrderItem, RecurringOrderStatus

router = APIRouter()


@router.get("", response_model=List[schemas.RecurringOrderOut])
def list_recurring_orders(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    status_filter: Optional[str] = None,
    customer_id: Optional[int] = None,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """List all recurring orders with optional filters."""
    query = db.query(RecurringOrder).options(
        joinedload(RecurringOrder.items)
    ).order_by(RecurringOrder.created_at.desc())

    if status_filter:
        query = query.filter(RecurringOrder.status == status_filter)
    if customer_id:
        query = query.filter(RecurringOrder.customer_id == customer_id)

    return query.offset(skip).limit(limit).all()


@router.get("/{recurring_order_id}", response_model=schemas.RecurringOrderOut)
def get_recurring_order(
    recurring_order_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """Get a single recurring order by ID."""
    ro = db.query(RecurringOrder).options(
        joinedload(RecurringOrder.items)
    ).filter(RecurringOrder.id == recurring_order_id).first()
    if not ro:
        raise HTTPException(status_code=404, detail="Recurring order not found")
    return ro


@router.post("", response_model=schemas.RecurringOrderOut, status_code=status.HTTP_201_CREATED)
def create_recurring_order(
    order_in: schemas.RecurringOrderCreate,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """Create a new recurring order subscription."""
    # Validate customer exists
    customer = db.query(models.Customer).filter(models.Customer.id == order_in.customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    # Calculate next delivery if not provided
    next_delivery = order_in.next_delivery_date or (datetime.utcnow() + timedelta(days=7))

    ro = RecurringOrder(
        customer_id=order_in.customer_id,
        frequency=order_in.frequency,
        status=RecurringOrderStatus.ACTIVE,
        next_delivery_date=next_delivery,
        notes=order_in.notes,
        delivery_fee=order_in.delivery_fee,
        platform_fee=order_in.platform_fee,
        location_id=order_in.location_id,
        payment_terms=order_in.payment_terms,
    )
    db.add(ro)
    db.flush()

    # Create items
    for item_in in order_in.items:
        product = db.query(models.Product).filter(models.Product.id == item_in.product_id).first()
        if not product:
            raise HTTPException(status_code=404, detail=f"Product {item_in.product_id} not found")

        item = RecurringOrderItem(
            recurring_order_id=ro.id,
            product_id=item_in.product_id,
            variant_id=item_in.variant_id,
            quantity=item_in.quantity,
        )
        db.add(item)

    db.commit()
    db.refresh(ro)
    return ro


@router.put("/{recurring_order_id}", response_model=schemas.RecurringOrderOut)
def update_recurring_order(
    recurring_order_id: int,
    order_in: schemas.RecurringOrderUpdate,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """Update a recurring order's properties."""
    ro = db.query(RecurringOrder).filter(RecurringOrder.id == recurring_order_id).first()
    if not ro:
        raise HTTPException(status_code=404, detail="Recurring order not found")

    update_data = order_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(ro, field, value)

    db.add(ro)
    db.commit()
    db.refresh(ro)
    return ro


@router.post("/{recurring_order_id}/pause", response_model=schemas.RecurringOrderOut)
def pause_recurring_order(
    recurring_order_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """Pause an active recurring order."""
    ro = db.query(RecurringOrder).filter(RecurringOrder.id == recurring_order_id).first()
    if not ro:
        raise HTTPException(status_code=404, detail="Recurring order not found")
    if ro.status != RecurringOrderStatus.ACTIVE:
        raise HTTPException(status_code=400, detail="Only active subscriptions can be paused")

    ro.status = RecurringOrderStatus.PAUSED
    db.commit()
    db.refresh(ro)
    return ro


@router.post("/{recurring_order_id}/resume", response_model=schemas.RecurringOrderOut)
def resume_recurring_order(
    recurring_order_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """Resume a paused recurring order."""
    ro = db.query(RecurringOrder).filter(RecurringOrder.id == recurring_order_id).first()
    if not ro:
        raise HTTPException(status_code=404, detail="Recurring order not found")
    if ro.status != RecurringOrderStatus.PAUSED:
        raise HTTPException(status_code=400, detail="Only paused subscriptions can be resumed")

    ro.status = RecurringOrderStatus.ACTIVE
    # Recalculate next delivery date
    ro.next_delivery_date = datetime.utcnow() + timedelta(days=7)
    db.commit()
    db.refresh(ro)
    return ro


@router.delete("/{recurring_order_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_recurring_order(
    recurring_order_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
):
    """Cancel/delete a recurring order."""
    ro = db.query(RecurringOrder).filter(RecurringOrder.id == recurring_order_id).first()
    if not ro:
        raise HTTPException(status_code=404, detail="Recurring order not found")

    db.delete(ro)
    db.commit()
