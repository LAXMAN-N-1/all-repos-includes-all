from __future__ import annotations

from collections import Counter
from datetime import UTC, datetime, timedelta

from fastapi import APIRouter, Depends, Request, Response, status
from sqlmodel import Session, select

from app.api import deps
from app.core.config import settings
from app.core.logging import get_logger
from app.core.audit import AuditLogger
from app.models.user import User
from app.models.user_identity import UserIdentity
from app.schemas.auth import (
    AuthMeResponse,
    AuthMeUser,
    LegacyAuthTombstoneResponse,
    LogoutAllResponse,
    MessageResponse,
)
from app.services.auth_service import AuthService
from app.services.token_service import TokenService

router = APIRouter()

_LEGACY_METHODS = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
_legacy_hits: Counter[str] = Counter()
_logger = get_logger("wezu_auth_legacy")
_sunset_at = (datetime.now(UTC) + timedelta(days=45)).strftime("%a, %d %b %Y %H:%M:%S GMT")
_docs_url = f"{(settings.API_PUBLIC_BASE_URL or '').rstrip('/')}/docs/auth-migration".lstrip("/")
if not _docs_url.startswith(("http://", "https://", "/")):
    _docs_url = "/docs/auth-migration"


@router.get("/me", response_model=AuthMeResponse)
def auth_me(
    current_user: User = Depends(deps.get_current_user),
    db: Session = Depends(deps.get_db),
) -> AuthMeResponse:
    identity = db.exec(
        select(UserIdentity).where(
            UserIdentity.user_id == current_user.id,
            UserIdentity.provider == "supabase",
        )
    ).first()
    roles = sorted(deps.get_user_role_names(current_user))
    permissions = sorted(current_user.all_permissions)
    return AuthMeResponse(
        user=AuthMeUser(
            id=current_user.id,
            email=current_user.email,
            full_name=current_user.full_name,
            phone_number=current_user.phone_number,
            user_type=getattr(current_user.user_type, "value", current_user.user_type),
            status=getattr(current_user.status, "value", current_user.status),
        ),
        roles=roles,
        permissions=permissions,
        identity_provider="supabase",
        identity_subject=identity.external_subject if identity else None,
    )


@router.post("/logout", response_model=MessageResponse)
def logout(
    current_user: User = Depends(deps.get_current_user),
    token: str = Depends(deps.oauth2_scheme),
    db: Session = Depends(deps.get_db),
) -> MessageResponse:
    AuthService.revoke_session(db, token)
    TokenService.blacklist_token(db, token)
    AuditLogger.log_event(db, current_user.id, "LOGOUT", "AUTH")
    return MessageResponse(message="Logged out successfully")


@router.post("/logout-all", response_model=LogoutAllResponse)
def logout_all(
    current_user: User = Depends(deps.get_current_user),
    db: Session = Depends(deps.get_db),
) -> LogoutAllResponse:
    revoked_count = AuthService.revoke_all_user_sessions(db, current_user.id)
    AuditLogger.log_event(
        db,
        current_user.id,
        "LOGOUT_ALL",
        "AUTH",
        metadata={"sessions_revoked": revoked_count},
    )
    return LogoutAllResponse(
        message="Logged out from all devices successfully",
        sessions_revoked=revoked_count,
    )


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


def _legacy_auth_tombstone_response(path: str, replacement: str) -> LegacyAuthTombstoneResponse:
    return LegacyAuthTombstoneResponse(
        code="legacy_endpoint_removed",
        message=f"Legacy auth endpoint '/api/v1/auth/{path}' is no longer available",
        replacement=replacement,
        docs_url=_docs_url,
        sunset_at=_sunset_at,
    )


@router.api_route("", methods=_LEGACY_METHODS, include_in_schema=False)
def auth_legacy_root_tombstone(request: Request, response: Response):
    replacement = "/api/v1/auth/me"
    _record_legacy_hit(request, replacement)
    _apply_deprecation_headers(response, replacement)
    return _legacy_auth_tombstone_response(path="", replacement=replacement)


@router.api_route("/{legacy_path:path}", methods=_LEGACY_METHODS, include_in_schema=False)
def auth_legacy_tombstone(legacy_path: str, request: Request, response: Response):
    replacement = "/api/v1/auth/me"
    if legacy_path == "me":
        # Defensive fallback: GET /me should match the typed route above.
        response.status_code = status.HTTP_404_NOT_FOUND
        return LegacyAuthTombstoneResponse(
            code="not_found",
            message="Not Found",
            replacement=replacement,
            docs_url=_docs_url,
            sunset_at=_sunset_at,
        )

    _record_legacy_hit(request, replacement)
    _apply_deprecation_headers(response, replacement)
    return _legacy_auth_tombstone_response(path=legacy_path, replacement=replacement)
