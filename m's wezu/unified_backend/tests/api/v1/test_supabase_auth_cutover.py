from __future__ import annotations

import pytest
from jose import jwt as jose_jwt
from sqlmodel import Session, select

from app.api import deps
from app.core.config import settings
from app.models.oauth import BlacklistedToken
from app.models.rbac import Role, UserRole
from app.models.user import User, UserStatus
from app.models.user_identity import UserIdentity
from app.services.auth_service import AuthService, SupabaseTokenValidationError


def _mock_supabase_verifier(payload_by_token: dict[str, dict]):
    def _verify(cls, token: str):
        payload = payload_by_token.get(token)
        if payload is None:
            raise SupabaseTokenValidationError("token_invalid", "invalid test token")
        return payload

    return classmethod(_verify)


def _ensure_role(session: Session, name: str, *, level: int = 0) -> Role:
    role = session.exec(select(Role).where(Role.name == name)).first()
    if role is None:
        role = Role(name=name, level=level, is_active=True)
        session.add(role)
        session.commit()
        session.refresh(role)
    return role


@pytest.fixture(autouse=True)
def _force_supabase_mode(monkeypatch):
    monkeypatch.setattr(settings, "AUTH_PROVIDER", "supabase")
    monkeypatch.setattr(settings, "SUPABASE_ENFORCE_EMAIL_VERIFIED", True)


def test_auth_me_returns_identity_and_rbac(client, session: Session, monkeypatch):
    user = User(
        email="supa-mapped@example.com",
        full_name="Supa Mapped",
        phone_number="9000011111",
        status=UserStatus.ACTIVE,
    )
    session.add(user)
    session.commit()
    session.refresh(user)

    session.add(
        UserIdentity(
            provider="supabase",
            external_subject="sub-123",
            user_id=user.id,
            email_snapshot=user.email,
        )
    )
    admin_role = _ensure_role(session, "operations_admin", level=100)
    session.add(UserRole(user_id=user.id, role_id=admin_role.id))
    session.commit()

    token = "supabase-valid-token"
    monkeypatch.setattr(
        AuthService,
        "verify_supabase_access_token",
        _mock_supabase_verifier(
            {
                token: {
                    "sub": "sub-123",
                    "email": "supa-mapped@example.com",
                    "email_verified": True,
                    "role": "authenticated",
                    "user_metadata": {"role_name": "admin"},
                    "iat": 1713072000,
                    "exp": 1893456000,
                }
            }
        ),
    )
    deps.invalidate_token_cache(token)

    response = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 200, response.text
    body = response.json()
    assert body["identity_provider"] == "supabase"
    assert body["identity_subject"] == "sub-123"
    assert body["user"]["email"] == "supa-mapped@example.com"
    assert "operations_admin" in body["roles"]


def test_auth_me_auto_links_unique_verified_email(client, session: Session, monkeypatch):
    user = User(
        email="supa-autolink@example.com",
        full_name="Supa AutoLink",
        phone_number="9000011112",
        status=UserStatus.ACTIVE,
    )
    session.add(user)
    session.commit()
    session.refresh(user)

    token = "supabase-autolink-token"
    monkeypatch.setattr(
        AuthService,
        "verify_supabase_access_token",
        _mock_supabase_verifier(
            {
                token: {
                    "sub": "sub-autolink",
                    "email": "supa-autolink@example.com",
                    "email_verified": True,
                    "iat": 1713072000,
                    "exp": 1893456000,
                }
            }
        ),
    )
    deps.invalidate_token_cache(token)

    response = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 200, response.text

    mapped = session.exec(
        select(UserIdentity).where(
            UserIdentity.provider == "supabase",
            UserIdentity.external_subject == "sub-autolink",
            UserIdentity.user_id == user.id,
        )
    ).first()
    assert mapped is not None


def test_auth_me_rejects_unmapped_identity(client, monkeypatch):
    token = "supabase-unmapped-token"
    monkeypatch.setattr(
        AuthService,
        "verify_supabase_access_token",
        _mock_supabase_verifier(
            {
                token: {
                    "sub": "sub-unmapped",
                    "email": "no-local-user@example.com",
                    "email_verified": True,
                    "iat": 1713072000,
                    "exp": 1893456000,
                }
            }
        ),
    )
    deps.invalidate_token_cache(token)

    response = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 401
    assert response.json()["detail"] == "identity_unmapped"


