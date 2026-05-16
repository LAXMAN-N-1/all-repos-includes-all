#!/usr/bin/env python3
"""
Strict seed script: roles -> users -> batteries.

Highlights:
- Standalone SQLAlchemy script (does not import app settings/bootstrap).
- Idempotent upserts scoped to deterministic seed keys.
- Ensures base role families exist (admin/customer/dealer/logistics).
- Seeds exactly 2 users per active role and exactly 50 batteries.
- Enforces relation integrity with hard-fail validation checks.
"""

from __future__ import annotations

import argparse
import hashlib
import re
import sys
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from typing import Any, Iterable

import sqlalchemy as sa
from passlib.context import CryptContext
from sqlalchemy import MetaData, Table, and_, delete, func, select, update
from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy.engine import Connection


USERS_PER_ROLE = 2
BATTERY_TOTAL = 50
DEFAULT_EMAIL_DOMAIN = "wezu.com"

ROLE_FAMILY_SPECS = (
    {"name": "admin", "category": "system", "level": 100, "is_system_role": True, "icon": "shield", "color": "#E53935"},
    {"name": "customer", "category": "customer", "level": 10, "is_system_role": True, "icon": "user", "color": "#1E88E5"},
    {"name": "dealer", "category": "dealer", "level": 50, "is_system_role": False, "icon": "store", "color": "#43A047"},
    {"name": "logistics", "category": "logistics", "level": 60, "is_system_role": True, "icon": "truck", "color": "#FB8C00"},
)

SEED_PERMISSION_SPECS = (
    {
        "slug": "battery:view:global",
        "module": "battery",
        "action": "view",
        "scope": "global",
        "description": "Seeded baseline read access for logistics/admin battery dashboards",
    },
)

ROLE_PERMISSION_SEED_MAP = {
    "admin": ("battery:view:global",),
    "logistics": ("battery:view:global",),
}

PREFERRED_OWNER_STATUSES = ("rented", "deployed", "reserved")
PREFERRED_NON_OWNER_STATUSES = (
    "available",
    "charging",
    "maintenance",
    "new",
    "ready",
    "in_transit",
    "faulty",
    "retired",
    "decommissioned",
)
PREFERRED_OWNER_LOCATIONS = ("customer", "station", "warehouse")
PREFERRED_NON_OWNER_LOCATIONS = ("warehouse", "station", "service_center", "recycling", "shelf", "transit", "customer")

pwd_context = CryptContext(schemes=["bcrypt", "pbkdf2_sha256"], deprecated="auto")


@dataclass(frozen=True)
class RoleRecord:
    id: int
    name: str
    category: str | None
    level: int | None


@dataclass(frozen=True)
class SeededUser:
    id: int
    email: str
    role_id: int
    role_name: str
    family: str
    user_type: str


@dataclass(frozen=True)
class SeedResult:
    active_roles: list[RoleRecord]
    seeded_users: list[SeededUser]
    seeded_battery_serials: list[str]
    owner_status_labels: set[str]


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def normalize_seed_tag(raw: str) -> str:
    cleaned = re.sub(r"[^a-zA-Z0-9_-]+", "-", raw.strip().lower())
    cleaned = cleaned.strip("-_")
    return cleaned or "strict-seed"


def short_hash_digits(value: str, length: int) -> str:
    digest = hashlib.sha256(value.encode("utf-8")).hexdigest()
    digits = "".join(str(int(ch, 16) % 10) for ch in digest)
    return digits[:length]


def reflect_tables(conn: Connection) -> dict[str, Table]:
    metadata = MetaData()
    required = ("roles", "users", "user_roles", "batteries")
    optional = ("permissions", "role_permissions")
    metadata.reflect(conn, only=required + optional)
    missing = [name for name in required if name not in metadata.tables]
    if missing:
        raise RuntimeError(f"Missing required tables: {', '.join(missing)}")
    tables = {name: metadata.tables[name] for name in required}
    for name in optional:
        if name in metadata.tables:
            tables[name] = metadata.tables[name]
    return tables


def table_cols(table: Table) -> set[str]:
    return {col.name for col in table.columns}


