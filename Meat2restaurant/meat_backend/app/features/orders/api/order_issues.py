from datetime import datetime
from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import models, schemas
from app.api import deps
from app.features.orders.models.order_issue import OrderIssue, IssueStatus

router = APIRouter()


@router.get("", response_model=List[schemas.OrderIssueOut])
def list_order_issues(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    status_filter: Optional[str] = None,
    priority: Optional[str] = None,
    order_id: Optional[int] = None,
    customer_id: Optional[int] = None,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """List all order issues with optional filters."""
    query = db.query(OrderIssue).order_by(OrderIssue.created_at.desc())

    if status_filter:
        query = query.filter(OrderIssue.status == status_filter)
    if priority:
        query = query.filter(OrderIssue.priority == priority)
    if order_id:
        query = query.filter(OrderIssue.order_id == order_id)
    if customer_id:
        query = query.filter(OrderIssue.customer_id == customer_id)

    return query.offset(skip).limit(limit).all()


@router.get("/{issue_id}", response_model=schemas.OrderIssueOut)
def get_order_issue(
    issue_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """Get a single order issue by ID."""
    issue = db.query(OrderIssue).filter(OrderIssue.id == issue_id).first()
    if not issue:
        raise HTTPException(status_code=404, detail="Order issue not found")
    return issue


@router.post("", response_model=schemas.OrderIssueOut, status_code=status.HTTP_201_CREATED)
def create_order_issue(
    issue_in: schemas.OrderIssueCreate,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """Report a new order issue."""
    # Validate order exists
    order = db.query(models.Order).filter(models.Order.id == issue_in.order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    # Validate customer exists
    customer = db.query(models.Customer).filter(models.Customer.id == issue_in.customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    issue = OrderIssue(
        order_id=issue_in.order_id,
        customer_id=issue_in.customer_id,
        issue_type=issue_in.issue_type,
        priority=issue_in.priority,
        status=IssueStatus.OPEN,
        description=issue_in.description,
        assigned_to_id=issue_in.assigned_to_id,
    )
    db.add(issue)
    db.commit()
    db.refresh(issue)
    return issue


@router.put("/{issue_id}", response_model=schemas.OrderIssueOut)
def update_order_issue(
    issue_id: int,
    issue_in: schemas.OrderIssueUpdate,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """Update an order issue (change status, add resolution, etc.)."""
    issue = db.query(OrderIssue).filter(OrderIssue.id == issue_id).first()
    if not issue:
        raise HTTPException(status_code=404, detail="Order issue not found")

    update_data = issue_in.dict(exclude_unset=True)

    # Auto-set resolved_at when status changes to resolved
    new_status = update_data.get("status")
    if new_status == IssueStatus.RESOLVED and issue.status != IssueStatus.RESOLVED:
        issue.resolved_at = datetime.utcnow()

    for field, value in update_data.items():
        setattr(issue, field, value)

    db.add(issue)
    db.commit()
    db.refresh(issue)
    return issue


@router.delete("/{issue_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_order_issue(
    issue_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
):
    """Delete an order issue."""
    issue = db.query(OrderIssue).filter(OrderIssue.id == issue_id).first()
    if not issue:
        raise HTTPException(status_code=404, detail="Order issue not found")

    db.delete(issue)
    db.commit()
