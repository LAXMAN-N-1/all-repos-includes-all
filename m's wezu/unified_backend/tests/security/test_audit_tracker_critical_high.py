from __future__ import annotations

from datetime import UTC, datetime, timedelta
from io import BytesIO
from pathlib import Path
from types import SimpleNamespace

import pytest
from fastapi import HTTPException
from sqlalchemy import text
from starlette.datastructures import Headers, UploadFile

from app.api import deps
from app.api.v1 import kyc as kyc_api
from app.api.v1 import orders_realtime as orders_realtime_api
from app.api.v1.orders import _resolve_driver_by_optional_column, _resolve_order_by_optional_column
from app.middleware import rate_limit as rate_limit_middleware
from app.models.session import UserSession
from app.models.user import User, UserStatus, UserType
from app.models.user_identity import UserIdentity
from app.services.auth_service import AuthService, SupabaseTokenValidationError
from app.services import token_service as token_service_module


def _root() -> Path:
    return Path(__file__).resolve().parents[2]


def test_c1_optional_column_lookup_rejects_injected_column_names(session):
    assert _resolve_order_by_optional_column(session, "id UNION SELECT 1", "1") is None
    assert _resolve_driver_by_optional_column(session, "id; DROP TABLE users", "1") is None


def test_c2_secure_kyc_upload_paths_and_magic_validation():
    base = "/tmp/uploads/kyc/123"
    generated = kyc_api._safe_upload_path(base, "aadhaar_front")
    assert generated.startswith(f"{base}/aadhaar_front_")
    assert ".." not in generated
    assert generated.endswith(".bin")

    good = UploadFile(
        filename="doc.jpg",
        file=BytesIO(b"\xff\xd8\xff\x00test"),
        headers=Headers({"content-type": "image/jpeg"}),
    )
    kyc_api._validate_file_content(good, allowed_content_types={"image/jpeg"})

    bad = UploadFile(
        filename="doc.jpg",
        file=BytesIO(b"NOTAJPEG"),
        headers=Headers({"content-type": "image/jpeg"}),
    )
    with pytest.raises(HTTPException):
        kyc_api._validate_file_content(bad, allowed_content_types={"image/jpeg"})


def test_c3_kyc_hmac_hashing_uses_secret(monkeypatch):
    monkeypatch.setattr(kyc_api.settings, "KYC_HMAC_SECRET", "unit-test-secret", raising=False)
    value = "123412341234"
    h1 = kyc_api._hmac_pii(value)
    h2 = kyc_api._hmac_pii(value)
    assert h1 == h2
    assert len(h1) == 64
    assert h1 != __import__("hashlib").sha256(value.encode()).hexdigest()


def test_c4_datetime_utcnow_removed_from_runtime_code():
    app_dir = _root() / "app"
    offenders = [
        str(path.relative_to(_root()))
        for path in app_dir.rglob("*.py")
        if "datetime.utcnow(" in path.read_text(encoding="utf-8")
    ]
    assert not offenders, f"datetime.utcnow() still present in: {offenders[:5]}"


def test_h1_refresh_grace_window_enforced(session, monkeypatch):
    try:
        session.exec(
            text(
                "ALTER TABLE user_sessions "
                "ADD COLUMN previous_token_issued_at TIMESTAMP"
            )
        )
        session.commit()
    except Exception:
        session.rollback()

    user = User(
        email="grace-window@test.com",
        phone_number="9000000001",
        full_name="Grace Window",
        user_type=UserType.CUSTOMER,
        status=UserStatus.ACTIVE,
    )
    session.add(user)
    session.commit()
    session.refresh(user)

    stale = UserSession(
        user_id=user.id,
        token_id="new-jti",
        previous_token_id="old-jti",
        previous_token_issued_at=datetime.now(UTC) - timedelta(seconds=180),
        refresh_token_hash=None,
        expires_at=datetime.now(UTC) + timedelta(days=1),
    )
    session.add(stale)
    session.commit()

    from jose import jwt as jose_jwt

    monkeypatch.setattr(
        jose_jwt,
        "decode",
        lambda *_args, **_kwargs: {"type": "refresh", "jti": "old-jti"},
    )
    assert AuthService.validate_session(session, "refresh-token", is_refresh=True) is None

    stale.previous_token_issued_at = datetime.now(UTC) - timedelta(seconds=20)
    session.add(stale)
    session.commit()
    assert AuthService.validate_session(session, "refresh-token", is_refresh=True) is not None