def enum_labels(conn: Connection, table_name: str, column_name: str) -> list[str]:
    rows = conn.execute(
        sa.text(
            """
            SELECT e.enumlabel
            FROM pg_attribute a
            JOIN pg_class c ON c.oid = a.attrelid
            JOIN pg_type t ON t.oid = a.atttypid
            JOIN pg_enum e ON e.enumtypid = t.oid
            JOIN pg_namespace n ON n.oid = c.relnamespace
            WHERE n.nspname = current_schema()
              AND c.relname = :table_name
              AND a.attname = :column_name
            ORDER BY e.enumsortorder
            """
        ),
        {"table_name": table_name, "column_name": column_name},
    ).scalars().all()
    return list(rows)


def coerce_enum_label(available: Iterable[str], desired: str) -> str:
    labels = list(available)
    if not labels:
        return desired
    by_lower = {label.lower(): label for label in labels}
    key = desired.lower()
    if key in by_lower:
        return by_lower[key]
    raise RuntimeError(
        f"Cannot map desired enum value '{desired}' to available labels: {labels}"
    )


def maybe_enum_label(available: Iterable[str], desired: str) -> str | None:
    labels = list(available)
    if not labels:
        return desired
    by_lower = {label.lower(): label for label in labels}
    return by_lower.get(desired.lower())


def rank_dedup(labels: Iterable[str]) -> list[str]:
    seen: set[str] = set()
    ordered: list[str] = []
    for label in labels:
        low = label.lower()
        if low in seen:
            continue
        seen.add(low)
        ordered.append(label)
    return ordered


def classify_role(role_name: str, category: str | None) -> tuple[str, str]:
    """Returns (family, user_type)."""
    name = (role_name or "").strip().lower()
    cat = (category or "").strip().lower()

    logistics_tokens = ("logistic", "dispatch", "driver", "fleet", "warehouse", "route")
    dealer_tokens = ("dealer",)
    dealer_staff_tokens = ("staff", "manager", "agent", "inventory", "finance", "support")

    if any(token in name for token in logistics_tokens) or "logistics" in cat:
        return "logistics", "logistics"

    if any(token in name for token in dealer_tokens) or "dealer" in cat:
        if "dealer_staff" in name or any(token in name for token in dealer_staff_tokens):
            return "dealer", "dealer_staff"
        return "dealer", "dealer"

    if "admin" in name or cat in {"admin", "system", "ops", "operations"}:
        return "admin", "admin"

    if "customer" in name or "user" in name or cat in {"customer", "consumer"}:
        return "customer", "customer"

    return "customer", "customer"


def slugify(text: str) -> str:
    value = re.sub(r"[^a-zA-Z0-9]+", "_", (text or "").strip().lower())
    value = value.strip("_")
    return value or "role"


def make_email(
    seed_tag: str,
    role_name: str,
    user_index: int,
    *,
    email_style: str,
    email_domain: str,
) -> str:
    role_slug = slugify(role_name)
    if email_style == "role-index":
        return f"{role_slug}{user_index}@{email_domain}"
    return f"{seed_tag}.{role_slug}.{user_index:02d}@{email_domain}"


def make_phone(seed_tag: str, role_name: str, user_index: int) -> str:
    # 12-digit deterministic mobile-like number.
    role_hash = short_hash_digits(role_name, 3)
    suffix = short_hash_digits(f"{seed_tag}:{role_name}:{user_index}", 5)
    return f"9{role_hash}{user_index:02d}{suffix}"


def make_role_payload(spec: dict[str, Any], cols: set[str], now: datetime) -> dict[str, Any]:
    payload: dict[str, Any] = {}
    if "name" in cols:
        payload["name"] = spec["name"]
    if "description" in cols:
        payload["description"] = f"Seed base role for {spec['name']}"
    if "category" in cols:
        payload["category"] = spec["category"]
    if "level" in cols:
        payload["level"] = spec["level"]
    if "parent_id" in cols:
        payload["parent_id"] = None
    if "is_system_role" in cols:
        payload["is_system_role"] = bool(spec["is_system_role"])
    if "is_custom_role" in cols:
        payload["is_custom_role"] = False
    if "is_active" in cols:
        payload["is_active"] = True
    if "scope_owner" in cols:
        payload["scope_owner"] = "global"
    if "dealer_id" in cols:
        payload["dealer_id"] = None
    if "icon" in cols:
        payload["icon"] = spec["icon"]
    if "color" in cols:
        payload["color"] = spec["color"]
    if "created_at" in cols:
        payload["created_at"] = now
    if "updated_at" in cols:
        payload["updated_at"] = now
    return payload


