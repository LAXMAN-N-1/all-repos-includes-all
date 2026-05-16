from __future__ import annotations

from collections import Counter
from datetime import UTC, datetime, timedelta

from fastapi import APIRouter, Request, Response, status

from app.core.config import settings
from app.core.logging import get_logger
from app.schemas.rbac import LegacyRBACTombstoneResponse

legacy_admin_rbac_router = APIRouter()
legacy_roles_router = APIRouter()
legacy_menus_router = APIRouter()
legacy_role_rights_router = APIRouter()
legacy_dealer_roles_router = APIRouter()

_LEGACY_METHODS = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
_legacy_hits: Counter[str] = Counter()
_logger = get_logger("wezu_rbac_legacy")

_sunset_at = (datetime.now(UTC) + timedelta(days=45)).strftime("%a, %d %b %Y %H:%M:%S GMT")
_docs_url = f"{(settings.API_PUBLIC_BASE_URL or '').rstrip('/')}/docs/rbac-migration".lstrip("/")
if not _docs_url.startswith(("http://", "https://", "/")):
    _docs_url = "/docs/rbac-migration"


def _record_legacy_hit(request: Request, replacement: str) -> None:
    key = f"{request.method} {request.url.path}"
    _legacy_hits[key] += 1
    _logger.warning(
        "api.legacy_endpoint_accessed",
        method=request.method,
        path=request.url.path,
        replacement=replacement,
        hits_total=_legacy_hits[key],
        client=request.headers.get("x-client-id") or request.headers.get("user-agent") or "unknown",
        user_agent=request.headers.get("user-agent"),
    )


def _apply_deprecation_headers(response: Response, replacement: str) -> None:
    response.status_code = status.HTTP_410_GONE
    response.headers["Warning"] = '299 - "Deprecated API endpoint. Use canonical RBAC route."'
    response.headers["Deprecation"] = "true"
    response.headers["Sunset"] = _sunset_at
    response.headers["Link"] = f'<{replacement}>; rel="successor-version"'


def _legacy_payload(message: str, replacement: str) -> LegacyRBACTombstoneResponse:
    return LegacyRBACTombstoneResponse(
        code="legacy_endpoint_removed",
        message=message,
        replacement=replacement,
        docs_url=_docs_url,
        sunset_at=_sunset_at,
    )


@legacy_admin_rbac_router.api_route("", methods=_LEGACY_METHODS, include_in_schema=False)
@legacy_admin_rbac_router.api_route("/{legacy_path:path}", methods=_LEGACY_METHODS, include_in_schema=False)
def legacy_admin_rbac_tombstone(request: Request, response: Response, legacy_path: str = ""):
    replacement = f"/api/v1/rbac/{legacy_path}".rstrip("/")
    if not replacement:
        replacement = "/api/v1/rbac"
    _record_legacy_hit(request, replacement)
    _apply_deprecation_headers(response, replacement)
    return _legacy_payload(
        message=f"Legacy RBAC endpoint '/api/v1/admin/rbac/{legacy_path}' is no longer available",
        replacement=replacement,
    )


@legacy_roles_router.api_route("", methods=_LEGACY_METHODS, include_in_schema=False)
@legacy_roles_router.api_route("/{legacy_path:path}", methods=_LEGACY_METHODS, include_in_schema=False)
def legacy_roles_tombstone(request: Request, response: Response, legacy_path: str = ""):
    replacement = f"/api/v1/rbac/roles/{legacy_path}".rstrip("/")
    _record_legacy_hit(request, replacement)
    _apply_deprecation_headers(response, replacement)
    return _legacy_payload(
        message=f"Legacy roles endpoint '/api/v1/roles/{legacy_path}' is no longer available",
        replacement=replacement,
    )


@legacy_menus_router.api_route("", methods=_LEGACY_METHODS, include_in_schema=False)
@legacy_menus_router.api_route("/{legacy_path:path}", methods=_LEGACY_METHODS, include_in_schema=False)
def legacy_menus_tombstone(request: Request, response: Response, legacy_path: str = ""):
    replacement = f"/api/v1/rbac/menus/{legacy_path}".rstrip("/")
    _record_legacy_hit(request, replacement)
    _apply_deprecation_headers(response, replacement)
    return _legacy_payload(
        message=f"Legacy menus endpoint '/api/v1/menus/{legacy_path}' is no longer available",
        replacement=replacement,
    )


@legacy_role_rights_router.api_route("", methods=_LEGACY_METHODS, include_in_schema=False)
@legacy_role_rights_router.api_route("/{legacy_path:path}", methods=_LEGACY_METHODS, include_in_schema=False)
def legacy_role_rights_tombstone(request: Request, response: Response, legacy_path: str = ""):
    replacement = f"/api/v1/rbac/role-rights/{legacy_path}".rstrip("/")
    _record_legacy_hit(request, replacement)
    _apply_deprecation_headers(response, replacement)
    return _legacy_payload(
        message=f"Legacy role-rights endpoint '/api/v1/role-rights/{legacy_path}' is no longer available",
        replacement=replacement,
    )


@legacy_dealer_roles_router.api_route("", methods=_LEGACY_METHODS, include_in_schema=False)
@legacy_dealer_roles_router.api_route("/{legacy_path:path}", methods=_LEGACY_METHODS, include_in_schema=False)
def legacy_dealer_roles_tombstone(request: Request, response: Response, legacy_path: str = ""):
    replacement = "/api/v1/rbac/roles"
    _record_legacy_hit(request, replacement)
    _apply_deprecation_headers(response, replacement)
    return _legacy_payload(
        message=f"Legacy dealer roles endpoint '/api/v1/dealers/me/roles/{legacy_path}' is no longer available",
        replacement=replacement,
    )
