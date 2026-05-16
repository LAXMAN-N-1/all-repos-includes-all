"""
Disconnect detection for BaseHTTPMiddleware subclasses.

Starlette's BaseHTTPMiddleware uses internal anyio memory streams to pipe
the response from the application back through ``call_next``.  When the
client disconnects mid-request the stream tears down and raises
``anyio.EndOfStream`` / ``anyio.WouldBlock``.

This module exposes :func:`is_client_disconnect` which inspects an
exception's **full traceback** (same technique as the ASGI-level
``SafeDisconnectMiddleware``) to determine whether the failure is a
benign client disconnect.

Usage in ``BaseHTTPMiddleware.dispatch``::

    from app.middleware.disconnect import is_client_disconnect

    class MyMiddleware(BaseHTTPMiddleware):
        async def dispatch(self, request, call_next):
            try:
                response = await call_next(request)
            except Exception as exc:
                if is_client_disconnect(exc):
                    logger.debug("client disconnected")
                else:
                    logger.exception("request failed")
                raise  # always re-raise; let SafeDisconnectMiddleware handle suppression
"""

from __future__ import annotations

import traceback as _tb


_DISCONNECT_MARKERS = (
    "anyio.EndOfStream",
    "anyio.WouldBlock",
)


def is_client_disconnect(exc: BaseException) -> bool:
    """
    Return True if *exc* is a genuine client disconnect.

    Uses full traceback string inspection (matching the ASGI-level
    SafeDisconnectMiddleware) — this is the most reliable way to
    distinguish real disconnects from application errors that happen
    to pass through BaseHTTPMiddleware's memory stream machinery.
    """
    try:
        tb_str = "".join(_tb.format_exception(type(exc), exc, exc.__traceback__))
        return any(marker in tb_str for marker in _DISCONNECT_MARKERS)
    except Exception:
        return False