def ensure_base_roles(conn: Connection, roles: Table, now: datetime) -> None:
    cols = table_cols(roles)
    for spec in ROLE_FAMILY_SPECS:
        payload = make_role_payload(spec, cols, now)
        stmt = pg_insert(roles).values(payload)
        update_set = {
            key: value
            for key, value in payload.items()
            if key not in {"name", "created_at"}
        }
        if "updated_at" in cols:
            update_set["updated_at"] = now
        stmt = stmt.on_conflict_do_update(
            index_elements=[roles.c.name],
            set_=update_set,
        )
        conn.execute(stmt)


def ensure_seed_permissions(
    conn: Connection,
    *,
    roles: Table,
    permissions: Table,
    role_permissions: Table,
    now: datetime,
) -> None:
    permission_cols = table_cols(permissions)
    for spec in SEED_PERMISSION_SPECS:
        payload: dict[str, Any] = {}
        if "slug" in permission_cols:
            payload["slug"] = spec["slug"]
        if "module" in permission_cols:
            payload["module"] = spec["module"]
        if "action" in permission_cols:
            payload["action"] = spec["action"]
        if "scope" in permission_cols:
            payload["scope"] = spec["scope"]
        if "description" in permission_cols:
            payload["description"] = spec["description"]
        if "resource_type" in permission_cols:
            payload["resource_type"] = spec["module"]
        if "constraints" in permission_cols:
            payload["constraints"] = None
        if "created_at" in permission_cols:
            payload["created_at"] = now
        if "updated_at" in permission_cols:
            payload["updated_at"] = now

        stmt = pg_insert(permissions).values(payload)
        update_set = {
            key: value
            for key, value in payload.items()
            if key not in {"slug", "created_at"}
        }
        if "updated_at" in permission_cols:
            update_set["updated_at"] = now
        stmt = stmt.on_conflict_do_update(
            index_elements=[permissions.c.slug],
            set_=update_set,
        )
        conn.execute(stmt)

    seeded_slugs = [spec["slug"] for spec in SEED_PERMISSION_SPECS]
    permission_id_by_slug = {
        str(row.slug): int(row.id)
        for row in conn.execute(
            select(permissions.c.slug, permissions.c.id).where(permissions.c.slug.in_(seeded_slugs))
        ).all()
    }
    role_id_by_name = {
        str(row.name): int(row.id)
        for row in conn.execute(
            select(roles.c.name, roles.c.id).where(roles.c.name.in_(ROLE_PERMISSION_SEED_MAP.keys()))
        ).all()
    }
    for role_name, slugs in ROLE_PERMISSION_SEED_MAP.items():
        role_id = role_id_by_name.get(role_name)
        if role_id is None:
            continue
        for slug in slugs:
            permission_id = permission_id_by_slug.get(slug)
            if permission_id is None:
                continue
            stmt = (
                pg_insert(role_permissions)
                .values(role_id=role_id, permission_id=permission_id)
                .on_conflict_do_nothing(
                    index_elements=[role_permissions.c.role_id, role_permissions.c.permission_id]
                )
            )
            conn.execute(stmt)


def fetch_active_roles(conn: Connection, roles: Table) -> list[RoleRecord]:
    stmt = select(
        roles.c.id,
        roles.c.name,
        roles.c.category if "category" in table_cols(roles) else sa.literal(None).label("category"),
        roles.c.level if "level" in table_cols(roles) else sa.literal(None).label("level"),
    ).order_by(roles.c.id.asc())
    if "is_active" in table_cols(roles):
        stmt = stmt.where(roles.c.is_active.is_(True))
    rows = conn.execute(stmt).all()
    return [
        RoleRecord(
            id=int(row.id),
            name=str(row.name),
            category=row.category,
            level=row.level,
        )
        for row in rows
    ]


