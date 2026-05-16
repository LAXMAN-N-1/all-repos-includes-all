from sqlmodel import select

from app.core.security import get_password_hash
from app.models.rbac import Role, UserRole
from app.models.user import User, UserStatus


def _ensure_role(session, role_name: str) -> Role:
    role = session.exec(select(Role).where(Role.name == role_name)).first()
    if role:
        return role

    role = Role(
        name=role_name,
        description=f"{role_name} role",
        is_system_role=True,
    )
    session.add(role)
    session.commit()
    session.refresh(role)
    return role


def _create_user_with_roles(
    session,
    *,
    email: str,
    phone_number: str,
    password: str,
    role_names: list[str],
) -> User:
    roles = [_ensure_role(session, role_name) for role_name in role_names]

    user = User(
        email=email,
        phone_number=phone_number,
        hashed_password=get_password_hash(password),
        status=UserStatus.ACTIVE,
        role_id=roles[0].id,
    )
    session.add(user)
    session.commit()
    session.refresh(user)

    for role in roles:
        session.add(UserRole(user_id=user.id, role_id=role.id))
    session.commit()
    session.refresh(user)
    return user


def test_logistics_login_scope_rejects_dealer_only_accounts(client, session):
    _create_user_with_roles(
        session,
        email="dealer-only@appscope.test",
        phone_number="9011111111",
        password="Password123!",
        role_names=["dealer_owner"],
    )

    response = client.post(
        "/api/v1/auth/login",
        json={
            "credential": "dealer-only@appscope.test",
            "password": "Password123!",
            "app_scope": "logistics",
        },
    )

    assert response.status_code == 403
    assert "not authorized for logistics app" in response.json()["detail"]


def test_logistics_scope_requires_explicit_role_when_multiple_roles(client, session):
    _create_user_with_roles(
        session,
        email="multirole@appscope.test",
        phone_number="9011111112",
        password="Password123!",
        role_names=["logistics_manager", "dispatcher"],
    )

    response = client.post(
        "/api/v1/auth/login",
        json={
            "credential": "multirole@appscope.test",
            "password": "Password123!",
            "app_scope": "logistics",
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["success"] is False
    assert payload["requires_role_selection"] is True
    assert set(payload["available_roles"]) == {"dispatcher", "logistics_manager"}
    assert payload.get("access_token") in (None, "")


def test_logistics_scope_login_with_selected_role_succeeds(client, session):
    _create_user_with_roles(
        session,
        email="multirole-selected@appscope.test",
        phone_number="9011111113",
        password="Password123!",
        role_names=["logistics_manager", "dispatcher"],
    )

    response = client.post(
        "/api/v1/auth/login",
        json={
            "credential": "multirole-selected@appscope.test",
            "password": "Password123!",
            "app_scope": "logistics",
            "role": "dispatcher",
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["success"] is True
    assert payload["requires_role_selection"] is False
    assert payload["role"] == "dispatcher"
    assert payload["access_token"]
