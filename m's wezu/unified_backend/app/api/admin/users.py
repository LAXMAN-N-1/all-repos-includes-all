from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select, func
from sqlalchemy import case
from typing import List, Optional
from datetime import datetime, UTC
from pydantic import BaseModel, EmailStr, Field
from app.api import deps
from app.models.user import User, UserStatus, UserType
from app.schemas.user import UserResponse
from app.core.database import get_db
from app.core.config import settings
from app.core.security import get_password_hash
from app.models.rbac import Role, UserRole
from app.core.rbac import canonical_role_name
from app.models.dealer import DealerProfile
from app.models.driver_profile import DriverProfile
from app.models.user_identity import UserIdentity, UserIdentityStatus
from app.models.access_assignment import StationStaffAssignment, WarehouseUserAssignment
from app.models.station import Station
from app.models.warehouse import Warehouse
from app.schemas.station import StationCreate
from app.schemas.warehouse import WarehouseCreate
from app.services.admin_user_provisioning_service import AdminUserProvisioningService
from app.services.auth_service import AuthService
from app.services.supabase_admin_service import SupabaseAdminService
from app.utils.runtime_cache import cached_call, invalidate_cache


router = APIRouter()

DEALER_SCOPE_ROLE_NAMES = {
    "dealer_owner",
    "dealer_manager",
    "dealer_inventory_staff",
    "dealer_finance_staff",
    "dealer_support_staff",
}
DEALER_STAFF_ROLE_NAMES = DEALER_SCOPE_ROLE_NAMES - {"dealer_owner"}
LOGISTICS_ROLE_NAMES = {
    "logistics_manager",
    "dispatcher",
    "fleet_manager",
    "warehouse_manager",
    "driver",
}


def _invalidate_admin_user_cache() -> None:
    invalidate_cache("admin-users")


def _derive_user_type_from_role(role_name: Optional[str], fallback: Optional[UserType]) -> UserType:
    role_lower = canonical_role_name(role_name or "")
    if role_lower in {"super_admin", "operations_admin", "security_admin", "finance_admin", "support_manager", "support_agent"}:
        return UserType.ADMIN
    if role_lower == "dealer_owner":
        return UserType.DEALER
    if role_lower in {"dealer_manager", "dealer_inventory_staff", "dealer_finance_staff", "dealer_support_staff"}:
        return UserType.DEALER_STAFF
    if role_lower in {"logistics_manager", "dispatcher", "fleet_manager", "warehouse_manager", "driver"}:
        return UserType.LOGISTICS
    return fallback or UserType.CUSTOMER


def _assert_can_create_role(current_user: User, role_name: str) -> None:
    actor_roles = deps.get_user_role_names(current_user)
    target_role = canonical_role_name(role_name)
    if current_user.is_superuser or "super_admin" in actor_roles:
        return
    if "security_admin" in actor_roles and target_role != "super_admin":
        return
    if "operations_admin" in actor_roles and target_role not in {"super_admin", "security_admin", "finance_admin"}:
        return
    raise HTTPException(status_code=403, detail="insufficient_permissions")


def _ensure_user_role(db: Session, user: User, role: Role, current_user: User) -> None:
    existing = db.exec(
        select(UserRole).where(UserRole.user_id == user.id, UserRole.role_id == role.id)
    ).first()
    if existing:
        return
    db.add(
        UserRole(
            user_id=user.id,
            role_id=role.id,
            assigned_by_user_id=current_user.id,
            effective_from=datetime.now(UTC),
        )
    )


def _get_supabase_identity(db: Session, user: User) -> Optional[UserIdentity]:
    if not user.id:
        return None
    return db.exec(
        select(UserIdentity).where(
            UserIdentity.user_id == user.id,
            UserIdentity.provider == "supabase",
        )
    ).first()


def _current_role_name(db: Session, user: User) -> Optional[str]:
    if user.role:
        return user.role.name
    if user.role_id:
        role = db.get(Role, user.role_id)
        if role:
            return role.name
    return None


def _build_supabase_user_metadata(
    *,
    user: User,
    role_name: Optional[str],
) -> dict[str, object]:
    return {
        "full_name": user.full_name or "",
        "role_name": role_name or "",
        "phone_number": user.phone_number or "",
        "status": user.status.value if user.status else "active",
        "local_user_id": user.id,
    }


def _sync_supabase_user_update(
    db: Session,
    *,
    user: User,
    attributes: dict[str, object],
) -> Optional[UserIdentity]:
    identity = _get_supabase_identity(db, user)
    if not identity or not identity.external_subject:
        return identity

    try:
        SupabaseAdminService.update_user(identity.external_subject, attributes)
    except ValueError as exc:
        raise HTTPException(status_code=502, detail=f"Supabase sync failed: {exc}") from exc
    return identity


