"""
Model ↔ schema drift detector.

Scans every ``SQLModel`` with ``table=True`` registered in the metadata
and logs a single loud warning for any whose backing table is missing
from the connected database. Long-term stability insurance: the next
time a consolidation/cleanup migration drops a table that live code
still references, this check surfaces it at startup — instead of
manifesting as a ``psycopg2.errors.UndefinedTable`` 500 on the first
real request to an affected endpoint.

This module only detects/logs drift. Callers decide policy:
- soft mode: log and continue
- strict mode: block startup when drift exists
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable

from sqlalchemy import inspect
from sqlmodel import SQLModel

from app.core.config import settings
from app.core.database import engine
from app.core.logging import get_logger

logger = get_logger(__name__)


@dataclass(frozen=True)
class ModelSchemaDriftReport:
    actionable_missing_tables: list[str]
    ignored_missing_tables: list[str]
    check_error: str | None = None


def _registered_tables() -> Iterable[str]:
    # Importing app.models.all ensures every SQLModel class is registered
    # on SQLModel.metadata before we enumerate it.
    import app.models.all  # noqa: F401

    return sorted(SQLModel.metadata.tables.keys())


def _ignored_tables() -> set[str]:
    return {
        str(table).strip().lower()
        for table in (getattr(settings, "SCHEMA_DRIFT_IGNORED_TABLES", []) or [])
        if str(table).strip()
    }


def get_model_schema_drift_report(*, emit_logs: bool = True) -> ModelSchemaDriftReport:
    """
    Return structured model↔schema drift details.

    `emit_logs=True` retains the existing startup logging behavior.
    """
    try:
        inspector = inspect(engine)
        existing = set(inspector.get_table_names())
    except Exception as exc:  # pragma: no cover — defensive
        if emit_logs:
            logger.warning("schema.drift_check_failed", error=str(exc))
        return ModelSchemaDriftReport(
            actionable_missing_tables=[],
            ignored_missing_tables=[],
            check_error=str(exc),
        )

    missing: list[str] = []
    for table_name in _registered_tables():
        if table_name not in existing:
            missing.append(table_name)

    ignored = _ignored_tables()
    actionable_missing = [table for table in missing if table.lower() not in ignored]
    ignored_missing = [table for table in missing if table.lower() in ignored]

    if emit_logs:
        log_missing = logger.error if getattr(settings, "SCHEMA_DRIFT_MISSING_TABLES_AS_ERROR", False) else logger.warning
        if actionable_missing:
            for table_name in actionable_missing:
                log_missing(
                    "schema.drift.missing_table",
                    table=table_name,
                    remedy=(
                        "A live SQLModel references this table but it does "
                        "not exist in the database. Add an alembic migration "
                        "that creates it (CREATE TABLE IF NOT EXISTS) or "
                        "delete the model if it is truly obsolete."
                    ),
                )
        if ignored_missing:
            logger.warning(
                "schema.drift.ignored_missing_tables",
                ignored_missing_table_count=len(ignored_missing),
                ignored_missing_tables=ignored_missing,
            )

        if actionable_missing:
            log_missing(
                "schema.drift.summary",
                missing_table_count=len(actionable_missing),
                missing_tables=actionable_missing,
                ignored_missing_table_count=len(ignored_missing),
            )
        else:
            logger.info("schema.drift.clean")
            logger.info(
                "schema.drift.summary",
                missing_table_count=0,
                missing_tables=[],
                ignored_missing_table_count=len(ignored_missing),
            )

    return ModelSchemaDriftReport(
        actionable_missing_tables=actionable_missing,
        ignored_missing_tables=ignored_missing,
    )


def check_model_schema_drift() -> list[str]:
    """
    Compatibility wrapper used by existing startup logging call sites.
    """
    return get_model_schema_drift_report(emit_logs=True).actionable_missing_tables
