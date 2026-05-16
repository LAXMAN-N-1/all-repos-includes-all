#!/usr/bin/env python3
"""
RBAC policy checks for the multi-role cutover.

Fails when:
1) Canonical RBAC mount /api/v1/rbac is missing.
2) Legacy RBAC routers are still mounted as live handlers.
3) New RBAC router misses explicit response_model declarations.
4) New RBAC router uses legacy mixed guard pattern check_permission(...).
"""
from __future__ import annotations

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
MAIN_FILE = ROOT / "app" / "main.py"
RBAC_ROUTER_FILE = ROOT / "app" / "api" / "v1" / "rbac.py"
DEPS_FILE = ROOT / "app" / "api" / "deps.py"
SEED_FILE = ROOT / "scripts" / "seed_production_data.py"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _check_canonical_mount(errors: list[str]) -> None:
    text = _read(MAIN_FILE)
    required_mounts = [
        'app.include_router(rbac.router, prefix=f"{v1_str}/rbac"',
        "rbac_tombstones.legacy_admin_rbac_router",
        "rbac_tombstones.legacy_roles_router",
        "rbac_tombstones.legacy_menus_router",
        "rbac_tombstones.legacy_role_rights_router",
        "rbac_tombstones.legacy_dealer_roles_router",
    ]
    for snippet in required_mounts:
        if snippet not in text:
            errors.append(f"{MAIN_FILE}: missing required RBAC mount snippet: {snippet}")

    forbidden_live_mounts = [
        'app.include_router(roles.router, prefix=f"{v1_str}/roles"',
        'app.include_router(menus.router, prefix=f"{v1_str}/menus"',
        'app.include_router(role_rights.router, prefix=f"{v1_str}/role-rights"',
        'app.include_router(admin_rbac.router, prefix=f"{admin_api}/rbac"',
        'app.include_router(dealer_portal_roles.router, prefix=f"{dealer_api}/me/roles"',
    ]
    for snippet in forbidden_live_mounts:
        if snippet in text:
            errors.append(f"{MAIN_FILE}: forbidden legacy live RBAC mount: {snippet}")


def _check_typed_router_contract(errors: list[str]) -> None:
    text = _read(RBAC_ROUTER_FILE)
    decorator = re.compile(r"^\s*@router\.(get|post|put|patch|delete)\((.*?)\)\s*$")
    for lineno, line in enumerate(text.splitlines(), start=1):
        match = decorator.match(line)
        if not match:
            continue
        if "status_code=status.HTTP_204_NO_CONTENT" in match.group(2):
            continue
        if "response_model=" not in match.group(2):
            errors.append(f"{RBAC_ROUTER_FILE}:{lineno}: missing response_model")

    forbidden_patterns = ["check_permission(", "rbac_service."]
    for pattern in forbidden_patterns:
        if pattern in text:
            errors.append(f"{RBAC_ROUTER_FILE}: forbidden RBAC implementation pattern detected: {pattern}")

    if "access_control_service" not in text:
        errors.append(f"{RBAC_ROUTER_FILE}: expected delegation via access_control_service")


def _check_tenant_claim_enforcement(errors: list[str]) -> None:
    text = _read(DEPS_FILE)
    required_snippets = [
        "detail=\"rbac_tenant_claim_invalid\"",
        "auth_tenant_id",
        "def _resolve_local_tenant_id(",
    ]
    for snippet in required_snippets:
        if snippet not in text:
            errors.append(f"{DEPS_FILE}: missing tenant-claim enforcement snippet: {snippet}")


def _check_canonical_rbac_permission_inventory(errors: list[str]) -> None:
    text = _read(SEED_FILE)
    required_permissions = [
        "rbac:roles:read",
        "rbac:roles:write",
        "rbac:permissions:read",
        "rbac:permissions:write",
        "rbac:assignments:read",
        "rbac:assignments:write",
        "rbac:menus:read",
        "rbac:menus:write",
        "rbac:role_rights:read",
        "rbac:role_rights:write",
        "rbac:access_paths:read",
        "rbac:access_paths:write",
    ]
    for slug in required_permissions:
        if slug not in text:
            errors.append(f"{SEED_FILE}: missing canonical RBAC permission slug seed: {slug}")


def main() -> int:
    errors: list[str] = []
    _check_canonical_mount(errors)
    _check_typed_router_contract(errors)
    _check_tenant_claim_enforcement(errors)
    _check_canonical_rbac_permission_inventory(errors)

    if errors:
        print("RBAC_POLICY_CHECK_FAILED")
        for err in errors:
            print(f"- {err}")
        return 1

    print("RBAC_POLICY_CHECK_PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