def test_h2_supabase_audience_validation_is_mandatory(monkeypatch):
    captured: dict[str, object] = {}
    from app.services import auth_service as auth_service_module

    monkeypatch.setattr(AuthService, "_resolve_supabase_signing_keys", classmethod(lambda _cls, _kid: {"keys": [{"kid": "kid"}]}))
    monkeypatch.setattr(AuthService, "_resolve_supabase_issuer", classmethod(lambda _cls: "https://example.supabase.co/auth/v1"))
    monkeypatch.setattr(auth_service_module.jose_jwt, "get_unverified_header", lambda _token: {"alg": "RS256", "kid": "kid"})

    def _decode(_token, _keys, **kwargs):
        captured.update(kwargs)
        return {"sub": "user-1", "role": "authenticated"}

    monkeypatch.setattr(auth_service_module.jose_jwt, "decode", _decode)
    monkeypatch.setattr(auth_service_module.settings, "SUPABASE_JWT_AUDIENCE", "authenticated", raising=False)
    AuthService.verify_supabase_access_token("token")
    assert captured["options"]["verify_aud"] is True
    assert captured["audience"] == "authenticated"

    monkeypatch.setattr(auth_service_module.settings, "SUPABASE_JWT_AUDIENCE", "", raising=False)
    with pytest.raises(SupabaseTokenValidationError):
        AuthService.verify_supabase_access_token("token")


def test_h3_inactive_user_invalidates_token_cache(session, monkeypatch):
    user = User(
        email="inactive-user@test.com",
        phone_number="9000000002",
        full_name="Inactive User",
        user_type=UserType.CUSTOMER,
        status=UserStatus.SUSPENDED,
    )
    session.add(user)
    session.commit()
    session.refresh(user)

    invalidated: list[tuple[str, object]] = []
    monkeypatch.setattr(deps, "_get_validated_token", lambda _token: deps._ValidatedToken(user_id=user.id, sid="1", issued_at=None))
    monkeypatch.setattr(deps, "invalidate_user_token_cache", lambda uid: invalidated.append(("user", uid)))
    monkeypatch.setattr(deps, "invalidate_token_cache", lambda token: invalidated.append(("token", token)))

    with pytest.raises(HTTPException) as exc:
        deps.get_user_from_token(session, token="cached-token", request=None)
    assert exc.value.status_code == 403
    assert ("user", user.id) in invalidated
    assert ("token", "cached-token") in invalidated


def test_h4_rate_limit_backend_must_be_distributed_in_production(monkeypatch):
    monkeypatch.setattr(rate_limit_middleware.settings, "ENVIRONMENT", "production", raising=False)
    monkeypatch.setattr(rate_limit_middleware.settings, "RATE_LIMIT_STORAGE_URL", None, raising=False)
    with pytest.raises(RuntimeError):
        rate_limit_middleware._resolve_rate_limit_storage_url()


def test_h5_pool_defaults_are_production_sized():
    cfg = (_root() / "app/core/config.py").read_text(encoding="utf-8")
    assert "DB_POOL_SIZE: int = 20" in cfg
    assert "DB_MAX_OVERFLOW: int = 10" in cfg


def test_h6_cors_headers_are_not_wildcard():
    source = (_root() / "app/main.py").read_text(encoding="utf-8")
    assert 'allow_headers=["*"]' not in source
    assert 'expose_headers=["*"]' not in source
    assert 'allow_headers=["Authorization", "Content-Type", "Accept", "X-Request-ID"]' in source