def upsert_user(
    conn: Connection,
    users: Table,
    *,
    forced_id: int | None,
    email: str,
    phone: str,
    full_name: str,
    hashed_password: str,
    role_id: int,
    family: str,
    desired_user_type: str,
    user_type_labels: list[str],
    status_labels: list[str],
    kyc_labels: list[str],
    now: datetime,
    seed_tag: str,
) -> int:
    cols = table_cols(users)
    payload: dict[str, Any] = {}

    if "email" not in cols:
        raise RuntimeError("users.email column is required for deterministic idempotent upsert.")

    if forced_id is not None and "id" in cols:
        payload["id"] = int(forced_id)
    payload["email"] = email
    if "phone_number" in cols:
        payload["phone_number"] = phone
    if "full_name" in cols:
        payload["full_name"] = full_name
    if "hashed_password" in cols:
        payload["hashed_password"] = hashed_password
    if "user_type" in cols:
        payload["user_type"] = coerce_enum_label(user_type_labels, desired_user_type)
    if "status" in cols:
        payload["status"] = coerce_enum_label(status_labels, "active")
    if "kyc_status" in cols:
        payload["kyc_status"] = coerce_enum_label(kyc_labels, "not_submitted")
    if "is_superuser" in cols:
        payload["is_superuser"] = family == "admin" and "super" in full_name.lower()
    if "role_id" in cols:
        payload["role_id"] = role_id
    if "failed_login_attempts" in cols:
        payload["failed_login_attempts"] = 0
    if "two_factor_enabled" in cols:
        payload["two_factor_enabled"] = False
    if "biometric_login_enabled" in cols:
        payload["biometric_login_enabled"] = False
    if "force_password_change" in cols:
        payload["force_password_change"] = False
    if "is_deleted" in cols:
        payload["is_deleted"] = False
    if "created_by_dealer_id" in cols:
        payload["created_by_dealer_id"] = None
    if "created_by_user_id" in cols:
        payload["created_by_user_id"] = None
    if "department" in cols:
        payload["department"] = family
    if "notes_internal" in cols:
        payload["notes_internal"] = f"{seed_tag}: strict deterministic seed user"
    if "created_at" in cols:
        payload["created_at"] = now
    if "updated_at" in cols:
        payload["updated_at"] = now

    stmt = pg_insert(users).values(payload)
    update_set = {
        key: value
        for key, value in payload.items()
        if key not in {"email", "created_at"}
    }
    if "updated_at" in cols:
        update_set["updated_at"] = now
    stmt = stmt.on_conflict_do_update(
        index_elements=[users.c.email],
        set_=update_set,
    ).returning(users.c.id)
    user_id = conn.execute(stmt).scalar_one()
    return int(user_id)


def upsert_user_role_link(
    conn: Connection,
    user_roles: Table,
    *,
    user_id: int,
    role_id: int,
    actor_user_id: int | None,
    seed_tag: str,
    now: datetime,
) -> None:
    cols = table_cols(user_roles)
    payload: dict[str, Any] = {
        "user_id": user_id,
        "role_id": role_id,
    }
    if "effective_from" in cols:
        payload["effective_from"] = now
    if "created_at" in cols:
        payload["created_at"] = now
    if "expires_at" in cols:
        payload["expires_at"] = None
    if "assigned_by" in cols:
        payload["assigned_by"] = None
    if "assigned_by_user_id" in cols:
        payload["assigned_by_user_id"] = actor_user_id
    if "assigned_by_subject" in cols:
        payload["assigned_by_subject"] = f"seed:{seed_tag}"
    if "notes" in cols:
        payload["notes"] = f"{seed_tag}: strict role assignment seed"

    stmt = pg_insert(user_roles).values(payload)
    update_set = {
        key: value
        for key, value in payload.items()
        if key not in {"user_id", "role_id", "created_at"}
    }
    stmt = stmt.on_conflict_do_update(
        index_elements=[user_roles.c.user_id, user_roles.c.role_id],
        set_=update_set,
    )
    conn.execute(stmt)


def build_status_plan(status_labels: list[str]) -> tuple[list[str], set[str]]:
    owner_statuses = rank_dedup(
        label
        for label in (
            maybe_enum_label(status_labels, desired) for desired in PREFERRED_OWNER_STATUSES
        )
        if label
    )
    non_owner_statuses = rank_dedup(
        label
        for label in (
            maybe_enum_label(status_labels, desired) for desired in PREFERRED_NON_OWNER_STATUSES
        )
        if label and label.lower() not in {s.lower() for s in owner_statuses}
    )

    if not owner_statuses and status_labels:
        # fallback: treat "rented" or first label as owner-capable only if present
        rented = maybe_enum_label(status_labels, "rented")
        if rented:
            owner_statuses = [rented]
    if not non_owner_statuses:
        non_owner_statuses = [
            s for s in status_labels if s.lower() not in {v.lower() for v in owner_statuses}
        ]

    cycle = owner_statuses + non_owner_statuses
    if not cycle and status_labels:
        cycle = status_labels[:]
    if not cycle:
        cycle = ["available"]

    owner_set = {s.lower() for s in owner_statuses}
    return cycle, owner_set


