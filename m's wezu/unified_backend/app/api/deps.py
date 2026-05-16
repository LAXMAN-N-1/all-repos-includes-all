from dataclasses import dataclass
from datetime import UTC, datetime
import hashlib
from threading import Lock
from time import monotonic
from typing import Any, Literal, Optional
from fastapi import Depends, Header, HTTPException, Request, status
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError, ExpiredSignatureError
from pydantic import ValidationError
from sqlmodel import Session, select
from sqlalchemy import func, or_, text
from sqlalchemy.orm import joinedload
from app.core.config import settings
from app.core.rbac import canonical_role_name, canonicalize_permission_slug, USERTYPE_TO_CANONICAL_ROLE
from app.core.database import get_db
from app.models.rbac import Role, UserRole
from app.models.user_identity import UserIdentity, UserIdentityLinkAudit, UserIdentityStatus
from app.models.user import User
from app.schemas.user import TokenPayload
from app.models.oauth import BlacklistedToken
from app.services.auth_service import AuthService, SupabaseTokenValidationError
from app.services.token_service import _blacklist_lookup_keys
from app.utils.datetime_utils import ensure_utc_aware, utcnow, utcnow_naive
import logging

logger = logging.getLogger(__name__)

ADMIN_ROLE_NAMES = {"super_admin", "operations_admin", "security_admin", "finance_admin"}
SUPPORT_ROLE_NAMES = {"support_manager", "support_agent"}
DEALER_OWNER_ROLE_NAMES = {"dealer_owner"}
DEALER_SCOPE_ROLE_NAMES = {
    "dealer_owner",
    "dealer_manager",
    "dealer_inventory_staff",
    "dealer_finance_staff",
    "dealer_support_staff",
}
DRIVER_ROLE_NAMES = {"driver"}
CUSTOMER_ROLE_NAMES = {"customer"}
LOGISTICS_ROLE_NAMES = {"logistics_manager", "dispatcher", "fleet_manager", "warehouse_manager"}
INTERNAL_OPERATOR_ROLE_NAMES = ADMIN_ROLE_NAMES | LOGISTICS_ROLE_NAMES | SUPPORT_ROLE_NAMES
TENANT_UNSAFE_INTERNAL_PATH_PREFIXES = {
    "/api/v1/logistics",
    "/api/v1/stock",
    "/api/v1/warehouses",
    "/api/v1/organizations",
    "/api/v1/settlements",
}
ACTOR_ROLE_ALIASES: dict[str, str] = {
    "super_admin": "admin",
    "operations_admin": "admin",
    "security_admin": "admin",
    "finance_admin": "admin",
    "admin": "admin",
    "support_agent": "admin",
    "support_manager": "admin",
    "dealer_owner": "dealer",
    "dealer_manager": "dealer",
    "dealer_inventory_staff": "dealer",
    "dealer_finance_staff": "dealer",
    "dealer_support_staff": "dealer",
    "dealer": "dealer",
    "warehouse_manager": "warehouse_operator",
    "logistics_manager": "warehouse_operator",
    "dispatcher": "warehouse_operator",
    "fleet_manager": "warehouse_operator",
    "warehouse_operator": "warehouse_operator",
    "driver": "driver",
    "customer": "customer",
}
NON_ACTOR_TOKEN_ROLES = {"authenticated", "anon", "service_role"}
ROLE_REQUIRED_ENTITY_CLAIMS: dict[str, tuple[str, ...]] = {
    "admin": tuple(),
    "dealer": ("dealer_id",),
    "warehouse_operator": ("warehouse_id",),
    "driver": ("driver_id",),
    "customer": ("customer_id",),
}
ACTOR_ENTITY_CLAIM_KEYS = ("dealer_id", "warehouse_id", "driver_id", "customer_id", "admin_id")
PLATFORM_ADMIN_GLOBAL_PERMISSION_BRIDGES = {
    "analytics:view:global",
}


@dataclass
class _ValidatedToken:
    user_id: int
    sid: Optional[str]
    issued_at: Optional[int]
    subject: Optional[str] = None
    tenant_id: Optional[int] = None
    roles_metadata: Optional[Any] = None
    actor_claims: Optional[dict[str, Any]] = None


@dataclass
class RBACScopeContext:
    user: User
    scope: Literal["global", "tenant"]
    tenant_id: Optional[int] = None
    dealer_id: Optional[int] = None
    auth_subject: Optional[str] = None


@dataclass
class TenantContext:
    user: User
    scope: Literal["global", "tenant"]
    tenant_id: Optional[int] = None
    dealer_id: Optional[int] = None
    auth_subject: Optional[str] = None


@dataclass
class ActorContext:
    sub: str
    role: str
    admin_id: Optional[int] = None
    dealer_id: Optional[int] = None
    warehouse_id: Optional[int] = None
    driver_id: Optional[int] = None
    customer_id: Optional[int] = None


_auth_cache: dict[str, tuple[float, _ValidatedToken]] = {}
_auth_cache_lock = Lock()
_auth_user_index: dict[int, set[str]] = {}


def _auth_cache_key(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def _prune_auth_cache(now: float) -> None:
    expired = [key for key, (expires_at, _) in _auth_cache.items() if expires_at <= now]
    for key in expired:
        _, cached = _auth_cache.pop(key, (0.0, None))
        if cached:
            user_keys = _auth_user_index.get(cached.user_id)
            if user_keys:
                user_keys.discard(key)
                if not user_keys:
                    _auth_user_index.pop(cached.user_id, None)


def _store_validated_token(token: str, validated: _ValidatedToken) -> None:
    ttl = settings.AUTH_TOKEN_CACHE_TTL_SECONDS
    if ttl <= 0:
        return
    now = monotonic()
    cache_key = _auth_cache_key(token)
    with _auth_cache_lock:
        _prune_auth_cache(now)
        previous = _auth_cache.get(cache_key)
        if previous:
            prior_user = previous[1].user_id
            user_keys = _auth_user_index.get(prior_user)
            if user_keys:
                user_keys.discard(cache_key)
                if not user_keys:
                    _auth_user_index.pop(prior_user, None)
        _auth_cache[cache_key] = (now + ttl, validated)
        _auth_user_index.setdefault(validated.user_id, set()).add(cache_key)


def _get_validated_token(token: str) -> Optional[_ValidatedToken]:
    ttl = settings.AUTH_TOKEN_CACHE_TTL_SECONDS
    if ttl <= 0:
        return None
    now = monotonic()
    cache_key = _auth_cache_key(token)
    with _auth_cache_lock:
        _prune_auth_cache(now)
        cached = _auth_cache.get(cache_key)
        if not cached or cached[0] <= now:
            return None
        return cached[1]


def invalidate_token_cache(token: Optional[str]) -> None:
    if not token:
        return
    cache_key = _auth_cache_key(token)
    with _auth_cache_lock:
        cached = _auth_cache.pop(cache_key, None)
        if cached:
            user_keys = _auth_user_index.get(cached[1].user_id)
            if user_keys:
                user_keys.discard(cache_key)
                if not user_keys:
                    _auth_user_index.pop(cached[1].user_id, None)


def invalidate_user_token_cache(user_id: int) -> None:
    with _auth_cache_lock:
        cache_keys = _auth_user_index.pop(user_id, set())
        for cache_key in cache_keys:
            _auth_cache.pop(cache_key, None)

_supabase_token_url = (
    f"{settings.SUPABASE_URL.rstrip('/')}/auth/v1/token"
    if settings.SUPABASE_URL
    else f"{settings.API_V1_STR}/auth/me"
)
oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl=_supabase_token_url,
    description="Use a Supabase bearer access token in the Authorization header.",
    auto_error=False,
)


