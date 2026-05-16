import re
import socket
import time

from sqlalchemy import event, inspect, pool, text
from sqlalchemy.engine import make_url
from sqlalchemy.orm import Session as SASession, with_loader_criteria
from sqlmodel import Session, create_engine

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)


def _resolve_ipv4_hostaddr(database_url: str) -> str | None:
    parsed_url = make_url(database_url)
    host = parsed_url.host
    if not host:
        return None
    port = parsed_url.port or 5432
    try:
        candidates = socket.getaddrinfo(
            host,
            port,
            family=socket.AF_INET,
            type=socket.SOCK_STREAM,
        )
    except Exception as exc:
        logger.warning("db.hostaddr.resolve_failed", host=host, error=str(exc))
        return None

    for _, _, _, _, sockaddr in candidates:
        if sockaddr and sockaddr[0]:
            return str(sockaddr[0])
    return None


def _build_engine():
    """
    Build the SQLAlchemy engine with the best pooling strategy:
    - SQLite: NullPool + WAL mode (for dev / APScheduler)
    - PostgreSQL: QueuePool with LIFO, connect timeout, optional SSL
    """
    database_url = settings.DATABASE_URL
    engine_kwargs = {
        "echo": settings.SQLALCHEMY_ECHO,
        "pool_pre_ping": settings.DB_POOL_PRE_PING,
    }

    if database_url.startswith("sqlite"):
        engine_kwargs["connect_args"] = {"check_same_thread": False, "timeout": 30}
        engine_kwargs["poolclass"] = pool.NullPool
    else:
        connect_args = {
            "connect_timeout": settings.DATABASE_CONNECT_TIMEOUT_SECONDS,
        }
        if settings.DATABASE_SSL_MODE:
            connect_args["sslmode"] = settings.DATABASE_SSL_MODE
        parsed_url = make_url(database_url)
        if parsed_url.drivername.startswith("postgresql"):
            configured_hostaddr = (settings.DATABASE_HOSTADDR or "").strip()
            if configured_hostaddr:
                connect_args["hostaddr"] = configured_hostaddr
            elif settings.DATABASE_PREFER_IPV4:
                resolved_hostaddr = _resolve_ipv4_hostaddr(database_url)
                if resolved_hostaddr:
                    connect_args["hostaddr"] = resolved_hostaddr

        engine_kwargs.update({
            "pool_size": settings.DB_POOL_SIZE,
            "max_overflow": settings.DB_MAX_OVERFLOW,
            "pool_timeout": settings.DB_POOL_TIMEOUT,
            "pool_recycle": settings.DB_POOL_RECYCLE,
            "pool_use_lifo": settings.DB_POOL_USE_LIFO,
            "connect_args": connect_args,
        })

    return create_engine(database_url, **engine_kwargs)


engine = _build_engine()


@event.listens_for(SASession, "do_orm_execute")
def _enforce_soft_delete_filters(execute_state) -> None:
    """
    Apply default soft-delete predicates at ORM execution time so callers
    cannot accidentally return deleted records.
    Opt-out per query via execution option `include_deleted=True`.
    """
    if not settings.SOFT_DELETE_GLOBAL_FILTER_ENABLED:
        return
    if not execute_state.is_select:
        return
    if execute_state.execution_options.get("include_deleted"):
        return

    from app.models.station import Station
    from app.models.user import User

    execute_state.statement = execute_state.statement.options(
        with_loader_criteria(User, lambda cls: cls.is_deleted == False, include_aliases=True),  # noqa: E712
        with_loader_criteria(Station, lambda cls: cls.is_deleted == False, include_aliases=True),  # noqa: E712
    )


# ── Compatibility schema patching ──────────────────────────────────────────

