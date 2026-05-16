from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app import models, schemas
from app.api import deps

router = APIRouter()

@router.get("/", response_model=List[schemas.CategoryOut])
def read_categories(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Retrieve categories.
    """
    categories = db.query(models.Category).offset(skip).limit(limit).all()
    return categories

@router.post("/", response_model=schemas.CategoryOut)
def create_category(
    *,
    db: Session = Depends(deps.get_db),
    category_in: schemas.CategoryCreate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Create new category.
    Only Staff/Admins.
    """
    if current_user.role not in ["admin", "staff", "super_admin"]:
        raise HTTPException(
            status_code=403,
            detail="You do not have permission to create categories."
        )
        
    category = models.Category(
        name=category_in.name,
        description=category_in.description
    )
    db.add(category)
    db.commit()
    db.refresh(category)
    return category

@router.put("/{category_id}", response_model=schemas.CategoryOut)
def update_category(
    *,
    db: Session = Depends(deps.get_db),
    category_id: int,
    category_in: schemas.CategoryUpdate,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Update a category.
    Only Staff/Admins.
    """
    if current_user.role not in ["admin", "staff", "super_admin"]:
        raise HTTPException(
            status_code=403,
            detail="You do not have permission to update categories."
        )
    
    category = db.query(models.Category).filter(models.Category.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    
    update_data = category_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(category, field, value)
    
    db.add(category)
    db.commit()
    db.refresh(category)
    return category

@router.delete("/{category_id}", response_model=schemas.CategoryOut)
def delete_category(
    *,
    db: Session = Depends(deps.get_db),
    category_id: int,
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Delete a category.
    Only Staff/Admins.
    """
    if current_user.role not in ["admin", "staff", "super_admin"]:
        raise HTTPException(
            status_code=403,
            detail="You do not have permission to delete categories."
        )
    
    category = db.query(models.Category).filter(models.Category.id == category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    
    # Check if category is used by products? 
    # For now, let's just delete or set products to null if the model allows.
    # Usually standard behavior in this app is delete.
    
    db.delete(category)
    db.commit()
    return category