def _auth_unauthorized(detail: str) -> HTTPException:
    return HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail=detail,
        headers={"WWW-Authenticate": "Bearer"},
    )


def _coerce_iat(raw_iat: Any) -> Optional[int]:
    if isinstance(raw_iat, int):
        return raw_iat
    if isinstance(raw_iat, str) and raw_iat.strip().isdigit():
        return int(raw_iat.strip())
    return None


def _coerce_bool(raw_value: Any) -> Optional[bool]:
    if isinstance(raw_value, bool):
        return raw_value
    if isinstance(raw_value, (int, float)) and not isinstance(raw_value, bool):
        return bool(raw_value)
    if isinstance(raw_value, str):
        normalized = raw_value.strip().lower()
        if normalized in {"1", "true", "yes", "y"}:
            return True
        if normalized in {"0", "false", "no", "n"}:
            return False
    return None


def _has_non_empty_claim(raw_value: Any) -> bool:
    if raw_value is None:
        return False
    if isinstance(raw_value, str):
        return bool(raw_value.strip())
    return True


def _is_supabase_email_verified(payload: dict[str, Any]) -> bool:
    direct_verified = _coerce_bool(payload.get("email_verified"))
    if direct_verified is True:
        return True
    if _has_non_empty_claim(payload.get("email_confirmed_at")):
        return True
    if _has_non_empty_claim(payload.get("confirmed_at")):
        return True

    user_metadata = payload.get("user_metadata")
    if isinstance(user_metadata, dict):
        metadata_verified = _coerce_bool(user_metadata.get("email_verified"))
        if metadata_verified is True:
            return True
        if _has_non_empty_claim(user_metadata.get("email_confirmed_at")):
            return True

    return False


def _coerce_int(raw_value: Any) -> Optional[int]:
    if isinstance(raw_value, bool):
        return None
    if isinstance(raw_value, int):
        return raw_value
    if isinstance(raw_value, str):
        cleaned = raw_value.strip()
        if cleaned and cleaned.lstrip("-").isdigit():
            try:
                return int(cleaned)
            except ValueError:
                return None
    return None


def _coerce_positive_int(raw_value: Any) -> Optional[int]:
    parsed = _coerce_int(raw_value)
    if parsed is None or parsed <= 0:
        return None
    return parsed


def _normalize_actor_role(raw_role: Any) -> str:
    canonical = canonical_role_name(str(raw_role or "").strip().lower())
    if not canonical:
        return ""
    return ACTOR_ROLE_ALIASES.get(canonical, canonical)


def _extract_actor_claims(
    payload: dict[str, Any],
    *,
    fail_closed: bool,
) -> Optional[dict[str, Any]]:
    app_metadata = payload.get("app_metadata")
    app_metadata_dict = app_metadata if isinstance(app_metadata, dict) else {}
    user_metadata = payload.get("user_metadata")
    user_metadata_dict = user_metadata if isinstance(user_metadata, dict) else {}

    role_candidates = (
        app_metadata_dict.get("role"),
        app_metadata_dict.get("user_role"),
        user_metadata_dict.get("role"),
        user_metadata_dict.get("role_name"),
        payload.get("role"),
    )
    normalized_role = ""
    for candidate in role_candidates:
        raw_candidate = str(candidate or "").strip().lower()
        if not raw_candidate or raw_candidate in NON_ACTOR_TOKEN_ROLES:
            continue
        normalized_role = _normalize_actor_role(candidate)
        if normalized_role:
            break

    if not normalized_role:
        return None

    if normalized_role not in ROLE_REQUIRED_ENTITY_CLAIMS:
        return None

    claims: dict[str, Any] = {"role": normalized_role}
    for key in ACTOR_ENTITY_CLAIM_KEYS:
        claims[key] = _coerce_positive_int(app_metadata_dict.get(key))
        if claims[key] is None:
            claims[key] = _coerce_positive_int(payload.get(key))

    sub = str(payload.get("sub") or "").strip()
    if fail_closed and not sub:
        raise _auth_unauthorized("token_invalid")

    if normalized_role == "admin" and claims.get("admin_id") is None:
        claims["admin_id"] = _coerce_positive_int(sub)
        if fail_closed and claims.get("admin_id") is None:
            raise _auth_unauthorized("token_missing_admin_claim")

    required_claims = ROLE_REQUIRED_ENTITY_CLAIMS.get(normalized_role, tuple())
    for claim_name in required_claims:
        if claims.get(claim_name) is None:
            if fail_closed:
                raise _auth_unauthorized(f"token_missing_{claim_name}_claim")
            return None

    return claims


def _extract_tenant_claim(payload: dict[str, Any]) -> Optional[int]:
    app_metadata = payload.get("app_metadata")
    if isinstance(app_metadata, dict):
        tenant_id = _coerce_int(app_metadata.get("tenant_id"))
        if tenant_id is not None:
            return tenant_id
    return None


def _is_token_issued_before_global_logout(
    issued_at_epoch: Optional[int],
    last_global_logout_at: Optional[datetime],
) -> bool:
    if not issued_at_epoch or not last_global_logout_at:
        return False
    token_issued_at = ensure_utc_aware(datetime.fromtimestamp(issued_at_epoch, UTC))
    global_logout_at = ensure_utc_aware(last_global_logout_at)
    if token_issued_at is None or global_logout_at is None:
        return False
    return token_issued_at < global_logout_at


