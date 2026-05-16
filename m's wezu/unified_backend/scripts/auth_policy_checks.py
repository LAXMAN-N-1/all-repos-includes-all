#!/usr/bin/env python3
"""
Auth policy checks for fast-cutover hardening.

Fails when:
1) Access-token dependency no longer enforces Supabase-only validation and access-token type checks.
2) Auth modules write undefined legacy User auth fields.
3) Direct `jwt.decode(...)` appears in auth route modules (outside approved deps/service).
4) Auth routes miss an explicit response_model.
"""
from __future__ import annotations

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]

DEPS_FILE = ROOT / "app" / "api" / "deps.py"
AUTH_ROUTE_FILES = [
    ROOT / "app" / "api" / "v1" / "auth.py",
    ROOT / "app" / "api" / "v1" / "customer_auth.py",
    ROOT / "app" / "api" / "v1" / "dealer_portal_auth.py",
    ROOT / "app" / "api" / "v1" / "sessions.py",
]
AUTH_GATEWAY_FILES = [
    ROOT / "app" / "api" / "v1" / "auth_gateway.py",
    ROOT / "app" / "api" / "v1" / "auth_tombstones.py",
]
MAIN_FILE = ROOT / "app" / "main.py"
CONFIG_FILE = ROOT / "app" / "core" / "config.py"
ENV_EXAMPLE_FILE = ROOT / ".env.example"

APPROVED_JWT_DECODE_FILES = {
    str((ROOT / "app" / "api" / "deps.py").resolve()),
    str((ROOT / "app" / "services" / "auth_service.py").resolve()),
    str((ROOT / "app" / "services" / "token_service.py").resolve()),
}

LEGACY_USER_FIELD_ASSIGN_PATTERNS = (
    r"\b(?:user|current_user|new_user)\.is_email_verified\s*=",
    r"\b(?:user|current_user|new_user)\.email_verification_token\s*=",
    r"\b(?:user|current_user|new_user)\.email_verification_expires\s*=",
    r"\b(?:user|current_user|new_user)\.two_factor_secret\s*=",
    r"\b(?:user|current_user|new_user)\.backup_codes\s*=",
    r"\b(?:user|current_user|new_user)\.security_question_id\s*=",
    r"\b(?:user|current_user|new_user)\.security_answer_hash\s*=",
)


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _check_access_token_enforcement(errors: list[str]) -> None:
    text = _read(DEPS_FILE)
    required_snippets = [
        'if settings.AUTH_PROVIDER != "supabase":',
        "_validate_supabase_access_token",
        'payload.get("type") or payload.get("token_type")',
    ]
    for snippet in required_snippets:
        if snippet not in text:
            errors.append(
                f"{DEPS_FILE}: missing required access-token enforcement snippet: {snippet!r}"
            )


def _check_legacy_user_field_writes(errors: list[str]) -> None:
    for path in AUTH_ROUTE_FILES + [ROOT / "app" / "services" / "auth_service.py"]:
        text = _read(path)
        for pattern in LEGACY_USER_FIELD_ASSIGN_PATTERNS:
            if re.search(pattern, text):
                errors.append(f"{path}: forbidden legacy User field write matched /{pattern}/")


def _check_jwt_decode_boundaries(errors: list[str]) -> None:
    for path in AUTH_ROUTE_FILES:
        text = _read(path)
        if "jwt.decode(" in text:
            errors.append(
                f"{path}: direct jwt.decode is forbidden in auth routes; use deps/AuthService validation pipeline"
            )

    # Defensive check for accidental future decode usage in app/api or app/services.
    for path in (ROOT / "app").rglob("*.py"):
        text = _read(path)
        if "jwt.decode(" not in text:
            continue
        resolved = str(path.resolve())
        if resolved in APPROVED_JWT_DECODE_FILES:
            continue
        # Keep this scoped to auth/security-sensitive modules for now.
        if "/api/v1/auth" in resolved or "/api/v1/sessions" in resolved or "/services/token_service.py" in resolved:
            errors.append(
                f"{path}: jwt.decode is outside approved modules ({', '.join(sorted(APPROVED_JWT_DECODE_FILES))})"
            )


