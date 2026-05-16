"""
Real-time Logistics Order Updates API
WebSocket endpoint for push-based order state changes.
"""
from dataclasses import dataclass
from typing import Optional
import logging
from datetime import datetime, UTC

from fastapi import APIRouter, HTTPException, Query, WebSocket, WebSocketDisconnect
from sqlmodel import Session

from app.api import deps
from app.core.config import settings
from app.core.database import engine
from app.services.websocket_service import manager

router = APIRouter()
logger = logging.getLogger(__name__)


@dataclass
class _RealtimeAuthContext:
    user_id: int
    is_global: bool
    tenant_id: Optional[int]


def _normalize_token(raw_token: str) -> str:
    token = (raw_token or "").strip()
    if token.lower().startswith("bearer "):
        token = token.split(" ", 1)[1].strip()
    return token


def _extract_subprotocol_token(websocket: WebSocket) -> str:
    """
    Browser-safe token transport:
    `new WebSocket(url, ["bearer", "<jwt>"])`
    """
    header_value = (websocket.headers.get("sec-websocket-protocol") or "").strip()
    if not header_value:
        return ""

    parts = [segment.strip() for segment in header_value.split(",") if segment.strip()]
    if len(parts) >= 2 and parts[0].lower() == "bearer":
        return _normalize_token(parts[1])

    for part in parts:
        lowered = part.lower()
        if lowered.startswith("bearer."):
            return _normalize_token(part.split(".", 1)[1])
    return ""


def _extract_websocket_token(websocket: WebSocket, query_token: Optional[str]) -> str:
    auth_header = websocket.headers.get("authorization")
    if auth_header:
        token = _normalize_token(auth_header)
        if token:
            return token

    subprotocol_token = _extract_subprotocol_token(websocket)
    if subprotocol_token:
        return subprotocol_token

    normalized_query_token = _normalize_token(query_token or "")
    if normalized_query_token and settings.WEBSOCKET_ALLOW_QUERY_TOKEN:
        logger.warning("orders.websocket_query_token_used")
        return normalized_query_token
    if normalized_query_token:
        raise HTTPException(status_code=401, detail="query_token_not_allowed")

    raise HTTPException(status_code=401, detail="token_missing")


def _authenticate_internal_operator(token: str) -> _RealtimeAuthContext:
    normalized = _normalize_token(token)
    if not normalized:
        raise ValueError("Missing token")
    with Session(engine) as db:
        user = deps.get_user_from_token(db=db, token=normalized)
        role_names = deps.get_user_role_names(user)
        if not (user.is_superuser or role_names & deps.INTERNAL_OPERATOR_ROLE_NAMES):
            raise HTTPException(status_code=403, detail="insufficient_permissions")

        # Mirrors deps._is_global_admin_actor: logistics users authenticate with
        # Supabase tokens that do not carry tenant_id claims, so treat them as
        # global scope exactly as the HTTP middleware does.
        is_global = deps._is_global_admin_actor(user)
        if is_global:
            return _RealtimeAuthContext(user_id=user.id, is_global=True, tenant_id=None)

        # Non-global users: resolve tenant from DB. Supabase tokens may omit the
        # tenant claim from app_metadata; fall back to DB-resolved value when absent
        # to mirror the behaviour in deps.require_tenant_context.
        validated = deps._validate_access_token_by_mode(db, normalized)
        claim_tenant_id = validated.tenant_id
        local_tenant_id = deps._resolve_local_tenant_id(db, user)
        if local_tenant_id is None:
            raise HTTPException(status_code=403, detail="tenant_claim_invalid")
        if claim_tenant_id is not None and int(claim_tenant_id) != int(local_tenant_id):
            raise HTTPException(status_code=403, detail="tenant_claim_invalid")
        return _RealtimeAuthContext(
            user_id=user.id,
            is_global=False,
            tenant_id=int(local_tenant_id),
        )


async def _send_auth_error_and_close(
    websocket: WebSocket,
    *,
    status_code: int,
    detail: str,
) -> None:
    close_code = 4403 if status_code == 403 else 4401
    try:
        await websocket.accept()
        await websocket.send_json(
            {
                "type": "auth_error",
                "status_code": status_code,
                "detail": detail,
            }
        )
    except Exception:
        logger.debug("Orders WebSocket auth failure frame could not be delivered")
    finally:
        try:
            await websocket.close(code=close_code, reason=detail[:123])
        except Exception:
            pass


