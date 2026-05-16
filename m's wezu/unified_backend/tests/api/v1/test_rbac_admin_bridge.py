from types import SimpleNamespace

import pytest
from fastapi import HTTPException
from sqlmodel import Session, select

from app.api import deps
from app.models.user import User


def test_platform_admin_gets_rbac_permission_bridge(
    session: Session,
    monkeypatch: pytest.MonkeyPatch,
):
    admin_user = session.exec(select(User).where(User.email == "admin@test.com")).first()
    assert admin_user is not None

    expected_context = SimpleNamespace(scope="global", user=admin_user)
    monkeypatch.setattr(
        deps,
        "_resolve_rbac_scope_context",
        lambda db, current_user, request: expected_context,
    )

    checker = deps.require_rbac_permission("rbac:roles:read")
    result = checker(request=SimpleNamespace(state=SimpleNamespace()), db=session, current_user=admin_user)

    assert result is expected_context


def test_non_admin_still_denied_without_rbac_permission(
    session: Session,
    normal_user: User,
    monkeypatch: pytest.MonkeyPatch,
):
    expected_context = SimpleNamespace(scope="tenant", user=normal_user)
    monkeypatch.setattr(
        deps,
        "_resolve_rbac_scope_context",
        lambda db, current_user, request: expected_context,
    )

    checker = deps.require_rbac_permission("rbac:roles:read")
    with pytest.raises(HTTPException) as exc:
        checker(request=SimpleNamespace(state=SimpleNamespace()), db=session, current_user=normal_user)

    assert exc.value.status_code == 403
    assert exc.value.detail == "insufficient_permissions"


def test_platform_admin_gets_analytics_global_permission_bridge(
    session: Session,
    monkeypatch: pytest.MonkeyPatch,
):
    admin_user = session.exec(select(User).where(User.email == "admin@test.com")).first()
    assert admin_user is not None

    expected_context = SimpleNamespace(scope="global", user=admin_user)
    monkeypatch.setattr(
        deps,
        "_resolve_tenant_context",
        lambda db, current_user, request, allow_global=True: expected_context,
    )

    checker = deps.require_global_permission("analytics:view:global")
    result = checker(request=SimpleNamespace(state=SimpleNamespace(auth_tenant_id=None)), db=session, current_user=admin_user)

    assert result.scope == "global"
    assert result.user == admin_user
