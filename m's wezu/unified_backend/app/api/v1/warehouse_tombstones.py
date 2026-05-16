from __future__ import annotations

from collections import Counter
from datetime import UTC, datetime, timedelta

from fastapi import APIRouter, Request, Response, status
from pydantic import BaseModel

from app.core.config import settings
from app.core.logging import get_logger

router = APIRouter()

_LEGACY_METHODS = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
_legacy_hits: Counter[str] = Counter()
_logger = get_logger("wezu_warehouse_legacy")
_sunset_at = (datetime.now(UTC) + timedelta(days=45)).strftime("%a, %d %b %Y %H:%M:%S GMT")
_docs_url = f"{(settings.API_PUBLIC_BASE_URL or '').rstrip('/')}/docs/warehouse-migration".lstrip("/")
if not _docs_url.startswith(("http://", "https://", "/")):
    _docs_url = "/docs/warehouse-migration"


class LegacyWarehouseTombstoneResponse(BaseModel):
    code: str
    message: str
    replacement: str
    docs_url: str
    sunset_at: str


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
    response.headers["Warning"] = '299 - "Deprecated API endpoint. Use canonical warehouse structure routes."'
    response.headers["Deprecation"] = "true"
    response.headers["Sunset"] = _sunset_at
    response.headers["Link"] = f'<{replacement}>; rel="successor-version"'


def _replacement_for_legacy_path(legacy_path: str) -> str:
    trimmed = legacy_path.strip().strip("/")
    if not trimmed:
        return "/api/v1/warehouses/structure/"
    if trimmed == "all":
        return "/api/v1/warehouses/structure/all"
    if trimmed.startswith("shelves/"):
        return f"/api/v1/warehouses/structure/{trimmed}"
    return f"/api/v1/warehouses/structure/{trimmed}"


@router.api_route("", methods=_LEGACY_METHODS, include_in_schema=False)
@router.api_route("/{legacy_path:path}", methods=_LEGACY_METHODS, include_in_schema=False)
def warehouse_legacy_tombstone(
    request: Request,
    response: Response,
    legacy_path: str = "",
) -> LegacyWarehouseTombstoneResponse:
    replacement = _replacement_for_legacy_path(legacy_path)
    _record_legacy_hit(request, replacement)
    _apply_deprecation_headers(response, replacement)
    return LegacyWarehouseTombstoneResponse(
        code="legacy_endpoint_removed",
        message=f"Legacy warehouse endpoint '/api/v1/warehouse/{legacy_path}' is no longer available",
        replacement=replacement,
        docs_url=_docs_url,
        sunset_at=_sunset_at,
    )
