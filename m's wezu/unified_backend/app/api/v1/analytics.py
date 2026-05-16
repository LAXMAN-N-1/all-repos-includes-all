"""
Customer Analytics and Dashboard API
Personal stats, usage patterns, and insights
"""
from __future__ import annotations

import base64
from collections import defaultdict
from dataclasses import dataclass
from datetime import UTC, date, datetime, time, timedelta
import csv
import io
import json
import logging
from threading import Lock
from typing import Any, Optional
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import Response
from pydantic import BaseModel, Field
from sqlmodel import Session, select

from app.api import deps
from app.core.config import settings
from app.models.user import User
from app.services.analytics_service import AnalyticsService
from app.services.admin_analytics_service import AdminAnalyticsService
from app.services.redis_service import RedisService
from app.schemas.common import DataResponse

logger = logging.getLogger(__name__)

router = APIRouter()

@router.get("/dashboard", response_model=DataResponse[dict])
def get_dashboard(
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db)
):
    """
    Get customer dashboard
    Shows active rentals, spending, favorite stations, etc.
    """
    dashboard = AnalyticsService.get_customer_dashboard(current_user.id, session)
    
    return DataResponse(
        success=True,
        data=dashboard
    )

@router.get("/rental-history", response_model=DataResponse[dict])
def get_rental_history_stats(
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db)
):
    """Get rental history statistics"""
    stats = AnalyticsService.get_rental_history_stats(current_user.id, session)
    
    return DataResponse(
        success=True,
        data=stats
    )

@router.get("/cost-analytics", response_model=DataResponse[dict])
def get_cost_analytics(
    months: int = Query(3, ge=1, le=12),
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db)
):
    """
    Get cost analytics
    Monthly breakdown of spending
    """
    analytics = AnalyticsService.get_cost_analytics(current_user.id, months, session)
    
    return DataResponse(
        success=True,
        data=analytics
    )

@router.get("/usage-patterns", response_model=DataResponse[dict])
def get_usage_patterns(
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db)
):
    """
    Get usage patterns
    Most active day/hour, average duration, etc.
    """
    patterns = AnalyticsService.get_usage_patterns(current_user.id, session)
    
    return DataResponse(
        success=True,
        data=patterns
    )

@router.get("/carbon-savings", response_model=DataResponse[dict])
def get_carbon_savings(
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db)
):
    """Calculate carbon savings from battery usage"""
    from app.models.rental import Rental
    from sqlmodel import select, func

    # Single SQL query: count + sum duration in seconds (replaces fetching all rows)
    result = session.exec(
        select(
            func.count(Rental.id),
            func.coalesce(
                func.sum(
                    func.extract("epoch", Rental.actual_end_time)
                    - func.extract("epoch", Rental.start_time)
                ),
                0.0,
            ),
        ).where(
            Rental.user_id == current_user.id,
            Rental.status == "completed",
            Rental.actual_end_time.isnot(None),
            Rental.start_time.isnot(None),
        )
    ).one()
    total_rentals, total_seconds = result
    total_hours = total_seconds / 3600.0

    # Assume 1 hour usage saves 0.5 kg CO2
    carbon_saved_kg = total_hours * 0.5
    trees_equivalent = carbon_saved_kg / 21
    
    return DataResponse(
        success=True,
        data={
            "total_rentals": total_rentals,
            "total_hours": round(total_hours, 2),
            "carbon_saved_kg": round(carbon_saved_kg, 2),
            "trees_equivalent": round(trees_equivalent, 2),
            "comparison": {
                "car_km_saved": round(carbon_saved_kg * 5, 2),
                "plastic_bottles_saved": int(carbon_saved_kg * 50)
            }
        }
    )