def _current_dealer_id(db: Session, user: User) -> Optional[int]:
    if user.created_by_dealer_id:
        return int(user.created_by_dealer_id)

    dealer_profile = db.exec(
        select(DealerProfile).where(DealerProfile.user_id == user.id)
    ).first()
    if dealer_profile and dealer_profile.id is not None:
        return int(dealer_profile.id)
    return None


def _active_station_ids(db: Session, user_id: int) -> list[int]:
    rows = db.exec(
        select(StationStaffAssignment.station_id).where(
            StationStaffAssignment.user_id == user_id,
            StationStaffAssignment.is_active == True,
        )
    ).all()
    return [int(row) for row in rows]


def _active_warehouse_ids(db: Session, user_id: int) -> list[int]:
    rows = db.exec(
        select(WarehouseUserAssignment.warehouse_id).where(
            WarehouseUserAssignment.user_id == user_id,
            WarehouseUserAssignment.is_active == True,
        )
    ).all()
    return [int(row) for row in rows]


def _deactivate_station_scope(db: Session, *, user_id: int) -> None:
    assignments = db.exec(
        select(StationStaffAssignment).where(
            StationStaffAssignment.user_id == user_id,
            StationStaffAssignment.is_active == True,
        )
    ).all()
    now = datetime.now(UTC)
    for assignment in assignments:
        assignment.is_active = False
        assignment.updated_at = now
        db.add(assignment)
    db.flush()


def _deactivate_warehouse_scope(db: Session, *, user_id: int) -> None:
    assignments = db.exec(
        select(WarehouseUserAssignment).where(
            WarehouseUserAssignment.user_id == user_id,
            WarehouseUserAssignment.is_active == True,
        )
    ).all()
    now = datetime.now(UTC)
    for assignment in assignments:
        assignment.is_active = False
        assignment.updated_at = now
        db.add(assignment)

    managed_warehouses = db.exec(
        select(Warehouse).where(Warehouse.manager_id == user_id)
    ).all()
    for warehouse in managed_warehouses:
        warehouse.manager_id = None
        warehouse.updated_at = now
        db.add(warehouse)
    db.flush()


def _sync_station_scope(
    db: Session,
    *,
    user: User,
    dealer_id: int,
    station_ids: list[int],
    current_user: User,
) -> None:
    keep_ids = set(station_ids)
    active_assignments = db.exec(
        select(StationStaffAssignment).where(
            StationStaffAssignment.user_id == user.id,
            StationStaffAssignment.is_active == True,
        )
    ).all()
    now = datetime.now(UTC)
    for assignment in active_assignments:
        if assignment.station_id not in keep_ids:
            assignment.is_active = False
            assignment.updated_at = now
            db.add(assignment)
    if keep_ids:
        AdminUserProvisioningService.assign_station_scope(
            db,
            user=user,
            dealer_id=dealer_id,
            station_ids=sorted(keep_ids),
            current_user=current_user,
        )
    db.flush()


def _sync_warehouse_scope(
    db: Session,
    *,
    user: User,
    warehouse_ids: list[int],
    current_user: User,
) -> None:
    keep_ids = set(warehouse_ids)
    active_assignments = db.exec(
        select(WarehouseUserAssignment).where(
            WarehouseUserAssignment.user_id == user.id,
            WarehouseUserAssignment.is_active == True,
        )
    ).all()
    now = datetime.now(UTC)
    for assignment in active_assignments:
        if assignment.warehouse_id not in keep_ids:
            assignment.is_active = False
            assignment.updated_at = now
            db.add(assignment)

    managed_warehouses = db.exec(
        select(Warehouse).where(Warehouse.manager_id == user.id)
    ).all()
    for warehouse in managed_warehouses:
        if warehouse.id not in keep_ids:
            warehouse.manager_id = None
            warehouse.updated_at = now
            db.add(warehouse)

    if keep_ids:
        AdminUserProvisioningService.assign_warehouse_scope(
            db,
            user=user,
            warehouse_ids=sorted(keep_ids),
            current_user=current_user,
        )
    db.flush()


class AdminDealerProfilePayload(BaseModel):
    business_name: str
    contact_person: Optional[str] = None
    contact_email: Optional[EmailStr] = None
    contact_phone: Optional[str] = None
    address_line1: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    pincode: Optional[str] = None
    gst_number: Optional[str] = None
    pan_number: Optional[str] = None


class AdminLogisticsProfilePayload(BaseModel):
    license_number: Optional[str] = None
    vehicle_type: Optional[str] = None
    vehicle_plate: Optional[str] = None


