from __future__ import annotations

import base64
import json
from datetime import datetime
from typing import Any, Optional

from fastapi import HTTPException


def encode_cursor(payload: dict[str, Any]) -> str:
    raw = json.dumps(payload, separators=(",", ":"), sort_keys=True).encode("utf-8")
    return base64.urlsafe_b64encode(raw).decode("utf-8").rstrip("=")


def decode_cursor(cursor: Optional[str]) -> Optional[dict[str, Any]]:
    if cursor is None:
        return None
    token = str(cursor).strip()
    if not token:
        return None
    padding = "=" * (-len(token) % 4)
    try:
        decoded = base64.urlsafe_b64decode((token + padding).encode("utf-8"))
        payload = json.loads(decoded.decode("utf-8"))
    except Exception as exc:
        raise HTTPException(status_code=400, detail=f"Invalid cursor: {exc}") from exc
    if not isinstance(payload, dict):
        raise HTTPException(status_code=400, detail="Invalid cursor payload")
    return payload


def cursor_datetime(value: Any, *, field_name: str) -> datetime:
    if isinstance(value, datetime):
        return value
    try:
        return datetime.fromisoformat(str(value))
    except Exception as exc:
        raise HTTPException(status_code=400, detail=f"Invalid cursor field '{field_name}'") from exc


def cursor_int(value: Any, *, field_name: str) -> int:
    try:
        parsed = int(value)
    except Exception as exc:
        raise HTTPException(status_code=400, detail=f"Invalid cursor field '{field_name}'") from exc
    if parsed < 0:
        raise HTTPException(status_code=400, detail=f"Invalid cursor field '{field_name}'")
    return parsed
