from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app import models, schemas
from app.api import deps

router = APIRouter()

@router.get("/", response_model=List[schemas.CustomerGroup])
def read_customer_groups(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Retrieve customer groups (Admin only).
    """
    groups = db.query(models.CustomerGroup).offset(skip).limit(limit).all()
    return groups

@router.post("/", response_model=schemas.CustomerGroup)
def create_customer_group(
    *,
    db: Session = Depends(deps.get_db),
    group_in: schemas.CustomerGroupCreate,
    current_user: models.User = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Create new customer group (Admin only).
    """
    group = db.query(models.CustomerGroup).filter(models.CustomerGroup.name == group_in.name).first()
    if group:
        raise HTTPException(
            status_code=400,
            detail="A group with this name already exists.",
        )
    
    group_data = group_in.model_dump()
    customer_ids = group_data.pop("customer_ids", None)
    
    db_group = models.CustomerGroup(**group_data)
    db.add(db_group)
    db.commit()
    db.refresh(db_group)

    if customer_ids is not None:
        customers_to_add = db.query(models.Customer).filter(models.Customer.id.in_(customer_ids)).all()
        for customer in customers_to_add:
            customer.group_id = db_group.id
            db.add(customer)
        db.commit()

    return db_group

@router.put("/{group_id}", response_model=schemas.CustomerGroup)
def update_customer_group(
    *,
    db: Session = Depends(deps.get_db),
    group_id: int,
    group_in: schemas.CustomerGroupUpdate,
    current_user: models.User = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Update a customer group (Admin only).
    """
    group = db.query(models.CustomerGroup).filter(models.CustomerGroup.id == group_id).first()
    if not group:
        raise HTTPException(status_code=404, detail="Customer group not found")
        
    update_data = group_in.model_dump(exclude_unset=True)
    customer_ids = update_data.pop("customer_ids", None)
    
    # Check name collision if name is being updated
    if "name" in update_data and update_data["name"] != group.name:
        existing = db.query(models.CustomerGroup).filter(models.CustomerGroup.name == update_data["name"]).first()
        if existing:
            raise HTTPException(status_code=400, detail="A group with this name already exists.")

    for field, value in update_data.items():
        setattr(group, field, value)

    db.add(group)
    db.commit()

    if customer_ids is not None:
        # Clear existing
        current_customers = db.query(models.Customer).filter(models.Customer.group_id == group_id).all()
        for customer in current_customers:
            customer.group_id = None
            db.add(customer)
            
        # Add new
        new_customers = db.query(models.Customer).filter(models.Customer.id.in_(customer_ids)).all()
        for customer in new_customers:
            customer.group_id = group_id
            db.add(customer)
            
        db.commit()

    db.refresh(group)
    return group

@router.delete("/{group_id}", response_model=schemas.CustomerGroup)
def delete_customer_group(
    *,
    db: Session = Depends(deps.get_db),
    group_id: int,
    current_user: models.User = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Delete a customer group (Admin only).
    Note: Removing a group will SET NULL on associated customers.
    """
    group = db.query(models.CustomerGroup).filter(models.CustomerGroup.id == group_id).first()
    if not group:
        raise HTTPException(status_code=404, detail="Customer group not found")
        
    # Unlink customers first
    customers = db.query(models.Customer).filter(models.Customer.group_id == group_id).all()
    for customer in customers:
        customer.group_id = None
        db.add(customer)
        
    db.delete(group)
    db.commit()
    return group
