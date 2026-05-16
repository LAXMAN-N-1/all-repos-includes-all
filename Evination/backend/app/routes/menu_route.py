from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.schemas.menu_schema import MenuCreate, MenuResponse
from app.models.menu_m import Menu
from app.models.user_m import User
from app.dependencies import get_current_active_user

router = APIRouter(prefix="/menus", tags=["Menus"])

@router.post("/", response_model=MenuResponse, status_code=status.HTTP_201_CREATED)
async def create_menu(
    menu: MenuCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_menu = db.query(Menu).filter(Menu.code == menu.code).first()
    if db_menu:
        raise HTTPException(status_code=400, detail="Menu code already exists")
    
    new_menu = Menu(**menu.dict(), created_by=current_user.username)
    db.add(new_menu)
    db.commit()
    db.refresh(new_menu)
    return new_menu

@router.get("/", response_model=List[MenuResponse])
async def get_menus(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    menus = db.query(Menu).filter(Menu.inactive == False).order_by(Menu.sort_order).offset(skip).limit(limit).all()
    return menus

@router.get("/hierarchy", response_model=List[dict])
async def get_menu_hierarchy(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """
    Get menu hierarchy with parent-child relationships
    Only returns menus the user has access to based on role_rights
    """
    from app.models.role_right_m import RoleRight
    
    # Get user's accessible menu IDs
    role_rights = db.query(RoleRight).filter(
        RoleRight.role_id == current_user.role_id,
        RoleRight.can_view == True,
        RoleRight.inactive == False
    ).all()
    
    accessible_menu_ids = {rr.menu_id for rr in role_rights}
    
    # Build rights map for quick lookup
    rights_map = {
        rr.menu_id: {
            "can_view": rr.can_view,
            "can_create": rr.can_create,
            "can_edit": rr.can_edit,
            "can_delete": rr.can_delete
        }
        for rr in role_rights
    }
    
    def build_menu_dict(menu: Menu):
        """Convert menu to dict with rights"""
        return {
            "id": menu.id,
            "name": menu.name,
            "code": menu.code,
            "icon": menu.icon,
            "route": menu.route,
            "menu_type": menu.menu_type,
            "sort_order": menu.sort_order,
            "parent_id": menu.parent_id,
            "rights": rights_map.get(menu.id, {})
        }
    
    def build_hierarchy(parent_id):
        """Recursively build menu hierarchy"""
        children = db.query(Menu).filter(
            Menu.parent_id == parent_id,
            Menu.id.in_(accessible_menu_ids),
            Menu.inactive == False
        ).order_by(Menu.sort_order).all()
        
        result = []
        for child in children:
            menu_dict = build_menu_dict(child)
            menu_dict["children"] = build_hierarchy(child.id)
            result.append(menu_dict)
        return result
    
    # Get main menus (parent_id = NULL)
    main_menus = db.query(Menu).filter(
        Menu.parent_id == None,
        Menu.id.in_(accessible_menu_ids),
        Menu.inactive == False
    ).order_by(Menu.sort_order).all()
    
    hierarchy = []
    for menu in main_menus:
        menu_dict = build_menu_dict(menu)
        menu_dict["children"] = build_hierarchy(menu.id)
        hierarchy.append(menu_dict)
    
    return hierarchy