def test_h7_scheduler_uses_distributed_lock_not_tmp_file():
    source = (_root() / "app/services/background_runtime_service.py").read_text(encoding="utf-8")
    assert "client.set(" in source and "nx=True" in source
    cfg = (_root() / "app/core/config.py").read_text(encoding="utf-8")
    assert "SCHEDULER_LOCK_FILE: Optional[str] = None" in cfg


def test_h8_seed_sql_hardening_present():
    sync_seed = (_root() / "app/db/seeds/sync_and_seed.py").read_text(encoding="utf-8")
    assert "WHERE station_id = :station_id" in sync_seed
    assert "WHERE station_id = {s.id}" not in sync_seed

    rbac_seed = (_root() / "app/db/seeds/rbac_hard_reset.py").read_text(encoding="utf-8")
    assert "ALLOWED_BACKUP_TABLES" in rbac_seed
    assert "_IDENTIFIER_RE" in rbac_seed


def test_h9_supabase_token_missing_iat_is_rejected(session, monkeypatch):
    user = User(
        email="missing-iat@test.com",
        phone_number="9000000091",
        full_name="Missing IAT",
        user_type=UserType.CUSTOMER,
        status=UserStatus.ACTIVE,
    )
    session.add(user)
    session.commit()
    session.refresh(user)

    session.add(
        UserIdentity(
            provider="supabase",
            external_subject="supabase-missing-iat",
            user_id=user.id,
            email_snapshot=user.email,
        )
    )
    session.commit()

    def _verify_supabase(cls, _token):
        return {
            "sub": "supabase-missing-iat",
            "email": "missing-iat@test.com",
            "email_verified": True,
            "role": "authenticated",
            "exp": int((datetime.now(UTC) + timedelta(minutes=15)).timestamp()),
        }

    token = "supabase-missing-iat-token"
    monkeypatch.setattr(deps.settings, "AUTH_PROVIDER", "supabase", raising=False)
    monkeypatch.setattr(deps.settings, "AUTH_REQUIRE_IAT_CLAIM", True, raising=False)
    monkeypatch.setattr(AuthService, "verify_supabase_access_token", classmethod(_verify_supabase))
    deps.invalidate_token_cache(token)

    with pytest.raises(HTTPException) as exc:
        deps.get_user_from_token(session, token=token, request=None)
    assert exc.value.status_code == 401
    assert exc.value.detail == "token_invalid"


def test_h10_websocket_query_token_disabled_by_default(monkeypatch):
    ws = SimpleNamespace(headers={})
    monkeypatch.setattr(orders_realtime_api.settings, "WEBSOCKET_ALLOW_QUERY_TOKEN", False, raising=False)

    with pytest.raises(HTTPException) as exc:
        orders_realtime_api._extract_websocket_token(ws, "legacy-query-token")
    assert exc.value.status_code == 401
    assert exc.value.detail == "query_token_not_allowed"


def test_h11_websocket_subprotocol_bearer_token_is_accepted(monkeypatch):
    ws = SimpleNamespace(headers={"sec-websocket-protocol": "bearer, ws.jwt.token"})
    monkeypatch.setattr(orders_realtime_api.settings, "WEBSOCKET_ALLOW_QUERY_TOKEN", False, raising=False)
    assert orders_realtime_api._extract_websocket_token(ws, None) == "ws.jwt.token"


def test_h12_blacklist_persists_token_fingerprint_not_raw(session, monkeypatch):
    token = "raw-access-token-value"
    expiry_epoch = int((datetime.now(UTC) + timedelta(minutes=5)).timestamp())
    monkeypatch.setattr(
        token_service_module.jwt,
        "decode",
        lambda *_args, **_kwargs: {"exp": expiry_epoch},
    )

    token_service_module.TokenService.blacklist_token(session, token)

    stored = session.exec(text("SELECT token FROM blacklisted_tokens LIMIT 1")).first()
    assert stored is not None
    stored_value = str(stored[0])
    assert stored_value.startswith("sha256:")
    assert stored_value != token

    with pytest.raises(HTTPException):
        deps._assert_not_blacklisted(session, token)
