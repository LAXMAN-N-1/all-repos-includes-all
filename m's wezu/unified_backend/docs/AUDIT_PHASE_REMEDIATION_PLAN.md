# Audit Remediation Plan (Phased)

This plan translates `Audit.txt.rtf` findings into executable phases.

## Phase 1 — Immediate Risk Containment (Implemented)

Status: `in_progress` (security/routing guardrails applied)

Completed in code:

1. RBAC route protection hardened in `app/main.py`
- Added `dependencies=admin_deps` to:
  - `/api/v1/roles`
  - `/api/v1/menus`
  - `/api/v1/role-rights`
  - `/api/v1/admin/security`

2. Dealer surface tightened in `app/main.py`
- `dealers.router` dependency changed from `get_current_user` to `get_current_dealer_scope_user`.

3. Telematics namespace collision reduced in `app/main.py`
- `telemetry.router` moved from `/api/v1/telematics` to `/api/v1/telemetry`.

4. Bare-prefix cleanup started with compatibility aliases in `app/main.py`
- Canonical mounts:
  - `kyc.router` -> `/api/v1/kyc`
  - `system.router` -> `/api/v1/system`
  - `customer_reservations.router` -> `/api/v1/customers/me`
- Legacy aliases retained with `include_in_schema=False` for transition.

5. Webhook isolation started in `app/main.py`
- Mounted `app/api/webhooks/razorpay.py` under `/api/webhooks`.
- Existing `/api/v1/payments/webhooks/razorpay` remains temporarily for compatibility.

## Phase 2 — Consolidation and Canonicalization

Status: `pending`

Actions:

1. Auth consolidation
- Introduce one canonical auth surface under `/api/v1/auth/*`.
- Keep `/customers/auth/*` and `/dealers/auth/*` as temporary aliases returning deprecation metadata.

2. Enhanced router merge
- Merge and remove duplicate pairs:
  - `wallet` + `wallet_enhanced`
  - `support` + `support_enhanced`
  - `rentals` + `rentals_enhanced`

3. Finance endpoint unification
- Keep `GET /api/v1/wallet/transactions` canonical.
- Deprecate duplicate transaction list endpoints.

4. RBAC service unification
- Collapse `role_service.py` and `rbac_service.py` into one canonical service module.

5. Deliveries naming consistency
- Keep `/api/v1/deliveries/*` canonical.
- Move realtime routes to `/api/v1/deliveries/realtime/*` and retain aliases temporarily.

## Phase 3 — Removal and Enforcement

Status: `pending`

Actions:

1. Remove legacy alias routes introduced in Phase 1 and Phase 2.
2. Delete duplicate modules (`*_enhanced.py`, legacy auth routers after cutover).
3. Remove runtime schema patching from startup and enforce migration-head checks.
4. Add permanent CI policy checks for:
- duplicate `(method, path)`
- banned legacy prefixes
- no bare `prefix=v1_str` registrations
- response-model coverage in core domains

## Auth Overhaul Program — Supabase-Only (Fast Cutover)

### Phase 1 — Additive Hardening (implemented)

1. Supabase-only production safety checks are enforced in `app/main.py`.
2. Auth gateway is canonicalized under `/api/v1/auth` with typed `GET /api/v1/auth/me`.
3. Legacy auth/session surfaces are tombstoned (`410`) via `app/api/v1/auth_tombstones.py`.
4. Passkey runtime routes are removed from mounts; passkey mode defaults to disabled.
5. Identity bridge tables are added:
- `user_identities`
- `user_identity_link_audit`
6. Auth dependency resolves identity via Supabase `sub` and local `user_id` mapping with deterministic conflict failures.

### Phase 2 — Deprecation Window (in progress)

1. Keep legacy endpoints tombstoned with migration guidance for one release window.
2. Remove any client reliance on backend-issued login/refresh/logout/session APIs.
3. Run operational migration:
- map/link existing accounts to Supabase identities,
- block unmapped identities post-window.

### Phase 3 — Final Removal (pending)

1. Delete legacy auth modules after sunset:
- `app/api/v1/auth.py`
- `app/api/v1/customer_auth.py`
- `app/api/v1/dealer_portal_auth.py`
- `app/api/v1/passkeys.py`
- `app/api/v1/sessions.py`
2. Remove local token issuance/rotation/revocation code from auth services.
3. Drop obsolete auth artifacts and passkey tables after data-retention window.
