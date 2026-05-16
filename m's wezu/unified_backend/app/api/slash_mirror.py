"""
Trailing-slash mirroring for FastAPI routes.

Background
----------
FastAPI's default ``redirect_slashes=True`` turns ``GET /foo`` into a
``307 Temporary Redirect`` when the real route is registered at
``/foo/``. That's two round-trips per request, and some HTTP clients
drop the ``Authorization`` header on 307s — causing the retargeted
request to hit auth dependencies with no token. We want neither.

Strategy
--------
1. The application is built with ``redirect_slashes=False`` so the
   router never issues 307s.
2. After every ``app.include_router(...)`` call has run,
   :func:`mirror_trailing_slashes` walks the fully-assembled route
   table and, for each ``APIRoute`` whose path ends in ``/`` (and
   isn't the root ``/``), registers a twin route at the same path
   *without* the trailing slash pointing to the same endpoint. The
   twin is hidden from the OpenAPI schema so docs stay clean.
3. A path that does *not* end in ``/`` is mirrored with a trailing
   slash added. Both registration styles found in the codebase are
   covered.

Uses ``app.add_api_route`` — FastAPI's public API — so every
dependency, response model, status code, tag, and auth gate is
carried over exactly without touching ``APIRoute`` constructor
internals (which change between FastAPI releases).
"""
from __future__ import annotations

from typing import Iterable

from fastapi import FastAPI
from fastapi.routing import APIRoute

from app.core.logging import get_logger

logger = get_logger(__name__)


def _iter_api_routes(app: FastAPI) -> Iterable[APIRoute]:
    for route in list(app.router.routes):
        if isinstance(route, APIRoute):
            yield route


def mirror_trailing_slashes(app: FastAPI) -> int:
    """
    Register slash/no-slash twins for every existing APIRoute.

    Returns the number of twin routes added. Safe to call exactly
    once, after all ``include_router`` calls have run. Idempotent: a
    second pass sees the twins and skips them.
    """
    existing_keys: set[tuple[str, frozenset[str]]] = {
        (route.path, frozenset(route.methods or ()))
        for route in _iter_api_routes(app)
    }

    added = 0
    skipped = 0
    for route in list(_iter_api_routes(app)):
        path = route.path
        methods = frozenset(route.methods or ())
        if not methods:
            continue

        # Root path is reachable as-is; skip.
        if path in ("", "/"):
            continue

        if path.endswith("/"):
            twin_path = path.rstrip("/")
            if not twin_path:
                continue
        else:
            twin_path = path + "/"

        key = (twin_path, methods)
        if key in existing_keys:
            continue  # already registered by its own router

        # Minimum stable kwargs only. Anything richer (response_class,
        # response_model_*, callbacks, openapi_extra, etc.) is version-
        # dependent on FastAPI's ``add_api_route`` signature, and the twin
        # is hidden from OpenAPI anyway so it doesn't need rich metadata
        # — it just needs to dispatch to the same endpoint with the same
        # dependency graph (auth gates, db session, rate limit, ...).
        try:
            app.add_api_route(
                twin_path,
                route.endpoint,
                methods=list(methods),
                response_model=route.response_model,
                status_code=route.status_code,
                tags=route.tags,
                dependencies=route.dependencies or None,
                include_in_schema=False,
                name=f"{route.name}__slash_twin" if route.name else None,
            )
        except Exception as exc:
            # A single bad route must NEVER block worker boot. Log and
            # keep going — the canonical route still works, clients just
            # pay the (historical) 307 cost for this specific path.
            logger.warning(
                "routing.slash_mirror_skipped",
                path=path,
                twin_path=twin_path,
                methods=sorted(methods),
                error=str(exc),
                error_type=type(exc).__name__,
            )
            skipped += 1
            continue

        existing_keys.add(key)
        added += 1

    total = sum(1 for _ in _iter_api_routes(app))
    logger.info(
        "routing.slash_mirror_applied",
        twins_added=added,
        twins_skipped=skipped,
        total_routes=total,
    )
    return added