def _assert_not_blacklisted(db: Session, token: str) -> None:
    lookup_keys = _blacklist_lookup_keys(token)
    if not lookup_keys:
        return
    blacklisted = db.exec(
        select(BlacklistedToken).where(BlacklistedToken.token.in_(lookup_keys))
    ).first()
    if blacklisted:
        raise _auth_unauthorized("token_invalid")


def _validate_iat_claim(payload: dict[str, Any]) -> Optional[int]:
    issued_at = _coerce_iat(payload.get("iat"))
    if settings.AUTH_REQUIRE_IAT_CLAIM and issued_at is None:
        raise _auth_unauthorized("token_invalid")

    if issued_at is not None:
        max_future_skew = max(int(settings.AUTH_IAT_FUTURE_SKEW_SECONDS), 0)
        now_epoch = int(utcnow().timestamp())
        if issued_at > now_epoch + max_future_skew:
            raise _auth_unauthorized("token_invalid")

    return issued_at


def _validate_local_access_token(db: Session, token: str) -> _ValidatedToken:
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        token_data = TokenPayload(**payload)
    except ExpiredSignatureError:
        raise _auth_unauthorized("token_expired")
    except (JWTError, ValidationError) as exc:
        logger.warning("auth.token_decode_failed", extra={"error": str(exc)})
        raise _auth_unauthorized("token_invalid")

    token_type = str(payload.get("type") or "").strip().lower()
    if token_type != "access":
        raise _auth_unauthorized("token_invalid")

    _assert_not_blacklisted(db, token)

    try:
        user_id = int(token_data.sub)
    except (TypeError, ValueError):
        raise _auth_unauthorized("token_invalid")

    sid_raw = payload.get("sid")
    sid = str(sid_raw).strip() if sid_raw is not None else ""
    if not sid:
        raise _auth_unauthorized("token_invalid")

    from app.models.session import UserSession

    # Canonical format is sid=str(UserSession.id). Keep fallback to legacy JTI
    # sid values during migration.
    user_session = None
    try:
        session_id = int(sid)
        user_session = db.exec(
            select(UserSession).where(UserSession.id == session_id)
        ).first()
    except (ValueError, TypeError):
        user_session = db.exec(
            select(UserSession).where(UserSession.token_id == sid)
        ).first()

    if (
        not user_session
        or not user_session.is_active
        or user_session.user_id != user_id
    ):
        raise _auth_unauthorized("token_invalid")

    return _ValidatedToken(
        user_id=user_id,
        sid=sid,
        issued_at=_validate_iat_claim(payload),
        subject=str(token_data.sub),
        tenant_id=_extract_tenant_claim(payload),
        roles_metadata=payload.get("app_metadata"),
        actor_claims=_extract_actor_claims(payload, fail_closed=False),
    )


def _find_users_by_email(db: Session, email: str) -> list[User]:
    email_normalized = email.strip().lower()
    if not email_normalized:
        return []
    return db.exec(
        select(User).where(func.lower(User.email) == email_normalized)
    ).all()

def _audit_identity_link_event(
    db: Session,
    *,
    provider: str,
    external_subject: Optional[str],
    email_snapshot: Optional[str],
    user_id: Optional[int],
    event_type: str,
    detail_code: str,
    success: bool,
) -> None:
    try:
        db.add(
            UserIdentityLinkAudit(
                provider=provider,
                external_subject=external_subject,
                email_snapshot=email_snapshot,
                user_id=user_id,
                event_type=event_type,
                detail_code=detail_code,
                success=success,
            )
        )
        db.commit()
    except Exception:
        db.rollback()
        logger.warning(
            "auth.identity_audit_write_failed",
            extra={
                "provider": provider,
                "event_type": event_type,
                "detail_code": detail_code,
            },
            exc_info=True,
        )


def _resolve_user_from_supabase_identity(
    db: Session,
    *,
    external_subject: str,
    email: Optional[str],
) -> User:
    provider = "supabase"
    normalized_email = (email or "").strip().lower() or None

    identity = db.exec(
        select(UserIdentity).where(
            UserIdentity.provider == provider,
            UserIdentity.external_subject == external_subject,
        )
    ).first()
    if identity:
        if identity.status != UserIdentityStatus.ACTIVE:
            _audit_identity_link_event(
                db,
                provider=provider,
                external_subject=external_subject,
                email_snapshot=normalized_email,
                user_id=identity.user_id,
                event_type="identity_lookup",
                detail_code="identity_disabled",
                success=False,
            )
            raise _auth_unauthorized("identity_disabled")

        user = db.get(User, identity.user_id)
        if not user:
            _audit_identity_link_event(
                db,
                provider=provider,
                external_subject=external_subject,
                email_snapshot=normalized_email,
                user_id=identity.user_id,
                event_type="identity_lookup",
                detail_code="identity_orphaned",
                success=False,
            )
            raise _auth_unauthorized("identity_mapping_conflict")

        identity.last_seen_at = utcnow()
        if normalized_email:
            identity.email_snapshot = normalized_email
        identity.updated_at = utcnow()
        db.add(identity)
        db.commit()
        return user

    if not normalized_email:
        _audit_identity_link_event(
            db,
            provider=provider,
            external_subject=external_subject,
            email_snapshot=None,
            user_id=None,
            event_type="identity_link_attempt",
            detail_code="identity_unmapped_missing_email",
            success=False,
        )
        raise _auth_unauthorized("identity_unmapped")

    matches = _find_users_by_email(db, normalized_email)
    if len(matches) > 1:
        _audit_identity_link_event(
            db,
            provider=provider,
            external_subject=external_subject,
            email_snapshot=normalized_email,
            user_id=None,
            event_type="identity_link_attempt",
            detail_code="identity_mapping_conflict_duplicate_email",
            success=False,
        )
        raise _auth_unauthorized("identity_mapping_conflict")

    if len(matches) == 0:
        _audit_identity_link_event(
            db,
            provider=provider,
            external_subject=external_subject,
            email_snapshot=normalized_email,
            user_id=None,
            event_type="identity_link_attempt",
            detail_code="identity_unmapped_no_local_user",
            success=False,
        )
        raise _auth_unauthorized("identity_unmapped")

    user = matches[0]
    new_identity = UserIdentity(
        provider=provider,
        external_subject=external_subject,
        user_id=user.id,
        email_snapshot=normalized_email,
        status=UserIdentityStatus.ACTIVE,
        linked_at=utcnow(),
        last_seen_at=utcnow(),
        created_at=utcnow(),
        updated_at=utcnow(),
    )
    db.add(new_identity)
    db.commit()
    db.refresh(new_identity)
    _audit_identity_link_event(
        db,
        provider=provider,
        external_subject=external_subject,
        email_snapshot=normalized_email,
        user_id=user.id,
        event_type="identity_link_attempt",
        detail_code="identity_auto_linked_by_verified_email",
        success=True,
    )
    return user


