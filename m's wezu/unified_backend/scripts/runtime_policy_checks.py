#!/usr/bin/env python3
"""
Runtime/tooling policy checks.

Fails when:
1) Repo runtime pin is missing or not Python 3.11.
2) Alembic env does not enforce Python 3.11+.
3) Test bootstrap does not enforce Python 3.11+.
4) Canonical wrapper scripts are missing.
5) `datetime.utcnow()` appears in application runtime code.
"""
from __future__ import annotations

from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
PYTHON_VERSION_FILE = ROOT / ".python-version"
ALEMBIC_ENV = ROOT / "alembic" / "env.py"
TESTS_CONFTEST = ROOT / "tests" / "conftest.py"
RUN_ALEMBIC = ROOT / "scripts" / "run_alembic.py"
RUN_PYTEST = ROOT / "scripts" / "run_pytest.py"
PY_RUNTIME = ROOT / "scripts" / "python_runtime.py"
APP_DIR = ROOT / "app"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def main() -> int:
    errors: list[str] = []

    if not PYTHON_VERSION_FILE.exists():
        errors.append(".python-version is missing")
    else:
        pinned = _read(PYTHON_VERSION_FILE).strip()
        if pinned != "3.11":
            errors.append(f".python-version must be '3.11', found {pinned!r}")

    alembic_text = _read(ALEMBIC_ENV)
    if "Python >= 3.11" not in alembic_text:
        errors.append(f"{ALEMBIC_ENV}: missing Python 3.11 guard")

    conftest_text = _read(TESTS_CONFTEST)
    if "Tests require Python >= 3.11" not in conftest_text:
        errors.append(f"{TESTS_CONFTEST}: missing Python 3.11 guard")

    for required_path in (RUN_ALEMBIC, RUN_PYTEST, PY_RUNTIME):
        if not required_path.exists():
            errors.append(f"missing required wrapper: {required_path}")

    utcnow_hits = [
        path
        for path in APP_DIR.rglob("*.py")
        if "datetime.utcnow(" in _read(path)
    ]
    if utcnow_hits:
        preview = ", ".join(str(path.relative_to(ROOT)) for path in utcnow_hits[:5])
        errors.append(f"datetime.utcnow() is forbidden in app runtime code ({preview})")

    if errors:
        print("RUNTIME_POLICY_CHECK_FAILED")
        for issue in errors:
            print(f"- {issue}")
        return 1

    print("RUNTIME_POLICY_CHECK_PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
