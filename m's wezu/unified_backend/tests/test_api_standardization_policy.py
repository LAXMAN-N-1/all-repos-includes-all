from __future__ import annotations

import ast
from pathlib import Path


TOUCHED_ROUTE_MODULES = [
    Path("app/api/v1/payments.py"),
    Path("app/api/v1/wallet.py"),
    Path("app/api/v1/wallet_enhanced.py"),
    Path("app/api/v1/notifications_enhanced.py"),
    Path("app/api/v1/support.py"),
    Path("app/api/v1/sessions.py"),
    Path("app/api/v1/orders.py"),
    Path("app/main.py"),
]


HTTP_DECORATORS = {"get", "post", "put", "patch", "delete"}


def _iter_route_decorators(module_path: Path):
    tree = ast.parse(module_path.read_text(encoding="utf-8"), filename=str(module_path))
    for node in ast.walk(tree):
        if not isinstance(node, ast.FunctionDef | ast.AsyncFunctionDef):
            continue
        for dec in node.decorator_list:
            if not isinstance(dec, ast.Call):
                continue
            if not isinstance(dec.func, ast.Attribute):
                continue
            if dec.func.attr not in HTTP_DECORATORS:
                continue
            yield module_path, node, dec


def test_no_explicit_response_model_dict_in_touched_modules():
    offenders: list[str] = []
    for module_path in TOUCHED_ROUTE_MODULES:
        if not module_path.exists():
            continue
        for path, fn, dec in _iter_route_decorators(module_path):
            for kw in dec.keywords:
                if kw.arg != "response_model":
                    continue
                if isinstance(kw.value, ast.Name) and kw.value.id == "dict":
                    offenders.append(f"{path}:{fn.lineno} -> {fn.name}")
    assert not offenders, "Explicit response_model=dict is forbidden in touched modules:\n" + "\n".join(offenders)


def test_main_has_no_removed_legacy_mounts():
    main_text = Path("app/main.py").read_text(encoding="utf-8")
    forbidden_snippets = [
        'prefix=f"{v1_str}/dealer/portal',
        'prefix=f"{v1_str}/orders"',
        'prefix=f"{v1_str}/telemetry"',
        'prefix=f"{v1_str}/location"',
        'prefix=f"{v1_str}/warehouse"',
        'prefix="/api/webhooks"',
    ]
    hits = [snippet for snippet in forbidden_snippets if snippet in main_text]
    assert not hits, "Found forbidden legacy mounts in app/main.py: " + ", ".join(hits)