def _validate_supabase_access_token(db: Session, token: str) -> _ValidatedToken:
    try:
        payload = AuthService.verify_supabase_access_token(token)
    except SupabaseTokenValidationError as exc:
        if exc.code == "token_expired":
            raise _auth_unauthorized("token_expired")
        raise _auth_unauthorized("token_invalid")

    token_type = str(payload.get("type") or payload.get("token_type") or "").strip().lower()
    if token_type and token_type not in {"access", "access_token", "bearer"}:
        raise _auth_unauthorized("token_invalid")

    sub = str(payload.get("sub") or "").strip()
    if not sub:
        raise _auth_unauthorized("token_invalid")
    issued_at = _validate_iat_claim(payload)

    email = str(payload.get("email") or "").strip()
    if settings.SUPABASE_ENFORCE_EMAIL_VERIFIED and email:
        if not _is_supabase_email_verified(payload):
            raise _auth_unauthorized("token_invalid")

    user = _resolve_user_from_supabase_identity(
        db,
        external_subject=sub,
        email=email or None,
    )

    app_metadata = payload.get("app_metadata")
    roles_metadata: Any = app_metadata if isinstance(app_metadata, dict) else None
    if roles_metadata is None:
        roles_metadata = payload.get("role")

    return _ValidatedToken(
        user_id=user.id,
        sid=None,
        issued_at=issued_at,
        subject=sub,
        tenant_id=_extract_tenant_claim(payload),
        roles_metadata=roles_metadata,
        actor_claims=_extract_actor_claims(payload, fail_closed=False),
    )


def _validate_access_token_by_mode(db: Session, token: str) -> _ValidatedToken:
    auth_provider = (settings.AUTH_PROVIDER or "").strip().lower()
    if auth_provider == "supabase":
        return _validate_supabase_access_token(db, token)
    if auth_provider == "hybrid":
        try:
            return _validate_local_access_token(db, token)
        except HTTPException as exc:
            # In hybrid mode local token_expired must not silently fall through.
            if exc.status_code == status.HTTP_401_UNAUTHORIZED and exc.detail == "token_invalid":
                return _validate_supabase_access_token(db, token)
            raise

    logger.error(
        "auth.invalid_provider_mode",
        extra={"auth_provider": settings.AUTH_PROVIDER, "expected": "supabase|hybrid"},
    )
    raise HTTPException(
        status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
        detail="auth_provider_misconfigured",
    )


def get_active_roles_for_user_id(
    db: Session,
    user_id: int,
) -> list[Role]:
    now = utcnow_naive()
    active_roles = db.exec(
        select(Role)
        .join(UserRole, UserRole.role_id == Role.id)
        .where(
            UserRole.user_id == user_id,
            Role.is_active == True,  # noqa: E712
            UserRole.effective_from <= now,
            or_(UserRole.expires_at == None, UserRole.expires_at >= now),  # noqa: E711
        )
        .order_by(Role.level.desc(), Role.name.asc())
    ).all()
    return active_roles


def get_user_from_token(
    db: Session,
    token: Optional[str],
    request: Optional[Request] = None,
) -> User:
    if not token or token.lower() in ["null", "undefined"]:
        raise _auth_unauthorized("token_missing")

    _assert_not_blacklisted(db, token)

    validated = _get_validated_token(token)

    if validated is None:
        validated = _validate_access_token_by_mode(db, token)
        _store_validated_token(token, validated)

    user = db.exec(
        select(User)
        .where(User.id == validated.user_id)
        .options(joinedload(User.role))
    ).first()

    if not user:
        raise _auth_unauthorized("token_invalid")
    if user.is_deleted:
        invalidate_user_token_cache(user.id)
        invalidate_token_cache(token)
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="insufficient_permissions",
        )
    if not user.is_active:
        invalidate_user_token_cache(user.id)
        invalidate_token_cache(token)
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="insufficient_permissions",
        )

    if getattr(user, "last_global_logout_at", None):
        if _is_token_issued_before_global_logout(
            validated.issued_at,
            user.last_global_logout_at,
        ):
            raise _auth_unauthorized("token_invalid")

    active_roles = get_active_roles_for_user_id(db, user.id)
    setattr(user, "_active_roles_cache", active_roles)

    if not active_roles and user.role:
        setattr(user, "_active_roles_cache", [user.role])
        active_roles = [user.role]

    # Keep active role pointer deterministic and in-sync with active assignments.
    active_role_ids = {role.id for role in active_roles if role.id is not None}
    if active_role_ids and user.role_id not in active_role_ids:
        best_role = active_roles[0]
        if best_role.id is not None:
            user.role_id = best_role.id
            db.add(user)
            db.commit()
            db.refresh(user)
            setattr(user, "_active_roles_cache", active_roles)

    if request is not None:
        request.state.user = user
        request.state.user_id = user.id
        request.state.session_sid = validated.sid
        request.state.auth_subject = validated.subject
        request.state.auth_tenant_id = validated.tenant_id
        request.state.auth_roles_metadata = validated.roles_metadata
        request.state.auth_actor_claims = validated.actor_claims
        from app.models.roles import RoleEnum
        role_names = get_user_role_names(user)
        if canonical_role_name(RoleEnum.SUPER_ADMIN.value) in role_names:
            request.state.user_role = RoleEnum.SUPER_ADMIN
        elif role_names & ADMIN_ROLE_NAMES:
            request.state.user_role = RoleEnum.ADMIN
        elif role_names & LOGISTICS_ROLE_NAMES:
            request.state.user_role = RoleEnum.LOGISTICS
        elif role_names & DEALER_SCOPE_ROLE_NAMES:
            request.state.user_role = RoleEnum.DEALER
        elif canonical_role_name(RoleEnum.DRIVER.value) in role_names:
            request.state.user_role = RoleEnum.DRIVER
        elif canonical_role_name(RoleEnum.CUSTOMER.value) in role_names:
            request.state.user_role = RoleEnum.CUSTOMER
        request.state.user_roles = sorted(role_names)
        request.state.primary_role = canonical_role_name(getattr(getattr(user, "role", None), "name", None))
        request.state.claimed_actor_role = (
            str((validated.actor_claims or {}).get("role") or "").strip() or None
        )

    return user