class AdminUserCreateRequest(BaseModel):
    full_name: str
    email: EmailStr
    phone_number: Optional[str] = None
    password: str = Field(min_length=8)
    role_id: Optional[int] = None
    role_name: Optional[str] = "customer"
    user_type: Optional[UserType] = UserType.CUSTOMER
    status: Optional[UserStatus] = UserStatus.ACTIVE
    dealer_id: Optional[int] = None
    dealer_profile: Optional[AdminDealerProfilePayload] = None
    station_ids: List[int] = Field(default_factory=list)
    stations_to_create: List[StationCreate] = Field(default_factory=list)
    warehouse_ids: List[int] = Field(default_factory=list)
    warehouses_to_create: List[WarehouseCreate] = Field(default_factory=list)
    logistics_profile: Optional[AdminLogisticsProfilePayload] = None


class AdminUserCreationRoleRead(BaseModel):
    id: int
    name: str
    canonical_name: str
    display_name: str
    description: Optional[str] = None
    category: str
    level: int
    is_system_role: bool
    user_type: str
    requires_dealer_profile: bool = False
    requires_dealer_id: bool = False
    requires_warehouse_ids: bool = False


def _creation_role_user_type(role_name: str) -> str:
    role_lower = canonical_role_name(role_name)
    if role_lower == "dealer_owner":
        return UserType.DEALER.value
    if role_lower in {
        "dealer_manager",
        "dealer_inventory_staff",
        "dealer_finance_staff",
        "dealer_support_staff",
    }:
        return UserType.DEALER_STAFF.value
    if role_lower in {
        "logistics_manager",
        "dispatcher",
        "fleet_manager",
        "warehouse_manager",
        "driver",
    }:
        return UserType.LOGISTICS.value
    if role_lower == "support_agent":
        return UserType.SUPPORT_AGENT.value
    if role_lower in {
        "super_admin",
        "operations_admin",
        "security_admin",
        "finance_admin",
        "support_manager",
    }:
        return UserType.ADMIN.value
    return UserType.CUSTOMER.value


def _role_display_name(role: Role) -> str:
    return (role.name or "").replace("_", " ").strip().title() or "Role"


def _resolve_existing_creation_role(
    db: Session,
    *,
    role_id: Optional[int],
    role_name: Optional[str],
) -> Role:
    """Resolve only roles that already exist in the database.

    The admin UI should use GET /admin/users/creation-roles and submit the
    selected role_id.  The alias-aware fallback keeps older clients working
    when they submit a canonical role_name but the DB still contains a legacy
    alias such as "admin".
    """
    if role_id is not None:
        role = db.get(Role, role_id)
        if not role:
            raise HTTPException(status_code=400, detail=f"Role id '{role_id}' not found")
        if not role.is_active:
            raise HTTPException(status_code=400, detail=f"Role '{role.name}' is inactive")
        return role

    requested_name = (role_name or "customer").strip() or "customer"
    exact_role = db.exec(
        select(Role).where(
            func.lower(Role.name) == requested_name.lower(),
            Role.is_active == True,
        )
    ).first()
    if exact_role:
        return exact_role

    canonical_requested = canonical_role_name(requested_name)
    if canonical_requested and canonical_requested != requested_name.lower():
        canonical_role = db.exec(
            select(Role).where(
                func.lower(Role.name) == canonical_requested.lower(),
                Role.is_active == True,
            )
        ).first()
        if canonical_role:
            return canonical_role

    active_roles = db.exec(select(Role).where(Role.is_active == True)).all()
    for role in active_roles:
        if canonical_role_name(role.name) == canonical_requested:
            return role

    raise HTTPException(
        status_code=400,
        detail=(
            f"Role '{requested_name}' not found. "
            "Fetch /api/v1/admin/users/creation-roles and submit a returned role_id or name."
        ),
    )


@router.get("/creation-roles", response_model=List[AdminUserCreationRoleRead])
@router.get("/roles", response_model=List[AdminUserCreationRoleRead], include_in_schema=False)
def list_user_creation_roles(
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_admin),
):
    """List roles the current admin may assign while creating a user.

    This endpoint is intentionally scoped to user creation. It does not require
    full RBAC role-management permissions, but it still applies the same
    create-role guard as the create-user endpoint.
    """
    roles = db.exec(
        select(Role)
        .where(Role.is_active == True)
        .order_by(Role.level.desc(), Role.name.asc())
    ).all()

    visible_roles: list[AdminUserCreationRoleRead] = []
    for role in roles:
        try:
            _assert_can_create_role(current_user, role.name)
        except HTTPException as exc:
            if exc.status_code == 403:
                continue
            raise

        role_name = canonical_role_name(role.name)
        visible_roles.append(
            AdminUserCreationRoleRead(
                id=role.id or 0,
                name=role.name,
                canonical_name=role_name,
                display_name=_role_display_name(role),
                description=role.description,
                category=role.category,
                level=role.level,
                is_system_role=role.is_system_role,
                user_type=_creation_role_user_type(role_name),
                requires_dealer_profile=role_name == "dealer_owner",
                requires_dealer_id=role_name
                in {
                    "dealer_manager",
                    "dealer_inventory_staff",
                    "dealer_finance_staff",
                    "dealer_support_staff",
                },
                requires_warehouse_ids=role_name == "warehouse_manager",
            )
        )

    return visible_roles


