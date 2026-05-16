#!/usr/bin/env python3
from __future__ import annotations

import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Iterable, Sequence


ROOT = Path(__file__).resolve().parents[1]
MIN_VERSION = (3, 11)


def _candidate_interpreters() -> list[str]:
    candidates: list[str] = []
    explicit = os.getenv("WEZU_PYTHON", "").strip()
    if explicit:
        candidates.append(explicit)

    local_candidates = [
        ROOT / ".venv" / "bin" / "python",
        ROOT / ".venv311" / "bin" / "python",
        ROOT / ".venv-seed" / "bin" / "python",
        ROOT / "venv" / "bin" / "python",
        ROOT / "tmpenv" / "bin" / "python",
    ]
    for path in local_candidates:
        if path.exists() and os.access(path, os.X_OK):
            candidates.append(str(path))

    for name in ("python3.12", "python3.11", "python3", "python"):
        resolved = shutil.which(name)
        if resolved:
            candidates.append(resolved)

    candidates.append(sys.executable)

    deduped: list[str] = []
    seen: set[str] = set()
    for item in candidates:
        normalized = str(Path(item).resolve()) if Path(item).exists() else item
        if normalized in seen:
            continue
        seen.add(normalized)
        deduped.append(item)
    return deduped


def _read_version(interpreter: str) -> tuple[int, int] | None:
    proc = subprocess.run(
        [interpreter, "-c", "import sys;print(f'{sys.version_info[0]}.{sys.version_info[1]}')"],
        capture_output=True,
        text=True,
        check=False,
    )
    if proc.returncode != 0:
        return None
    raw = (proc.stdout or "").strip()
    parts = raw.split(".")
    if len(parts) != 2 or not all(part.isdigit() for part in parts):
        return None
    return int(parts[0]), int(parts[1])


def _has_module(interpreter: str, module_name: str) -> bool:
    proc = subprocess.run(
        [
            interpreter,
            "-c",
            (
                "import importlib.util,sys;"
                f"sys.exit(0 if importlib.util.find_spec('{module_name}') else 1)"
            ),
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    return proc.returncode == 0


def select_python(required_module: str | None = None) -> str:
    for interpreter in _candidate_interpreters():
        version = _read_version(interpreter)
        if version is None or version < MIN_VERSION:
            continue
        if required_module and not _has_module(interpreter, required_module):
            continue
        return interpreter

    requirement = f"Python >= {MIN_VERSION[0]}.{MIN_VERSION[1]}"
    if required_module:
        requirement += f" with module '{required_module}' installed"
    raise RuntimeError(
        f"No compatible interpreter found ({requirement}). "
        "Set WEZU_PYTHON=/absolute/path/to/python if needed."
    )


def exec_with_python(interpreter: str, argv: Sequence[str]) -> int:
    proc = subprocess.run([interpreter, *argv], check=False)
    return int(proc.returncode)


def format_runtime_hint(interpreter: str) -> str:
    version = _read_version(interpreter)
    version_text = "unknown" if version is None else f"{version[0]}.{version[1]}"
    return f"Using Python {version_text} at {interpreter}"


def check_current_python_or_exit() -> None:
    if sys.version_info < MIN_VERSION:
        raise SystemExit(
            f"Python {sys.version_info.major}.{sys.version_info.minor} is unsupported. "
            f"Use Python >= {MIN_VERSION[0]}.{MIN_VERSION[1]}."
        )

