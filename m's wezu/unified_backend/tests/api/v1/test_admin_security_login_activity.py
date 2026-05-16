from datetime import UTC, datetime

from fastapi.testclient import TestClient
from sqlmodel import Session, select

from app.api import deps
from app.core.security import get_password_hash
from app.main import app
from app.models.rbac import Role
from app.models.session import UserSession
from app.models.user import User, UserStatus, UserType


def test_login_activity_falls_back_to_local_user_sessions(
    client: TestClient,
    session: Session,
):
    admin_user = session.exec(select(User).where(User.email == "admin@test.com")).first()
    assert admin_user is not None

    customer_role = session.exec(select(Role).where(Role.name == "customer")).first()
    if customer_role is None:
        customer_role = Role(name="customer", description="Customer", category="system", level=1)
        session.add(customer_role)
        session.commit()
        session.refresh(customer_role)

    actor = User(
        email="login.activity@test.com",
        phone_number="7000000001",
        full_name="Login Activity User",
        hashed_password=get_password_hash("password"),
        status=UserStatus.ACTIVE,
        user_type=UserType.CUSTOMER,
        role_id=customer_role.id,
    )
    session.add(actor)
    session.commit()
    session.refresh(actor)

    login_session = UserSession(
        user_id=actor.id,
        token_id="token-login-activity",
        ip_address="10.20.30.40",
        user_agent="Mozilla/5.0 Test Browser",
        is_active=True,
        created_at=datetime(2026, 4, 23, 10, 30, tzinfo=UTC),
        issued_at=datetime(2026, 4, 23, 10, 30, tzinfo=UTC),
        last_active_at=datetime(2026, 4, 23, 10, 45, tzinfo=UTC),
    )
    session.add(login_session)
    session.commit()

    app.dependency_overrides[deps.get_current_active_admin] = lambda: admin_user
    try:
        response = client.get("/api/v1/admin/security/login-activity?skip=0&limit=100")
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200, response.text
    payload = response.json()
    assert payload["source"] == "local_user_sessions"
    assert payload["total_count"] >= 1
    assert len(payload["items"]) >= 1

    row = payload["items"][0]
    assert row["email"] == "login.activity@test.com"
    assert row["user_name"] == "Login Activity User"
    assert row["role_name"] == "customer"
    assert row["ip_address"] == "10.20.30.40"
    assert row["device_browser"] == "Mozilla/5.0 Test Browser"
    assert row["is_success"] is True