@router.get("/export")
def export_analytics_data(
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db),
    format: str = Query("json", pattern="^(json|csv)$"),
    from_date: Optional[str] = Query(default=None),
    to_date: Optional[str] = Query(default=None),
):
    """Export user rentals + transactions with KPI summary in JSON or CSV."""
    from app.models.rental import Rental
    from app.models.financial import Transaction
    from sqlmodel import select

    def _parse_export_datetime(
        value: Optional[str],
        *,
        field_name: str,
        end_of_day: bool = False,
    ) -> Optional[datetime]:
        if value is None:
            return None

        raw = value.strip()
        if not raw:
            return None

        try:
            if "T" not in raw and len(raw) == 10:
                parsed_date = date.fromisoformat(raw)
                parsed_time = time.max if end_of_day else time.min
                return datetime.combine(parsed_date, parsed_time, tzinfo=UTC)

            if raw.endswith("Z"):
                raw = raw[:-1] + "+00:00"
            parsed = datetime.fromisoformat(raw)
        except ValueError as exc:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid {field_name}. Use ISO-8601 date or datetime.",
            ) from exc

        if parsed.tzinfo is None:
            return parsed.replace(tzinfo=UTC)
        return parsed.astimezone(UTC)

    def _enum_value(value: Any) -> str:
        if value is None:
            return ""
        if hasattr(value, "value"):
            return str(value.value)
        return str(value)

    def _month_key(ts: Optional[datetime]) -> str:
        if ts is None:
            return "unknown"
        normalized = ts if ts.tzinfo else ts.replace(tzinfo=UTC)
        return normalized.strftime("%Y-%m")

    fmt = (format or "json").lower()
    start_at = _parse_export_datetime(from_date, field_name="from_date")
    end_at = _parse_export_datetime(to_date, field_name="to_date", end_of_day=True)
    if start_at and end_at and start_at > end_at:
        raise HTTPException(status_code=400, detail="from_date must be earlier than to_date")

    rental_query = select(Rental).where(Rental.user_id == current_user.id)
    if start_at is not None:
        rental_query = rental_query.where(Rental.start_time >= start_at)
    if end_at is not None:
        rental_query = rental_query.where(Rental.start_time <= end_at)
    rental_query = rental_query.order_by(Rental.start_time.desc())
    rentals = session.exec(rental_query).all()

    txn_query = select(Transaction).where(Transaction.user_id == current_user.id)
    if start_at is not None:
        txn_query = txn_query.where(Transaction.created_at >= start_at)
    if end_at is not None:
        txn_query = txn_query.where(Transaction.created_at <= end_at)
    txn_query = txn_query.order_by(Transaction.created_at.desc())
    transactions = session.exec(txn_query).all()

    total_rental_amount = 0.0
    total_late_fees = 0.0
    total_distance_km = 0.0
    completed_rentals = 0
    active_rentals = 0
    total_duration_minutes = 0.0
    rental_duration_count = 0

    monthly_rental_breakdown: dict[str, dict[str, float | int]] = defaultdict(
        lambda: {"rentals": 0, "revenue": 0.0, "distance_km": 0.0}
    )

    serialized_rentals: list[dict[str, Any]] = []
    for rental in rentals:
        status = _enum_value(rental.status)
        start_time = rental.start_time
        end_time = rental.end_time

        total_rental_amount += float(rental.total_amount or 0.0)
        total_late_fees += float(rental.late_fee or 0.0)
        total_distance_km += float(rental.distance_traveled_km or 0.0)

        if status == "completed":
            completed_rentals += 1
        if status == "active":
            active_rentals += 1

        duration_minutes = None
        if start_time and end_time and end_time > start_time:
            duration_minutes = round((end_time - start_time).total_seconds() / 60, 2)
            total_duration_minutes += duration_minutes
            rental_duration_count += 1

        month_key = _month_key(start_time)
        monthly_rental_breakdown[month_key]["rentals"] += 1
        monthly_rental_breakdown[month_key]["revenue"] += float(rental.total_amount or 0.0)
        monthly_rental_breakdown[month_key]["distance_km"] += float(
            rental.distance_traveled_km or 0.0
        )

        serialized_rentals.append(
            {
                "id": rental.id,
                "battery_id": rental.battery_id,
                "start_station_id": rental.start_station_id,
                "end_station_id": rental.end_station_id,
                "start_time": start_time.isoformat() if start_time else None,
                "end_time": end_time.isoformat() if end_time else None,
                "duration_minutes": duration_minutes,
                "total_amount": round(float(rental.total_amount or 0.0), 2),
                "late_fee": round(float(rental.late_fee or 0.0), 2),
                "distance_traveled_km": round(float(rental.distance_traveled_km or 0.0), 2),
                "status": status,
            }
        )

    total_transaction_amount = 0.0
    successful_transaction_amount = 0.0
    failed_transactions = 0

    by_transaction_type: dict[str, float] = defaultdict(float)
    by_payment_method: dict[str, float] = defaultdict(float)
    monthly_transaction_breakdown: dict[str, dict[str, float | int]] = defaultdict(
        lambda: {"transactions": 0, "amount": 0.0, "successful_amount": 0.0}
    )

    serialized_transactions: list[dict[str, Any]] = []
    for txn in transactions:
        status = _enum_value(txn.status)
        txn_type = _enum_value(txn.transaction_type)
        payment_method = (txn.payment_method or "").strip().lower() or "unknown"
        amount_value = float(txn.amount or 0.0)

        total_transaction_amount += amount_value
        by_transaction_type[txn_type] += amount_value
        by_payment_method[payment_method] += amount_value

        month_key = _month_key(txn.created_at)
        monthly_transaction_breakdown[month_key]["transactions"] += 1
        monthly_transaction_breakdown[month_key]["amount"] += amount_value

        if status == "success":
            successful_transaction_amount += amount_value
            monthly_transaction_breakdown[month_key]["successful_amount"] += amount_value
        elif status in {"failed", "cancelled"}:
            failed_transactions += 1

        serialized_transactions.append(
            {
                "id": txn.id,
                "rental_id": txn.rental_id,
                "wallet_id": txn.wallet_id,
                "amount": round(amount_value, 2),
                "currency": txn.currency,
                "transaction_type": txn_type,
                "status": status,
                "payment_method": payment_method,
                "payment_gateway_ref": txn.payment_gateway_ref,
                "created_at": txn.created_at.isoformat() if txn.created_at else None,
                "description": txn.description,
            }
        )

    avg_rental_duration_minutes = (
        round(total_duration_minutes / rental_duration_count, 2)
        if rental_duration_count > 0
        else 0.0
    )

    summary = {
        "window": {
            "from": start_at.isoformat() if start_at else None,
            "to": end_at.isoformat() if end_at else None,
            "generated_at": datetime.now(UTC).isoformat(),
        },
        "rentals": {
            "total_count": len(rentals),
            "completed_count": completed_rentals,
            "active_count": active_rentals,
            "total_amount": round(total_rental_amount, 2),
            "total_late_fees": round(total_late_fees, 2),
            "total_distance_km": round(total_distance_km, 2),
            "avg_duration_minutes": avg_rental_duration_minutes,
        },
        "transactions": {
            "total_count": len(transactions),
            "failed_count": failed_transactions,
            "total_amount": round(total_transaction_amount, 2),
            "successful_amount": round(successful_transaction_amount, 2),
            "by_type": {key: round(value, 2) for key, value in sorted(by_transaction_type.items())},
            "by_payment_method": {
                key: round(value, 2) for key, value in sorted(by_payment_method.items())
            },
        },
        "monthly_breakdown": {
            "rentals": {
                key: {
                    "rentals": int(value["rentals"]),
                    "revenue": round(float(value["revenue"]), 2),
                    "distance_km": round(float(value["distance_km"]), 2),
                }
                for key, value in sorted(monthly_rental_breakdown.items())
            },
            "transactions": {
                key: {
                    "transactions": int(value["transactions"]),
                    "amount": round(float(value["amount"]), 2),
                    "successful_amount": round(float(value["successful_amount"]), 2),
                }
                for key, value in sorted(monthly_transaction_breakdown.items())
            },
        },
    }

    payload = {
        "user_id": current_user.id,
        "summary": summary,
        "rentals": serialized_rentals,
        "transactions": serialized_transactions,
    }

    if fmt == "csv":
        output = io.StringIO()
        writer = csv.writer(output)
        writer.writerow(
            [
                "section",
                "id",
                "status",
                "amount",
                "currency",
                "transaction_type",
                "payment_method",
                "start_time",
                "end_time",
                "created_at",
                "details",
            ]
        )

        for row in serialized_rentals:
            writer.writerow(
                [
                    "rental",
                    row["id"],
                    row["status"],
                    row["total_amount"],
                    "INR",
                    "rental",
                    "",
                    row["start_time"],
                    row["end_time"],
                    "",
                    (
                        f"battery_id={row['battery_id']};start_station={row['start_station_id']};"
                        f"end_station={row['end_station_id']};distance_km={row['distance_traveled_km']};"
                        f"late_fee={row['late_fee']}"
                    ),
                ]
            )

        for row in serialized_transactions:
            writer.writerow(
                [
                    "transaction",
                    row["id"],
                    row["status"],
                    row["amount"],
                    row["currency"],
                    row["transaction_type"],
                    row["payment_method"],
                    "",
                    "",
                    row["created_at"],
                    row.get("description") or "",
                ]
            )

        writer.writerow(
            [
                "summary",
                "totals",
                "",
                summary["rentals"]["total_amount"],
                "INR",
                "rental_totals",
                "",
                "",
                "",
                summary["window"]["generated_at"],
                (
                    f"rentals={summary['rentals']['total_count']};completed={summary['rentals']['completed_count']};"
                    f"distance_km={summary['rentals']['total_distance_km']};"
                    f"avg_duration_min={summary['rentals']['avg_duration_minutes']}"
                ),
            ]
        )
        writer.writerow(
            [
                "summary",
                "transactions",
                "",
                summary["transactions"]["total_amount"],
                "INR",
                "transaction_totals",
                "",
                "",
                "",
                summary["window"]["generated_at"],
                (
                    f"transactions={summary['transactions']['total_count']};"
                    f"failed={summary['transactions']['failed_count']};"
                    f"successful_amount={summary['transactions']['successful_amount']}"
                ),
            ]
        )

        filename_window = summary["window"]["from"] or "all"
        return Response(
            content=output.getvalue(),
            media_type="text/csv",
            headers={
                "Content-Disposition": (
                    f"attachment; filename=analytics_{current_user.id}_{filename_window}.csv"
                )
            },
        )

    return DataResponse(success=True, data=payload)