def get_user_role_names(user: User) -> set[str]:
    role_names: set[str] = set()

    for role in getattr(user, "roles", []) or []:
        role_name = canonical_role_name((getattr(role, "name", "") or "").strip().lower())
        if role_name:
            role_names.add(role_name)

    primary_role = getattr(user, "role", None)
    primary_role_name = canonical_role_name((getattr(primary_role, "name", "") or "").strip().lower())
    if primary_role_name:
        role_names.add(primary_role_name)

    user_type = getattr(user, "user_type", None)
    if user_type:
        user_type_value = str(getattr(user_type, "value", user_type)).strip().lower()
        canonical = USERTYPE_TO_CANONICAL_ROLE.get(user_type_value) or canonical_role_name(user_type_value)
        if canonical:
            role_names.add(canonical)

    if getattr(user, "is_superuser", False):
        role_names.add("super_admin")

    return role_names


def get_user_role_names_sorted(user: User) -> list[str]:
    return sorted(get_user_role_names(user))


def _mark_authz_failure(
    request: Optional[Request],
    *,
    permission_slug: Optional[str] = None,
    allowed_roles: Optional[set[str] | list[str] | tuple[str, ...]] = None,
) -> None:
    if request is None:
        return
    if permission_slug:
        request.state.required_permission = canonicalize_permission_slug(permission_slug)
    if allowed_roles:
        request.state.allowed_roles = sorted(
            canonical_role_name(role_name)
            for role_name in allowed_roles
            if canonical_role_name(role_name)
        )


def _is_platform_admin_user(user: User) -> bool:
    from app.models.user import UserType

    role_names = get_user_role_names(user)
    return bool(
        getattr(user, "is_superuser", False)
        or getattr(user, "user_type", None) == UserType.ADMIN
        or bool(role_names & ADMIN_ROLE_NAMES)
    )


def get_dealer_profile_for_user_id(db: Session, user_id: int):
    from app.models.dealer import DealerProfile

    dealer_profile = db.exec(
        select(DealerProfile).where(DealerProfile.user_id == user_id)
    ).first()
    if dealer_profile:
        return dealer_profile

    user = db.get(User, user_id)
    dealer_id = getattr(user, "created_by_dealer_id", None) if user else None
    if dealer_id:
        return db.get(DealerProfile, dealer_id)
    return None


def get_dealer_profile_for_user(db: Session, user: User):
    return get_dealer_profile_for_user_id(db, user.id)


def _resolve_local_dealer_id(db: Session, current_user: User) -> Optional[int]:
    dealer_profile = get_dealer_profile_for_user(db, current_user)
    if dealer_profile and getattr(dealer_profile, "id", None):
        return int(dealer_profile.id)

    created_by_dealer_id = getattr(current_user, "created_by_dealer_id", None)
    if created_by_dealer_id:
        return int(created_by_dealer_id)

    role_dealer_ids = {
        int(role.dealer_id)
        for role in getattr(current_user, "roles", []) or []
        if getattr(role, "dealer_id", None) is not None
    }
    if len(role_dealer_ids) == 1:
        return next(iter(role_dealer_ids))
    return None


def get_dealer_profile_or_403(
    db: Session,
    user_id: int,
    detail: str = "Not a dealer account",
):
    dealer_profile = get_dealer_profile_for_user_id(db, user_id)
    if not dealer_profile:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=detail)
    return dealer_profile


def get_current_user(
    request: Request,
    db: Session = Depends(get_db),
    token: Optional[str] = Depends(oauth2_scheme)
) -> User:
    return get_user_from_token(db=db, token=token, request=request)

def get_current_active_superuser(
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> User:
    if not (current_user.is_superuser or "super_admin" in get_user_role_names(current_user)):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="insufficient_permissions",
        )
    _resolve_tenant_context(
        db,
        current_user,
        request,
        allow_global=True,
    )
    return current_user

def get_current_active_admin(
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> User:
    if not _is_platform_admin_user(current_user):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="insufficient_permissions",
        )
    _resolve_tenant_context(
        db,
        current_user,
        request,
        allow_global=True,
    )
    return current_user

def check_permission(menu_name: str, permission_type: str = "view"):
    """
    Dependency to check if user has specific permission for a menu by name
    """
    def permission_checker(
        request: Request,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
    ) -> User:
        # Superusers and platform admins always have access
        if _is_platform_admin_user(current_user):
            return current_user

        role_ids = [r.id for r in getattr(current_user, "roles", []) if getattr(r, "id", None) is not None]
        if not role_ids and current_user.role_id:
            role_ids = [current_user.role_id]
        if not role_ids:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="User has no role assigned"
            )

        from app.services.rbac_service import rbac_service
        has_access = any(
            rbac_service.check_menu_access(db, role_id, menu_name, permission_type)
            for role_id in role_ids
        )
        if not has_access:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="insufficient_permissions",
            )

        _resolve_tenant_context(
            db,
            current_user,
            request,
            allow_global=True,
        )
        
        return current_user
    
    return permission_checker

# Alias for compatibility
get_current_active_user = get_current_user

# --- Granular RBAC Dependencies ---

def require_role(role_name: str):
    """
    Dependency: Verify current user has a specific role.
    Usage: current_user: User = Depends(require_role("Driver"))
    """
    def role_checker(
        current_user: User = Depends(get_current_user)
    ) -> User:
        if current_user.is_superuser:
            return current_user

        required = canonical_role_name(role_name)
        user_role_names = get_user_role_names(current_user)
        if required not in user_role_names:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="insufficient_permissions",
            )
        return current_user
    
    return role_checker


def require_permission(permission_slug: str):
    """
    Dependency: Verify current user has a specific permission.
    Usage: current_user: User = Depends(require_permission("battery:view:global"))
    """
    def permission_checker(
        request: Request,
        current_user: User = Depends(get_current_user)
    ) -> User:
        if current_user.is_superuser:
            return current_user
        
        if not current_user.has_permission(permission_slug):
            _mark_authz_failure(request, permission_slug=permission_slug)
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="insufficient_permissions",
            )
        return current_user
    
    return permission_checker


def _resolve_local_tenant_id(db: Session, current_user: User) -> Optional[int]:
    try:
        from app.models.tenant import TenantMembership

        memberships = db.exec(
            select(TenantMembership).where(
                TenantMembership.user_id == current_user.id,
                TenantMembership.status == "active",
            )
        ).all()
        if memberships:
            default_membership = next((item for item in memberships if item.is_default), None)
            if default_membership:
                return int(default_membership.tenant_id)
            tenant_ids = {int(item.tenant_id) for item in memberships}
            if len(tenant_ids) == 1:
                return next(iter(tenant_ids))
    except Exception:
        # Keep compatibility while tenant tables are rolling out.
        pass

    dealer_profile = get_dealer_profile_for_user(db, current_user)
    if dealer_profile and getattr(dealer_profile, "id", None):
        return int(getattr(dealer_profile, "tenant_id", None) or dealer_profile.id)

    created_by_dealer_id = getattr(current_user, "created_by_dealer_id", None)
    if created_by_dealer_id:
        return int(created_by_dealer_id)

    role_tenant_ids = {
        int(role.dealer_id)
        for role in getattr(current_user, "roles", []) or []
        if getattr(role, "dealer_id", None) is not None
    }
    if len(role_tenant_ids) == 1:
        return next(iter(role_tenant_ids))
    return None


