from __future__ import annotations

from app.api import deps
from app.main import app
from app.models.rbac import Permission, Role
from app.models.user import User


def test_legacy_rbac_routes_are_tombstoned(client):
    legacy_paths = [
        "/api/v1/admin/rbac/roles",
        "/api/v1/roles",
        "/api/v1/menus",
        "/api/v1/role-rights",
        "/api/v1/dealers/me/roles",
    ]
    for path in legacy_paths:
        response = client.get(path)
        assert response.status_code == 410, (path, response.text)
        body = response.json()
        assert body["code"] == "legacy_endpoint_removed"
        assert "replacement" in body
        assert response.headers.get("Deprecation") == "true"
        assert response.headers.get("Sunset")
        assert response.headers.get("Warning")
        assert response.headers.get("Link")


def test_canonical_rbac_roles_route_is_live_under_new_namespace(client):
    # New canonical namespace exists and is protected (not a 404).
    response = client.get("/api/v1/rbac/roles")
    assert response.status_code in {401, 403}


def test_tenant_scope_cannot_assign_cross_tenant_role(client, session):
    permission = Permission(
        slug="rbac:assignments:write",
        module="rbac",
        action="assignments_write",
        scope="tenant",
    )
    tenant_role = Role(
        name="dealer_owner",
        description="Dealer owner",
        category="dealer",
        is_custom_role=False,
        scope_owner="dealer",
        dealer_id=10,
    )
    tenant_role.permissions.append(permission)
    session.add(permission)
    session.add(tenant_role)
    session.commit()
    session.refresh(tenant_role)

    actor = User(
        email="tenant-actor@rbac.test",
        full_name="Tenant Actor",
        created_by_dealer_id=10,
        role_id=tenant_role.id,
    )
    target = User(
        email="tenant-target@rbac.test",
        full_name="Tenant Target",
        created_by_dealer_id=10,
    )
    cross_tenant_role = Role(
        name="tenant_other_custom_role",
        description="Other dealer role",
        category="dealer",
        is_custom_role=True,
        scope_owner="dealer",
        dealer_id=999,
    )
    session.add(actor)
    session.add(target)
    session.add(cross_tenant_role)
    session.commit()
    session.refresh(actor)
    session.refresh(target)
    session.refresh(cross_tenant_role)

    setattr(actor, "_active_roles_cache", [tenant_role])

    app.dependency_overrides[deps.get_current_user] = lambda: actor
    try:
        response = client.post(
            f"/api/v1/rbac/assignments/users/{target.id}/roles",
            json={"role_id": cross_tenant_role.id},
        )
    finally:
        app.dependency_overrides.pop(deps.get_current_user, None)

    assert response.status_code == 403
    assert response.json()["detail"] == "rbac_scope_forbidden"
