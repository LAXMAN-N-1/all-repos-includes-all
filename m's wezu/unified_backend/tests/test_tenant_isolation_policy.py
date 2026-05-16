from __future__ import annotations

from pathlib import Path


def _read(path: str) -> str:
    return Path(path).read_text(encoding="utf-8")


def test_sensitive_finance_and_branch_routes_require_global_admin_context():
    branches_text = _read("app/api/v1/branches.py")
    settlements_text = _read("app/api/v1/settlements.py")

    assert "deps.require_global_admin_context" in branches_text
    assert "deps.require_global_admin_context" in settlements_text


def test_upload_api_forbids_client_selected_directory_and_uses_tenant_prefix():
    utils_text = _read("app/api/v1/utils.py")

    assert "directory:" not in utils_text
    assert "deps.get_tenant_upload_prefix" in utils_text
    assert 'directory="misc"' in utils_text


def test_dealer_scope_dependencies_enforce_tenant_context_resolution():
    deps_text = _read("app/api/deps.py")

    assert "def get_current_dealer_scope_user(" in deps_text
    assert "allow_global=False" in deps_text
    assert "_resolve_tenant_context(" in deps_text


def test_realtime_orders_requires_tenant_scoped_subscription_for_non_global_users():
    realtime_text = _read("app/api/v1/orders_realtime.py")

    assert "order_id_required_for_tenant_scope" in realtime_text
    assert "tenant_id=auth_context.tenant_id" in realtime_text


def test_tenant_operators_are_no_longer_blocked_on_canonical_scoped_routes():
    deps_text = _read("app/api/deps.py")

    assert '"/api/v1/deliveries"' not in deps_text
    assert '"/api/v1/manifests"' not in deps_text
    assert '"/api/v1/inventory"' not in deps_text