def choose_location_types(location_labels: list[str]) -> tuple[str, list[str]]:
    owner_location = None
    for desired in PREFERRED_OWNER_LOCATIONS:
        label = maybe_enum_label(location_labels, desired)
        if label:
            owner_location = label
            break
    if owner_location is None:
        owner_location = location_labels[0] if location_labels else "warehouse"

    non_owner = rank_dedup(
        label
        for label in (
            maybe_enum_label(location_labels, desired) for desired in PREFERRED_NON_OWNER_LOCATIONS
        )
        if label
    )
    if not non_owner:
        non_owner = location_labels[:] or [owner_location]
    return owner_location, non_owner


def upsert_battery(
    conn: Connection,
    batteries: Table,
    *,
    serial_number: str,
    qr_code_data: str,
    status: str,
    health_status: str,
    location_type: str,
    created_by: int | None,
    current_user_id: int | None,
    now: datetime,
    idx: int,
    seed_tag: str,
) -> None:
    cols = table_cols(batteries)
    payload: dict[str, Any] = {}

    if "serial_number" not in cols:
        raise RuntimeError("batteries.serial_number column is required for deterministic idempotent upsert.")

    payload["serial_number"] = serial_number
    if "qr_code_data" in cols:
        payload["qr_code_data"] = qr_code_data
    if "iot_device_id" in cols:
        payload["iot_device_id"] = None
    if "sku_id" in cols:
        payload["sku_id"] = None
    if "spec_id" in cols:
        payload["spec_id"] = None
    if "station_id" in cols:
        payload["station_id"] = None
    if "current_user_id" in cols:
        payload["current_user_id"] = current_user_id
    if "created_by" in cols:
        payload["created_by"] = created_by
    if "status" in cols:
        payload["status"] = status
    if "health_status" in cols:
        payload["health_status"] = health_status
    if "current_charge" in cols:
        payload["current_charge"] = round(35 + ((idx * 7) % 65), 2)
    if "health_percentage" in cols:
        payload["health_percentage"] = round(70 + ((idx * 3) % 30), 2)
    if "cycle_count" in cols:
        payload["cycle_count"] = 80 + (idx * 4)
    if "total_cycles" in cols:
        payload["total_cycles"] = 120 + (idx * 5)
    if "temperature_c" in cols:
        payload["temperature_c"] = round(22 + ((idx % 12) * 1.2), 2)
    if "manufacturer" in cols:
        payload["manufacturer"] = "WEZU Seed Labs"
    if "battery_type" in cols:
        payload["battery_type"] = "48V/30Ah"
    if "purchase_cost" in cols:
        payload["purchase_cost"] = float(45000 + (idx * 55))
    if "notes" in cols:
        payload["notes"] = f"{seed_tag}: strict battery seed row {idx}"
    if "location_type" in cols:
        payload["location_type"] = location_type
    if "manufacture_date" in cols:
        payload["manufacture_date"] = now - timedelta(days=365 + (idx * 2))
    if "purchase_date" in cols:
        payload["purchase_date"] = now - timedelta(days=300 + idx)
    if "warranty_expiry" in cols:
        payload["warranty_expiry"] = now + timedelta(days=365 + (idx * 3))
    if "last_charged_at" in cols:
        payload["last_charged_at"] = now - timedelta(hours=(idx % 48))
    if "last_inspected_at" in cols:
        payload["last_inspected_at"] = now - timedelta(days=(idx % 30))
    if "last_maintenance_date" in cols:
        payload["last_maintenance_date"] = now - timedelta(days=(idx % 90))
    if "last_maintenance_cycles" in cols:
        payload["last_maintenance_cycles"] = max(0, 60 + (idx * 3))
    if "state_of_health" in cols:
        payload["state_of_health"] = round(75 + ((idx * 2) % 25), 2)
    if "temperature_history" in cols:
        base_temp = float(payload.get("temperature_c", 25.0))
        payload["temperature_history"] = [round(base_temp - 1.5, 2), round(base_temp - 0.7, 2), base_temp]
    if "charge_cycles" in cols:
        payload["charge_cycles"] = 20 + (idx * 3)
    if "location_id" in cols:
        payload["location_id"] = None
    if "retirement_date" in cols:
        payload["retirement_date"] = None
    if "decommissioned_at" in cols:
        payload["decommissioned_at"] = None
    if "decommissioned_by" in cols:
        payload["decommissioned_by"] = None
    if "decommission_reason" in cols:
        payload["decommission_reason"] = None
    if "last_telemetry_at" in cols:
        payload["last_telemetry_at"] = now - timedelta(minutes=(idx % 120))
    if "created_at" in cols:
        payload["created_at"] = now
    if "updated_at" in cols:
        payload["updated_at"] = now

    stmt = pg_insert(batteries).values(payload)
    update_set = {
        key: value
        for key, value in payload.items()
        if key not in {"serial_number", "created_at"}
    }
    if "updated_at" in cols:
        update_set["updated_at"] = now
    stmt = stmt.on_conflict_do_update(
        index_elements=[batteries.c.serial_number],
        set_=update_set,
    )
    conn.execute(stmt)