@router.post("/", response_model=dict)
def admin_create_user(
    payload: AdminUserCreateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_admin),
):
    """Admin: create a Supabase Auth user and link the local RBAC profile."""
    # 1. Duplicate check
    existing = db.exec(select(User).where(User.email == payload.email)).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already exists")

    if payload.phone_number:
        phone_exists = db.exec(select(User).where(User.phone_number == payload.phone_number)).first()
        if phone_exists:
            raise HTTPException(status_code=400, detail="Phone number already exists")

    resolved_role = _resolve_existing_creation_role(
        db,
        role_id=payload.role_id,
        role_name=payload.role_name,
    )
    _assert_can_create_role(current_user, resolved_role.name)

    role_name = canonical_role_name(resolved_role.name)
    logistics_role_names = {"logistics_manager", "dispatcher", "fleet_manager", "warehouse_manager", "driver"}
    if role_name == "dealer_owner" and payload.dealer_profile is None:
        raise HTTPException(status_code=400, detail="dealer_profile is required for dealer_owner")
    if role_name in {"dealer_manager", "dealer_inventory_staff", "dealer_finance_staff", "dealer_support_staff"} and not payload.dealer_id:
        raise HTTPException(status_code=400, detail="dealer_id is required for dealer staff")
    combined_warehouse_links = [*payload.warehouse_ids]
    if role_name == "warehouse_manager" and not (combined_warehouse_links or payload.warehouses_to_create):
        raise HTTPException(
            status_code=400,
            detail="warehouse_ids or warehouses_to_create is required for warehouse_manager",
        )

    supabase_subject = None
    try:
        supabase_user = SupabaseAdminService.create_user(
            email=str(payload.email),
            password=payload.password,
            user_metadata={
                "full_name": payload.full_name,
                "role_name": resolved_role.name,
            },
        )
        supabase_subject = str(supabase_user.get("id") or supabase_user.get("user", {}).get("id") or "")
        if not supabase_subject:
            raise ValueError("Supabase response did not include a user id")

        new_user = User(
            email=str(payload.email),
            full_name=payload.full_name,
            phone_number=payload.phone_number,
            hashed_password=None,
            user_type=_derive_user_type_from_role(resolved_role.name, payload.user_type),
            status=payload.status or UserStatus.ACTIVE,
            role_id=resolved_role.id,
            is_superuser=False,
            created_by_user_id=current_user.id,
            created_at=datetime.now(UTC),
        )
        if payload.dealer_id:
            dealer = db.get(DealerProfile, payload.dealer_id)
            if not dealer:
                raise HTTPException(status_code=404, detail="dealer_not_found")
            new_user.created_by_dealer_id = dealer.id
        db.add(new_user)
        db.flush()

        db.add(
            UserIdentity(
                provider="supabase",
                external_subject=supabase_subject,
                user_id=new_user.id,
                email_snapshot=str(payload.email),
            )
        )
        _ensure_user_role(db, new_user, resolved_role, current_user)

        dealer_profile = None
        tenant_id = None
        created_station_ids: list[int] = []
        created_warehouse_ids: list[int] = []
        assigned_station_ids = list(payload.station_ids)
        assigned_warehouse_ids = list(payload.warehouse_ids)
        if role_name == "dealer_owner" and payload.dealer_profile:
            dealer_profile = AdminUserProvisioningService.create_dealer_profile(
                db,
                user=new_user,
                payload=payload.dealer_profile,
            )
            tenant = AdminUserProvisioningService.ensure_dealer_tenant(
                db,
                dealer=dealer_profile,
            )
            tenant_id = tenant.id
            AdminUserProvisioningService.ensure_membership(
                db,
                tenant_id=tenant.id,
                user_id=new_user.id,
                scope="tenant_owner",
                is_default=True,
            )
            if payload.stations_to_create:
                created_stations = AdminUserProvisioningService.create_stations_for_dealer(
                    db,
                    dealer=dealer_profile,
                    payloads=payload.stations_to_create,
                )
                created_station_ids = [station.id for station in created_stations if station.id is not None]
        elif payload.dealer_id:
            dealer = db.get(DealerProfile, payload.dealer_id)
            if not dealer:
                raise HTTPException(status_code=404, detail="dealer_not_found")
            tenant = AdminUserProvisioningService.ensure_dealer_tenant(db, dealer=dealer)
            tenant_id = tenant.id
            AdminUserProvisioningService.ensure_membership(
                db,
                tenant_id=tenant.id,
                user_id=new_user.id,
                scope="tenant_member",
                is_default=True,
            )
            AdminUserProvisioningService.assign_station_scope(
                db,
                user=new_user,
                dealer_id=dealer.id,
                station_ids=payload.station_ids,
                current_user=current_user,
            )

        if role_name in logistics_role_names and payload.warehouses_to_create:
            created_warehouses = AdminUserProvisioningService.create_warehouses(
                db,
                payloads=payload.warehouses_to_create,
                manager_user_id=new_user.id,
            )
            created_warehouse_ids = [warehouse.id for warehouse in created_warehouses if warehouse.id is not None]
            assigned_warehouse_ids.extend(created_warehouse_ids)

        if assigned_warehouse_ids:
            AdminUserProvisioningService.assign_warehouse_scope(
                db,
                user=new_user,
                warehouse_ids=assigned_warehouse_ids,
                current_user=current_user,
            )

        if role_name == "driver" and payload.logistics_profile:
            db.add(
                DriverProfile(
                    user_id=new_user.id,
                    name=new_user.full_name,
                    phone_number=new_user.phone_number,
                    license_number=payload.logistics_profile.license_number or "",
                    vehicle_type=payload.logistics_profile.vehicle_type or "",
                    vehicle_plate=payload.logistics_profile.vehicle_plate or "",
                )
            )

        db.commit()
        db.refresh(new_user)
    except HTTPException:
        db.rollback()
        if supabase_subject:
            SupabaseAdminService.delete_user(supabase_subject)
        raise
    except Exception as exc:
        db.rollback()
        if supabase_subject:
            SupabaseAdminService.delete_user(supabase_subject)
        raise HTTPException(status_code=400, detail=str(exc))

    _invalidate_admin_user_cache()

    return {
        "id": new_user.id,
        "email": new_user.email,
        "full_name": new_user.full_name,
        "status": new_user.status.value,
        "role_id": resolved_role.id,
        "role_name": resolved_role.name,
        "canonical_role_name": role_name,
        "supabase_subject": supabase_subject,
        "tenant_id": tenant_id,
        "dealer_id": dealer_profile.id if dealer_profile else payload.dealer_id,
        "station_ids": assigned_station_ids,
        "created_station_ids": created_station_ids,
        "warehouse_ids": assigned_warehouse_ids,
        "created_warehouse_ids": created_warehouse_ids,
    }


