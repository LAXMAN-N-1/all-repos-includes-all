from __future__ import annotations

from typing import Iterable, Optional

from app.core.rbac import canonical_role_name, role_sort_key
from app.models.roles import RoleEnum


_APP_SCOPE_ALIASES = {
    "logistics_app": "logistics",
    "logistics_ops": "logistics",
    "dealer_portal": "dealer",
    "dealer_app": "dealer",
    "customer_app": "customer",
    "driver_app": "driver",
    "admin_app": "admin",
}

_APP_SCOPE_ALLOWED_ROLES_RAW: dict[str, set[str]] = {
    "logistics": {
        RoleEnum.SUPER_ADMIN.value,
        RoleEnum.OPERATIONS_ADMIN.value,
        RoleEnum.SECURITY_ADMIN.value,
        RoleEnum.FINANCE_ADMIN.value,
        RoleEnum.SUPPORT_MANAGER.value,
        RoleEnum.SUPPORT_AGENT.value,
        RoleEnum.LOGISTICS_MANAGER.value,
        RoleEnum.DISPATCHER.value,
        RoleEnum.FLEET_MANAGER.value,
        RoleEnum.WAREHOUSE_MANAGER.value,
        # Backward compatibility for legacy/custom role naming in older DBs.
        "operations",
        "ops",
        "ops_manager",
        "operations_manager",
        "operations_staff",
        "operationsstaff",
    },
    "dealer": {
        RoleEnum.SUPER_ADMIN.value,
        RoleEnum.DEALER_OWNER.value,
        RoleEnum.DEALER_MANAGER.value,
        RoleEnum.DEALER_INVENTORY_STAFF.value,
        RoleEnum.DEALER_FINANCE_STAFF.value,
        RoleEnum.DEALER_SUPPORT_STAFF.value,
    },
    "customer": {
        RoleEnum.SUPER_ADMIN.value,
        RoleEnum.CUSTOMER.value,
    },
    "driver": {
        RoleEnum.SUPER_ADMIN.value,
        RoleEnum.DRIVER.value,
    },
    "admin": {
        RoleEnum.SUPER_ADMIN.value,
        RoleEnum.OPERATIONS_ADMIN.value,
        RoleEnum.SECURITY_ADMIN.value,
        RoleEnum.FINANCE_ADMIN.value,
    },
}

_APP_SCOPE_ALLOWED_ROLES: dict[str, set[str]] = {
    scope: {
        canonical_role_name(role_name)
        for role_name in role_names
        if canonical_role_name(role_name)
    }
    for scope, role_names in _APP_SCOPE_ALLOWED_ROLES_RAW.items()
}


def normalize_app_scope(app_scope: Optional[str]) -> Optional[str]:
    if app_scope is None:
        return None
    normalized = (
        str(app_scope)
        .strip()
        .lower()
        .replace("-", "_")
        .replace(" ", "_")
    )
    if not normalized:
        return None
    return _APP_SCOPE_ALIASES.get(normalized, normalized)


def supported_app_scopes() -> tuple[str, ...]:
    return tuple(sorted(_APP_SCOPE_ALLOWED_ROLES.keys()))


def resolve_app_scope(
    request_scope: Optional[str] = None,
    header_scope: Optional[str] = None,
) -> Optional[str]:
    normalized_request_scope = normalize_app_scope(request_scope)
    normalized_header_scope = normalize_app_scope(header_scope)

    if (
        normalized_request_scope
        and normalized_header_scope
        and normalized_request_scope != normalized_header_scope
    ):
        raise ValueError("Conflicting app scope values in request body and header")

    resolved_scope = normalized_request_scope or normalized_header_scope
    if resolved_scope and resolved_scope not in _APP_SCOPE_ALLOWED_ROLES:
        supported = ", ".join(supported_app_scopes())
        raise ValueError(f"Unsupported app scope '{resolved_scope}'. Supported scopes: {supported}")
    return resolved_scope


def allowed_roles_for_app_scope(app_scope: Optional[str]) -> set[str]:
    normalized_scope = normalize_app_scope(app_scope)
    if not normalized_scope:
        return set()
    return set(_APP_SCOPE_ALLOWED_ROLES.get(normalized_scope, set()))


def filter_roles_for_app_scope(
    role_names: Iterable[str],
    app_scope: Optional[str],
) -> list[str]:
    normalized_roles = {
        canonical_role_name(role_name)
        for role_name in role_names
        if canonical_role_name(role_name)
    }
    normalized_scope = normalize_app_scope(app_scope)
    if not normalized_scope:
        return sorted(normalized_roles, key=role_sort_key)

    allowed_roles = _APP_SCOPE_ALLOWED_ROLES.get(normalized_scope, set())
    return sorted(normalized_roles & allowed_roles, key=role_sort_key)


def is_role_allowed_for_app_scope(role_name: Optional[str], app_scope: Optional[str]) -> bool:
    normalized_role = canonical_role_name(role_name)
    if not normalized_role:
        return False

    normalized_scope = normalize_app_scope(app_scope)
    if not normalized_scope:
        return True

    allowed_roles = _APP_SCOPE_ALLOWED_ROLES.get(normalized_scope, set())
    return normalized_role in allowed_roles