_LOGISTICS_COMPAT_COLUMNS: dict[str, dict[str, dict[str, str]]] = {
    "logistics_orders": {
        "status": {
            "postgresql": "VARCHAR NOT NULL DEFAULT 'pending'",
            "sqlite": "TEXT NOT NULL DEFAULT 'pending'",
        },
        "priority": {
            "postgresql": "VARCHAR NOT NULL DEFAULT 'normal'",
            "sqlite": "TEXT NOT NULL DEFAULT 'normal'",
        },
        "units": {
            "postgresql": "INTEGER NOT NULL DEFAULT 1",
            "sqlite": "INTEGER NOT NULL DEFAULT 1",
        },
        "destination": {
            "postgresql": "VARCHAR NOT NULL DEFAULT ''",
            "sqlite": "TEXT NOT NULL DEFAULT ''",
        },
        "latitude": {
            "postgresql": "DOUBLE PRECISION",
            "sqlite": "REAL",
        },
        "longitude": {
            "postgresql": "DOUBLE PRECISION",
            "sqlite": "REAL",
        },
        "notes": {
            "postgresql": "TEXT",
            "sqlite": "TEXT",
        },
        "customer_name": {
            "postgresql": "VARCHAR NOT NULL DEFAULT 'Walk-in Customer'",
            "sqlite": "TEXT NOT NULL DEFAULT 'Walk-in Customer'",
        },
        "customer_phone": {
            "postgresql": "VARCHAR",
            "sqlite": "TEXT",
        },
        "total_value": {
            "postgresql": "NUMERIC(12,2) NOT NULL DEFAULT 0",
            "sqlite": "NUMERIC NOT NULL DEFAULT 0",
        },
        "tracking_number": {
            "postgresql": "VARCHAR",
            "sqlite": "TEXT",
        },
        "assigned_battery_ids": {
            "postgresql": "TEXT",
            "sqlite": "TEXT",
        },
        "assigned_driver_id": {
            "postgresql": "INTEGER",
            "sqlite": "INTEGER",
        },
        "order_date": {
            "postgresql": "TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()",
            "sqlite": "TEXT",
        },
        "estimated_delivery": {
            "postgresql": "TIMESTAMP WITHOUT TIME ZONE",
            "sqlite": "TEXT",
        },
        "dispatch_date": {
            "postgresql": "TIMESTAMP WITHOUT TIME ZONE",
            "sqlite": "TEXT",
        },
        "delivered_at": {
            "postgresql": "TIMESTAMP WITHOUT TIME ZONE",
            "sqlite": "TEXT",
        },
        "updated_at": {
            "postgresql": "TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()",
            "sqlite": "TEXT",
        },
        "proof_of_delivery_url": {
            "postgresql": "VARCHAR",
            "sqlite": "TEXT",
        },
        "proof_of_delivery_notes": {
            "postgresql": "TEXT",
            "sqlite": "TEXT",
        },
        "proof_of_delivery_captured_at": {
            "postgresql": "TIMESTAMP WITHOUT TIME ZONE",
            "sqlite": "TEXT",
        },
        "proof_of_delivery_signature_url": {
            "postgresql": "VARCHAR",
            "sqlite": "TEXT",
        },
        "recipient_name": {
            "postgresql": "VARCHAR",
            "sqlite": "TEXT",
        },
        "failure_reason": {
            "postgresql": "TEXT",
            "sqlite": "TEXT",
        },
        "scheduled_slot_start": {
            "postgresql": "TIMESTAMP WITHOUT TIME ZONE",
            "sqlite": "TEXT",
        },
        "scheduled_slot_end": {
            "postgresql": "TIMESTAMP WITHOUT TIME ZONE",
            "sqlite": "TEXT",
        },
        "is_confirmed": {
            "postgresql": "BOOLEAN NOT NULL DEFAULT FALSE",
            "sqlite": "INTEGER NOT NULL DEFAULT 0",
        },
        "confirmation_sent_at": {
            "postgresql": "TIMESTAMP WITHOUT TIME ZONE",
            "sqlite": "TEXT",
        },
        "type": {
            "postgresql": "VARCHAR NOT NULL DEFAULT 'delivery'",
            "sqlite": "TEXT NOT NULL DEFAULT 'delivery'",
        },
        "original_order_id": {
            "postgresql": "VARCHAR",
            "sqlite": "TEXT",
        },
        "refund_status": {
            "postgresql": "VARCHAR NOT NULL DEFAULT 'none'",
            "sqlite": "TEXT NOT NULL DEFAULT 'none'",
        },
    },
    "logistics_order_batteries": {
        "order_id": {
            "postgresql": "VARCHAR",
            "sqlite": "TEXT",
        },
        "battery_id": {
            "postgresql": "VARCHAR",
            "sqlite": "TEXT",
        },
        "battery_pk": {
            "postgresql": "INTEGER",
            "sqlite": "INTEGER",
        },
        "created_at": {
            "postgresql": "TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()",
            "sqlite": "TEXT",
        },
    },
    "inventory_transfers": {
        "from_location_type": {
            "postgresql": "VARCHAR NOT NULL DEFAULT 'warehouse'",
            "sqlite": "TEXT NOT NULL DEFAULT 'warehouse'",
        },
        "from_location_id": {
            "postgresql": "INTEGER NOT NULL DEFAULT 0",
            "sqlite": "INTEGER NOT NULL DEFAULT 0",
        },
        "to_location_type": {
            "postgresql": "VARCHAR NOT NULL DEFAULT 'station'",
            "sqlite": "TEXT NOT NULL DEFAULT 'station'",
        },
        "to_location_id": {
            "postgresql": "INTEGER NOT NULL DEFAULT 0",
            "sqlite": "INTEGER NOT NULL DEFAULT 0",
        },
        "driver_id": {
            "postgresql": "INTEGER",
            "sqlite": "INTEGER",
        },
        "items": {
            "postgresql": "TEXT NOT NULL DEFAULT '[]'",
            "sqlite": "TEXT NOT NULL DEFAULT '[]'",
        },
        "status": {
            "postgresql": "VARCHAR NOT NULL DEFAULT 'pending'",
            "sqlite": "TEXT NOT NULL DEFAULT 'pending'",
        },
        "created_at": {
            "postgresql": "TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()",
            "sqlite": "TEXT",
        },
        "updated_at": {
            "postgresql": "TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()",
            "sqlite": "TEXT",
        },
        "completed_at": {
            "postgresql": "TIMESTAMP WITHOUT TIME ZONE",
            "sqlite": "TEXT",
        },
    },
    "inventory_transfer_items": {
        "transfer_id": {
            "postgresql": "INTEGER NOT NULL DEFAULT 0",
            "sqlite": "INTEGER NOT NULL DEFAULT 0",
        },
        "battery_id": {
            "postgresql": "VARCHAR",
            "sqlite": "TEXT",
        },
        "battery_pk": {
            "postgresql": "INTEGER",
            "sqlite": "INTEGER",
        },
        "created_at": {
            "postgresql": "TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()",
            "sqlite": "TEXT",
        },
    },
    "stock_discrepancies": {
        "location_type": {
            "postgresql": "VARCHAR NOT NULL DEFAULT 'warehouse'",
            "sqlite": "TEXT NOT NULL DEFAULT 'warehouse'",
        },
        "location_id": {
            "postgresql": "INTEGER NOT NULL DEFAULT 0",
            "sqlite": "INTEGER NOT NULL DEFAULT 0",
        },
        "system_count": {
            "postgresql": "INTEGER NOT NULL DEFAULT 0",
            "sqlite": "INTEGER NOT NULL DEFAULT 0",
        },
        "physical_count": {
            "postgresql": "INTEGER NOT NULL DEFAULT 0",
            "sqlite": "INTEGER NOT NULL DEFAULT 0",
        },
        "missing_items": {
            "postgresql": "TEXT",
            "sqlite": "TEXT",
        },
        "extra_items": {
            "postgresql": "TEXT",
            "sqlite": "TEXT",
        },
        "notes": {
            "postgresql": "TEXT",
            "sqlite": "TEXT",
        },
        "status": {
            "postgresql": "VARCHAR NOT NULL DEFAULT 'open'",
            "sqlite": "TEXT NOT NULL DEFAULT 'open'",
        },
        "reported_by_id": {
            "postgresql": "INTEGER",
            "sqlite": "INTEGER",
        },
        "created_at": {
            "postgresql": "TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()",
            "sqlite": "TEXT",
        },
    },
    "manifests": {
        "source": {
            "postgresql": "VARCHAR NOT NULL DEFAULT ''",
            "sqlite": "TEXT NOT NULL DEFAULT ''",
        },
        "date": {
            "postgresql": "TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()",
            "sqlite": "TEXT",
        },
        "status": {
            "postgresql": "VARCHAR NOT NULL DEFAULT 'In Transit'",
            "sqlite": "TEXT NOT NULL DEFAULT 'In Transit'",
        },
        "created_at": {
            "postgresql": "TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()",
            "sqlite": "TEXT",
        },
    },
    "manifest_items": {
        "manifest_id": {
            "postgresql": "VARCHAR",
            "sqlite": "TEXT",
        },
        "battery_id": {
            "postgresql": "VARCHAR",
            "sqlite": "TEXT",
        },
        "battery_table_id": {
            "postgresql": "INTEGER",
            "sqlite": "INTEGER",
        },
        "type": {
            "postgresql": "VARCHAR NOT NULL DEFAULT ''",
            "sqlite": "TEXT NOT NULL DEFAULT ''",
        },
        "status": {
            "postgresql": "VARCHAR NOT NULL DEFAULT 'pending'",
            "sqlite": "TEXT NOT NULL DEFAULT 'pending'",
        },
    },
    "idempotency_keys": {
        "idempotency_key": {
            "postgresql": "VARCHAR",
            "sqlite": "TEXT",
        },
        "request_method": {
            "postgresql": "VARCHAR",
            "sqlite": "TEXT",
        },
        "request_path": {
            "postgresql": "VARCHAR",
            "sqlite": "TEXT",
        },
        "request_fingerprint": {
            "postgresql": "VARCHAR",
            "sqlite": "TEXT",
        },
        "response_status_code": {
            "postgresql": "INTEGER",
            "sqlite": "INTEGER",
        },
        "response_payload": {
            "postgresql": "TEXT",
            "sqlite": "TEXT",
        },
        "created_at": {
            "postgresql": "TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()",
            "sqlite": "TEXT",
        },
        "expires_at": {
            "postgresql": "TIMESTAMP WITHOUT TIME ZONE",
            "sqlite": "TEXT",
        },
    },
}