def _is_global_admin_actor(current_user: User) -> bool:
    if current_user.is_superuser:
        return True
    role_names = get_user_role_names(current_user)
    # Logistics app users currently authenticate with Supabase access tokens that
    # do not always carry tenant claims. Treat logistics operators as global
    # actors in allow_global flows so internal logistics endpoints remain usable.
    return bool(role_names & (ADMIN_ROLE_NAMES | LOGISTICS_ROLE_NAMES))


def _apply_db_tenant_session_context(
    db: Session,
    context: TenantContext,
    *,
    actor_claims: Optional[dict[str, Any]] = None,
) -> None:
    try:
        db.exec(
            text("SELECT set_config('app.user_id', :user_id, true)").bindparams(
                user_id=str(context.user.id)
            )
        )
        db.exec(
            text("SELECT set_config('app.scope', :scope, true)").bindparams(
                scope=context.scope
            )
        )
        db.exec(
            text("SELECT set_config('app.auth_subject', :subject, true)").bindparams(
                subject=str(context.auth_subject or "")
            )
        )
        db.exec(
            text("SELECT set_config('app.tenant_id', :tenant_id, true)").bindparams(
                tenant_id=str(context.tenant_id or "")
            )
        )
        db.exec(
            text("SELECT set_config('app.actor_role', :actor_role, true)").bindparams(
                actor_role=str((actor_claims or {}).get("role") or "")
            )
        )
        db.exec(
            text("SELECT set_config('app.actor_admin_id', :actor_admin_id, true)").bindparams(
                actor_admin_id=str((actor_claims or {}).get("admin_id") or "")
            )
        )
        db.exec(
            text("SELECT set_config('app.actor_dealer_id', :actor_dealer_id, true)").bindparams(
                actor_dealer_id=str((actor_claims or {}).get("dealer_id") or "")
            )
        )
        db.exec(
            text("SELECT set_config('app.actor_warehouse_id', :actor_warehouse_id, true)").bindparams(
                actor_warehouse_id=str((actor_claims or {}).get("warehouse_id") or "")
            )
        )
        db.exec(
            text("SELECT set_config('app.actor_driver_id', :actor_driver_id, true)").bindparams(
                actor_driver_id=str((actor_claims or {}).get("driver_id") or "")
            )
        )
        db.exec(
            text("SELECT set_config('app.actor_customer_id', :actor_customer_id, true)").bindparams(
                actor_customer_id=str((actor_claims or {}).get("customer_id") or "")
            )
        )
    except Exception:
        logger.debug("tenant.session_context_unavailable", exc_info=True)


def _resolve_tenant_context(
    db: Session,
    current_user: User,
    request: Optional[Request] = None,
    *,
    allow_global: bool = False,
) -> TenantContext:
    auth_subject = getattr(request.state, "auth_subject", None) if request is not None else None
    actor_claims = (
        getattr(request.state, "auth_actor_claims", None)
        if request is not None
        else None
    )
    if allow_global and _is_global_admin_actor(current_user):
        context = TenantContext(
            user=current_user,
            scope="global",
            dealer_id=_resolve_local_dealer_id(db, current_user),
            auth_subject=auth_subject,
        )
        _apply_db_tenant_session_context(db, context, actor_claims=actor_claims)
        return context

    local_tenant_id = _resolve_local_tenant_id(db, current_user)
    if local_tenant_id is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="tenant_context_missing",
        )

    claim_tenant_id = None
    if request is not None:
        claim_tenant_id = _coerce_int(getattr(request.state, "auth_tenant_id", None))
    if (
        claim_tenant_id is None
        and request is not None
        and str(settings.ENVIRONMENT or "").lower().startswith("test")
        and getattr(request.state, "auth_subject", None) is None
    ):
        claim_tenant_id = local_tenant_id
    if claim_tenant_id is None or claim_tenant_id != local_tenant_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="tenant_claim_invalid",
        )

    context = TenantContext(
        user=current_user,
        scope="tenant",
        tenant_id=local_tenant_id,
        dealer_id=_resolve_local_dealer_id(db, current_user),
        auth_subject=auth_subject,
    )
    _apply_db_tenant_session_context(db, context, actor_claims=actor_claims)
    return context


def _assert_tenant_safe_internal_route(request: Request, context: TenantContext) -> None:
    if context.scope == "global":
        return
    path = str(request.url.path or "")
    if any(path.startswith(prefix) for prefix in TENANT_UNSAFE_INTERNAL_PATH_PREFIXES):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="tenant_scope_not_supported_for_endpoint",
        )


def require_tenant_context(
    *,
    allow_global: bool = False,
):
    def tenant_checker(
        request: Request,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
    ) -> TenantContext:
        return _resolve_tenant_context(
            db,
            current_user,
            request,
            allow_global=allow_global,
        )

    return tenant_checker


def require_global_admin_context(
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> TenantContext:
    context = _resolve_tenant_context(
        db,
        current_user,
        request,
        allow_global=True,
    )
    if context.scope != "global":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="insufficient_permissions",
        )
    return context


def get_tenant_upload_prefix(
    context: TenantContext = Depends(require_tenant_context(allow_global=True)),
) -> str:
    if context.scope == "global":
        return f"global/user-{context.user.id}"
    return f"tenant/{context.tenant_id}"


