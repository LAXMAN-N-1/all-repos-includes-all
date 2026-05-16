from fastapi.testclient import TestClient
from sqlmodel import Session, select

from app.api import deps
from app.core.config import settings
from app.core.security import get_password_hash
from app.main import app
from app.api.admin.stations import create_station as admin_create_station
from app.api.admin.users import AdminUserCreateRequest, admin_create_user
from app.models.access_assignment import WarehouseUserAssignment
from app.models.dealer import DealerProfile
from app.models.rbac import Role, UserRole
from app.models.station import Station
from app.models.tenant import TenantMembership
from app.models.user_identity import UserIdentity
from app.models.user import User, UserStatus, UserType
from app.models.warehouse import Warehouse
from app.schemas.station import StationCreate


def _add_role(session: Session, name: str, *, level: int = 10) -> Role:
    existing = session.exec(select(Role).where(Role.name == name)).first()
    if existing:
        existing.level = level
        existing.is_active = True
        session.add(existing)
        session.commit()
        session.refresh(existing)
        return existing

    role = Role(
        name=name,
        description=f"{name} role",
        category=name.split("_")[0],
        level=level,
        is_system_role=True,
    )
    session.add(role)
    session.commit()
    session.refresh(role)
    return role


def _add_admin_user(session: Session, role: Role) -> User:
    user = User(
        email="ops-admin@example.com",
        full_name="Ops Admin",
        phone_number="9100000000",
        hashed_password=get_password_hash("password"),
        status=UserStatus.ACTIVE,
        user_type=UserType.ADMIN,
        role_id=role.id,
    )
    session.add(user)
    session.commit()
    session.refresh(user)
    session.add(UserRole(user_id=user.id, role_id=role.id))
    session.commit()
    return user


def test_creation_roles_lists_roles_current_admin_can_create(
    client: TestClient,
    session: Session,
):
    ops_role = _add_role(session, "operations_admin", level=90)
    _add_role(session, "security_admin", level=85)
    logistics_role = _add_role(session, "logistics_manager", level=70)
    dealer_role = _add_role(session, "dealer_owner", level=60)
    admin = _add_admin_user(session, ops_role)

    app.dependency_overrides[deps.get_current_active_admin] = lambda: admin
    try:
        response = client.get(
            f"{settings.API_V1_STR}/admin/users/creation-roles"
        )
    finally:
        app.dependency_overrides.pop(deps.get_current_active_admin, None)

    assert response.status_code == 200, response.text
    names = {item["name"] for item in response.json()}
    assert ops_role.name in names
    assert logistics_role.name in names
    assert dealer_role.name in names
    assert "security_admin" not in names

    dealer_item = next(
        item for item in response.json() if item["name"] == "dealer_owner"
    )
    assert dealer_item["user_type"] == "dealer"
    assert dealer_item["requires_dealer_profile"] is True


def test_creation_roles_returns_existing_role_name_with_canonical_alias(
    client: TestClient,
    session: Session,
):
    legacy_admin_role = _add_role(session, "admin", level=90)
    admin = _add_admin_user(session, legacy_admin_role)

    app.dependency_overrides[deps.get_current_active_admin] = lambda: admin
    try:
        response = client.get(
            f"{settings.API_V1_STR}/admin/users/creation-roles"
        )
    finally:
        app.dependency_overrides.pop(deps.get_current_active_admin, None)

    assert response.status_code == 200, response.text
    legacy_item = next(item for item in response.json() if item["id"] == legacy_admin_role.id)
    assert legacy_item["name"] == "admin"
    assert legacy_item["canonical_name"] == "operations_admin"
    assert legacy_item["display_name"] == "Admin"


