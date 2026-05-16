from __future__ import annotations

from collections import Counter
from datetime import UTC, datetime, timedelta

from fastapi import APIRouter, Request, Response, status

from app.core.config import settings
from app.core.logging import get_logger
from app.schemas.auth import LegacyAuthTombstoneResponse

_LEGACY_METHODS = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]

customer_auth_router = APIRouter()
dealer_auth_router = APIRouter()
sessions_router = APIRouter()

_legacy_hits: Counter[str] = Counter()
_logger = get_logger("wezu_auth_legacy")
_sunset_at = (datetime.now(UTC) + timedelta(days=45)).strftime("%a, %d %b %Y %H:%M:%S GMT")
_docs_url = f"{(settings.API_PUBLIC_BASE_URL or '').rstrip('/')}/docs/auth-migration".lstrip("/")
if not _docs_url.startswith(("http://", "https://", "/")):
    _docs_url = "/docs/auth-migration"


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
    response.headers["Warning"] = '299 - "Deprecated API endpoint. Use Supabase auth + canonical introspection endpoint."'
    response.headers["Deprecation"] = "true"
    response.headers["Sunset"] = _sunset_at
    response.headers["Link"] = f'<{replacement}>; rel="successor-version"'


def _payload(message: str, replacement: str) -> LegacyAuthTombstoneResponse:
    return LegacyAuthTombstoneResponse(
        code="legacy_endpoint_removed",
        message=message,
        replacement=replacement,
        docs_url=_docs_url,
        sunset_at=_sunset_at,
    )


@customer_auth_router.api_route("", methods=_LEGACY_METHODS, include_in_schema=False)
@customer_auth_router.api_route("/{legacy_path:path}", methods=_LEGACY_METHODS, include_in_schema=False)
def customer_auth_tombstone(request: Request, response: Response, legacy_path: str = ""):
    replacement = "/api/v1/auth/me"
    _record_legacy_hit(request, replacement)
    _apply_deprecation_headers(response, replacement)
    return _payload(
        message=f"Legacy customer auth endpoint '/api/v1/customers/auth/{legacy_path}' is no longer available",
        replacement=replacement,
    )


@dealer_auth_router.api_route("", methods=_LEGACY_METHODS, include_in_schema=False)
@dealer_auth_router.api_route("/{legacy_path:path}", methods=_LEGACY_METHODS, include_in_schema=False)
def dealer_auth_tombstone(request: Request, response: Response, legacy_path: str = ""):
    replacement = "/api/v1/auth/me"
    _record_legacy_hit(request, replacement)
    _apply_deprecation_headers(response, replacement)
    return _payload(
        message=f"Legacy dealer auth endpoint '/api/v1/dealers/auth/{legacy_path}' is no longer available",
        replacement=replacement,
    )


@sessions_router.api_route("", methods=_LEGACY_METHODS, include_in_schema=False)
@sessions_router.api_route("/{legacy_path:path}", methods=_LEGACY_METHODS, include_in_schema=False)
def sessions_tombstone(request: Request, response: Response, legacy_path: str = ""):
    replacement = "/api/v1/auth/me"
    _record_legacy_hit(request, replacement)
    _apply_deprecation_headers(response, replacement)
    return _payload(
        message=f"Legacy backend session endpoint '/api/v1/sessions/{legacy_path}' is no longer available",
        replacement=replacement,
    )