def _resolve_rbac_scope_context(
    db: Session,
    current_user: User,
    request: Optional[Request] = None,
) -> RBACScopeContext:
    auth_subject = getattr(request.state, "auth_subject", None) if request is not None else None
    if current_user.is_superuser:
        return RBACScopeContext(
            user=current_user,
            scope="global",
            dealer_id=_resolve_local_dealer_id(db, current_user),
            auth_subject=auth_subject,
        )

    role_names = get_user_role_names(current_user)
    if bool(role_names & ADMIN_ROLE_NAMES):
        return RBACScopeContext(
            user=current_user,
            scope="global",
            dealer_id=_resolve_local_dealer_id(db, current_user),
            auth_subject=auth_subject,
        )

    local_tenant_id = _resolve_local_tenant_id(db, current_user)
    if local_tenant_id is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="insufficient_permissions",
        )

    claim_tenant_id = None
    if request is not None:
        claim_tenant_id = _coerce_int(getattr(request.state, "auth_tenant_id", None))
    if (
        claim_tenant_id is None
        and request is not None
        and getattr(request.state, "auth_subject", None) is None
        and not str(request.headers.get("authorization") or "").strip()
    ):
        # Dependency-override fallback used by tests that inject current_user
        # directly (bypassing token parsing and request.state claim hydration).
        claim_tenant_id = local_tenant_id
    if claim_tenant_id is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="rbac_tenant_claim_invalid",
        )
    if claim_tenant_id != local_tenant_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="rbac_tenant_claim_invalid",
        )

    return RBACScopeContext(
        user=current_user,
        scope="tenant",
        tenant_id=local_tenant_id,
        dealer_id=_resolve_local_dealer_id(db, current_user),
        auth_subject=auth_subject,
    )


def get_rbac_scope_context(
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> RBACScopeContext:
    return _resolve_rbac_scope_context(db, current_user, request)


def require_rbac_permission(
    permission_slug: str,
    *,
    require_global: bool = False,
    allow_tenant: bool = True,
):
    def permission_checker(
        request: Request,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
    ) -> RBACScopeContext:
        context = _resolve_rbac_scope_context(db, current_user, request)

        permission_allowed = current_user.is_superuser or current_user.has_permission(permission_slug)
        if not permission_allowed and permission_slug.startswith("rbac:"):
            # Migration bridge: allow coarse-grained legacy RBAC permissions
            # while canonical granular slugs are rolled out.
            if permission_slug.endswith(":read"):
                permission_allowed = current_user.has_permission("rbac:read")
            elif permission_slug.endswith(":write"):
                permission_allowed = (
                    current_user.has_permission("rbac:manage")
                    or current_user.has_permission("rbac:write")
                )
            else:
                permission_allowed = current_user.has_permission("rbac:manage")

        if not permission_allowed and permission_slug.startswith("rbac:"):
            # Migration bridge: legacy admin users were historically allowed to
            # access RBAC without explicit granular slugs. Preserve that access
            # while canonical permission assignments are being rolled out.
            permission_allowed = _is_platform_admin_user(current_user)

        if not permission_allowed:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="insufficient_permissions",
            )

        if require_global and context.scope != "global":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="rbac_scope_forbidden",
            )

        if not allow_tenant and context.scope == "tenant":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="rbac_scope_forbidden",
            )

        return context

    return permission_checker


def require_global_permission(permission_slug: str):
    """
    Require a global-scope permission and explicitly reject tenant-scoped claims.

    Use for platform-wide dashboards and controls where tenant-scoped tokens must
    never access global aggregates.
    """

    def permission_checker(
        request: Request,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
    ) -> RBACScopeContext:
        permission_allowed = current_user.is_superuser or current_user.has_permission(permission_slug)
        if (
            not permission_allowed
            and canonicalize_permission_slug(permission_slug) in PLATFORM_ADMIN_GLOBAL_PERMISSION_BRIDGES
        ):
            # Compatibility bridge: legacy platform admins historically had
            # analytics access before granular analytics permissions were seeded.
            permission_allowed = _is_platform_admin_user(current_user)
        if not permission_allowed:
            _mark_authz_failure(request, permission_slug=permission_slug)
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="insufficient_permissions",
            )

        context = _resolve_tenant_context(
            db,
            current_user,
            request,
            allow_global=True,
        )
        if context.scope != "global":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="rbac_scope_forbidden",
            )

        claim_tenant_id = _coerce_int(getattr(request.state, "auth_tenant_id", None))
        if claim_tenant_id is not None and not current_user.is_superuser:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="rbac_scope_forbidden",
            )

        return RBACScopeContext(
            user=current_user,
            scope="global",
            dealer_id=_resolve_local_dealer_id(db, current_user),
            auth_subject=getattr(request.state, "auth_subject", None),
        )

    return permission_checker

def get_current_admin(current_user: User = Depends(get_current_user)) -> User:
    if not _is_platform_admin_user(current_user):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="insufficient_permissions",
        )
    return current_user

def get_current_dealer(
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> User:
    from app.models.user import UserType

    user_role_names = get_user_role_names(current_user)
    if not (
        current_user.is_superuser
        or current_user.user_type == UserType.DEALER
        or bool(user_role_names & DEALER_OWNER_ROLE_NAMES)
    ):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="insufficient_permissions",
        )
    _resolve_tenant_context(
        db,
        current_user,
        request,
        allow_global=True,
    )
    return current_user

def get_current_driver(current_user: User = Depends(get_current_user)) -> User:
    if current_user.is_superuser:
        return current_user

    user_role_names = get_user_role_names(current_user)
    if not (user_role_names & DRIVER_ROLE_NAMES):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="insufficient_permissions",
        )
    return current_user

def get_current_customer(current_user: User = Depends(get_current_user)) -> User:
    if current_user.is_superuser:
        return current_user

    user_role_names = get_user_role_names(current_user)
    if not (user_role_names & CUSTOMER_ROLE_NAMES):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="insufficient_permissions",
        )
    return current_user


def get_current_logistics(current_user: User = Depends(get_current_user)) -> User:
    from app.models.user import UserType

    if current_user.is_superuser:
        return current_user

    user_role_names = get_user_role_names(current_user)
    if not (
        current_user.user_type == UserType.LOGISTICS
        or bool(user_role_names & LOGISTICS_ROLE_NAMES)
    ):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="insufficient_permissions",
        )
    return current_user


def require_station_read_access(
    request: Request,
    current_user: User = Depends(get_current_user),
) -> User:
    if current_user.is_superuser:
        return current_user

    role_names = get_user_role_names(current_user)
    if role_names & (ADMIN_ROLE_NAMES | LOGISTICS_ROLE_NAMES):
        return current_user

    if current_user.has_permission("station:read"):
        return current_user

    _mark_authz_failure(
        request,
        permission_slug="station:read",
        allowed_roles=ADMIN_ROLE_NAMES | LOGISTICS_ROLE_NAMES,
    )
    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="insufficient_permissions",
    )