def run_seed(
    conn: Connection,
    *,
    default_password: str,
    seed_tag: str,
    user_id_base: int | None,
    email_style: str,
    email_domain: str,
) -> SeedResult:
    tables = reflect_tables(conn)
    roles = tables["roles"]
    users = tables["users"]
    user_roles = tables["user_roles"]
    batteries = tables["batteries"]
    permissions = tables.get("permissions")
    role_permissions = tables.get("role_permissions")
    now = utcnow()

    ensure_base_roles(conn, roles, now)
    if permissions is not None and role_permissions is not None:
        ensure_seed_permissions(
            conn,
            roles=roles,
            permissions=permissions,
            role_permissions=role_permissions,
            now=now,
        )
    active_roles = fetch_active_roles(conn, roles)
    if not active_roles:
        raise RuntimeError("No active roles found after ensuring base family roles.")

    user_type_labels = enum_labels(conn, "users", "user_type")
    user_status_labels = enum_labels(conn, "users", "status")
    kyc_labels = enum_labels(conn, "users", "kyc_status")

    password_hash = pwd_context.hash(default_password)
    seeded_users: list[SeededUser] = []
    intended_role_by_user: dict[int, int] = {}

    for role in active_roles:
        family, desired_user_type = classify_role(role.name, role.category)
        for idx in range(1, USERS_PER_ROLE + 1):
            user_ordinal = ((role.id * USERS_PER_ROLE) + idx)
            forced_id = (user_id_base + user_ordinal) if user_id_base is not None else None
            email = make_email(
                seed_tag,
                role.name,
                idx,
                email_style=email_style,
                email_domain=email_domain,
            )
            phone = make_phone(seed_tag, role.name, idx)
            full_name = f"Seed {role.name.title()} #{idx:02d}"
            user_id = upsert_user(
                conn,
                users,
                forced_id=forced_id,
                email=email,
                phone=phone,
                full_name=full_name,
                hashed_password=password_hash,
                role_id=role.id,
                family=family,
                desired_user_type=desired_user_type,
                user_type_labels=user_type_labels,
                status_labels=user_status_labels,
                kyc_labels=kyc_labels,
                now=now,
                seed_tag=seed_tag,
            )
            seeded_users.append(
                SeededUser(
                    id=user_id,
                    email=email,
                    role_id=role.id,
                    role_name=role.name,
                    family=family,
                    user_type=desired_user_type,
                )
            )
            intended_role_by_user[user_id] = role.id

    admin_actor_id = next((u.id for u in seeded_users if u.family == "admin"), None)
    for user in seeded_users:
        upsert_user_role_link(
            conn,
            user_roles,
            user_id=user.id,
            role_id=user.role_id,
            actor_user_id=admin_actor_id,
            seed_tag=seed_tag,
            now=now,
        )

    # Ensure one role link per seeded user.
    for user in seeded_users:
        conn.execute(
            delete(user_roles).where(
                and_(
                    user_roles.c.user_id == user.id,
                    user_roles.c.role_id != user.role_id,
                )
            )
        )
        if "role_id" in table_cols(users):
            values: dict[str, Any] = {"role_id": user.role_id}
            if "updated_at" in table_cols(users):
                values["updated_at"] = now
            conn.execute(
                update(users).where(users.c.id == user.id).values(**values)
            )

    battery_status_labels = enum_labels(conn, "batteries", "status")
    location_type_labels = enum_labels(conn, "batteries", "location_type")
    health_status_labels = enum_labels(conn, "batteries", "health_status")

    status_cycle, owner_status_set = build_status_plan(battery_status_labels)
    owner_location, non_owner_locations = choose_location_types(location_type_labels)
    health_good = coerce_enum_label(health_status_labels, "good")

    creator_pool = [u.id for u in seeded_users if u.family == "admin"] or [u.id for u in seeded_users]
    owner_pool = [u.id for u in seeded_users if u.family in {"customer", "dealer", "logistics"}] or [u.id for u in seeded_users]

    seeded_serials: list[str] = []
    seed_code = re.sub(r"[^a-zA-Z0-9]+", "", seed_tag).upper()[:16] or "STRICTSEED"
    for idx in range(1, BATTERY_TOTAL + 1):
        serial = f"BAT-{seed_code}-{idx:03d}"
        qr_data = f"QR-{seed_code}-{idx:03d}"
        status = status_cycle[(idx - 1) % len(status_cycle)]
        is_owner_status = status.lower() in owner_status_set

        current_owner = owner_pool[(idx - 1) % len(owner_pool)] if is_owner_status else None
        created_by = creator_pool[(idx - 1) % len(creator_pool)] if creator_pool else None
        location_type = owner_location if is_owner_status else non_owner_locations[(idx - 1) % len(non_owner_locations)]

        upsert_battery(
            conn,
            batteries,
            serial_number=serial,
            qr_code_data=qr_data,
            status=status,
            health_status=health_good,
            location_type=location_type,
            created_by=created_by,
            current_user_id=current_owner,
            now=now,
            idx=idx,
            seed_tag=seed_tag,
        )
        seeded_serials.append(serial)

    return SeedResult(
        active_roles=active_roles,
        seeded_users=seeded_users,
        seeded_battery_serials=seeded_serials,
        owner_status_labels=owner_status_set,
    )


