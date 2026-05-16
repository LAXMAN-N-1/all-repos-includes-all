from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import Optional
from datetime import datetime, timedelta
from app.database import get_db
from app.models.user import User, UserRole
from app.auth.deps import get_current_user
from app.services.dashboard_service import DashboardService
from fastapi import HTTPException

router = APIRouter(prefix="/api/v1/dashboard", tags=["Dashboard"])

@router.get("/overview")
async def get_dashboard_overview(
    store_id: Optional[int] = Query(None),
    period: str = Query("today", regex="^(today|this_week|this_month)$"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get dashboard overview based on user role and permissions.
    
    - HQ Admin: Cross-store metrics
    - Store Admin: Store-specific metrics
    - Pharmacist: Prescription queue and fulfillment metrics
    - Customer: Personal order history
    """
    dashboard_service = DashboardService(db)
    
    if current_user.role.code == UserRole.HQ_ADMIN.value:
        return await dashboard_service.get_hq_dashboard(period)
    
    elif current_user.role.code == UserRole.STORE_ADMIN.value:
        # Get user's assigned stores
        store_ids = [store.id for store in current_user.assigned_stores]
        if store_id and store_id not in store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this store")
        
        target_store = store_id or store_ids[0] if store_ids else None
        return await dashboard_service.get_store_dashboard(target_store, period)
    
    elif current_user.role.code == UserRole.PHARMACIST.value:
        store_ids = [store.id for store in current_user.assigned_stores]
        target_store = store_id or store_ids[0] if store_ids else None
        return await dashboard_service.get_pharmacist_dashboard(target_store)
    
    else:  # CUSTOMER
        return await dashboard_service.get_customer_dashboard(current_user.id)

@router.get("/menus")
async def get_user_menus(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get accessible menus/screens for current user based on role.
    Returns hierarchical menu structure with permissions.
    """
    from app.models.menu import Menu
    from app.models.role import Role, role_menus
    from sqlalchemy import and_
    
    # Get user's role from the current_user object
    role = current_user.role
    
    if not role:
        return {"menus": []}
    
    # Query menus accessible by this role
    menus_query = db.query(
        Menu,
        role_menus.c.can_view,
        role_menus.c.can_create,
        role_menus.c.can_update,
        role_menus.c.can_delete
    ).join(
        role_menus,
        and_(
            role_menus.c.menu_id == Menu.id,
            role_menus.c.role_id == role.id
        )
    ).filter(
        Menu.inactive == False,
        Menu.is_visible == True,
        role_menus.c.can_view == True
    ).order_by(
        Menu.level, Menu.sequence
    ).all()
    
    # Build hierarchical structure
    menu_dict = {}
    root_menus = []
    
    for menu, can_view, can_create, can_update, can_delete in menus_query:
        menu_data = {
            "id": str(menu.id),
            "name": menu.name,
            "code": menu.code,
            "icon": menu.icon,
            "route": menu.route,
            "level": menu.level,
            "sequence": menu.sequence,
            "permissions": {
                "can_view": can_view,
                "can_create": can_create,
                "can_update": can_update,
                "can_delete": can_delete
            },
            "children": []
        }
        
        menu_dict[str(menu.id)] = menu_data
        
        if menu.parent_id is None:
            root_menus.append(menu_data)
        else:
            parent_id = str(menu.parent_id)
            if parent_id in menu_dict:
                menu_dict[parent_id]["children"].append(menu_data)
    
    return {"menus": root_menus}