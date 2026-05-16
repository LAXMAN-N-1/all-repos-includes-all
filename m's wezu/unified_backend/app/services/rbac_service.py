from typing import List, Optional
from sqlmodel import Session, select
from app.models.rbac import Role, Permission, RolePermission
from app.models.role_right import RoleRight
from app.models.menu import Menu
from app.services.role_service import role_service

class RBACService:
    @staticmethod
    def get_role_by_name(db: Session, name: str) -> Optional[Role]:
        return role_service.get_role_by_name(db, name)

    @staticmethod
    def list_roles(db: Session) -> List[Role]:
        return role_service.get_roles(db, include_permissions=True)

    @staticmethod
    def create_role(db: Session, role_in: Role, permission_ids: List[int] = []) -> Role:
        role_data = {
            "name": role_in.name,
            "description": role_in.description,
            "category": role_in.category,
            "level": role_in.level,
            "parent_id": getattr(role_in, "parent_id", None),
            "is_system_role": bool(getattr(role_in, "is_system_role", False)),
            "is_custom_role": bool(getattr(role_in, "is_custom_role", False)),
            "is_active": bool(getattr(role_in, "is_active", True)),
            "scope_owner": getattr(role_in, "scope_owner", "global"),
            "dealer_id": getattr(role_in, "dealer_id", None),
            "icon": getattr(role_in, "icon", None),
            "color": getattr(role_in, "color", None),
        }
        return role_service.create_role_record(
            db,
            role_data=role_data,
            permission_ids=permission_ids,
        )

    @staticmethod
    def update_role(db: Session, role_id: int, update_data: dict, permission_ids: Optional[List[int]] = None) -> Role:
        return role_service.update_role_fields(
            db,
            role_id,
            update_data=update_data,
            permission_ids=permission_ids,
        )

    @staticmethod
    def list_permissions(db: Session) -> List[Permission]:
        return role_service.list_permissions(db)

    @staticmethod
    def get_user_permissions(db: Session, role_id: int) -> List[str]:
        """
        Get all permission slugs for a given role.
        """
        # This joins RolePermission and Permission to get the slugs
        # Assuming a link model RolePermission exists
        statement = (
            select(Permission.slug)
            .join(RolePermission)
            .where(RolePermission.role_id == role_id)
        )
        return list(db.exec(statement).all())

    @staticmethod
    def check_menu_access(db: Session, role_id: int, menu_name: str, permission_type: str = "view") -> bool:
        """
        Check if a role has a specific right on a menu.
        """
        statement = (
            select(RoleRight)
            .join(Menu)
            .where(RoleRight.role_id == role_id)
            .where(Menu.name == menu_name)
        )
        right = db.exec(statement).first()
        if not right:
            return False
        
        if permission_type == "view": return right.can_view
        if permission_type == "create": return right.can_create
        if permission_type == "edit": return right.can_edit
        if permission_type == "delete": return right.can_delete
        return False

    @staticmethod
    def assign_role_to_user(db: Session, user_id: int, role_id: int):
        from app.models.user import User
        user = db.get(User, user_id)
        if user:
            user.role_id = role_id
            db.add(user)
            db.commit()
            db.refresh(user)
        return user

    @staticmethod
    def get_menu_for_role(db: Session, role_id: int) -> List[dict]:
        """
        Get hierarchical menu structure for a role based on RoleRight.
        """
        # Fetch root menus where role has view permission
        statement = (
            select(Menu)
            .join(RoleRight)
            .where(RoleRight.role_id == role_id)
            .where(RoleRight.can_view == True)
            .where(Menu.parent_id == None)
            .where(Menu.is_active == True)
            .order_by(Menu.menu_order)
        )
        root_menus = db.exec(statement).all()
        
        menu_data = []
        for menu in root_menus:
            item = {
                "label": menu.display_name,
                "path": menu.route,
                "icon": menu.icon,
                "children": []
            }
            
            # Fetch children
            child_statement = (
                select(Menu)
                .join(RoleRight)
                .where(RoleRight.role_id == role_id)
                .where(RoleRight.can_view == True)
                .where(Menu.parent_id == menu.id)
                .where(Menu.is_active == True)
                .order_by(Menu.menu_order)
            )
            children = db.exec(child_statement).all()
            for child in children:
                item["children"].append({
                    "label": child.display_name,
                    "path": child.route,
                    "icon": child.icon
                })
            
            menu_data.append(item)
            
        return menu_data

rbac_service = RBACService()
