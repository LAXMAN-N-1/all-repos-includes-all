from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Optional
from uuid import uuid4

from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, Query
from fastapi.responses import Response
from pydantic import BaseModel, ConfigDict, Field, field_validator
from sqlmodel import Session

from app.api import deps
from app.models.user import User
from app.schemas.common import DataResponse
from app.services.analytics_dashboard_service import REPORT_SECTION_VALUES
from app.services.analytics_report_service import AnalyticsReportService

router = APIRouter()

_ALLOWED_REPORT_FORMATS = {"pdf", "csv", "xlsx"}


class DashboardReportRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    from_: Optional[str] = Field(default=None, alias="from")
    to: Optional[str] = Field(default=None)
    timezone: str = Field(default="UTC")
    format: str = Field(default="pdf")
    include_sections: list[str] = Field(default_factory=lambda: list(REPORT_SECTION_VALUES))

    @field_validator("format")
    @classmethod
    def _normalize_format(cls, value: str) -> str:
        normalized = (value or "pdf").strip().lower()
        if normalized not in _ALLOWED_REPORT_FORMATS:
            raise ValueError(f"format must be one of {sorted(_ALLOWED_REPORT_FORMATS)}")
        return normalized

    @field_validator("timezone")
    @classmethod
    def _normalize_timezone(cls, value: str) -> str:
        timezone_name = (value or "UTC").strip()
        return timezone_name or "UTC"


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
        parsed = parsed.replace(tzinfo=timezone.utc)
    else:
        parsed = parsed.astimezone(timezone.utc)

    if end_of_day and parsed.hour == 0 and parsed.minute == 0 and parsed.second == 0:
        parsed = parsed.replace(hour=23, minute=59, second=59, microsecond=999999)
    return parsed


def _enforce_report_access(job: Any, current_user: User) -> None:
    owner_id = getattr(job, "requested_by_user_id", None)
    if owner_id is None:
        return
    if current_user.is_superuser:
        return
    if int(owner_id) != int(current_user.id):
        raise HTTPException(status_code=403, detail="Forbidden")


@router.post("/reports/dashboard")
def queue_dashboard_report(
    request: DashboardReportRequest,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db),
):
    from_dt = _parse_iso_datetime(request.from_)
    to_dt = _parse_iso_datetime(request.to, end_of_day=True)
    if from_dt is None or to_dt is None:
        raise HTTPException(status_code=400, detail="'from' and 'to' are required")
    if from_dt > to_dt:
        raise HTTPException(status_code=400, detail="'from' must be earlier than 'to'")

    include_sections = [section for section in request.include_sections if section in REPORT_SECTION_VALUES]
    if not include_sections:
        include_sections = list(REPORT_SECTION_VALUES)

    report_id = f"rpt_{uuid4().hex[:16]}"
    job = AnalyticsReportService.queue_dashboard_report(
        session,
        report_id=report_id,
        from_dt=from_dt,
        to_dt=to_dt,
        timezone_name=request.timezone,
        report_format=request.format,
        include_sections=include_sections,
        requested_by_user_id=current_user.id,
    )

    background_tasks.add_task(AnalyticsReportService.run_dashboard_report_job, job.report_id)

    return DataResponse(
        success=True,
        data={
            "report_id": job.report_id,
            "status": job.status,
        },
    )


@router.get("/reports/{report_id}")
def get_dashboard_report_status(
    report_id: str,
    current_user: User = Depends(deps.get_current_user),
    session: Session = Depends(deps.get_db),
):
    job = AnalyticsReportService.get_report_status(session, report_id)
    _enforce_report_access(job, current_user)

    file_url = job.file_url
    if job.status == "completed":
        file_url = AnalyticsReportService.build_download_url(job.report_id, expires_at=job.expires_at)

    return DataResponse(
        success=True,
        data={
            "report_id": job.report_id,
            "status": job.status,
            "file_url": file_url,
            "expires_at": job.expires_at.isoformat() if job.expires_at else None,
            "detail": job.detail,
        },
    )


@router.get("/reports/{report_id}/download")
def download_dashboard_report(
    report_id: str,
    token: str = Query(default=""),
    session: Session = Depends(deps.get_db),
):
    if not token:
        raise HTTPException(status_code=401, detail="Download token required")
    if not AnalyticsReportService.is_valid_download_token(token, report_id=report_id):
        raise HTTPException(status_code=403, detail="Invalid or expired download token")

    job = AnalyticsReportService.get_report_status(session, report_id)
    now = datetime.utcnow()
    if job.expires_at and job.expires_at < now:
        raise HTTPException(status_code=410, detail="Report expired")

    file_bytes = AnalyticsReportService.read_report_file(job)
    report_format = (job.report_format or "pdf").strip().lower()
    media_types = {
        "pdf": "application/pdf",
        "csv": "text/csv",
        "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    }
    media_type = media_types.get(report_format, "application/octet-stream")
    filename = f"dashboard_report_{report_id}.{report_format}"

    return Response(
        content=file_bytes,
        media_type=media_type,
        headers={
            "Content-Disposition": f'attachment; filename="{filename}"',
            "Cache-Control": "private, max-age=300",
        },
    )