class PaginatedUsersResponse(BaseModel):
    users: List[dict]
    total_count: int
    page: int
    page_size: int


class SuspendRequest(BaseModel):
    reason: str


class ReactivateRequest(BaseModel):
    notes: Optional[str] = None


class AdminUserUpdateRequest(BaseModel):
    full_name: Optional[str] = None
    email: Optional[str] = None
    phone_number: Optional[str] = None
    role_id: Optional[int] = None
    role_name: Optional[str] = None
    dealer_id: Optional[int] = None
    station_ids: Optional[List[int]] = None
    warehouse_ids: Optional[List[int]] = None


class AdminPasswordResetRequest(BaseModel):
    new_password: Optional[str] = None
    password: Optional[str] = None
    force_reset: bool = True


def _serialize_user(user: User, role_name: Optional[str] = None) -> dict:
    return {
        "id": user.id,
        "full_name": user.full_name or "Unknown",
        "email": user.email or "",
        "phone_number": user.phone_number or "",
        "user_type": user.user_type.value if user.user_type else "customer",
        "status": user.status.value if user.status else "active",
        "kyc_status": user.kyc_status.value if user.kyc_status else "not_submitted",
        "is_active": user.is_active,
        "is_superuser": user.is_superuser,
        "profile_picture": user.profile_picture,
        "role": role_name,
        "created_at": user.created_at.isoformat() if user.created_at else None,
        "last_login": user.last_login.isoformat() if user.last_login else None,
        "last_login_at": user.last_login.isoformat() if user.last_login else None,
        "deletion_reason": user.deletion_reason,
        "suspension_reason": user.deletion_reason,  # Alias for frontend compat
        "force_password_reset": user.force_password_change,
        "invited_by": None,
    }


def _serialize_user_detail(db: Session, user: User, role_name: Optional[str] = None) -> dict:
    payload = _serialize_user(user, role_name=role_name)
    payload["role_id"] = user.role_id
    payload["role_name"] = role_name
    payload["dealer_id"] = _current_dealer_id(db, user)
    payload["station_ids"] = _active_station_ids(db, int(user.id))
    payload["warehouse_ids"] = _active_warehouse_ids(db, int(user.id))
    return payload