def _compat_driver_key(driver_name: str) -> str | None:
    if driver_name.startswith("postgresql"):
        return "postgresql"
    if driver_name.startswith("sqlite"):
        return "sqlite"
    return None

def ensure_roles_schema_compatibility() -> None:
    """
    Backfill RBAC role columns if migrations were skipped.
    This keeps auth endpoints alive on partially-migrated databases.
    """
    parsed_url = make_url(settings.DATABASE_URL)
    driver = parsed_url.drivername
    if not (driver.startswith("postgresql") or driver.startswith("sqlite")):
        return

    with engine.begin() as conn:
        inspector = inspect(conn)
        if not inspector.has_table("roles"):
            return

        cols = {col["name"] for col in inspector.get_columns("roles")}
        statements: list[str] = []
        patched_columns: list[str] = []

        if driver.startswith("postgresql"):
            if "is_custom_role" not in cols:
                statements.append(
                    "ALTER TABLE roles ADD COLUMN IF NOT EXISTS is_custom_role BOOLEAN NOT NULL DEFAULT FALSE"
                )
                patched_columns.append("is_custom_role")
            if "scope_owner" not in cols:
                statements.append(
                    "ALTER TABLE roles ADD COLUMN IF NOT EXISTS scope_owner VARCHAR NOT NULL DEFAULT 'global'"
                )
                patched_columns.append("scope_owner")
        else:  # sqlite
            if "is_custom_role" not in cols:
                statements.append(
                    "ALTER TABLE roles ADD COLUMN is_custom_role BOOLEAN NOT NULL DEFAULT 0"
                )
                patched_columns.append("is_custom_role")
            if "scope_owner" not in cols:
                statements.append(
                    "ALTER TABLE roles ADD COLUMN scope_owner VARCHAR NOT NULL DEFAULT 'global'"
                )
                patched_columns.append("scope_owner")

        for statement in statements:
            conn.execute(text(statement))

        if statements:
            logger.info(
                "schema.roles_compatibility_patch_applied",
                patched_columns=patched_columns,
            )