@router.get("/recent-activity")
def get_recent_activity(
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db),
):
    """Recent activity feed for dashboard clients."""
    role_names = deps.get_user_role_names(current_user)
    if role_names & deps.INTERNAL_OPERATOR_ROLE_NAMES:
        raw_activity = AdminAnalyticsService.get_recent_activity(session)
        if isinstance(raw_activity, dict):
            items = raw_activity.get("items")
            if isinstance(items, list):
                return DataResponse(success=True, data={"items": items})
            return DataResponse(success=True, data={"items": [raw_activity]})
        if isinstance(raw_activity, list):
            return DataResponse(success=True, data={"items": raw_activity})
        return DataResponse(success=True, data={"items": []})

    # Customer fallback: synthesize from recent rentals.
    rental_history = AnalyticsService.get_rental_history_stats(current_user.id, session) or {}
    items = [
        {
            "id": f"user-{current_user.id}-rentals",
            "title": "Rental activity updated",
            "action": "rental_stats_updated",
            "timestamp": datetime.now(UTC).isoformat(),
            "meta": rental_history,
        }
    ]
    return DataResponse(success=True, data={"items": items})


class DashboardReportRequest(BaseModel):
    from_: Optional[str] = Field(default=None, alias="from")
    to: Optional[str] = Field(default=None)
    timezone: str = Field(default="UTC")
    format: str = Field(default="csv")
    include_sections: list[str] = Field(default_factory=list)


