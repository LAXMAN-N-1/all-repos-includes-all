from datetime import UTC, datetime
from unittest.mock import MagicMock

import pytest
from fastapi import HTTPException
from fastapi.testclient import TestClient
from sqlmodel import Session, select

from app.api import deps
from app.api.v1.deliveries_canonical import create_order
from app.models.access_assignment import WarehouseUserAssignment
from app.models.dealer import DealerProfile
from app.models.order import Order
from app.models.rbac import Permission, Role, UserRole
from app.models.user import User
from app.models.warehouse import Warehouse
from app.schemas.order import OrderCreate


def _create_permission(session: Session, slug: str) -> Permission:
    permission = Permission(slug=slug, module="test", action="read")
    session.add(permission)
    session.commit()
    session.refresh(permission)
    return permission


def _create_role_with_permissions(session: Session, name: str, perm_slugs: list[str]) -> Role:
    role = Role(name=name, is_active=True)
    session.add(role)
    session.commit()

    for slug in perm_slugs:
        permission = session.exec(select(Permission).where(Permission.slug == slug)).first()
        if permission is None:
            permission = _create_permission(session, slug)
        role.permissions.append(permission)

    session.add(role)
    session.commit()
    session.refresh(role)
    return role


def _create_user(session: Session, email: str) -> User:
    user = User(email=email, is_active=True)
    session.add(user)
    session.commit()
    session.refresh(user)
    return user


def _assign_role(session: Session, user: User, role: Role) -> None:
    session.add(UserRole(user_id=user.id, role_id=role.id))
    session.commit()


def _create_dealer_profile(session: Session, user: User) -> DealerProfile:
    profile = DealerProfile(
        user_id=user.id,
        business_name="Warehouse Test Dealer",
        contact_person="Dealer User",
        contact_email="dealer-warehouse@test.com",
        contact_phone="9999999999",
        address_line1="1 Test Street",
        city="Hyderabad",
        state="Telangana",
        pincode="500001",
    )
    session.add(profile)
    session.commit()
    session.refresh(profile)
    return profile


def _create_warehouse(session: Session, name: str, code: str) -> Warehouse:
    warehouse = Warehouse(
        name=name,
        code=code,
        address="Warehouse Address",
        city="Hyderabad",
        state="Telangana",
        pincode="500001",
        is_active=True,
    )
    session.add(warehouse)
    session.commit()
    session.refresh(warehouse)
    return warehouse


def _warehouse_actor_context(warehouse_id: int) -> deps.ActorContext:
    return deps.ActorContext(
        sub="warehouse-test-subject",
        role="warehouse_operator",
        warehouse_id=warehouse_id,
    )


def _request() -> MagicMock:
    request = MagicMock()
    request.headers = {}
    return request


