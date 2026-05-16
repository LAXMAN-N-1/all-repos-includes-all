from __future__ import annotations

from datetime import UTC, datetime
from uuid import uuid4

import pytest
from fastapi import HTTPException
from sqlmodel import Session, select

from app.api import deps
from app.api.admin.stock import (
    DealerStockRequestApprove,
    approve_dealer_stock_request,
)
from app.api.admin.users import AdminUserCreateRequest, admin_create_user
from app.api.v1.inventory import (
    TransferCreateCompat,
    confirm_transfer_receipt,
    create_transfer_order,
)
from app.core.dealer_scope import accessible_station_ids_for_user
from app.models.access_assignment import StationStaffAssignment, WarehouseUserAssignment
from app.models.battery import Battery, BatteryStatus, LocationType
from app.models.dealer import DealerProfile
from app.models.dealer_stock_request import DealerStockRequest, StockRequestStatus
from app.models.driver_profile import DriverProfile
from app.models.rbac import Role
from app.models.station import Station
from app.models.tenant import Tenant
from app.models.tenant import TenantMembership
from app.models.user_identity import UserIdentity
from app.models.user import User, UserStatus, UserType
from app.models.warehouse import Warehouse
from app.services.dealer_portal_inventory_service import DealerPortalInventoryService


def _role(session: Session, name: str, *, level: int = 10) -> Role:
    existing = session.exec(select(Role).where(Role.name == name)).first()
    if existing:
        return existing
    role = Role(name=name, level=level, is_active=True)
    session.add(role)
    session.commit()
    session.refresh(role)
    return role


def _user(session: Session, email_prefix: str, role: Role | None = None, *, user_type: UserType = UserType.CUSTOMER) -> User:
    user = User(
        email=f"{email_prefix}-{uuid4().hex[:8]}@test.local",
        phone_number=str(abs(hash(email_prefix + uuid4().hex)) % 9_000_000_000 + 1_000_000_000),
        full_name=email_prefix,
        status=UserStatus.ACTIVE,
        user_type=user_type,
        role_id=role.id if role else None,
    )
    session.add(user)
    session.commit()
    session.refresh(user)
    if role:
        setattr(user, "_active_roles_cache", [role])
    return user


def _dealer_with_stations(session: Session) -> tuple[DealerProfile, User, Station, Station]:
    owner_role = _role(session, "dealer_owner")
    owner = _user(session, "dealer-owner", owner_role, user_type=UserType.DEALER)
    dealer = DealerProfile(
        user_id=owner.id,
        business_name="Dealer Tenant",
        contact_person="Owner",
        contact_email=owner.email,
        contact_phone=owner.phone_number,
        address_line1="1 Dealer Street",
        city="Hyderabad",
        state="Telangana",
        pincode="500001",
        is_active=True,
    )
    session.add(dealer)
    session.commit()
    session.refresh(dealer)

    tenant = Tenant(id=dealer.id, slug=f"dealer-{dealer.id}", name=dealer.business_name)
    session.add(tenant)
    session.commit()
    dealer.tenant_id = tenant.id
    session.add(dealer)
    session.commit()
    session.refresh(dealer)

    station_a = Station(
        name="Station A",
        tenant_id=tenant.id,
        dealer_id=dealer.id,
        address="A",
        latitude=17.1,
        longitude=78.1,
        total_slots=10,
    )
    station_b = Station(
        name="Station B",
        tenant_id=tenant.id,
        dealer_id=dealer.id,
        address="B",
        latitude=17.2,
        longitude=78.2,
        total_slots=10,
    )
    session.add(station_a)
    session.add(station_b)
    session.commit()
    session.refresh(station_a)
    session.refresh(station_b)
    return dealer, owner, station_a, station_b