def ensure_logistics_schema_compatibility() -> None:
    """
    Backfill frequently-missing logistics columns when migrations drift.
    This is add-only and idempotent (never drops or rewrites existing columns).
    """
    parsed_url = make_url(settings.DATABASE_URL)
    driver = parsed_url.drivername
    driver_key = _compat_driver_key(driver)
    if not driver_key:
        return

    patched: dict[str, list[str]] = {}
    with engine.begin() as conn:
        inspector = inspect(conn)
        for table_name, columns in _LOGISTICS_COMPAT_COLUMNS.items():
            if not inspector.has_table(table_name):
                continue

            existing_columns = {col["name"] for col in inspector.get_columns(table_name)}
            for column_name, ddl_by_driver in columns.items():
                if column_name in existing_columns:
                    continue
                ddl = ddl_by_driver.get(driver_key)
                if not ddl:
                    continue

                if driver_key == "postgresql":
                    statement = (
                        f'ALTER TABLE "{table_name}" '
                        f'ADD COLUMN IF NOT EXISTS "{column_name}" {ddl}'
                    )
                else:
                    statement = (
                        f'ALTER TABLE "{table_name}" '
                        f'ADD COLUMN "{column_name}" {ddl}'
                    )

                conn.execute(text(statement))
                patched.setdefault(table_name, []).append(column_name)

    if patched:
        logger.info("schema.logistics_compatibility_patch_applied", patched=patched)