@dataclass
class _DashboardReportRecord:
    report_id: str
    status: str
    created_at: datetime
    expires_at: datetime
    content: bytes
    content_type: str
    filename: str
    detail: Optional[str] = None


_REPORT_KEY_PREFIX = "analytics_report:"


class _ReportStore:
    """Redis-primary, process-memory fallback store for dashboard reports.

    In multi-worker deployments (Gunicorn / multiple Uvicorn processes) each
    worker has its own heap, so a plain dict would make report IDs invisible
    across processes.  Redis is the shared source of truth; the local dict
    kicks in only when Redis is unreachable (single-worker dev/test scenarios).
    """

    _local: dict[str, _DashboardReportRecord] = {}
    _lock = Lock()

    @staticmethod
    def _redis_key(report_id: str) -> str:
        return f"{_REPORT_KEY_PREFIX}{report_id}"

    @classmethod
    def save(cls, record: _DashboardReportRecord) -> None:
        client = RedisService.get_client()
        if client is not None:
            try:
                payload = json.dumps(
                    {
                        "report_id": record.report_id,
                        "status": record.status,
                        "created_at": record.created_at.isoformat(),
                        "expires_at": record.expires_at.isoformat(),
                        # base64 so both CSV (text) and PDF (bytes) survive JSON round-trip
                        "content_b64": base64.b64encode(record.content).decode("ascii"),
                        "content_type": record.content_type,
                        "filename": record.filename,
                        "detail": record.detail,
                    }
                )
                client.setex(
                    cls._redis_key(record.report_id),
                    settings.ANALYTICS_REPORT_TTL_SECONDS,
                    payload,
                )
                return
            except Exception:
                logger.warning(
                    "analytics_report.redis_save_failed report_id=%s",
                    record.report_id,
                    exc_info=True,
                )

        # Fallback: process-local memory with best-effort expiry pruning on write.
        with cls._lock:
            now = datetime.now(UTC)
            for stale in [k for k, v in cls._local.items() if v.expires_at <= now]:
                cls._local.pop(stale, None)
            cls._local[record.report_id] = record

    @classmethod
    def get(cls, report_id: str) -> Optional[_DashboardReportRecord]:
        client = RedisService.get_client()
        if client is not None:
            try:
                raw = client.get(cls._redis_key(report_id))
                if raw:
                    data = json.loads(raw)
                    return _DashboardReportRecord(
                        report_id=data["report_id"],
                        status=data["status"],
                        created_at=datetime.fromisoformat(data["created_at"]),
                        expires_at=datetime.fromisoformat(data["expires_at"]),
                        content=base64.b64decode(data["content_b64"]),
                        content_type=data["content_type"],
                        filename=data["filename"],
                        detail=data.get("detail"),
                    )
                return None
            except Exception:
                logger.warning(
                    "analytics_report.redis_get_failed report_id=%s",
                    report_id,
                    exc_info=True,
                )

        with cls._lock:
            return cls._local.get(report_id)