def _check_response_model_coverage(errors: list[str]) -> None:
    route_decorator = re.compile(r"^\s*@router\.(get|post|put|patch|delete)\((.*?)\)\s*$")
    for path in AUTH_ROUTE_FILES:
        for lineno, line in enumerate(_read(path).splitlines(), start=1):
            match = route_decorator.match(line)
            if not match:
                continue
            if "response_model=" not in match.group(2):
                errors.append(f"{path}:{lineno}: auth route missing explicit response_model")


def _check_supabase_only_runtime_wiring(errors: list[str]) -> None:
    config_text = _read(CONFIG_FILE)
    if "PASSKEY_ENABLED: bool = False" not in config_text:
        errors.append(f"{CONFIG_FILE}: PASSKEY_ENABLED must default to False")

    main_text = _read(MAIN_FILE)
    if 'if settings.AUTH_PROVIDER != "supabase":' not in main_text:
        errors.append(f"{MAIN_FILE}: production safety must enforce AUTH_PROVIDER == 'supabase'")
    if "PASSKEY_ENABLED must be false in production" not in main_text:
        errors.append(f"{MAIN_FILE}: production safety must enforce passkeys disabled")

    forbidden_live_mounts = [
        "app.include_router(auth.router, prefix=f\"{v1_str}/auth\"",
        "app.include_router(customer_auth.router, prefix=f\"{v1_str}/customers/auth\"",
        "app.include_router(dealer_portal_auth.router, prefix=f\"{dealer_api}/auth\"",
        "app.include_router(passkeys.router, prefix=f\"{v1_str}/auth\"",
        "app.include_router(sessions.router, prefix=f\"{v1_str}/sessions\"",
    ]
    for mount in forbidden_live_mounts:
        if mount in main_text:
            errors.append(f"{MAIN_FILE}: forbidden live legacy auth mount detected: {mount}")

    required_mounts = [
        "app.include_router(auth_gateway.router, prefix=f\"{v1_str}/auth\"",
        "app.include_router(\n    auth_tombstones.customer_auth_router,",
        "app.include_router(\n    auth_tombstones.dealer_auth_router,",
        "app.include_router(\n    auth_tombstones.sessions_router,",
    ]
    for mount in required_mounts:
        if mount not in main_text:
            errors.append(f"{MAIN_FILE}: missing required supabase auth/tombstone mount: {mount}")


def _check_no_local_token_issuance_in_gateway(errors: list[str]) -> None:
    patterns = [
        "create_access_token(",
        "create_refresh_token(",
        "rotate_refresh_session_tokens(",
        "revoke_session(",
        "revoke_all_user_sessions(",
    ]
    for path in AUTH_GATEWAY_FILES:
        text = _read(path)
        for pattern in patterns:
            if pattern in text:
                errors.append(
                    f"{path}: gateway/tombstone surface must not issue or revoke local tokens ({pattern})"
                )


def _check_env_example_supabase_defaults(errors: list[str]) -> None:
    if not ENV_EXAMPLE_FILE.exists():
        errors.append(f"{ENV_EXAMPLE_FILE}: missing .env example file")
        return
    text = _read(ENV_EXAMPLE_FILE)
    required_snippets = [
        "AUTH_PROVIDER=supabase",
        "SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co",
        "SUPABASE_JWKS_URL=https://YOUR_PROJECT_REF.supabase.co/auth/v1/.well-known/jwks.json",
        "SUPABASE_JWT_ISSUER=https://YOUR_PROJECT_REF.supabase.co/auth/v1",
    ]
    for snippet in required_snippets:
        if snippet not in text:
            errors.append(f"{ENV_EXAMPLE_FILE}: missing Supabase-compatible default snippet: {snippet!r}")


def main() -> int:
    errors: list[str] = []
    _check_access_token_enforcement(errors)
    _check_legacy_user_field_writes(errors)
    _check_jwt_decode_boundaries(errors)
    _check_response_model_coverage(errors)
    _check_supabase_only_runtime_wiring(errors)
    _check_no_local_token_issuance_in_gateway(errors)
    _check_env_example_supabase_defaults(errors)

    if errors:
        print("AUTH_POLICY_CHECK_FAILED")
        for err in errors:
            print(f"- {err}")
        return 1

    print("AUTH_POLICY_CHECK_PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