def _derive_actor_context_from_user(
    db: Session,
    current_user: User,
    *,
    auth_subject: Optional[str] = None,
) -> ActorContext:
    role_names = get_user_role_names(current_user)

    role = "customer"
    admin_id: Optional[int] = None
    dealer_id: Optional[int] = None
    warehouse_id: Optional[int] = None
    driver_id: Optional[int] = None
    customer_id: Optional[int] = None

    if getattr(current_user, "is_superuser", False) or role_names & ADMIN_ROLE_NAMES:
        role = "admin"
        admin_id = int(current_user.id)
    elif role_names & DEALER_SCOPE_ROLE_NAMES:
        role = "dealer"
        dealer_id = _resolve_local_dealer_id(db, current_user)
    elif role_names & LOGISTICS_ROLE_NAMES:
        role = "warehouse_operator"
        from app.models.access_assignment import WarehouseUserAssignment

        warehouse_id = db.exec(
            select(WarehouseUserAssignment.warehouse_id).where(
                WarehouseUserAssignment.user_id == current_user.id,
                WarehouseUserAssignment.is_active == True,  # noqa: E712
            )
        ).first()
        warehouse_id = _coerce_positive_int(warehouse_id)
    elif role_names & DRIVER_ROLE_NAMES:
        role = "driver"
        driver_id = _coerce_positive_int(getattr(current_user, "id", None))
    elif role_names & CUSTOMER_ROLE_NAMES:
        role = "customer"
        customer_id = _coerce_positive_int(getattr(current_user, "id", None))

    derived_subject = str(auth_subject or current_user.id)
    return ActorContext(
        sub=derived_subject,
        role=role,
        admin_id=admin_id,
        dealer_id=dealer_id,
        warehouse_id=warehouse_id,
        driver_id=driver_id,
        customer_id=customer_id,
    )


def _resolve_actor_context(
    db: Session,
    current_user: User,
    request: Optional[Request] = None,
) -> ActorContext:
    auth_subject = getattr(request.state, "auth_subject", None) if request is not None else None
    derived_context = _derive_actor_context_from_user(
        db,
        current_user,
        auth_subject=auth_subject,
    )
    auth_actor_claims = (
        getattr(request.state, "auth_actor_claims", None)
        if request is not None
        else None
    )
    if isinstance(auth_actor_claims, dict) and str(auth_actor_claims.get("role") or "").strip():
        role = _normalize_actor_role(auth_actor_claims.get("role"))
        if role in ROLE_REQUIRED_ENTITY_CLAIMS and role == derived_context.role:
            return ActorContext(
                sub=str(auth_subject or current_user.id),
                role=role,
                admin_id=_coerce_positive_int(auth_actor_claims.get("admin_id")) or derived_context.admin_id,
                dealer_id=_coerce_positive_int(auth_actor_claims.get("dealer_id")) or derived_context.dealer_id,
                warehouse_id=_coerce_positive_int(auth_actor_claims.get("warehouse_id")) or derived_context.warehouse_id,
                driver_id=_coerce_positive_int(auth_actor_claims.get("driver_id")) or derived_context.driver_id,
                customer_id=_coerce_positive_int(auth_actor_claims.get("customer_id")) or derived_context.customer_id,
            )
        logger.info(
            "auth.actor_claims_ignored",
            extra={
                "user_id": current_user.id,
                "auth_subject": auth_subject,
                "claimed_role": str(auth_actor_claims.get("role") or ""),
                "derived_role": derived_context.role,
            },
        )

    return derived_context


def get_actor_context(
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> ActorContext:
    context = _resolve_actor_context(db, current_user, request)
    request.state.actor_context = context
    return context


def require_actor_role(*allowed_roles: str):
    normalized_allowed = {_normalize_actor_role(role) for role in allowed_roles if role}

    def checker(
        actor_context: ActorContext = Depends(get_actor_context),
    ) -> ActorContext:
        if normalized_allowed and actor_context.role not in normalized_allowed:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="insufficient_permissions",
            )
        return actor_context

    return checker


def get_current_dealer_scope_user(
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> User:
    if current_user.is_superuser:
        _resolve_tenant_context(
            db,
            current_user,
            request,
            allow_global=True,
        )
        return current_user

    role_names = get_user_role_names(current_user)

    # Allow internal operators (admins + logistics) through the router-level
    # gate so they can reach endpoint-specific guards like
    # require_internal_operator on the read_dealers endpoint.
    if role_names & INTERNAL_OPERATOR_ROLE_NAMES:
        _resolve_tenant_context(
            db,
            current_user,
            request,
            allow_global=True,
        )
        return current_user

    if role_names & DEALER_SCOPE_ROLE_NAMES:
        _resolve_tenant_context(
            db,
            current_user,
            request,
            allow_global=False,
        )
        return current_user

    if get_dealer_profile_for_user(db, current_user):
        _resolve_tenant_context(
            db,
            current_user,
            request,
            allow_global=False,
        )
        return current_user

    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="insufficient_permissions",
    )


def require_driver_or_internal_operator(
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> User:
    if current_user.is_superuser:
        return current_user

    role_names = get_user_role_names(current_user)
    if role_names & DRIVER_ROLE_NAMES:
        return current_user

    if role_names & INTERNAL_OPERATOR_ROLE_NAMES:
        context = _resolve_tenant_context(
            db,
            current_user,
            request,
            allow_global=True,
        )
        _assert_tenant_safe_internal_route(request, context)
        return current_user

    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="insufficient_permissions",
    )


def require_customer_or_internal_operator(
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> User:
    if current_user.is_superuser:
        return current_user

    role_names = get_user_role_names(current_user)
    if role_names & CUSTOMER_ROLE_NAMES:
        return current_user

    if role_names & INTERNAL_OPERATOR_ROLE_NAMES:
        context = _resolve_tenant_context(
            db,
            current_user,
            request,
            allow_global=True,
        )
        _assert_tenant_safe_internal_route(request, context)
        return current_user

    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="insufficient_permissions",
    )


def require_internal_operator(
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> User:
    """Require admin or warehouse/logistics operator role."""
    if current_user.is_superuser:
        return current_user

    user_role_names = get_user_role_names(current_user)
    if not user_role_names & INTERNAL_OPERATOR_ROLE_NAMES:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="insufficient_permissions",
        )

    context = _resolve_tenant_context(
        db,
        current_user,
        request,
        allow_global=True,
    )
    _assert_tenant_safe_internal_route(request, context)
    return current_user


def require_internal_service_token(
    x_internal_service_token: Optional[str] = Header(default=None, alias="X-Internal-Service-Token"),
) -> bool:
    configured = (settings.INTERNAL_SERVICE_TOKEN or "").strip()
    if not configured:
        if settings.ENVIRONMENT.lower() == "production":
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Internal service token is not configured",
            )
        return True

    if not x_internal_service_token or x_internal_service_token.strip() != configured:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid internal service token",
        )
    return True
