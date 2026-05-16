#!/usr/bin/env python3
from __future__ import annotations

import sys

from python_runtime import format_runtime_hint, select_python


def main() -> int:
    if len(sys.argv) <= 1:
        print("usage: python3 scripts/run_alembic.py <alembic args...>", file=sys.stderr)
        return 2

    try:
        interpreter = select_python(required_module="alembic")
    except RuntimeError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1
    print(format_runtime_hint(interpreter), file=sys.stderr)

    code = (
        "from alembic.config import main as alembic_main;"
        "import sys;"
        "raise SystemExit(alembic_main(argv=sys.argv[1:]))"
    )

    from python_runtime import exec_with_python

    return exec_with_python(interpreter, ["-c", code, *sys.argv[1:]])


if __name__ == "__main__":
    raise SystemExit(main())