# ── Connection-level hooks ─────────────────────────────────────────────────

@event.listens_for(engine, "connect")
def _on_connect(dbapi_connection, connection_record):
    """
    Per-connection setup:
    - SQLite  → enable WAL journal + NORMAL sync
    - PostgreSQL → lock search_path to public (safe for PgBouncer/Neon)
    """
    parsed_url = make_url(settings.DATABASE_URL)

    if parsed_url.drivername.startswith("sqlite"):
        cursor = dbapi_connection.cursor()
        try:
            cursor.execute("PRAGMA journal_mode=WAL")
            cursor.execute("PRAGMA synchronous=NORMAL")
        finally:
            cursor.close()
    elif parsed_url.drivername.startswith("postgresql"):
        cursor = dbapi_connection.cursor()
        try:
            # Prefer public (Supabase-safe), then detect app schema from known app tables.
            app_schema = "public"
            try:
                cursor.execute(
                    "SELECT table_schema FROM information_schema.tables "
                    "WHERE table_name IN ('roles', 'users', 'stations', 'batteries') "
                    "  AND table_schema NOT IN "
                    "      ('information_schema', 'pg_catalog', 'auth', 'storage', 'graphql', 'realtime') "
                    "ORDER BY CASE WHEN table_schema = 'public' THEN 0 ELSE 1 END, table_schema "
                    "LIMIT 1"
                )
                row = cursor.fetchone()
                if row and row[0]:
                    app_schema = _safe_schema_name(row[0], default="public")
            except Exception as exc:
                logger.warning("db.search_path.detect_failed", error=str(exc))

            try:
                cursor.execute(f"SET search_path TO {app_schema}, public")
            except Exception as exc:
                logger.warning(
                    "db.search_path.set_failed",
                    schema=app_schema,
                    error=str(exc),
                )
                cursor.execute("SET search_path TO public")
        finally:
            cursor.close()


# ── SQL observability (slow queries + suspicious no-op mutations) ───────────

_UPDATE_TABLE_RE = re.compile(r"^\s*UPDATE\s+([a-zA-Z0-9_\.\"`]+)", re.IGNORECASE)
_DELETE_TABLE_RE = re.compile(r"^\s*DELETE\s+FROM\s+([a-zA-Z0-9_\.\"`]+)", re.IGNORECASE)
_INSERT_TABLE_RE = re.compile(r"^\s*INSERT\s+INTO\s+([a-zA-Z0-9_\.\"`]+)", re.IGNORECASE)
_SQL_IDENTIFIER_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


def _safe_schema_name(value: object, default: str = "public") -> str:
    schema = str(value or "").strip()
    if _SQL_IDENTIFIER_RE.match(schema):
        return schema
    return default


def _compact_sql(statement: object, *, max_len: int = 400) -> str:
    compact = " ".join(str(statement).split())
    if len(compact) <= max_len:
        return compact
    return f"{compact[:max_len]}..."


def _mutation_info(statement: object) -> tuple[str | None, str | None]:
    sql = str(statement)
    stripped = sql.lstrip().upper()
    if stripped.startswith("UPDATE"):
        match = _UPDATE_TABLE_RE.match(sql)
        return "UPDATE", (match.group(1) if match else None)
    if stripped.startswith("DELETE"):
        match = _DELETE_TABLE_RE.match(sql)
        return "DELETE", (match.group(1) if match else None)
    if stripped.startswith("INSERT"):
        match = _INSERT_TABLE_RE.match(sql)
        return "INSERT", (match.group(1) if match else None)
    return None, None