def _warehouse(session: Session) -> Warehouse:
    warehouse = Warehouse(
        name="Warehouse A",
        code=f"WH-{uuid4().hex[:8]}",
        address="Warehouse",
        city="Hyderabad",
        state="Telangana",
        pincode="500001",
        is_active=True,
    )
    session.add(warehouse)
    session.commit()
    session.refresh(warehouse)
    return warehouse


def test_dealer_owner_sees_all_stations_and_staff_only_assigned_station(session: Session):
    dealer, owner, station_a, station_b = _dealer_with_stations(session)

    assert set(accessible_station_ids_for_user(session, owner, dealer)) == {station_a.id, station_b.id}

    staff_role = _role(session, "dealer_inventory_staff")
    staff = _user(session, "inventory-staff", staff_role, user_type=UserType.DEALER_STAFF)
    staff.created_by_dealer_id = dealer.id
    session.add(staff)
    session.add(
        StationStaffAssignment(
            dealer_id=dealer.id,
            station_id=station_a.id,
            user_id=staff.id,
            assigned_by_user_id=owner.id,
        )
    )
    session.commit()

    assert accessible_station_ids_for_user(session, staff, dealer) == [station_a.id]


def test_station_scoped_stock_request_requires_assigned_station(session: Session):
    dealer, owner, station_a, station_b = _dealer_with_stations(session)

    created = DealerPortalInventoryService.create_stock_request(
        db=session,
        dealer_id=dealer.id,
        tenant_id=dealer.tenant_id,
        station_id=station_a.id,
        quantity=2,
        model_name="48V Pack",
        user_id=owner.id,
        accessible_station_ids=[station_a.id],
    )

    assert created["station_id"] == station_a.id
    assert created["tenant_id"] == dealer.tenant_id
    with pytest.raises(ValueError, match="Station not found"):
        DealerPortalInventoryService.create_stock_request(
            db=session,
            dealer_id=dealer.id,
            tenant_id=dealer.tenant_id,
            station_id=station_b.id,
            quantity=2,
            model_name="48V Pack",
            user_id=owner.id,
            accessible_station_ids=[station_a.id],
        )


def test_operations_admin_approves_request_and_security_admin_cannot(session: Session):
    dealer, _, station, _ = _dealer_with_stations(session)
    warehouse = _warehouse(session)
    req = DealerStockRequest(
        tenant_id=dealer.tenant_id,
        dealer_id=dealer.id,
        station_id=station.id,
        quantity=2,
        status=StockRequestStatus.PENDING,
    )
    session.add(req)
    session.commit()
    session.refresh(req)

    security_admin = _user(session, "security-admin", _role(session, "security_admin", level=90), user_type=UserType.ADMIN)
    with pytest.raises(HTTPException) as exc:
        approve_dealer_stock_request(
            request_id=req.id,
            payload=DealerStockRequestApprove(source_warehouse_id=warehouse.id),
            db=session,
            current_user=security_admin,
        )
    assert exc.value.status_code == 403

    operations_admin = _user(session, "operations-admin", _role(session, "operations_admin", level=90), user_type=UserType.ADMIN)
    response = approve_dealer_stock_request(
        request_id=req.id,
        payload=DealerStockRequestApprove(source_warehouse_id=warehouse.id, notes="ship from WH-A"),
        db=session,
        current_user=operations_admin,
    )

    session.refresh(req)
    assert response["data"]["status"] == "approved"
    assert req.source_warehouse_id == warehouse.id
    assert req.approved_by == operations_admin.id


