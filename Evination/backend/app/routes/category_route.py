from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.schemas.category_schema import CategoryCreate, CategoryUpdate
from app.services.category_service import CategoryService
from app.dependencies import get_current_active_user, PermissionChecker
from app.models.user_m import User

router = APIRouter(prefix="/categories", tags=["Event Categories"])


@router.post(
    "/",
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(PermissionChecker(["event.category.create"]))]
)
async def create_category(
    category: CategoryCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Create new event category"""
    return CategoryService.create_category(db, category, current_user)


@router.get(
    "/",
    dependencies=[Depends(PermissionChecker(["event.category.view"]))]
)
async def get_categories(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get all event categories with stats"""
    return CategoryService.get_categories_with_stats(db, skip, limit)


@router.get(
    "/{category_id}",
    dependencies=[Depends(PermissionChecker(["event.category.view"]))]
)
async def get_category(
    category_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get category by ID"""
    category = CategoryService.get_category_by_id(db, category_id)
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    return category


@router.put(
    "/{category_id}",
    dependencies=[Depends(PermissionChecker(["event.category.update"]))]
)
async def update_category(
    category_id: int,
    category_update: CategoryUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Update event category"""
    return CategoryService.update_category(db, category_id, category_update, current_user)


@router.delete(
    "/{category_id}",
    dependencies=[Depends(PermissionChecker(["event.category.delete"]))]
)
async def delete_category(
    category_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Soft delete category"""
    CategoryService.delete_category(db, category_id, current_user)
    return {"message": "Category deleted successfully"}


@router.get(
    "/public/list",
    status_code=status.HTTP_200_OK
)
async def get_public_categories(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """Get all event categories (Public Access)"""
    return CategoryService.get_categories_with_stats(db, skip, limit)