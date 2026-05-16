"""
WEZU Energy – Unified Backend
Merged from wezu-backend-laxman (feature-rich) and wezu-backend (hardened).
"""
import asyncio
import os
import re
import ssl
import traceback
import anyio
from contextlib import asynccontextmanager
from pathlib import Path
from urllib.parse import urlsplit

from app.core.logging import setup_logging, get_logger

# Initialize structured logging globally
setup_logging()

from fastapi import Depends, FastAPI, HTTPException, Request, Response, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from sqlalchemy.exc import OperationalError, SQLAlchemyError
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.middleware.trustedhost import TrustedHostMiddleware
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

from app.core.config import settings
from app.core.database import (
    ensure_logistics_schema_compatibility,
    ensure_roles_schema_compatibility,
)
from app.db.session import engine
from app.api import deps
import app.models.all  # noqa: F401  Ensure all SQLModel classes registered
from app.middleware.rate_limit import limiter
from app.middleware.audit import AuditMiddleware
from app.middleware.security import SecureHeadersMiddleware
from app.middleware.proxy_headers import TrustedProxyHeadersMiddleware
from app.middleware.proxy_host import ProxyHostRewriteMiddleware
from app.middleware.request_logging import RequestLoggingMiddleware
from app.middleware.anomaly_logging import AnomalyLoggingMiddleware
from app.middleware.rbac_middleware import RBACMiddleware
from app.middleware.server_timing import ServerTimingMiddleware
from app.api.errors.handlers import add_exception_handlers
from app.workers import start_scheduler, stop_scheduler
from app.services.websocket_service import heartbeat_task
from app.services.mqtt_service import start_mqtt_service, stop_mqtt_service
from app.services.request_audit_queue import request_audit_queue
from app.services.background_runtime_service import BackgroundRuntimeService
from app.services.startup_diagnostics_service import StartupDiagnosticsService
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

# ── Router imports (all from Laxman + Hardened) ────────────────────────────
from app.api.v1 import (
    users, kyc, stations, batteries,
    bookings, wallet, payments, support, favorites, analytics,
    transactions, promo, faqs, iot, swaps, i18n, fraud, branches, organizations,
    warehouses, screens, stock, dealers, logistics, settlements,
    telematics, vehicles, locations, system, roles, menus, role_rights,
    admin_kyc, audit, ml, inventory, admin_stations, station_monitoring,
    dealer_portal_dashboard, dealer_portal_tickets,
    dealer_portal_customers, dealer_portal_settings, dealer_onboarding,
    dealer_documents, dealer_portal_users,
    dealer_analytics, dealer_campaigns, dealer_stations, drivers, catalog,
    admin_invoices, admin_financial_reports, admin_audit, admin_rbac, admin_users,
    admin_dealers, maintenance, security,
)
# Hardened-only endpoints
from app.api.v1 import (
    manifests, routes, warehouse_structure,
    battery_catalog, location, utils,
    wallet_enhanced,
    notifications_enhanced, support_enhanced,
    customer_reservations, customer_dashboard, dealer_portal_inventory,
    auth_gateway, auth_tombstones, rbac, rbac_tombstones, warehouse_tombstones,
    deliveries_canonical, rentals_canonical,
)
from app.api.v1.admin import (
    support as admin_support, faqs as admin_faqs, analytics as admin_analytics,
    users as admin_sub_users, promo as admin_coupons, reviews as admin_reviews,
    roles as admin_roles, legal as admin_legal, banners as admin_banners,
    media as admin_media, blogs as admin_blogs,
)
from app.api.admin import router as global_admin_router
from app.api.v1.dashboard import router as dashboard_router
from app.api.internal import hotspots as internal_hotspots
from app.api.webhooks import razorpay as razorpay_webhooks

# ── macOS dev SSL fix ──────────────────────────────────────────────────────
if settings.ENVIRONMENT != "production":
    try:
        _create_unverified_https_context = ssl._create_unverified_context
    except AttributeError:
        pass
    else:
        ssl._create_default_https_context = _create_unverified_https_context

# ── Sentry ─────────────────────────────────────────────────────────────────
if settings.SENTRY_DSN:
    sentry_sdk.init(
        dsn=settings.SENTRY_DSN,
        environment=settings.ENVIRONMENT,
        traces_sample_rate=settings.SENTRY_TRACES_SAMPLE_RATE,
        integrations=[FastApiIntegration()],
    )

logger = get_logger(__name__)
logger.info(
    "logging.initialized",
    environment=settings.ENVIRONMENT,
    log_level=settings.LOG_LEVEL,
    log_access_logs=settings.LOG_ACCESS_LOGS,
    log_requests=settings.LOG_REQUESTS,
)

from app.utils.cors import cors_headers_for_origin