def validate_integrity(conn: Connection, result: SeedResult) -> None:
    tables = reflect_tables(conn)
    roles = tables["roles"]
    users = tables["users"]
    user_roles = tables["user_roles"]
    batteries = tables["batteries"]

    # 1) No orphan user_roles rows (global check).
    orphan_user_roles = conn.execute(
        select(func.count())
        .select_from(
            user_roles.outerjoin(users, user_roles.c.user_id == users.c.id).outerjoin(
                roles, user_roles.c.role_id == roles.c.id
            )
        )
        .where(sa.or_(users.c.id.is_(None), roles.c.id.is_(None)))
    ).scalar_one()
    if int(orphan_user_roles) != 0:
        raise RuntimeError(f"Integrity check failed: orphan user_roles rows found ({orphan_user_roles}).")

    # 2) Every seeded user has exactly one intended role assignment.
    intended = {user.id: user.role_id for user in result.seeded_users}
    for user_id, role_id in intended.items():
        total_links = conn.execute(
            select(func.count()).select_from(user_roles).where(user_roles.c.user_id == user_id)
        ).scalar_one()
        intended_links = conn.execute(
            select(func.count())
            .select_from(user_roles)
            .where(and_(user_roles.c.user_id == user_id, user_roles.c.role_id == role_id))
        ).scalar_one()
        if int(total_links) != 1 or int(intended_links) != 1:
            raise RuntimeError(
                f"Integrity check failed: user {user_id} role links total={total_links}, intended={intended_links}."
            )

    # 3) users.role_id matches intended role.
    if "role_id" in table_cols(users):
        for user_id, role_id in intended.items():
            actual_role_id = conn.execute(
                select(users.c.role_id).where(users.c.id == user_id)
            ).scalar_one_or_none()
            if actual_role_id != role_id:
                raise RuntimeError(
                    f"Integrity check failed: users.role_id mismatch for user {user_id}, expected {role_id}, got {actual_role_id}."
                )

    # 4) No orphan battery user references for seeded batteries.
    serials = result.seeded_battery_serials
    for col_name in ("created_by", "current_user_id", "decommissioned_by"):
        if col_name not in table_cols(batteries):
            continue
        col = getattr(batteries.c, col_name)
        orphan_count = conn.execute(
            select(func.count())
            .select_from(batteries.outerjoin(users, col == users.c.id))
            .where(
                and_(
                    batteries.c.serial_number.in_(serials),
                    col.is_not(None),
                    users.c.id.is_(None),
                )
            )
        ).scalar_one()
        if int(orphan_count) != 0:
            raise RuntimeError(
                f"Integrity check failed: orphan battery reference in {col_name} ({orphan_count})."
            )

    # 5) Battery status / ownership consistency for seeded batteries.
    if "current_user_id" in table_cols(batteries) and "status" in table_cols(batteries):
        rows = conn.execute(
            select(batteries.c.serial_number, batteries.c.status, batteries.c.current_user_id).where(
                batteries.c.serial_number.in_(serials)
            )
        ).all()
        for row in rows:
            status = str(row.status).lower()
            has_owner = row.current_user_id is not None
            expected_owner = status in result.owner_status_labels
            if expected_owner != has_owner:
                raise RuntimeError(
                    f"Integrity check failed: battery {row.serial_number} status={row.status} owner={row.current_user_id}."
                )

    # 6) Count checks.
    active_role_count_stmt = select(func.count()).select_from(roles)
    if "is_active" in table_cols(roles):
        active_role_count_stmt = active_role_count_stmt.where(roles.c.is_active.is_(True))
    active_role_count = int(conn.execute(active_role_count_stmt).scalar_one())
    expected_seeded_users = active_role_count * USERS_PER_ROLE
    if len(result.seeded_users) != expected_seeded_users:
        raise RuntimeError(
            f"Integrity check failed: seeded users in-memory={len(result.seeded_users)}, expected={expected_seeded_users}."
        )

    db_seed_user_count = int(
        conn.execute(
            select(func.count()).select_from(users).where(users.c.email.in_([u.email for u in result.seeded_users]))
        ).scalar_one()
    )
    if db_seed_user_count != expected_seeded_users:
        raise RuntimeError(
            f"Integrity check failed: seeded users in DB={db_seed_user_count}, expected={expected_seeded_users}."
        )

    db_seed_battery_count = int(
        conn.execute(
            select(func.count()).select_from(batteries).where(
                batteries.c.serial_number.in_(result.seeded_battery_serials)
            )
        ).scalar_one()
    )
    if db_seed_battery_count != BATTERY_TOTAL:
        raise RuntimeError(
            f"Integrity check failed: seeded batteries in DB={db_seed_battery_count}, expected={BATTERY_TOTAL}."
        )