def test_admin_create_user_accepts_existing_role_id(
    session: Session,
    monkeypatch,
):
    ops_role = _add_role(session, "operations_admin", level=90)
    support_role = _add_role(session, "support_agent", level=60)
    admin = _add_admin_user(session, ops_role)
    supabase_subject = "supabase-existing-role-id"

    monkeypatch.setattr(
        "app.api.admin.users.SupabaseAdminService.create_user",
        staticmethod(lambda **_: {"id": supabase_subject}),
    )
    monkeypatch.setattr(
        "app.api.admin.users.SupabaseAdminService.delete_user",
        staticmethod(lambda *_: None),
    )

    response = admin_create_user(
        payload=AdminUserCreateRequest(
            full_name="Support Agent",
            email="support-agent@example.com",
            password="Password123",
            role_id=support_role.id,
            role_name=None,
            user_type=UserType.SUPPORT_AGENT,
        ),
        db=session,
        current_user=admin,
    )

    identity = session.exec(
        select(UserIdentity).where(UserIdentity.external_subject == supabase_subject)
    ).first()
    assert identity is not None
    assert response["role_id"] == support_role.id
    assert response["role_name"] == "support_agent"
    assert response["canonical_role_name"] == "support_agent"


def test_admin_create_user_resolves_canonical_name_to_existing_legacy_role(
    session: Session,
    monkeypatch,
):
    legacy_admin_role = _add_role(session, "admin", level=90)
    admin = _add_admin_user(session, legacy_admin_role)
    supabase_subject = "supabase-legacy-admin-role"

    monkeypatch.setattr(
        "app.api.admin.users.SupabaseAdminService.create_user",
        staticmethod(lambda **_: {"id": supabase_subject}),
    )
    monkeypatch.setattr(
        "app.api.admin.users.SupabaseAdminService.delete_user",
        staticmethod(lambda *_: None),
    )

    response = admin_create_user(
        payload=AdminUserCreateRequest(
            full_name="Ops User",
            email="ops-user@example.com",
            password="Password123",
            role_name="operations_admin",
            user_type=UserType.ADMIN,
        ),
        db=session,
        current_user=admin,
    )

    assert response["role_id"] == legacy_admin_role.id
    assert response["role_name"] == "admin"
    assert response["canonical_role_name"] == "operations_admin"


def test_admin_create_user_creates_dealer_owner_with_connected_stations(
    session: Session,
    monkeypatch,
):
    admin_role = _add_role(session, "operations_admin", level=90)
    dealer_role = _add_role(session, "dealer_owner", level=60)
    admin = _add_admin_user(session, admin_role)
    supabase_subject = "supabase-dealer-owner-with-stations"

    monkeypatch.setattr(
        "app.api.admin.users.SupabaseAdminService.create_user",
        staticmethod(lambda **_: {"id": supabase_subject}),
    )
    monkeypatch.setattr(
        "app.api.admin.users.SupabaseAdminService.delete_user",
        staticmethod(lambda *_: None),
    )

    response = admin_create_user(
        payload=AdminUserCreateRequest(
            full_name="Dealer Owner",
            email="dealer-owner@example.com",
            password="Password123",
            role_id=dealer_role.id,
            role_name=None,
            user_type=UserType.DEALER,
            dealer_profile={
                "business_name": "Dealer Owner Business",
                "contact_person": "Dealer Owner",
                "contact_email": "dealer-owner@example.com",
                "contact_phone": "9000000001",
                "address_line1": "Road 1",
                "city": "Hyderabad",
                "state": "Telangana",
                "pincode": "500001",
            },
            stations_to_create=[
                {
                    "name": "Dealer Station 1",
                    "address": "Address 1",
                    "city": "Hyderabad",
                    "latitude": 17.1,
                    "longitude": 78.1,
                    "station_type": "automated",
                    "total_slots": 8,
                },
                {
                    "name": "Dealer Station 2",
                    "address": "Address 2",
                    "city": "Hyderabad",
                    "latitude": 17.2,
                    "longitude": 78.2,
                    "station_type": "hybrid",
                    "total_slots": 10,
                },
            ],
        ),
        db=session,
        current_user=admin,
    )

    dealer = session.exec(
        select(DealerProfile).where(DealerProfile.user_id == response["id"])
    ).first()
    stations = session.exec(
        select(Station).where(Station.dealer_id == dealer.id).order_by(Station.id.asc())
    ).all()
    membership = session.exec(
        select(TenantMembership).where(
            TenantMembership.tenant_id == dealer.tenant_id,
            TenantMembership.user_id == response["id"],
        )
    ).first()

    assert dealer is not None
    assert dealer.tenant_id == response["tenant_id"]
    assert membership is not None
    assert len(stations) == 2
    assert response["dealer_id"] == dealer.id
    assert len(response["created_station_ids"]) == 2
    assert {station.id for station in stations} == set(response["created_station_ids"])
    assert all(station.tenant_id == dealer.tenant_id for station in stations)