CORS_ALLOWED_METHODS = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
CORS_ALLOWED_HEADERS = [
    "Authorization", "Content-Type", "Accept", "Origin",
    "X-Requested-With", "X-Request-ID", "X-Correlation-ID",
]
_CORS_HEADER_TOKEN_RE = re.compile(r"^[A-Za-z0-9!#$%&'*+.^_`|~-]+$")


def _resolve_preflight_allow_headers(request: Request) -> str:
    """
    Return a safe Access-Control-Allow-Headers value.

    For allowed origins, we echo validated requested header names to avoid
    frontend breakage when apps introduce new custom headers.
    """
    raw_requested = (request.headers.get("access-control-request-headers") or "").strip()
    if not raw_requested:
        return ", ".join(CORS_ALLOWED_HEADERS)

    seen: set[str] = set()
    accepted: list[str] = []
    for part in raw_requested.split(","):
        token = part.strip()
        if not token:
            continue
        if not _CORS_HEADER_TOKEN_RE.fullmatch(token):
            continue
        key = token.lower()
        if key in seen:
            continue
        seen.add(key)
        accepted.append(token)

    if not accepted:
        return ", ".join(CORS_ALLOWED_HEADERS)
    return ", ".join(accepted)


class CORSErrorMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)
        origin = request.headers.get("origin", "")
        for key, value in cors_headers_for_origin(origin).items():
            response.headers[key] = value
        return response


class CORSPreflightMiddleware(BaseHTTPMiddleware):
    """
    Handle CORS preflight (OPTIONS) at the middleware layer instead of via
    a catch-all ``@app.options("/{full_path:path}")`` route.

    Why: a route-based catch-all registers against the router's path index,
    so when a ``GET /foo`` request arrives and ``/foo/`` is the real route,
    Starlette's router sees the catch-all as a path match with wrong
    method and returns ``405`` **before** the trailing-slash redirect
    middleware ever runs — producing log lines like
    ``route_name=global_options_handler method=GET status_code=405``.

    A middleware runs *before* the router, so non-OPTIONS requests pass
    through untouched and slash-redirect works again. Only real CORS
    preflight requests (OPTIONS + ``access-control-request-method``
    header) are short-circuited here. Plain OPTIONS requests fall
    through to any route-level handlers.
    """

    async def dispatch(self, request: Request, call_next):
        if (
            request.method == "OPTIONS"
            and "access-control-request-method" in request.headers
        ):
            origin = request.headers.get("origin", "")
            headers = {
                "Access-Control-Allow-Methods": ", ".join(CORS_ALLOWED_METHODS),
                "Access-Control-Allow-Headers": _resolve_preflight_allow_headers(request),
                "Access-Control-Max-Age": "600",
            }
            headers.update(cors_headers_for_origin(origin))
            return Response(status_code=200, headers=headers)
        return await call_next(request)


# ── Production safety validation (from Hardened) ───────────────────────────

def _validate_production_safety() -> None:
    if settings.ENVIRONMENT.lower() != "production" or not settings.ENFORCE_PRODUCTION_SAFETY:
        return

    local_hosts = {"localhost", "127.0.0.1", "testserver"}
    local_cors = {"http://localhost:3000", "http://127.0.0.1:3000"}

    if settings.ALLOW_TEST_OTP_BYPASS:
        raise RuntimeError("ALLOW_TEST_OTP_BYPASS must be false in production")
    if settings.ENABLE_API_DOCS:
        raise RuntimeError("ENABLE_API_DOCS must be false in production")
    if set(settings.ALLOWED_HOSTS).issubset(local_hosts):
        raise RuntimeError("ALLOWED_HOSTS must include production domain(s)")
    if not settings.CORS_ORIGINS:
        raise RuntimeError("CORS_ORIGINS must be explicitly configured in production")
    if set(settings.CORS_ORIGINS).issubset(local_cors):
        raise RuntimeError("CORS_ORIGINS must include production origin(s)")
    if settings.FRONTEND_BASE_URL.startswith(("http://localhost", "http://127.0.0.1")):
        raise RuntimeError("FRONTEND_BASE_URL must be a production URL")
    if len(settings.SECRET_KEY or "") < 32 or "change-this-in-production" in settings.SECRET_KEY:
        raise RuntimeError("SECRET_KEY is unsafe for production")
    placeholder_db_markers = ("change_this_password", "user:password@", "localhost:5432/wezy_db")
    if any(marker in settings.DATABASE_URL for marker in placeholder_db_markers):
        raise RuntimeError("DATABASE_URL is using placeholder credentials")
    if settings.TELEMATICS_GO_WORKER_ENABLED and len((settings.INTERNAL_SERVICE_TOKEN or "").strip()) < 24:
        raise RuntimeError("INTERNAL_SERVICE_TOKEN must be set (>=24 chars) when TELEMATICS_GO_WORKER_ENABLED=true")
    if settings.FRAUD_COMPUTE_SERVICE_ENABLED and not (settings.FRAUD_COMPUTE_SERVICE_URL or "").strip():
        raise RuntimeError("FRAUD_COMPUTE_SERVICE_URL must be set when FRAUD_COMPUTE_SERVICE_ENABLED=true")
    if settings.AUTH_PROVIDER != "supabase":
        raise RuntimeError("AUTH_PROVIDER must be set to 'supabase' in production")
    if settings.PASSKEY_ENABLED:
        raise RuntimeError("PASSKEY_ENABLED must be false in production for Supabase-only auth mode")