def _register_sql_observability() -> None:
    slow_threshold_ms = int(getattr(settings, "SQL_SLOW_QUERY_LOG_MS", 0) or 0)
    slow_warn_cooldown_seconds = max(
        0, int(getattr(settings, "SQL_SLOW_QUERY_WARN_COOLDOWN_SECONDS", 0) or 0)
    )
    slow_ignore_patterns = tuple(
        pattern.strip().lower()
        for pattern in (getattr(settings, "SQL_SLOW_QUERY_IGNORE_PATTERNS", []) or [])
        if pattern and pattern.strip()
    )
    log_noop_mutations = bool(getattr(settings, "DB_LOG_NOOP_MUTATIONS", True))
    ignore_tables = {
        name.strip().lower()
        for name in (settings.DB_NOOP_MUTATION_IGNORE_TABLES or [])
        if name.strip()
    }
    if slow_threshold_ms <= 0 and not log_noop_mutations:
        return

    slow_query_last_warned_at: dict[str, float] = {}
    slow_query_suppressed_count: dict[str, int] = {}

    @event.listens_for(engine, "before_cursor_execute")
    def _before_cursor_execute(conn, cursor, statement, parameters, context, executemany):
        conn.info.setdefault("_query_start_times", []).append(time.perf_counter())

    @event.listens_for(engine, "after_cursor_execute")
    def _after_cursor_execute(conn, cursor, statement, parameters, context, executemany):
        start_times = conn.info.get("_query_start_times")
        if not start_times:
            return
        started_at = start_times.pop()
        duration_ms = (time.perf_counter() - started_at) * 1000
        rowcount = getattr(cursor, "rowcount", None)
        sql_text = _compact_sql(statement)

        if slow_threshold_ms > 0 and duration_ms >= slow_threshold_ms:
            sql_key = sql_text.lower()
            if not any(pattern in sql_key for pattern in slow_ignore_patterns):
                if slow_warn_cooldown_seconds > 0:
                    now_monotonic = time.monotonic()
                    last_warned_at = slow_query_last_warned_at.get(sql_key)
                    if (
                        last_warned_at is not None
                        and (now_monotonic - last_warned_at) < slow_warn_cooldown_seconds
                    ):
                        slow_query_suppressed_count[sql_key] = (
                            slow_query_suppressed_count.get(sql_key, 0) + 1
                        )
                    else:
                        # Prevent unbounded growth in long-lived workers.
                        if len(slow_query_last_warned_at) > 2048:
                            slow_query_last_warned_at.clear()
                            slow_query_suppressed_count.clear()
                        suppressed = slow_query_suppressed_count.pop(sql_key, 0)
                        slow_query_last_warned_at[sql_key] = now_monotonic
                        log_payload = {
                            "duration_ms": round(duration_ms, 2),
                            "threshold_ms": slow_threshold_ms,
                            "rowcount": rowcount,
                            "executemany": executemany,
                            "sql": sql_text,
                        }
                        if suppressed:
                            log_payload["suppressed_since_last"] = suppressed
                        logger.warning("anomaly.db.slow_query", **log_payload)
                else:
                    logger.warning(
                        "anomaly.db.slow_query",
                        duration_ms=round(duration_ms, 2),
                        threshold_ms=slow_threshold_ms,
                        rowcount=rowcount,
                        executemany=executemany,
                        sql=sql_text,
                    )

        if not log_noop_mutations:
            return
        operation, raw_table = _mutation_info(statement)
        if not operation:
            return
        table_name = (raw_table or "").strip().strip('"`').lower()
        if table_name and table_name in ignore_tables:
            return
        if rowcount == 0:
            logger.warning(
                "anomaly.db.noop_mutation",
                operation=operation,
                table=table_name or None,
                rowcount=rowcount,
                executemany=executemany,
                sql=sql_text,
            )


_register_sql_observability()


# ── Session dependency ─────────────────────────────────────────────────────

def get_db():
    """Dependency for FastAPI endpoints."""
    with Session(engine) as session:
        yield session