@router.get("/")
def list_users(
    skip: int = 0,
    limit: int = 100,
    search: Optional[str] = None,
    status: Optional[str] = None,
    user_type: Optional[str] = None,
    kyc_status: Optional[str] = None,
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    """List all users with pagination, search, and filters."""
    def _load_users() -> dict:
        statement = select(User).where(User.is_deleted == False)

        if search:
            statement = statement.where(
                (User.full_name.ilike(f"%{search}%")) |
                (User.email.ilike(f"%{search}%")) |
                (User.phone_number.ilike(f"%{search}%"))
            )

        if status:
            statement = statement.where(User.status == status.lower())

        if user_type:
            statement = statement.where(User.user_type == user_type)

        if kyc_status:
            statement = statement.where(User.kyc_status == kyc_status)

        total_count = db.exec(select(func.count()).select_from(statement.subquery())).one()
        users = db.exec(statement.order_by(User.created_at.desc()).offset(skip).limit(limit)).all()

        role_ids = {u.role_id for u in users if u.role_id}
        role_map = (
            {r.id: r.name for r in db.exec(select(Role).where(Role.id.in_(role_ids))).all()}
            if role_ids else {}
        )

        user_list = []
        for u in users:
            role_name = None
            if u.role:
                role_name = u.role.name
            elif u.role_id:
                role_name = role_map.get(u.role_id)
            user_list.append(_serialize_user(u, role_name=role_name))

        return {
            "items": user_list,
            "total_count": total_count,
            "page": skip // limit + 1 if limit > 0 else 1,
            "page_size": limit,
        }

    return cached_call(
        "admin-users",
        "list",
        current_user.id,
        skip,
        limit,
        search or "",
        status or "",
        user_type or "",
        kyc_status or "",
        ttl_seconds=settings.USER_ADMIN_CACHE_TTL_SECONDS,
        call=_load_users,
    )


@router.get("/summary")
def get_user_summary(
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    """Get user statistics for admin dashboard."""
    def _load_summary() -> dict:
        total, active, suspended, pending_verification, inactive = db.exec(
            select(
                func.count(User.id),
                func.coalesce(func.sum(case((User.status == UserStatus.ACTIVE, 1), else_=0)), 0),
                func.coalesce(func.sum(case((User.status == UserStatus.SUSPENDED, 1), else_=0)), 0),
                func.coalesce(func.sum(case((User.status == UserStatus.PENDING_VERIFICATION, 1), else_=0)), 0),
                func.coalesce(func.sum(case((User.is_active == False, 1), else_=0)), 0),
            ).where(User.is_deleted == False)
        ).one()

        return {
            "total_users": total,
            "active_count": active,
            "inactive_count": inactive,
            "suspended_count": suspended,
            "pending_count": pending_verification,
        }

    return cached_call(
        "admin-users",
        "summary",
        current_user.id,
        ttl_seconds=settings.USER_ADMIN_CACHE_TTL_SECONDS,
        call=_load_summary,
    )


@router.get("/suspended")
def list_suspended_users(
    skip: int = 0,
    limit: int = 100,
    search: Optional[str] = None,
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    """List all suspended users."""
    statement = select(User).where(
        User.status == UserStatus.SUSPENDED,
        User.is_deleted == False
    )

    if search:
        statement = statement.where(
            (User.full_name.ilike(f"%{search}%")) |
            (User.email.ilike(f"%{search}%")) |
            (User.phone_number.ilike(f"%{search}%"))
        )

    count_stmt = select(func.count()).select_from(statement.subquery())
    total_count = db.exec(count_stmt).one()

    statement = statement.order_by(User.updated_at.desc()).offset(skip).limit(limit)
    users = db.exec(statement).all()

    user_list = []
    for u in users:
        serialized = _serialize_user(u, role_name=None)
        serialized["suspension_reason"] = u.deletion_reason
        serialized["suspended_at"] = u.updated_at.isoformat() if u.updated_at else None
        user_list.append(serialized)

    return {
        "items": user_list,
        "total_count": total_count,
        "page": skip // limit + 1 if limit > 0 else 1,
        "page_size": limit,
    }


@router.get("/{user_id}")
def get_user_detail(
    user_id: int,
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    """Get detailed view of a specific user."""
    user = db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    role_name = None
    if user.role_id:
        from app.models.rbac import Role
        role = db.get(Role, user.role_id)
        role_name = role.name if role else None

    return _serialize_user_detail(db, user, role_name=role_name)


@router.put("/{user_id}")
def update_user_detail(
    user_id: int,
    payload: AdminUserUpdateRequest,
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    user = db.get(User, user_id)
    if not user or user.is_deleted:
        raise HTTPException(status_code=404, detail="User not found")

    update_data = payload.model_dump(exclude_unset=True)
    requested_role_id = update_data.pop("role_id", None)
    requested_role_name = update_data.pop("role_name", None)
    requested_dealer_id = update_data.pop("dealer_id", None)
    requested_station_ids = update_data.pop("station_ids", None)
    requested_warehouse_ids = update_data.pop("warehouse_ids", None)

    if "email" in update_data and update_data["email"] != user.email:
        existing = db.exec(select(User).where(User.email == update_data["email"], User.id != user_id)).first()
        if existing:
            raise HTTPException(status_code=400, detail="Email already exists")
    if "phone_number" in update_data and update_data["phone_number"] != user.phone_number:
        existing_phone = db.exec(
            select(User).where(User.phone_number == update_data["phone_number"], User.id != user_id)
        ).first()
        if existing_phone:
            raise HTTPException(status_code=400, detail="Phone number already exists")

    current_role = db.get(Role, user.role_id) if user.role_id else None
    if requested_role_id is not None or requested_role_name is not None:
        next_role = _resolve_existing_creation_role(
            db,
            role_id=requested_role_id,
            role_name=requested_role_name,
        )
    elif current_role is not None:
        next_role = current_role
    else:
        next_role = _resolve_existing_creation_role(db, role_id=None, role_name="customer")

    _assert_can_create_role(current_user, next_role.name)
    canonical_next_role = canonical_role_name(next_role.name)

    dealer_id = requested_dealer_id
    if dealer_id is None and canonical_next_role in DEALER_SCOPE_ROLE_NAMES:
        dealer_id = _current_dealer_id(db, user)

    if canonical_next_role in DEALER_STAFF_ROLE_NAMES and not dealer_id:
        raise HTTPException(status_code=400, detail="dealer_id is required for dealer staff")

    next_full_name = update_data.get("full_name", user.full_name)
    next_email = update_data.get("email", user.email)
    next_phone = update_data.get("phone_number", user.phone_number)
    role_name = next_role.name
    supabase_attributes = {
        "email": next_email,
        "phone": next_phone,
        "user_metadata": {
            "full_name": next_full_name or "",
            "role_name": role_name or "",
            "phone_number": next_phone or "",
            "status": user.status.value if user.status else "active",
            "local_user_id": user.id,
        },
    }
    identity = _sync_supabase_user_update(
        db,
        user=user,
        attributes=supabase_attributes,
    )

    for key, value in update_data.items():
        setattr(user, key, value)
    user.role_id = next_role.id
    user.user_type = _derive_user_type_from_role(next_role.name, user.user_type)
    if canonical_next_role in DEALER_SCOPE_ROLE_NAMES:
        user.created_by_dealer_id = dealer_id
    elif user.created_by_dealer_id is not None:
        user.created_by_dealer_id = None
    user.updated_at = datetime.now(UTC)
    db.add(user)

    if canonical_next_role in DEALER_STAFF_ROLE_NAMES:
        target_station_ids = (
            requested_station_ids
            if requested_station_ids is not None
            else _active_station_ids(db, int(user.id))
        )
        _sync_station_scope(
            db,
            user=user,
            dealer_id=int(dealer_id),
            station_ids=target_station_ids,
            current_user=current_user,
        )
    else:
        _deactivate_station_scope(db, user_id=int(user.id))

    if canonical_next_role in LOGISTICS_ROLE_NAMES:
        target_warehouse_ids = (
            requested_warehouse_ids
            if requested_warehouse_ids is not None
            else _active_warehouse_ids(db, int(user.id))
        )
        _sync_warehouse_scope(
            db,
            user=user,
            warehouse_ids=target_warehouse_ids,
            current_user=current_user,
        )
    else:
        _deactivate_warehouse_scope(db, user_id=int(user.id))

    if identity:
        identity.email_snapshot = user.email
        identity.status = UserIdentityStatus.ACTIVE
        identity.updated_at = datetime.now(UTC)
        db.add(identity)
    db.commit()
    db.refresh(user)
    _invalidate_admin_user_cache()

    role_name = _current_role_name(db, user)
    return _serialize_user_detail(db, user, role_name=role_name)


# DECONFLICTED P0-B: POST /{user_id}/reset-password removed.
# Canonical handler lives in app/api/v1/admin_users.py::admin_reset_password
# (has richer audit trail).  Removed 2026-04-06.


@router.put("/{user_id}/password")
def update_user_password(
    user_id: int,
    payload: AdminPasswordResetRequest,
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    user = db.get(User, user_id)
    if not user or user.is_deleted:
        raise HTTPException(status_code=404, detail="User not found")

    raw_password = payload.new_password or payload.password
    if not raw_password:
        raise HTTPException(status_code=400, detail="new_password is required")

    _sync_supabase_user_update(
        db,
        user=user,
        attributes={"password": raw_password},
    )

    user.hashed_password = get_password_hash(raw_password)
    user.force_password_change = payload.force_reset
    user.updated_at = datetime.now(UTC)
    db.add(user)
    db.commit()
    AuthService.revoke_all_user_sessions(db, user.id)
    _invalidate_admin_user_cache()
    return {"status": "success", "message": "Password reset successful"}


@router.delete("/{user_id}")
def delete_user(
    user_id: int,
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    user = db.get(User, user_id)
    if not user or user.is_deleted:
        raise HTTPException(status_code=404, detail="User not found")

    identity = _get_supabase_identity(db, user)
    if identity and identity.external_subject:
        try:
            SupabaseAdminService.delete_user(identity.external_subject)
        except ValueError as exc:
            raise HTTPException(status_code=502, detail=f"Supabase sync failed: {exc}") from exc

    user.is_deleted = True
    user.deleted_at = datetime.now(UTC)
    user.status = UserStatus.DELETED
    user.updated_at = datetime.now(UTC)
    user.last_global_logout_at = datetime.now(UTC)
    db.add(user)
    if identity:
        identity.status = UserIdentityStatus.DISABLED
        identity.updated_at = datetime.now(UTC)
        db.add(identity)
    db.commit()
    AuthService.revoke_all_user_sessions(db, user.id)
    _invalidate_admin_user_cache()
    return {"status": "success", "message": f"User {user.full_name or user.email} deleted"}


@router.put("/{user_id}/toggle-active")
def toggle_user_active(
    user_id: int,
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    """Block or unblock a user."""
    user = db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.is_active = not user.is_active
    user.updated_at = datetime.now(UTC)
    db.add(user)
    db.commit()
    db.refresh(user)
    _invalidate_admin_user_cache()
    return {"status": "success", "is_active": user.is_active}


@router.put("/{user_id}/suspend")
def suspend_user(
    user_id: int,
    request: SuspendRequest,
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    """Suspend a user account with a reason."""
    user = db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user.status == UserStatus.SUSPENDED:
        raise HTTPException(status_code=400, detail="User is already suspended")

    role_name = _current_role_name(db, user)
    identity = _sync_supabase_user_update(
        db,
        user=user,
        attributes={
            "ban_duration": "876000h",
            "user_metadata": {
                "full_name": user.full_name or "",
                "role_name": role_name or "",
                "phone_number": user.phone_number or "",
                "status": UserStatus.SUSPENDED.value,
                "local_user_id": user.id,
            },
        },
    )

    user.status = UserStatus.SUSPENDED
    user.deletion_reason = request.reason  # Reusing for suspension reason
    user.updated_at = datetime.now(UTC)
    user.last_global_logout_at = datetime.now(UTC)
    db.add(user)
    if identity:
        identity.status = UserIdentityStatus.DISABLED
        identity.updated_at = datetime.now(UTC)
        db.add(identity)
    db.commit()
    db.refresh(user)
    AuthService.revoke_all_user_sessions(db, user.id)
    _invalidate_admin_user_cache()

    return {
        "status": "success",
        "message": f"User {user.full_name} has been suspended",
        "user_status": user.status.value,
    }


@router.put("/{user_id}/reactivate")
def reactivate_user(
    user_id: int,
    request: ReactivateRequest = None,
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    """Reactivate a suspended user account."""
    user = db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user.status != UserStatus.SUSPENDED:
        raise HTTPException(status_code=400, detail="User is not suspended")

    role_name = _current_role_name(db, user)
    identity = _sync_supabase_user_update(
        db,
        user=user,
        attributes={
            "ban_duration": "none",
            "user_metadata": {
                "full_name": user.full_name or "",
                "role_name": role_name or "",
                "phone_number": user.phone_number or "",
                "status": UserStatus.ACTIVE.value,
                "local_user_id": user.id,
            },
        },
    )

    user.status = UserStatus.ACTIVE
    user.deletion_reason = None  # Clear suspension reason
    user.updated_at = datetime.now(UTC)
    db.add(user)
    if identity:
        identity.status = UserIdentityStatus.ACTIVE
        identity.updated_at = datetime.now(UTC)
        db.add(identity)
    db.commit()
    db.refresh(user)
    _invalidate_admin_user_cache()

    return {
        "status": "success",
        "message": f"User {user.full_name} has been reactivated",
        "user_status": user.status.value,
    }


@router.put("/{user_id}/kyc-status")
def update_user_kyc_status(
    user_id: int,
    status: str = Query(..., pattern="^(pending|verified|rejected)$"),
    current_user: User = Depends(deps.get_current_active_admin),
    db: Session = Depends(get_db),
):
    """Update user KYC status."""
    user = db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.kyc_status = status
    user.updated_at = datetime.now(UTC)
    db.add(user)
    db.commit()
    db.refresh(user)
    _invalidate_admin_user_cache()
    return {"status": "success", "kyc_status": user.kyc_status}
