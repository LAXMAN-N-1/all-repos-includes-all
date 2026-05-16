from __future__ import annotations

from datetime import UTC, datetime, timedelta
from types import SimpleNamespace

from app.api.deps import _is_token_issued_before_global_logout
from app.core.rbac import RoleWindow
from app.services.password_service import PasswordService


def test_token_issue_time_guard_handles_mixed_timezone_values() -> None:
    issued_at = int(datetime(2026, 4, 20, 10, 0, tzinfo=UTC).timestamp())

    # Stored DB values can be naive after legacy migrations.
    last_global_logout_naive = datetime(2026, 4, 20, 11, 0)
    assert _is_token_issued_before_global_logout(issued_at, last_global_logout_naive) is True

    # A newer token should remain valid regardless of tz-awareness mismatch.
    newer_issued_at = int(datetime(2026, 4, 20, 12, 0, tzinfo=UTC).timestamp())
    assert _is_token_issued_before_global_logout(newer_issued_at, last_global_logout_naive) is False


def test_role_window_is_active_handles_naive_db_timestamps() -> None:
    now_aware = datetime.now(UTC)
    window = RoleWindow(
        effective_from=(now_aware - timedelta(hours=1)).replace(tzinfo=None),
        expires_at=(now_aware + timedelta(hours=1)).replace(tzinfo=None),
    )
    assert window.is_active(now=now_aware) is True

    expired_window = RoleWindow(
        effective_from=(now_aware - timedelta(days=2)).replace(tzinfo=None),
        expires_at=(now_aware - timedelta(days=1)).replace(tzinfo=None),
    )
    assert expired_window.is_active(now=now_aware) is False


def test_password_expiry_handles_naive_timestamps() -> None:
    user = SimpleNamespace(
        password_changed_at=(datetime.now(UTC) - timedelta(days=120)).replace(tzinfo=None),
        created_at=(datetime.now(UTC) - timedelta(days=120)).replace(tzinfo=None),
    )
    assert PasswordService.is_password_expired(user) is True

    fresh_user = SimpleNamespace(
        password_changed_at=datetime.now(UTC) - timedelta(days=1),
        created_at=datetime.now(UTC) - timedelta(days=120),
    )
    assert PasswordService.is_password_expired(fresh_user) is False

