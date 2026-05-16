#!/usr/bin/env python3
from __future__ import annotations

import sys

from python_runtime import exec_with_python, format_runtime_hint, select_python


def main() -> int:
    try:
        interpreter = select_python(required_module="pytest")
    except RuntimeError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1
    print(format_runtime_hint(interpreter), file=sys.stderr)
    return exec_with_python(interpreter, ["-m", "pytest", *sys.argv[1:]])


if __name__ == "__main__":
    raise SystemExit(main())