# ── Lifespan ───────────────────────────────────────────────────────────────

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Unified startup: Laxman services + Hardened resilience."""
    scheduler_started = False
    mqtt_started = False
    request_audit_started = False
    background_runtime_initialized = False
    startup_without_db = False
    allow_start_without_db = bool(getattr(settings, "ALLOW_START_WITHOUT_DB", False))

    try:
        logger.info(
            "startup.settings",
            environment=settings.ENVIRONMENT,
            db_pool=settings.DB_POOL_SIZE,
            db_overflow=settings.DB_MAX_OVERFLOW,
            audit_logging=settings.AUDIT_REQUEST_LOGGING_ENABLED,
            gunicorn_workers=os.getenv("GUNICORN_WORKERS", "1"),
        )

        if settings.ENVIRONMENT == "test":
            yield
            return

        _validate_production_safety()

        # Database init
        if settings.DB_INIT_ON_STARTUP:
            try:
                logger.info("Running Alembic migrations...")
                from alembic.config import Config as AlembicConfig
                from alembic import command as alembic_command
                alembic_cfg = AlembicConfig("alembic.ini")
                alembic_command.upgrade(alembic_cfg, "head")
                logger.info("Alembic migrations complete.")
            except Exception:
                logger.exception("Alembic migration failed; aborting startup.")
                raise
        else:
            try:
                from app.db.session import init_db
                init_db(
                    create_tables=settings.AUTO_CREATE_TABLES,
                    seed_roles=settings.AUTO_SEED_ROLES,
                )
            except SQLAlchemyError as exc:
                if not allow_start_without_db:
                    raise
                startup_without_db = True
                logger.exception("db.unavailable_during_init.degraded_mode", error=str(exc))

        # Logistics compatibility backfill
        if settings.LOGISTICS_SCHEMA_AUTOPATCH_ENABLED and not startup_without_db:
            try:
                ensure_logistics_schema_compatibility()
            except SQLAlchemyError as exc:
                if not allow_start_without_db:
                    raise
                startup_without_db = True
                logger.exception("schema.logistics_compatibility_failed.degraded_mode", error=str(exc))

        # Logistics schema validation
        if settings.LOGISTICS_SCHEMA_CHECK_ENABLED and not startup_without_db:
            try:
                from app.db.logistics_schema_guard import validate_logistics_schema
                validate_logistics_schema(strict=settings.LOGISTICS_SCHEMA_STRICT)
            except SQLAlchemyError as exc:
                if not allow_start_without_db:
                    raise
                startup_without_db = True
                logger.exception("schema.validation_failed.degraded_mode", error=str(exc))

        # RBAC compatibility backfill
        if not startup_without_db:
            try:
                ensure_roles_schema_compatibility()
            except SQLAlchemyError as exc:
                if not allow_start_without_db:
                    raise
                startup_without_db = True
                logger.exception("schema.roles_compatibility_failed.degraded_mode", error=str(exc))

        # Startup diagnostics enforcement
        if not startup_without_db:
            StartupDiagnosticsService.enforce_required_dependencies()
        else:
            logger.warning(
                "Skipping strict startup dependency enforcement because app is in DB-degraded mode."
            )

        # Background runtime (leader election)
        background_runtime = await BackgroundRuntimeService.initialize()
        background_runtime_initialized = True

        # Scheduler
        if settings.RUN_BACKGROUND_TASKS and settings.SCHEDULER_ENABLED:
            if background_runtime.run_scheduler:
                try:
                    start_scheduler()
                    scheduler_started = True
                    logger.info("Background scheduler started.")
                except Exception:
                    logger.exception("Scheduler startup failed")
            else:
                logger.info(
                    "scheduler.disabled_for_process",
                    mode=background_runtime.mode,
                    reason=background_runtime.reason,
                )

        # MQTT
        if settings.RUN_BACKGROUND_TASKS and settings.MQTT_ENABLED:
            try:
                start_mqtt_service()
                mqtt_started = True
                logger.info("MQTT service started.")
            except Exception:
                logger.exception("MQTT startup failed")

        # Heartbeat
        if settings.RUN_BACKGROUND_TASKS:
            asyncio.create_task(heartbeat_task())

        # Audit queue
        if settings.AUDIT_REQUEST_LOGGING_ENABLED:
            await request_audit_queue.start()
            request_audit_started = True

        websocket_manager = None
        if settings.ORDER_WEBSOCKET_REALTIME_ENABLED:
            # Legacy websocket order fanout path. Supabase direct realtime is canonical.
            from app.services.websocket_service import manager as websocket_manager
            await websocket_manager.start_order_pubsub_listener(
                run_outbox_dispatch=background_runtime.run_outbox_dispatch
            )

        if startup_without_db:
            logger.warning(
                "App started WITHOUT database (ALLOW_START_WITHOUT_DB=true). "
                "DB endpoints return 503 until recovery."
            )

        yield

        # ── Shutdown ───────────────────────────────────────────────────────
        if websocket_manager is not None:
            await websocket_manager.stop_order_pubsub_listener()
        if scheduler_started:
            stop_scheduler()
        if mqtt_started:
            stop_mqtt_service()
        if request_audit_started:
            await request_audit_queue.stop()
        if background_runtime_initialized:
            await BackgroundRuntimeService.shutdown()

    except Exception:
        logger.exception("Fatal error during startup. Sleeping 10s to prevent crash loop.")
        await asyncio.sleep(10)
        raise


# ── App creation ───────────────────────────────────────────────────────────

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json" if settings.ENABLE_API_DOCS else None,
    docs_url="/docs" if settings.ENABLE_API_DOCS else None,
    redoc_url="/redoc" if settings.ENABLE_API_DOCS else None,
    lifespan=lifespan,
    # Disable 307 slash-redirects. Instead, every collection route is
    # mirrored to its slash/no-slash twin by
    # ``app.api.slash_mirror.mirror_trailing_slashes`` after all
    # routers are included. Reason: 307 redirects cost an extra round
    # trip and some HTTP clients drop Authorization headers on
    # redirect, breaking auth-gated endpoints in the wild.
    redirect_slashes=False,
)

# Static files
uploads_dir = Path("uploads")
uploads_dir.mkdir(parents=True, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=str(uploads_dir)), name="uploads")

# ── Middleware stack ───────────────────────────────────────────────────────
# Order matters: last-added runs first.

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
add_exception_handlers(app)


@app.exception_handler(OperationalError)
async def operational_db_error_handler(_request, exc: OperationalError):
    logger.warning("database.operational_error", error=str(exc))
    return JSONResponse(
        status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
        content={"detail": "Database is temporarily unavailable"},
    )


app.add_middleware(RBACMiddleware)
app.add_middleware(GZipMiddleware, minimum_size=1000)
app.add_middleware(SecureHeadersMiddleware)
app.add_middleware(ServerTimingMiddleware)

if settings.AUDIT_REQUEST_LOGGING_ENABLED:
    app.add_middleware(AuditMiddleware)

# TrustedHost
always_allowed_hosts = {"localhost", "127.0.0.1", "testserver"}
derived_public_hosts: set[str] = set()
for candidate in (settings.API_PUBLIC_BASE_URL, settings.MEDIA_BASE_URL):
    value = (candidate or "").strip()
    if not value:
        continue
    parsed = urlsplit(value)
    host = (parsed.hostname or "").strip().lower()
    if host:
        derived_public_hosts.add(host)
trusted_host_allowlist = sorted(
    set(settings.ALLOWED_HOSTS) | always_allowed_hosts | derived_public_hosts
)
if settings.ENABLE_TRUSTED_HOST_MIDDLEWARE:
    app.add_middleware(TrustedHostMiddleware, allowed_hosts=trusted_host_allowlist)

app.add_middleware(AnomalyLoggingMiddleware)
app.add_middleware(RequestLoggingMiddleware)
app.add_middleware(TrustedProxyHeadersMiddleware)
app.add_middleware(ProxyHostRewriteMiddleware)
app.add_middleware(CORSErrorMiddleware)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_origin_regex=settings.cors_allow_origin_regex,
    allow_credentials=True,
    allow_methods=CORS_ALLOWED_METHODS,
    allow_headers=["Authorization", "Content-Type", "Accept", "X-Request-ID"],
    expose_headers=["X-Request-ID", "X-RateLimit-Limit", "X-RateLimit-Remaining"],
)

# Outermost middleware — short-circuits real CORS preflight (OPTIONS with
# ``access-control-request-method``) at the middleware layer so it never
# reaches the router. Replaces the prior catch-all
# ``@app.options("/{full_path:path}")`` route which was producing spurious
# 405s for non-OPTIONS requests by shadowing trailing-slash redirects.
app.add_middleware(CORSPreflightMiddleware)

class SafeDisconnectMiddleware:
    """
    Catches genuine client-disconnect exceptions from the anyio/starlette stack
    and sends a 499 instead of letting uvicorn log 'Exception in ASGI application'.
    
    IMPORTANT: every suppressed exception is logged to stderr so it appears in
    docker logs for debugging.
    """
    # Only genuine disconnect markers — NOT generic errors
    _DISCONNECT_MARKERS = (
        "anyio.EndOfStream",
        "anyio.WouldBlock",
    )

    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        try:
            await self.app(scope, receive, send)
        except BaseException as exc:
            import traceback as _tb
            import sys

            tb_str = "".join(_tb.format_exception(type(exc), exc, exc.__traceback__))
            is_disconnect = any(marker in tb_str for marker in self._DISCONNECT_MARKERS)

            path = scope.get("path", "?")
            method = scope.get("method", "?")

            if is_disconnect:
                # Log but suppress — this is a client disconnect, not a bug.
                print(
                    f"[DISCONNECT SUPPRESSED] {method} {path}: {type(exc).__name__}: {exc}",
                    file=sys.stderr,
                    flush=True,
                )
                return

            # NOT a disconnect — re-raise so the real error propagates.
            raise

app.add_middleware(SafeDisconnectMiddleware)

# NOTE: CORS preflight is handled by ``CORSPreflightMiddleware`` above,
# registered in the middleware stack near ``CORSMiddleware``. The previous
# route-based ``@app.options("/{full_path:path}")`` catch-all was removed
# because it shadowed FastAPI's trailing-slash redirect, causing any
# ``GET /collection`` (without trailing slash) to return 405 with
# ``route_name=global_options_handler`` in the logs.


# ── System & Health endpoints ──────────────────────────────────────────────

@app.get("/live", tags=["System"])
def live_check():
    return {
        "status": "ok",
        "service": "api",
        "environment": settings.ENVIRONMENT,
        "version": settings.APP_VERSION,
    }


def _readiness_payload() -> tuple[dict[str, str], bool]:
    from sqlalchemy import text
    db_ok = redis_ok = False
    mongo_ok = None
    mongo_configured = bool(
        settings.MONGODB_URL and settings.MONGODB_URL != "mongodb://localhost:27017"
    )
    try:
        from app.db.session import SessionLocal
        with SessionLocal() as db:
            db.execute(text("SELECT 1"))
            db_ok = True
    except Exception as e:
        logger.error("readiness.db_failure", error=str(e))
    try:
        import redis as _redis
        # Reuse a module-level connection pool so /health doesn't create
        # a new TCP connection per call (Traefik calls every 20s).
        _health_redis_pool = getattr(_readiness_payload, "_redis_pool", None)
        if _health_redis_pool is None:
            _health_redis_pool = _redis.ConnectionPool.from_url(
                settings.REDIS_URL,
                socket_connect_timeout=2,
                socket_timeout=2,
                max_connections=2,
            )
            _readiness_payload._redis_pool = _health_redis_pool  # type: ignore[attr-defined]
        r = _redis.Redis(connection_pool=_health_redis_pool)
        r.ping()
        redis_ok = True
    except Exception as e:
        logger.error("readiness.redis_failure", error=str(e))
    if mongo_configured:
        try:
            from pymongo import MongoClient
            client = MongoClient(
                settings.MONGODB_URL,
                serverSelectionTimeoutMS=1000,
                connectTimeoutMS=1000,
                socketTimeoutMS=1000,
            )
            client.admin.command("ping")
            mongo_ok = True
        except Exception as e:
            logger.error("readiness.mongodb_failure", error=str(e))

    dependencies = {
        "database": "online" if db_ok else "offline",
        "redis": "online" if redis_ok else "offline",
        "mongodb": "online" if mongo_ok else ("not_configured" if mongo_ok is None else "offline"),
    }
    ready = db_ok and redis_ok and (mongo_ok is None or mongo_ok)
    return dependencies, ready


@app.get("/health", tags=["System"])
def health_check():
    dependencies, ready = _readiness_payload()
    payload = {
        "status": "ok" if ready else "degraded",
        **dependencies,
        "environment": settings.ENVIRONMENT,
        "version": settings.APP_VERSION,
    }
    if ready:
        return payload
    return JSONResponse(status_code=503, content=payload)


@app.get("/ready", tags=["System"])
def readiness_check():
    report = StartupDiagnosticsService.collect_report()
    if report.get("required_failures"):
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail={
                "status": "not_ready",
                "required_failures": report.get("required_failures", []),
                "components": {
                    name: component.get("status")
                    for name, component in (report.get("components") or {}).items()
                },
            },
        )
    deps_info, _ = _readiness_payload()
    return {
        "status": "ready",
        "dependencies": deps_info,
        "components": {
            name: component.get("status")
            for name, component in (report.get("components") or {}).items()
        },
    }


@app.get("/", tags=["System"])
async def root():
    return {"message": f"Welcome to {settings.PROJECT_NAME} API", "version": settings.APP_VERSION}


# ── Android asset links (from Hardened) ────────────────────────────────────

def _android_assetlinks_payload() -> list[dict]:
    if not settings.PASSKEY_ENABLED:
        return []
    package_name = (settings.PASSKEY_ANDROID_PACKAGE_NAME or "").strip()
    fingerprints = [
        str(fp).strip()
        for fp in settings.PASSKEY_ANDROID_SHA256_CERT_FINGERPRINTS
        if str(fp).strip()
    ]
    relations = [
        str(r).strip()
        for r in settings.PASSKEY_ANDROID_RELATIONS
        if str(r).strip()
    ] or [
        "delegate_permission/common.handle_all_urls",
        "delegate_permission/common.get_login_creds",
    ]
    if not package_name or not fingerprints:
        return []
    return [{
        "relation": relations,
        "target": {
            "namespace": "android_app",
            "package_name": package_name,
            "sha256_cert_fingerprints": fingerprints,
        },
    }]


@app.api_route("/.well-known/assetlinks.json", methods=["GET", "HEAD"], include_in_schema=False)
async def android_assetlinks(request: Request):
    if request.method == "HEAD":
        return Response(media_type="application/json")
    return JSONResponse(
        content=_android_assetlinks_payload(),
        media_type="application/json",
        headers={"Cache-Control": "public, max-age=300"},
    )


# ══════════════════════════════════════════════════════════════════════════
# ROUTE REGISTRATION
# ══════════════════════════════════════════════════════════════════════════

v1_str = settings.API_V1_STR

# ── Auth Gateway (Supabase-only) ───────────────────────────────────────────
app.include_router(auth_gateway.router, prefix=f"{v1_str}/auth", tags=["Auth Gateway"])
app.include_router(
    auth_tombstones.customer_auth_router,
    prefix=f"{v1_str}/customers/auth",
    tags=["Customer Auth (Legacy)"],
)
app.include_router(
    auth_tombstones.sessions_router,
    prefix=f"{v1_str}/sessions",
    tags=["Sessions (Legacy)"],
)
app.include_router(customer_dashboard.router, prefix=f"{v1_str}/customers/me/dashboard", tags=["Customer Dashboard"])
app.include_router(customer_reservations.router, prefix=f"{v1_str}/customers/me", tags=["Customer Reservations"])
app.include_router(
    customer_reservations.router,
    prefix=f"{v1_str}",
    tags=["Customer Reservations (Legacy)"],
    include_in_schema=False,
)

# ── Core Entities ──────────────────────────────────────────────────────────
app.include_router(users.router, prefix=f"{v1_str}/users", tags=["Users"])
app.include_router(kyc.router, prefix=f"{v1_str}/kyc", tags=["KYC"])
app.include_router(kyc.router, prefix=v1_str, tags=["KYC (Legacy)"], include_in_schema=False)
app.include_router(stations.router, prefix=f"{v1_str}/stations", tags=["Stations"])
app.include_router(batteries.router, prefix=f"{v1_str}/batteries", tags=["Batteries"])
app.include_router(battery_catalog.router, prefix=f"{v1_str}/batteries", tags=["Battery Catalog"])
app.include_router(rentals_canonical.router, prefix=f"{v1_str}/rentals", tags=["Rentals"])
app.include_router(bookings.router, prefix=f"{v1_str}/bookings", tags=["Bookings"])
app.include_router(vehicles.router, prefix=f"{v1_str}/vehicles", tags=["Vehicles"])
app.include_router(swaps.router, prefix=f"{v1_str}/swaps", tags=["Swaps"])
app.include_router(maintenance.router, prefix=f"{v1_str}/maintenance", tags=["Maintenance"])

# ── Finance ────────────────────────────────────────────────────────────────
app.include_router(wallet.router, prefix=f"{v1_str}/wallet", tags=["Wallet"])
app.include_router(payments.router, prefix=f"{v1_str}/payments", tags=["Payments"])
app.include_router(notifications_enhanced.router, prefix=f"{v1_str}/notifications", tags=["Notifications"])
app.include_router(support.router, prefix=f"{v1_str}/support", tags=["Support"])
app.include_router(favorites.router, prefix=f"{v1_str}/favorites", tags=["Favorites"])
app.include_router(transactions.router, prefix=f"{v1_str}/transactions", tags=["Transactions"])
app.include_router(settlements.router, prefix=f"{v1_str}/settlements", tags=["Settlements"])

# ── Enhanced endpoints (from Hardened) ─────────────────────────────────────
app.include_router(wallet_enhanced.router, prefix=f"{v1_str}/wallet", tags=["Wallet Enhanced"])
app.include_router(support_enhanced.router, prefix=f"{v1_str}/support", tags=["Support Enhanced"])

# ── Utility & Info ─────────────────────────────────────────────────────────
app.include_router(promo.router, prefix=f"{v1_str}/promo", tags=["Promo"])
app.include_router(faqs.router, prefix=f"{v1_str}/faqs", tags=["FAQs"])
app.include_router(catalog.router, prefix=f"{v1_str}/catalog", tags=["Catalog"])
app.include_router(i18n.router, prefix=f"{v1_str}/i18n", tags=["i18n"])
app.include_router(screens.router, prefix=f"{v1_str}/screens", tags=["UI Config"])
app.include_router(utils.router, prefix=f"{v1_str}/utils", tags=["Utilities"])

# ── Analytics ──────────────────────────────────────────────────────────────
app.include_router(analytics.router, prefix=f"{v1_str}/analytics", tags=["Analytics"])
app.include_router(station_monitoring.router, prefix=f"{v1_str}/station-monitoring", tags=["Station Monitoring"])

# ── RBAC ───────────────────────────────────────────────────────────────────
admin_api = f"{v1_str}/admin"
admin_deps = [Depends(deps.get_current_active_admin)]

app.include_router(rbac.router, prefix=f"{v1_str}/rbac", tags=["RBAC"])
app.include_router(rbac_tombstones.legacy_roles_router, prefix=f"{v1_str}/roles", tags=["RBAC (Legacy)"])
app.include_router(rbac_tombstones.legacy_menus_router, prefix=f"{v1_str}/menus", tags=["RBAC (Legacy)"])
app.include_router(
    rbac_tombstones.legacy_role_rights_router,
    prefix=f"{v1_str}/role-rights",
    tags=["RBAC (Legacy)"],
)
app.include_router(security.router, prefix=f"{v1_str}/admin/security", tags=["Admin Security"], dependencies=admin_deps)

# ── Admin ──────────────────────────────────────────────────────────────────
app.include_router(global_admin_router, prefix=admin_api, tags=["Admin: Core"], dependencies=admin_deps)
app.include_router(dashboard_router, prefix=f"{v1_str}/dashboard", tags=["Admin: Dashboard"], dependencies=admin_deps)
app.include_router(admin_users.router, prefix=f"{admin_api}/users", tags=["Admin: Users Actions"], dependencies=admin_deps)
app.include_router(admin_kyc.router, prefix=f"{admin_api}/kyc", tags=["Admin: KYC"], dependencies=admin_deps)
app.include_router(admin_stations.router, prefix=f"{admin_api}/stations", tags=["Admin: Stations"], dependencies=admin_deps)
app.include_router(admin_invoices.router, prefix=f"{admin_api}/invoices", tags=["Admin: Invoices"], dependencies=admin_deps)
app.include_router(admin_analytics.router, prefix=f"{admin_api}/analytics", tags=["Admin: Analytics"], dependencies=admin_deps)
app.include_router(admin_audit.router, prefix=f"{admin_api}/audit-logs", tags=["Admin: Audit"], dependencies=admin_deps)
app.include_router(
    rbac_tombstones.legacy_admin_rbac_router,
    prefix=f"{admin_api}/rbac",
    tags=["Admin: RBAC (Legacy)"],
)
app.include_router(admin_legal.router, prefix=f"{admin_api}/legal", tags=["Admin: Legal"], dependencies=admin_deps)
app.include_router(admin_banners.router, prefix=f"{admin_api}/banners", tags=["Admin: Banners"], dependencies=admin_deps)
app.include_router(admin_blogs.router, prefix=f"{admin_api}/blogs", tags=["Admin: Blogs"], dependencies=admin_deps)
app.include_router(admin_dealers.router, prefix=f"{admin_api}/dealers", tags=["Admin: Dealers"], dependencies=admin_deps)
app.include_router(admin_financial_reports.router, prefix=f"{admin_api}/financial-reports", tags=["Admin: Financial Reports"], dependencies=admin_deps)
app.include_router(payments.admin_router, prefix=f"{admin_api}/payments", tags=["Admin: Payments"], dependencies=admin_deps)
app.include_router(notifications_enhanced.admin_router, prefix=f"{admin_api}/notifications", tags=["Admin: Notifications"], dependencies=admin_deps)

# ── Dealer ─────────────────────────────────────────────────────────────────
dealer_api = f"{v1_str}/dealers"
dealer_profile_deps = [Depends(deps.get_current_dealer_scope_user)]
dealer_scope_deps = [Depends(deps.get_current_dealer_scope_user)]

app.include_router(
    auth_tombstones.dealer_auth_router,
    prefix=f"{dealer_api}/auth",
    tags=["Dealer: Auth (Legacy)"],
)
app.include_router(dealers.router, prefix=f"{v1_str}/dealers", tags=["Dealer: Profile"], dependencies=dealer_profile_deps)
app.include_router(dealer_stations.router, prefix=f"{dealer_api}/stations", tags=["Dealer: Stations"], dependencies=dealer_scope_deps)
app.include_router(dealer_portal_dashboard.router, prefix=f"{dealer_api}/me", tags=["Dealer: Dashboard"], dependencies=dealer_scope_deps)
app.include_router(dealer_portal_tickets.router, prefix=f"{dealer_api}/me/tickets", tags=["Dealer: Tickets"], dependencies=dealer_scope_deps)
app.include_router(
    rbac_tombstones.legacy_dealer_roles_router,
    prefix=f"{dealer_api}/me/roles",
    tags=["Dealer: Roles (Legacy)"],
)
app.include_router(dealer_portal_users.router, prefix=f"{dealer_api}/me/team", tags=["Dealer: Users"], dependencies=dealer_scope_deps)
app.include_router(dealer_portal_settings.router, prefix=f"{dealer_api}/me/settings", tags=["Dealer: Settings"], dependencies=dealer_scope_deps)
app.include_router(dealer_portal_customers.router, prefix=f"{dealer_api}/me/customers", tags=["Dealer: Customers"], dependencies=dealer_scope_deps)
app.include_router(dealer_analytics.router, prefix=f"{dealer_api}/me/analytics", tags=["Dealer: Analytics"], dependencies=dealer_scope_deps)
app.include_router(dealer_campaigns.router, prefix=f"{dealer_api}/me/campaigns", tags=["Dealer: Campaigns"], dependencies=dealer_scope_deps)
app.include_router(dealer_onboarding.router, prefix=f"{dealer_api}/me/onboarding", tags=["Dealer: Onboarding"], dependencies=dealer_scope_deps)
app.include_router(dealer_portal_inventory.router, prefix=f"{dealer_api}/me", tags=["Dealer: Inventory"], dependencies=dealer_scope_deps)

# ── Logistics ──────────────────────────────────────────────────────────────
app.include_router(logistics.router, prefix=f"{v1_str}/logistics", tags=["Logistics"])
app.include_router(deliveries_canonical.router, prefix=f"{v1_str}/deliveries", tags=["Logistics Orders"])
if settings.ORDER_WEBSOCKET_REALTIME_ENABLED:
    from app.api.v1 import orders_realtime
    app.include_router(orders_realtime.router, prefix=f"{v1_str}/deliveries", tags=["Orders Realtime (Legacy)"])
app.include_router(drivers.router, prefix=f"{v1_str}/drivers", tags=["Fleet Drivers"])
app.include_router(manifests.router, prefix=f"{v1_str}/manifests", tags=["Manifests"])
app.include_router(warehouse_structure.router, prefix=f"{v1_str}/warehouses/structure", tags=["Warehouse Structure"])
app.include_router(warehouse_tombstones.router, prefix=f"{v1_str}/warehouse", tags=["Warehouse (Legacy)"])
app.include_router(routes.router, prefix=f"{v1_str}/routes", tags=["Route Optimization"])
app.include_router(stock.router, prefix=f"{v1_str}/stock", tags=["Stock"])

# ── IoT & Telematics ──────────────────────────────────────────────────────
app.include_router(telematics.router, prefix=f"{v1_str}/telematics", tags=["Telematics"])
app.include_router(iot.router, prefix=f"{v1_str}/iot", tags=["IoT"])

# ── Other ──────────────────────────────────────────────────────────────────
app.include_router(fraud.router, prefix=f"{v1_str}/fraud", tags=["Fraud Detection"])
app.include_router(branches.router, prefix=f"{v1_str}/branches", tags=["Branches"])
app.include_router(organizations.router, prefix=f"{v1_str}/organizations", tags=["Organizations"])
app.include_router(warehouses.router, prefix=f"{v1_str}/warehouses", tags=["Warehouses"])
app.include_router(locations.router, prefix=f"{v1_str}/locations", tags=["Locations Hierarchy"])
app.include_router(location.router, prefix=f"{v1_str}/locations/rentals", tags=["Location"])
app.include_router(inventory.router, prefix=f"{v1_str}/inventory", tags=["Inventory"])
app.include_router(ml.router, prefix=f"{v1_str}/ml", tags=["Machine Learning"])
app.include_router(audit.router, prefix=f"{v1_str}/audit", tags=["Audit Logs"])
app.include_router(system.router, prefix=f"{v1_str}/system", tags=["System"])
app.include_router(system.router, prefix=v1_str, tags=["System (Legacy)"], include_in_schema=False)

# ── Webhooks & Internal ───────────────────────────────────────────────────
app.include_router(razorpay_webhooks.router, prefix=f"{v1_str}/webhooks", tags=["Webhooks"])
app.include_router(internal_hotspots.router, prefix="/api/internal/hotspots", tags=["Internal"])


# ── Trailing-slash mirroring ───────────────────────────────────────────────
# Register every route under both its slash and no-slash form so clients
# calling ``GET /foo`` or ``GET /foo/`` both hit the same handler without
# a 307 redirect. Must run AFTER all ``include_router`` calls.
#
# Guarded: any failure inside the mirror helper MUST NOT block worker
# boot. If it blows up, the app still serves traffic — just without the
# mirror (FastAPI's default redirect_slashes fallback is not available
# because we set it to False above, so un-mirrored collection endpoints
# will 404 on the no-slash form, but the canonical slash form still
# works and the container stays up instead of restart-looping).
try:
    from app.api.slash_mirror import mirror_trailing_slashes  # noqa: E402
    mirror_trailing_slashes(app)
except Exception as _slash_mirror_exc:  # pragma: no cover — defensive
    logger.exception(
        "routing.slash_mirror_failed",
        error=str(_slash_mirror_exc),
    )