def _parse_iso_datetime(raw_value: Optional[str], *, end_of_day: bool = False) -> Optional[datetime]:
    if raw_value is None:
        return None
    value = raw_value.strip()
    if not value:
        return None
    try:
        if value.endswith("Z"):
            value = value[:-1] + "+00:00"
        parsed = datetime.fromisoformat(value)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail="Invalid datetime format") from exc

    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=UTC)
    else:
        parsed = parsed.astimezone(UTC)

    if end_of_day and parsed.hour == 0 and parsed.minute == 0 and parsed.second == 0:
        parsed = parsed.replace(hour=23, minute=59, second=59, microsecond=999999)
    return parsed


def _pdf_escape(value: str) -> str:
    return value.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)")


def _build_minimal_pdf(lines: list[str]) -> bytes:
    safe_lines = [line.strip()[:200] for line in lines if line.strip()]
    if not safe_lines:
        safe_lines = ["Dashboard report"]

    stream_lines = ["BT", "/F1 12 Tf", "50 790 Td"]
    for line in safe_lines:
        stream_lines.append(f"({_pdf_escape(line)}) Tj")
        stream_lines.append("0 -16 Td")
    stream_lines.append("ET")
    stream_content = "\n".join(stream_lines).encode("latin-1", "replace")

    objects: list[bytes] = []
    objects.append(b"<< /Type /Catalog /Pages 2 0 R >>")
    objects.append(b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>")
    objects.append(
        b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] "
        b"/Resources << /Font << /F1 5 0 R >> >> /Contents 4 0 R >>"
    )
    objects.append(
        b"<< /Length " + str(len(stream_content)).encode("ascii") + b" >>\nstream\n"
        + stream_content
        + b"\nendstream"
    )
    objects.append(b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>")

    buffer = io.BytesIO()
    buffer.write(b"%PDF-1.4\n%\xe2\xe3\xcf\xd3\n")
    offsets = [0]
    for index, obj in enumerate(objects, start=1):
        offsets.append(buffer.tell())
        buffer.write(f"{index} 0 obj\n".encode("ascii"))
        buffer.write(obj)
        buffer.write(b"\nendobj\n")

    xref_position = buffer.tell()
    buffer.write(f"xref\n0 {len(objects) + 1}\n".encode("ascii"))
    buffer.write(b"0000000000 65535 f \n")
    for offset in offsets[1:]:
        buffer.write(f"{offset:010d} 00000 n \n".encode("ascii"))
    buffer.write(
        (
            f"trailer << /Size {len(objects) + 1} /Root 1 0 R >>\n"
            f"startxref\n{xref_position}\n%%EOF"
        ).encode("ascii")
    )
    return buffer.getvalue()


def _flatten_report_dict(prefix: str, value: Any, output: list[tuple[str, str]]) -> None:
    if isinstance(value, dict):
        for key, nested in value.items():
            next_prefix = f"{prefix}.{key}" if prefix else str(key)
            _flatten_report_dict(next_prefix, nested, output)
        return
    if isinstance(value, list):
        output.append((prefix, json.dumps(value, default=str)))
        return
    output.append((prefix, "" if value is None else str(value)))


def _build_report_payload(
    current_user: User,
    session: Session,
    start_at: Optional[datetime],
    end_at: Optional[datetime],
) -> dict[str, Any]:
    role_names = deps.get_user_role_names(current_user)
    if role_names & deps.INTERNAL_OPERATOR_ROLE_NAMES:
        overview = AdminAnalyticsService.get_overview(session)
        recent_activity = AdminAnalyticsService.get_recent_activity(session)
        return {
            "scope": "internal",
            "window": {
                "from": start_at.isoformat() if start_at else None,
                "to": end_at.isoformat() if end_at else None,
                "generated_at": datetime.now(UTC).isoformat(),
            },
            "overview": overview,
            "recent_activity": recent_activity,
        }

    dashboard = AnalyticsService.get_customer_dashboard(current_user.id, session)
    rental_history = AnalyticsService.get_rental_history_stats(current_user.id, session)
    return {
        "scope": "customer",
        "window": {
            "from": start_at.isoformat() if start_at else None,
            "to": end_at.isoformat() if end_at else None,
            "generated_at": datetime.now(UTC).isoformat(),
        },
        "dashboard": dashboard,
        "rental_history": rental_history,
    }


def _create_report_content(payload: dict[str, Any], report_format: str) -> tuple[bytes, str, str]:
    normalized_format = report_format.strip().lower()
    if normalized_format == "pdf":
        flattened: list[tuple[str, str]] = []
        _flatten_report_dict("", payload, flattened)
        lines = [f"{key}: {value}" for key, value in flattened[:120]]
        report_bytes = _build_minimal_pdf(lines)
        return report_bytes, "application/pdf", "dashboard_report.pdf"

    flattened_rows: list[tuple[str, str]] = []
    _flatten_report_dict("", payload, flattened_rows)
    stream = io.StringIO()
    writer = csv.writer(stream)
    writer.writerow(["key", "value"])
    for row in flattened_rows:
        writer.writerow(row)
    report_bytes = stream.getvalue().encode("utf-8")
    return report_bytes, "text/csv", "dashboard_report.csv"


def _get_report_or_404(report_id: str) -> _DashboardReportRecord:
    record = _ReportStore.get(report_id)
    if not record:
        raise HTTPException(status_code=404, detail="Report not found")
    if record.expires_at <= datetime.now(UTC):
        raise HTTPException(status_code=404, detail="Report expired")
    return record

import threading
from app.db.session import SessionLocal


def _generate_report_in_thread(
    report_id: str,
    user_id: int,
    start_at: Optional[datetime],
    end_at: Optional[datetime],
    report_format: str,
) -> None:
    """Run report generation in a detached thread with its own DB session.

    IMPORTANT: Every code path MUST update the report status in Redis to
    either 'completed' or 'failed'.  The previous implementation had multiple
    silent-drop paths where _ReportStore.get() returned None and the status
    was never updated, leaving the Flutter app polling 'processing' forever.
    """
    import sys
    import traceback as _tb

    def _save_result(
        *,
        status: str,
        content: bytes = b"",
        content_type: str = "",
        filename: str = "",
        detail: Optional[str] = None,
    ) -> None:
        """Construct a fresh record and save — never depends on .get()."""
        now = datetime.now(UTC)
        record = _DashboardReportRecord(
            report_id=report_id,
            status=status,
            created_at=now,
            expires_at=now + timedelta(seconds=settings.ANALYTICS_REPORT_TTL_SECONDS),
            content=content,
            content_type=content_type,
            filename=filename,
            detail=detail,
        )
        try:
            _ReportStore.save(record)
        except Exception:
            # Absolute last resort — if we can't even write to Redis
            print(
                f"[REPORT CRITICAL] Cannot save report {report_id} status={status}: "
                f"{_tb.format_exc()}",
                file=sys.stderr,
                flush=True,
            )

    try:
        with SessionLocal() as session:
            from app.models.user import User
            from sqlalchemy.orm import selectinload

            # Eagerly load role (singular) so get_user_role_names doesn't hit
            # lazy-load issues outside a request context.
            stmt = (
                select(User)
                .where(User.id == user_id)
                .options(selectinload(User.role))
            )
            current_user = session.exec(stmt).first()

            if not current_user:
                _save_result(status="failed", detail="User not found")
                return

            report_payload = _build_report_payload(
                current_user, session, start_at, end_at
            )
            content, content_type, filename = _create_report_content(
                report_payload, report_format=report_format
            )

            _save_result(
                status="completed",
                content=content,
                content_type=content_type,
                filename=filename,
            )
            logger.info(
                "report_generation_completed",
                report_id=report_id,
                size_bytes=len(content),
            )
    except Exception as exc:
        detail = f"{type(exc).__name__}: {exc}"
        logger.exception("report_generation_failed report_id=%s", report_id)
        # Also print to stderr so it appears in docker logs even if
        # structlog is misconfigured for background threads.
        print(
            f"[REPORT ERROR] {report_id}: {detail}\n{_tb.format_exc()}",
            file=sys.stderr,
            flush=True,
        )
        _save_result(status="failed", detail=detail[:500])


@router.post("/reports/dashboard")
def queue_dashboard_report(
    request: DashboardReportRequest,
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db),
):
    start_at = _parse_iso_datetime(request.from_)
    end_at = _parse_iso_datetime(request.to, end_of_day=True)
    if start_at and end_at and start_at > end_at:
        raise HTTPException(status_code=400, detail="'from' must be earlier than 'to'")

    report_id = f"rpt_{uuid4().hex[:16]}"
    now = datetime.now(UTC)

    # Save a placeholder record so the polling endpoint can find it immediately.
    record = _DashboardReportRecord(
        report_id=report_id,
        status="processing",
        created_at=now,
        expires_at=now + timedelta(seconds=settings.ANALYTICS_REPORT_TTL_SECONDS),
        content=b"",
        content_type="",
        filename="",
    )
    _ReportStore.save(record)

    # Fire-and-forget: a raw thread is independent of the ASGI response
    # lifecycle, so it won't trigger EndOfStream / WouldBlock when the
    # HTTP response finishes and Starlette tears down its memory streams.
    thread = threading.Thread(
        target=_generate_report_in_thread,
        kwargs={
            "report_id": report_id,
            "user_id": current_user.id,
            "start_at": start_at,
            "end_at": end_at,
            "report_format": request.format or "csv",
        },
        daemon=True,
    )
    thread.start()

    return DataResponse(
        success=True,
        data={
            "report_id": report_id,
            "status": "processing",
        },
    )


@router.get("/reports/{report_id}")
def get_dashboard_report_status(
    report_id: str,
    current_user: User = Depends(deps.get_current_user),
):
    report = _get_report_or_404(report_id)
    return DataResponse(
        success=True,
        data={
            "report_id": report.report_id,
            "status": report.status,
            "file_url": f"/api/v1/analytics/reports/{report.report_id}/download",
            "expires_at": report.expires_at.isoformat(),
            "detail": report.detail,
        },
    )


@router.get("/reports/{report_id}/download")
def download_dashboard_report(
    report_id: str,
    current_user: User = Depends(deps.get_current_user),
):
    report = _get_report_or_404(report_id)
    return Response(
        content=report.content,
        media_type=report.content_type,
        headers={
            "Content-Disposition": f'attachment; filename="{report.filename}"',
            "Cache-Control": "private, max-age=300",
        },
    )