def test_admin_create_user_creates_logistics_user_with_connected_warehouses(
    session: Session,
    monkeypatch,
):
    admin_role = _add_role(session, "operations_admin", level=90)
    logistics_role = _add_role(session, "warehouse_manager", level=60)
    admin = _add_admin_user(session, admin_role)
    supabase_subject = "supabase-logistics-with-warehouses"

    monkeypatch.setattr(
        "app.api.admin.users.SupabaseAdminService.create_user",
        staticmethod(lambda **_: {"id": supabase_subject}),
    )
    monkeypatch.setattr(
        "app.api.admin.users.SupabaseAdminService.delete_user",
        staticmethod(lambda *_: None),
    )

    response = admin_create_user(
        payload=AdminUserCreateRequest(
            full_name="Warehouse Manager",
            email="warehouse-manager@example.com",
            password="Password123",
            role_id=logistics_role.id,
            role_name=None,
            user_type=UserType.LOGISTICS,
            warehouses_to_create=[
                {
                    "name": "Warehouse 1",
                    "code": "WM-001",
                    "address": "Warehouse Address 1",
                    "city": "Hyderabad",
                    "state": "Telangana",
                    "pincode": "500001",
                },
                {
                    "name": "Warehouse 2",
                    "code": "WM-002",
                    "address": "Warehouse Address 2",
                    "city": "Hyderabad",
                    "state": "Telangana",
                    "pincode": "500002",
                },
            ],
        ),
        db=session,
        current_user=admin,
    )

    warehouses = session.exec(
        select(Warehouse).where(Warehouse.manager_id == response["id"]).order_by(Warehouse.id.asc())
    ).all()
    assignments = session.exec(
        select(WarehouseUserAssignment).where(WarehouseUserAssignment.user_id == response["id"])
    ).all()

    assert len(warehouses) == 2
    assert len(assignments) == 2
    assert len(response["created_warehouse_ids"]) == 2
    assert set(response["warehouse_ids"]) == set(response["created_warehouse_ids"])
    assert {warehouse.id for warehouse in warehouses} == set(response["created_warehouse_ids"])


def test_admin_station_create_persists_dealer_id(
    session: Session,
):
    admin_role = _add_role(session, "operations_admin", level=90)
    dealer_role = _add_role(session, "dealer_owner", level=60)
    admin = _add_admin_user(session, admin_role)

    dealer_owner = User(
        email="dealer-owner-station@test.local",
        full_name="Dealer Owner Station",
        phone_number="9000000099",
        hashed_password=get_password_hash("password"),
        status=UserStatus.ACTIVE,
        user_type=UserType.DEALER,
        role_id=dealer_role.id,
    )
    session.add(dealer_owner)
    session.commit()
    session.refresh(dealer_owner)

    dealer = DealerProfile(
        user_id=dealer_owner.id,
        business_name="Station Dealer",
        contact_person="Station Dealer",
        contact_email=dealer_owner.email,
        contact_phone=dealer_owner.phone_number,
        address_line1="Dealer Address",
        city="Hyderabad",
        state="Telangana",
        pincode="500001",
        is_active=True,
    )
    session.add(dealer)
    session.commit()
    session.refresh(dealer)

    response = admin_create_station(
        request=StationCreate(
            name="Dealer Linked Station",
            address="Linked Address",
            city="Hyderabad",
            latitude=17.31,
            longitude=78.42,
            dealer_id=dealer.id,
            total_slots=12,
        ),
        db=session,
        current_user=admin,
    )

    created = session.get(Station, response["station_id"])
    assert created is not None
    assert created.dealer_id == dealer.id