def test_transfer_completion_fulfills_approved_dealer_station_request(session: Session):
    dealer, _, station, _ = _dealer_with_stations(session)
    warehouse = _warehouse(session)
    logistics_role = _role(session, "logistics_manager", level=80)
    logistics_user = _user(session, "logistics-manager", logistics_role, user_type=UserType.LOGISTICS)
    driver_role = _role(session, "driver")
    driver_user = _user(session, "driver-user", driver_role, user_type=UserType.LOGISTICS)
    driver_profile = DriverProfile(
        user_id=driver_user.id,
        name=driver_user.full_name,
        phone_number=driver_user.phone_number,
        license_number="DL-1",
        vehicle_type="van",
        vehicle_plate="TS-01",
    )
    session.add(driver_profile)
    session.commit()
    session.refresh(driver_profile)

    session.add(WarehouseUserAssignment(warehouse_id=warehouse.id, user_id=logistics_user.id))
    batteries: list[Battery] = []
    for idx in range(2):
        battery = Battery(
            serial_number=f"BAT-{uuid4().hex[:8]}-{idx}",
            status=BatteryStatus.AVAILABLE,
            location_type=LocationType.WAREHOUSE,
            location_id=warehouse.id,
        )
        session.add(battery)
        batteries.append(battery)
    session.commit()
    for battery in batteries:
        session.refresh(battery)

    req = DealerStockRequest(
        tenant_id=dealer.tenant_id,
        dealer_id=dealer.id,
        station_id=station.id,
        source_warehouse_id=warehouse.id,
        quantity=2,
        status=StockRequestStatus.APPROVED,
        approved_by=logistics_user.id,
        approved_at=datetime.now(UTC),
    )
    session.add(req)
    session.commit()
    session.refresh(req)

    transfer_payload = create_transfer_order(
        session=session,
        transfer_in=TransferCreateCompat(
            battery_ids=[battery.serial_number for battery in batteries],
            dealer_stock_request_id=req.id,
            from_location_type="warehouse",
            from_location_id=warehouse.id,
            to_location_type="station",
            to_location_id=station.id,
            driver_id=driver_profile.id,
        ),
        current_user=logistics_user,
        tenant_context=deps.TenantContext(user=logistics_user, scope="global"),
    )
    session.refresh(req)
    assert req.status == StockRequestStatus.IN_FULFILLMENT
    assert req.assigned_transfer_id == transfer_payload["id"]

    received_payload = confirm_transfer_receipt(
        session=session,
        id=transfer_payload["id"],
        current_user=driver_user,
        tenant_context=deps.TenantContext(user=driver_user, scope="global"),
    )

    session.refresh(req)
    assert received_payload["status"] == "completed"
    assert req.status == StockRequestStatus.FULFILLED
    assert req.fulfilled_quantity == 2
    for battery in batteries:
        session.refresh(battery)
        assert battery.location_type == LocationType.STATION
        assert battery.location_id == station.id
        assert battery.station_id == station.id


def test_admin_supabase_user_create_links_dealer_staff_scope(session: Session, monkeypatch: pytest.MonkeyPatch):
    dealer, _, station, _ = _dealer_with_stations(session)
    staff_role = _role(session, "dealer_inventory_staff")
    operations_admin = _user(
        session,
        "operations-admin-create",
        _role(session, "operations_admin", level=90),
        user_type=UserType.ADMIN,
    )
    supabase_subject = f"supabase-{uuid4().hex}"

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
            full_name="Station Staff",
            email="station.staff@example.com",
            password="Password123",
            role_name=staff_role.name,
            user_type=UserType.DEALER_STAFF,
            dealer_id=dealer.id,
            station_ids=[station.id],
        ),
        db=session,
        current_user=operations_admin,
    )

    identity = session.exec(
        select(UserIdentity).where(UserIdentity.external_subject == supabase_subject)
    ).first()
    membership = session.exec(
        select(TenantMembership).where(
            TenantMembership.tenant_id == dealer.tenant_id,
            TenantMembership.user_id == response["id"],
        )
    ).first()
    station_assignment = session.exec(
        select(StationStaffAssignment).where(
            StationStaffAssignment.user_id == response["id"],
            StationStaffAssignment.station_id == station.id,
        )
    ).first()

    assert identity is not None
    assert membership is not None
    assert station_assignment is not None
    assert response["tenant_id"] == dealer.tenant_id
    assert response["dealer_id"] == dealer.id
