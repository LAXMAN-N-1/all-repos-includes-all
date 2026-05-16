from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app import models, schemas
from app.api import deps
from app.models.menu import Menu

router = APIRouter()

@router.get("/", response_model=List[schemas.Menu])
def read_menus(
    db: Session = Depends(deps.get_db),
    current_user: Any = Depends(deps.get_current_active_user)
) -> Any:
    """
    Retrieve menus. Returns top-level menus with their children.
    """
    # Fetch top-level menus (those without a parent)
    menus = db.query(Menu).filter(Menu.parent_id == None, Menu.is_active == True).order_by(Menu.sort_order).all()
    
    # Filter by permission if necessary
    # For now, superuser sees everything, others see what they have permission for
    if getattr(current_user, "is_superuser", False):
        return menus
    
    # Simple role-based filtering if needed in future
    return menus

@router.post("/", response_model=schemas.Menu)
def create_menu(
    *,
    db: Session = Depends(deps.get_db),
    menu_in: schemas.MenuCreate,
    current_user: Any = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Create a new menu item.
    """
    menu = Menu(**menu_in.dict())
    db.add(menu)
    db.commit()
    db.refresh(menu)
    return menu

@router.put("/{menu_id}", response_model=schemas.Menu)
def update_menu(
    *,
    db: Session = Depends(deps.get_db),
    menu_id: int,
    menu_in: schemas.MenuUpdate,
    current_user: Any = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Update a menu item.
    """
    menu = db.query(Menu).filter(Menu.id == menu_id).first()
    if not menu:
        raise HTTPException(status_code=404, detail="Menu not found")
    
    update_data = menu_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(menu, field, value)
    
    db.add(menu)
    db.commit()
    db.refresh(menu)
    return menu

@router.delete("/{menu_id}", response_model=schemas.Menu)
def delete_menu(
    *,
    db: Session = Depends(deps.get_db),
    menu_id: int,
    current_user: Any = Depends(deps.get_current_active_superuser),
) -> Any:
    """
    Delete a menu item.
    """
    menu = db.query(Menu).filter(Menu.id == menu_id).first()
    if not menu:
        raise HTTPException(status_code=404, detail="Menu not found")
    
    db.delete(menu)
    db.commit()
    return menu
