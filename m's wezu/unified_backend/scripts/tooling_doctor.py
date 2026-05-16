#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
from pathlib import Path

from python_runtime import ROOT, _candidate_interpreters, _has_module, _read_version


def main() -> int:
    rows = []
    for interpreter in _candidate_interpreters():
        version = _read_version(interpreter)
        rows.append(
            {
                "path": interpreter,
                "exists": Path(interpreter).exists() if "/" in interpreter else True,
                "version": None if version is None else f"{version[0]}.{version[1]}",
                "has_alembic": _has_module(interpreter, "alembic") if version else False,
                "has_pytest": _has_module(interpreter, "pytest") if version else False,
            }
        )

    print(json.dumps({"cwd": str(ROOT), "interpreters": rows}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

