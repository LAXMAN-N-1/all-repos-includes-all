from __future__ import annotations

from pathlib import Path


def test_main_has_canonical_rbac_mount_and_no_live_legacy_rbac_mounts():
    main_text = Path("app/main.py").read_text(encoding="utf-8")

    required = [
        'app.include_router(rbac.router, prefix=f"{v1_str}/rbac"',
        "rbac_tombstones.legacy_admin_rbac_router",
        "rbac_tombstones.legacy_roles_router",
        "rbac_tombstones.legacy_menus_router",
        "rbac_tombstones.legacy_role_rights_router",
        "rbac_tombstones.legacy_dealer_roles_router",
    ]
    missing = [item for item in required if item not in main_text]
    assert not missing, "Missing required RBAC cutover mounts: " + ", ".join(missing)

    forbidden = [
        'app.include_router(roles.router, prefix=f"{v1_str}/roles"',
        'app.include_router(menus.router, prefix=f"{v1_str}/menus"',
        'app.include_router(role_rights.router, prefix=f"{v1_str}/role-rights"',
        'app.include_router(admin_rbac.router, prefix=f"{admin_api}/rbac"',
        'app.include_router(dealer_portal_roles.router, prefix=f"{dealer_api}/me/roles"',
    ]
    hits = [item for item in forbidden if item in main_text]
    assert not hits, "Found forbidden live legacy RBAC mounts: " + ", ".join(hits)
