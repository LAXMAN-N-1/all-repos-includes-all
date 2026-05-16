#!/usr/bin/env python3
from __future__ import annotations

import os
import sys
from dataclasses import dataclass

from sqlalchemy import create_engine, text


EXPECTED_TABLES = (
    "dealer_profiles",
    "dealer_documents",
    "dealer_applications",
    "dealer_inventories",
    "dealer_stock_requests",
    "dealer_promotions",
    "staff_profiles",
    "stations",
    "settlements",
    "users",
    "commission_logs",
    "chargebacks",
    "settlement_disputes",
    "inventory_transactions",
    "promotion_usages",
    "logistics_orders",
    "logistics_order_batteries",
    "battery_transfers",
    "logistics_manifests",
    "delivery_orders",
    "inventory_transfers",
    "inventory_transfer_items",
    "stock_discrepancies",
    "manifests",
    "manifest_items",
)

EXPECTED_POLICIES = {"wezu_global_access", "wezu_tenant_access"}


@dataclass
class TableRlsState:
    table_name: str
    rls_enabled: bool
    rls_forced: bool
    policies: set[str]


def _boolish(value: object) -> bool:
    return bool(value) is True


def _load_table_states(database_url: str) -> list[TableRlsState]:
    engine = create_engine(database_url)
    placeholders = ", ".join(f":t{i}" for i in range(len(EXPECTED_TABLES)))
    table_params = {f"t{i}": name for i, name in enumerate(EXPECTED_TABLES)}

    with engine.begin() as conn:
        rows = conn.execute(
            text(
                f"""
                SELECT c.relname AS table_name, c.relrowsecurity AS rls_enabled, c.relforcerowsecurity AS rls_forced
                FROM pg_class c
                JOIN pg_namespace n ON n.oid = c.relnamespace
                WHERE n.nspname = 'public'
                  AND c.relname IN ({placeholders})
                """
            ),
            table_params,
        ).mappings().all()

        policy_rows = conn.execute(
            text(
                f"""
                SELECT tablename, policyname
                FROM pg_policies
                WHERE schemaname = 'public'
                  AND tablename IN ({placeholders})
                """
            ),
            table_params,
        ).mappings().all()

    rel_map = {row["table_name"]: row for row in rows}
    policy_map: dict[str, set[str]] = {table: set() for table in EXPECTED_TABLES}
    for row in policy_rows:
        policy_map.setdefault(str(row["tablename"]), set()).add(str(row["policyname"]))

    states: list[TableRlsState] = []
    for table in EXPECTED_TABLES:
        rel = rel_map.get(table)
        states.append(
            TableRlsState(
                table_name=table,
                rls_enabled=_boolish(rel["rls_enabled"]) if rel else False,
                rls_forced=_boolish(rel["rls_forced"]) if rel else False,
                policies=policy_map.get(table, set()),
            )
        )
    return states


def main() -> int:
    database_url = os.getenv("DATABASE_URL", "").strip()
    if not database_url:
        print("error: DATABASE_URL is required", file=sys.stderr)
        return 2

    try:
        states = _load_table_states(database_url)
    except Exception as exc:
        print(f"error: failed to query database: {exc}", file=sys.stderr)
        return 2

    failures: list[str] = []
    for state in states:
        if not state.rls_enabled:
            failures.append(f"{state.table_name}: row level security is not enabled")
        if not state.rls_forced:
            failures.append(f"{state.table_name}: row level security is not forced")
        missing = EXPECTED_POLICIES - state.policies
        if missing:
            failures.append(
                f"{state.table_name}: missing policies {', '.join(sorted(missing))}"
            )

    if failures:
        print("tenant RLS validation failed:", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1

    print("tenant RLS validation passed for all expected tables")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