@router.websocket("/stream")
@router.websocket("/stream/{order_id}")
async def orders_stream(
    websocket: WebSocket,
    token: Optional[str] = Query(
        default=None,
        description="Deprecated fallback. Prefer Authorization header or Sec-WebSocket-Protocol bearer token transport.",
    ),
    order_id: Optional[str] = None,
):
    """
    WebSocket endpoint for order updates.

    Examples:
    - Authorization: Bearer <jwt>
    - Sec-WebSocket-Protocol: bearer, <jwt>
    """
    try:
        token_value = _extract_websocket_token(websocket, token)
        auth_context = _authenticate_internal_operator(token_value)
    except HTTPException as exc:
        status_code = 403 if exc.status_code == 403 else 401
        detail = str(exc.detail or "Invalid or unauthorized token")
        await _send_auth_error_and_close(
            websocket,
            status_code=status_code,
            detail=detail,
        )
        logger.warning(
            "Orders WebSocket auth failed: status=%s detail=%s path=%s",
            exc.status_code,
            exc.detail,
            websocket.url.path,
        )
        return
    except Exception as exc:
        await _send_auth_error_and_close(
            websocket,
            status_code=401,
            detail="Invalid or unauthorized token",
        )
        logger.warning(
            "Orders WebSocket auth failed: %s: %s path=%s",
            type(exc).__name__,
            exc,
            websocket.url.path,
            exc_info=True,
        )
        return

    await manager.connect(websocket, auth_context.user_id)
    try:
        if order_id:
            await manager.subscribe_order(
                auth_context.user_id,
                str(order_id),
                global_scope=auth_context.is_global,
                tenant_id=auth_context.tenant_id,
            )
        else:
            if not auth_context.is_global:
                await _send_auth_error_and_close(
                    websocket,
                    status_code=403,
                    detail="order_id_required_for_tenant_scope",
                )
                manager.disconnect(websocket, auth_context.user_id)
                return
            await manager.subscribe_all_orders(
                auth_context.user_id,
                global_scope=True,
            )

        await websocket.send_json(
            {
                "type": "orders_stream_ready",
                "timestamp": datetime.now(UTC).isoformat(),
                "scope": "global" if auth_context.is_global and not order_id else "order",
                "order_id": str(order_id) if order_id else None,
                "tenant_id": auth_context.tenant_id,
                "supports_inventory_location_subscriptions": True,
            }
        )

        while True:
            payload = await websocket.receive_json()
            command = (payload or {}).get("command")
            if command == "ping":
                await websocket.send_json(
                    {
                        "type": "pong",
                        "timestamp": datetime.now(UTC).isoformat(),
                    }
                )
            elif command == "subscribe_order":
                target_order_id = str((payload or {}).get("order_id") or "").strip()
                if target_order_id:
                    await manager.subscribe_order(
                        auth_context.user_id,
                        target_order_id,
                        global_scope=auth_context.is_global,
                        tenant_id=auth_context.tenant_id,
                    )
            elif command == "unsubscribe_order":
                target_order_id = str((payload or {}).get("order_id") or "").strip()
                if target_order_id:
                    await manager.unsubscribe_order(
                        auth_context.user_id,
                        target_order_id,
                        global_scope=auth_context.is_global,
                        tenant_id=auth_context.tenant_id,
                    )
            elif command == "subscribe_inventory_location":
                raw_location_type = str((payload or {}).get("location_type") or "").strip()
                raw_location_id = (payload or {}).get("location_id")
                try:
                    location_id_int = int(raw_location_id)
                    subscription_key = await manager.subscribe_inventory_location(
                        auth_context.user_id,
                        raw_location_type,
                        location_id_int,
                        global_scope=auth_context.is_global,
                        tenant_id=auth_context.tenant_id,
                    )
                    await websocket.send_json(
                        {
                            "type": "inventory_subscription_ack",
                            "timestamp": datetime.now(UTC).isoformat(),
                            "action": "subscribe",
                            "subscription_key": subscription_key,
                        }
                    )
                except Exception as exc:
                    await websocket.send_json(
                        {
                            "type": "inventory_subscription_error",
                            "timestamp": datetime.now(UTC).isoformat(),
                            "detail": str(exc),
                        }
                    )
            elif command == "unsubscribe_inventory_location":
                raw_location_type = str((payload or {}).get("location_type") or "").strip()
                raw_location_id = (payload or {}).get("location_id")
                try:
                    location_id_int = int(raw_location_id)
                    subscription_key = await manager.unsubscribe_inventory_location(
                        auth_context.user_id,
                        raw_location_type,
                        location_id_int,
                        global_scope=auth_context.is_global,
                        tenant_id=auth_context.tenant_id,
                    )
                    await websocket.send_json(
                        {
                            "type": "inventory_subscription_ack",
                            "timestamp": datetime.now(UTC).isoformat(),
                            "action": "unsubscribe",
                            "subscription_key": subscription_key,
                        }
                    )
                except Exception as exc:
                    await websocket.send_json(
                        {
                            "type": "inventory_subscription_error",
                            "timestamp": datetime.now(UTC).isoformat(),
                            "detail": str(exc),
                        }
                    )
    except WebSocketDisconnect:
        manager.disconnect(websocket, auth_context.user_id)
    except Exception as exc:
        logger.exception("Orders WebSocket runtime error: %s", exc)
        manager.disconnect(websocket, auth_context.user_id)
        await websocket.close()