def test_auth_me_rejects_local_legacy_jwt(client):
    token = jose_jwt.encode(
        {"sub": "123", "type": "access", "sid": "legacy-session"},
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM,
    )
    deps.invalidate_token_cache(token)

    response = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 401
    assert response.json()["detail"] == "token_invalid"


def test_auth_me_rejects_non_access_supabase_token(client, monkeypatch):
    token = "supabase-refresh-token"
    monkeypatch.setattr(
        AuthService,
        "verify_supabase_access_token",
        _mock_supabase_verifier(
            {
                token: {
                    "sub": "sub-refresh",
                    "email": "refresh@example.com",
                    "email_verified": True,
                    "type": "refresh",
                    "iat": 1713072000,
                    "exp": 1893456000,
                }
            }
        ),
    )
    deps.invalidate_token_cache(token)

    response = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 401
    assert response.json()["detail"] == "token_invalid"


def test_logout_blacklists_supabase_token_and_invalidates_cached_auth(
    client,
    session: Session,
    monkeypatch,
):
    user = User(
        email="logout-supabase@example.com",
        full_name="Supabase Logout",
        phone_number="9000011113",
        status=UserStatus.ACTIVE,
    )
    session.add(user)
    session.commit()
    session.refresh(user)

    session.add(
        UserIdentity(
            provider="supabase",
            external_subject="sub-logout-supabase",
            user_id=user.id,
            email_snapshot=user.email,
        )
    )
    session.commit()

    token = "supabase-logout-token"
    monkeypatch.setattr(
        AuthService,
        "verify_supabase_access_token",
        _mock_supabase_verifier(
            {
                token: {
                    "sub": "sub-logout-supabase",
                    "email": "logout-supabase@example.com",
                    "email_verified": True,
                    "iat": 1713072000,
                    "exp": 1893456000,
                }
            }
        ),
    )
    deps.invalidate_token_cache(token)

    warmup_response = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert warmup_response.status_code == 200, warmup_response.text

    logout_response = client.post(
        "/api/v1/auth/logout",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert logout_response.status_code == 200, logout_response.text

    blacklisted = session.exec(select(BlacklistedToken)).all()
    assert blacklisted, "Logout should persist a token blacklist entry"

    rejected_response = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert rejected_response.status_code == 401, rejected_response.text
    assert rejected_response.json()["detail"] == "token_invalid"


def test_auth_me_blocks_suspended_local_user_even_with_valid_supabase_token(client, session: Session, monkeypatch):
    user = User(
        email="supa-suspended@example.com",
        full_name="Supa Suspended",
        phone_number="9000011114",
        status=UserStatus.SUSPENDED,
    )
    session.add(user)
    session.commit()
    session.refresh(user)

    session.add(
        UserIdentity(
            provider="supabase",
            external_subject="sub-suspended",
            user_id=user.id,
            email_snapshot=user.email,
        )
    )
    session.commit()

    token = "supabase-suspended-token"
    monkeypatch.setattr(
        AuthService,
        "verify_supabase_access_token",
        _mock_supabase_verifier(
            {
                token: {
                    "sub": "sub-suspended",
                    "email": "supa-suspended@example.com",
                    "email_verified": True,
                    "type": "access",
                    "iat": 1713072000,
                    "exp": 1893456000,
                }
            }
        ),
    )
    deps.invalidate_token_cache(token)

    response = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 403
    assert response.json()["detail"] == "insufficient_permissions"


@pytest.mark.parametrize(
    "path",
    [
        "/api/v1/auth/login",
        "/api/v1/auth/token",
        "/api/v1/auth/refresh",
        "/api/v1/auth/passkeys",
        "/api/v1/customers/auth/login",
        "/api/v1/dealers/auth/login",
        "/api/v1/sessions",
    ],
)
def test_legacy_auth_and_sessions_are_tombstoned(client, path):
    response = client.post(path) if path.endswith("login") or path.endswith("token") or path.endswith("refresh") else client.get(path)
    assert response.status_code == 410
    body = response.json()
    assert "replacement" in body
    assert body.get("code") == "legacy_endpoint_removed"
    assert response.headers.get("Deprecation") == "true"
    assert response.headers.get("Sunset")
    assert response.headers.get("Warning")
    assert response.headers.get("Link")