def print_report(result: SeedResult, *, dry_run: bool) -> None:
    role_count = len(result.active_roles)
    user_count = len(result.seeded_users)
    battery_count = len(result.seeded_battery_serials)
    owner_statuses = ", ".join(sorted(result.owner_status_labels)) or "(none)"
    print("Seed report")
    print(f"- Active roles targeted: {role_count}")
    print(f"- Seeded users: {user_count} (expected {role_count} x {USERS_PER_ROLE})")
    print(f"- Seeded batteries: {battery_count} (expected {BATTERY_TOTAL})")
    print(f"- Owner-required battery statuses: {owner_statuses}")
    print(f"- Mode: {'dry-run (rolled back)' if dry_run else 'commit'}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Strict deterministic seed: roles -> users -> batteries")
    parser.add_argument(
        "--database-url",
        required=True,
        help="PostgreSQL connection URL (required).",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Run full seed + validation inside one transaction and rollback.",
    )
    parser.add_argument(
        "--default-password",
        default="SeedPass#2026!",
        help="Deterministic password used for all seeded users before hashing.",
    )
    parser.add_argument(
        "--seed-tag",
        default="strict-seed-v1",
        help="Marker used in deterministic keys and notes for script-owned records.",
    )
    parser.add_argument(
        "--email-style",
        choices=("role-index", "tagged"),
        default="role-index",
        help="Email format: role-index => admin1@domain, tagged => seedtag.role.01@domain.",
    )
    parser.add_argument(
        "--email-domain",
        default=DEFAULT_EMAIL_DOMAIN,
        help="Email domain used for seeded users.",
    )
    parser.add_argument(
        "--user-id-base",
        type=int,
        default=None,
        help="Optional numeric base for explicit seeded user IDs (e.g. 900000 => 9000xx range).",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    seed_tag = normalize_seed_tag(args.seed_tag)
    engine = sa.create_engine(args.database_url, future=True)

    with engine.connect() as conn:
        if conn.dialect.name != "postgresql":
            raise RuntimeError(f"Unsupported dialect '{conn.dialect.name}'. This script requires PostgreSQL.")

        tx = conn.begin()
        try:
            result = run_seed(
                conn,
                default_password=args.default_password,
                seed_tag=seed_tag,
                user_id_base=args.user_id_base,
                email_style=args.email_style,
                email_domain=args.email_domain,
            )
            validate_integrity(conn, result)
            print_report(result, dry_run=args.dry_run)

            if args.dry_run:
                tx.rollback()
                print("Dry-run complete. All changes rolled back.")
            else:
                tx.commit()
                print("Seed complete. Changes committed.")
            return 0
        except Exception:
            tx.rollback()
            raise


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"Seed failed: {exc}", file=sys.stderr)
        raise