class TestWarehouseDeliveryScope:
    def test_warehouse_user_list_orders_only_for_assigned_warehouse(
        self,
        client: TestClient,
        session: Session,
    ):
        user = _create_user(session, "warehouse-orders@test.com")
        role = _create_role_with_permissions(session, "warehouse_manager", [])
        _assign_role(session, user, role)
        warehouse = _create_warehouse(session, "Warehouse One", "WH-ORD-1")
        other_warehouse = _create_warehouse(session, "Warehouse Two", "WH-ORD-2")
        session.add(
            WarehouseUserAssignment(
                warehouse_id=warehouse.id,
                user_id=user.id,
                is_active=True,
            )
        )
        session.add(
            Order(
                id="ORD-WH-001",
                status="PENDING_ADMIN_APPROVAL",
                priority="normal",
                units=1,
                destination="Hyderabad",
                customer_name="Warehouse Customer",
                source_warehouse_id=warehouse.id,
                order_date=datetime.now(UTC),
                updated_at=datetime.now(UTC),
            )
        )
        session.add(
            Order(
                id="ORD-WH-002",
                status="PENDING_ADMIN_APPROVAL",
                priority="normal",
                units=1,
                destination="Secunderabad",
                customer_name="Other Warehouse Customer",
                source_warehouse_id=other_warehouse.id,
                order_date=datetime.now(UTC),
                updated_at=datetime.now(UTC),
            )
        )
        session.commit()

        app = client.app
        app.dependency_overrides[deps.get_current_user] = lambda: user
        app.dependency_overrides[deps.get_actor_context] = (
            lambda: _warehouse_actor_context(warehouse.id)
        )

        response = client.get("/api/v1/deliveries/")
        assert response.status_code == 200
        payload = response.json()
        order_ids = [row["id"] for row in payload["data"]]
        assert "ORD-WH-001" in order_ids
        assert "ORD-WH-002" not in order_ids

    def test_warehouse_user_create_order_forces_actor_warehouse(
        self,
        client: TestClient,
        session: Session,
        monkeypatch: pytest.MonkeyPatch,
    ):
        user = _create_user(session, "warehouse-create@test.com")
        role = _create_role_with_permissions(session, "warehouse_manager", [])
        _assign_role(session, user, role)
        warehouse = _create_warehouse(session, "Warehouse Create", "WH-CRT-1")
        session.add(
            WarehouseUserAssignment(
                warehouse_id=warehouse.id,
                user_id=user.id,
                is_active=True,
            )
        )
        session.commit()
        dealer_user = _create_user(session, "warehouse-dealer@test.com")
        dealer_profile = _create_dealer_profile(session, dealer_user)

        app = client.app
        app.dependency_overrides[deps.get_current_user] = lambda: user
        app.dependency_overrides[deps.get_actor_context] = (
            lambda: _warehouse_actor_context(warehouse.id)
        )
        monkeypatch.setattr(
            "app.api.v1.deliveries_canonical.assign_admin_user_id",
            lambda *args, **kwargs: user.id,
        )

        response = create_order.__wrapped__(
            request=_request(),
            payload=OrderCreate(
                units=2,
                destination="Warehouse Created Delivery",
                customer_name="Trace Customer",
                dealer_id=dealer_profile.id,
            ),
            current_user=user,
            actor_context=_warehouse_actor_context(warehouse.id),
            tenant_context=deps.TenantContext(user=user, scope="global"),
            session=session,
            idempotency_key=None,
        )
        payload = response.data.model_dump()
        assert payload["source_warehouse_id"] == warehouse.id
        assert payload["created_by_role"] == "warehouse_operator"

        stored_order = session.get(Order, payload["id"])
        assert stored_order is not None
        assert stored_order.source_warehouse_id == warehouse.id

    def test_warehouse_user_cannot_override_source_warehouse(
        self,
        client: TestClient,
        session: Session,
    ):
        user = _create_user(session, "warehouse-mismatch@test.com")
        role = _create_role_with_permissions(session, "warehouse_manager", [])
        _assign_role(session, user, role)
        warehouse = _create_warehouse(session, "Warehouse Scoped", "WH-SCP-1")
        other_warehouse = _create_warehouse(session, "Warehouse Other", "WH-SCP-2")
        session.add(
            WarehouseUserAssignment(
                warehouse_id=warehouse.id,
                user_id=user.id,
                is_active=True,
            )
        )
        session.commit()
        dealer_user = _create_user(session, "warehouse-mismatch-dealer@test.com")
        dealer_profile = _create_dealer_profile(session, dealer_user)

        app = client.app
        app.dependency_overrides[deps.get_current_user] = lambda: user
        app.dependency_overrides[deps.get_actor_context] = (
            lambda: _warehouse_actor_context(warehouse.id)
        )

        with pytest.raises(HTTPException) as exc_info:
            create_order.__wrapped__(
                request=_request(),
                payload=OrderCreate(
                    units=1,
                    destination="Invalid Warehouse Override",
                    customer_name="Trace Customer",
                    dealer_id=dealer_profile.id,
                    source_warehouse_id=other_warehouse.id,
                ),
                current_user=user,
                actor_context=_warehouse_actor_context(warehouse.id),
                tenant_context=deps.TenantContext(user=user, scope="global"),
                session=session,
                idempotency_key=None,
            )
        assert exc_info.value.status_code == 403
        assert exc_info.value.detail == "warehouse_assignment_mismatch"
