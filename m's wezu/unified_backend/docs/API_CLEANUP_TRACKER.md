# API Cleanup Tracker

Tracks all duplicate-endpoint consolidations and naming-standardisation tasks
identified across the wezu-backend-unified codebase.

**Legend**
- `[x]` Done — merged, deleted, or applied
- `[ ]` Pending
- 🔴 Critical (security / correctness bug or broken client contract)
- 🟡 High (silent duplication or misleading behaviour)
- 🟢 Low / polish (naming, docs, minor inconsistency)

---

## Part A — Duplicate Endpoint Consolidations

### A1 — Already completed ✅

These were identified, compared, and merged/deleted in the first consolidation pass.

- [x] 🔴 `notifications_enhanced.py` absorbed all of `notifications.py` — `notifications.py` deleted
- [x] 🔴 `analytics.py` absorbed the rich export + fixed carbon-savings query from `analytics_enhanced.py` — `analytics_enhanced.py` deleted
- [x] 🔴 `payments.py` absorbed webhook-queueing, set-default, refund-history, receipt/invoice from `payments_enhanced.py` — `payments_enhanced.py` deleted
- [x] 🔴 `users.py` + `auth.py` + `sessions.py` supersede `profile.py` — `profile.py` deleted
- [x] 🔴 `catalog.py` is canonical for cart/warranty — `purchases_enhanced.py` deleted (stubs confirmed non-functional)
- [x] 🟡 `dealer_portal_dashboard.py` transactions: merged date-range, amount-range, status, search filters from `dealers.py` while keeping batch-load N+1 fix
- [x] 🟡 `main.py` router mounts deduplicated — single `notifications_enhanced` mount, no duplicate imports

### A2 — Post-merge hardening ✅

Code-quality fixes applied immediately after the consolidation pass.

- [x] 🔴 `payments.py GET /{id}/refund-status` — added `current_user` dep + wallet-join ownership check (was fully unauthenticated)
- [x] 🔴 `analytics.py _DASHBOARD_REPORT_STORE` — replaced process-local `dict` with `_ReportStore` class (Redis-primary, in-memory fallback); reports now visible across Gunicorn workers
- [x] 🟡 `analytics.py get_carbon_savings` / `export_analytics_data` — removed spurious `async def` (sync `Session`, no awaits)
- [x] 🟡 `auth.py change_password` — removed redundant `db.add()` after `db.merge()`
- [x] 🟡 `notifications_enhanced.py` — replaced `datetime.utcnow()` with `datetime.now(UTC)` (×2)
- [x] 🟡 `payments.py set_default_payment_method` — replaced `datetime.utcnow()` with `datetime.now(UTC)`
- [x] 🟡 `dealer_portal_dashboard.py get_dealer_transactions` — UTC coercion for naive `start_date` / `end_date` query params
- [x] 🟡 `payments.py get_invoice` — GST rate moved from hardcoded `Decimal("0.18")` to `settings.GST_RATE`
- [x] 🟢 `payments.py` module docstring updated from stale "Enhanced Payment" copy
- [x] 🟢 `payments.py GET /refunds` vs `GET /refunds/history` — clarifying docstrings added

### A3 — Remaining duplicates (pending) ⬜

#### A3-1 — `transactions.py GET /` vs `payments.py GET /transactions`
- **File A:** `app/api/v1/transactions.py:11` — wallet JOIN query, typed `TransactionResponse` schema, `skip/limit` pagination
- **File B:** `app/api/v1/payments.py:192` — direct `user_id` query, no pagination, raw list
- **Winner:** `transactions.py` — typed schema + pagination
- [ ] 🟡 Remove `GET /transactions` endpoint from `payments.py` (lines 192–203)
- [ ] 🟡 Verify `transactions.py` is the only canonical transaction-list endpoint and it covers all transaction types (rentals + purchases)

#### A3-2 — `wallet.py GET /transactions/{id}/receipt` vs `payments.py GET /{id}/receipt`
- **File A:** `app/api/v1/wallet.py:177` — ownership via direct `txn.user_id` check
- **File B:** `app/api/v1/payments.py:450` — ownership via `_get_owned_transaction` (wallet JOIN — more secure)
- **Winner:** `payments.py` — wallet-join prevents user-ID spoofing
- [ ] 🟡 Remove `GET /transactions/{payment_id}/receipt` from `wallet.py` (lines 177–191)
- [ ] 🟢 Confirm `payments.py GET /{id}/receipt` covers both rental and non-rental transactions

#### A3-3 — `dealers.py GET /me/dashboard` vs `dealer_portal_dashboard.py GET /`
- **File A:** `app/api/v1/dealers.py:68` — single `DealerService.get_dashboard_stats()` call, no caching
- **File B:** `app/api/v1/dealer_portal_dashboard.py:43` — full KPIs + alerts + promotions + recent activity, `cached_call()` TTL
- **Winner:** `dealer_portal_dashboard.py` — cached, structured, richer
- [ ] 🟡 Remove `GET /me/dashboard` from `dealers.py` (lines 68–78)
- [ ] 🟢 Update any client references from `/dealers/me/dashboard` to the portal dashboard path

#### A3-4 — Role CRUD triplicated across three service layers
- **File A:** `app/api/v1/roles.py` → `/api/v1/roles` — uses `role_service`, `check_permission` guard
- **File B:** `app/api/v1/admin_rbac.py` → `/api/v1/admin/rbac/roles` — uses raw DB + batch user-counts, `get_current_active_admin` guard
- **File C:** `app/api/v1/admin/roles.py` → `/admin/roles` — uses `rbac_service`, `get_current_active_superuser` guard, unique `GET /permissions` endpoint
- **Note:** Three audiences (internal operator / admin user / superuser) justify separate route files. The problem is three different service layers (`role_service`, `rbac_service`, raw DB) doing the same DB work.
- [ ] 🟡 Consolidate `role_service` and `rbac_service` into one canonical service (`app/services/role_service.py`)
- [ ] 🟡 Repoint `admin_rbac.py` and `admin/roles.py` to the unified service (keep their route files + auth guards)
- [ ] 🟢 Ensure batch user-count logic from `admin_rbac.py` is inside the service, not inline in the route

#### A3-5 — `wallet.py POST /withdraw` vs `wallet_enhanced.py POST /withdrawals`
- **File A:** `app/api/v1/wallet.py:149` — accepts raw bank details inline (first-time withdrawal flow)
- **File B:** `app/api/v1/wallet_enhanced.py:32` — accepts `bank_account_id` reference (returning-user flow)
- **Note:** Both call `WalletService.request_withdrawal()`. These are two legitimate but separate user flows — NOT a pure duplicate. No deletion needed.
- [ ] 🟢 Add docstring to `wallet.py POST /withdraw`: "Use when submitting bank details for the first time"
- [ ] 🟢 Add docstring to `wallet_enhanced.py POST /withdrawals`: "Use when referencing a saved bank account ID"

---

## Part B — Naming Standardisation

> **The 10 rules for this codebase**
> 1. All routes under `/api/v1/` — retire `/api/admin/`
> 2. Collections are always plural nouns
> 3. Authenticated user's own resources → `/me` — never `/my`
> 4. Paths are nouns — HTTP method carries the verb
> 5. Only allowed path-action words (POST only): `cancel` `approve` `confirm` `complete` `verify`
> 6. Max 3 path segments after `/api/v1/` — flatten `/portal/` and deep nesting
> 7. Partial updates → `PATCH` only — no duplicate `PUT` aliases
> 8. Hyphens in URL paths, underscores in query params and file names
> 9. Same resource = same canonical path — no split across two modules
> 10. Domain collisions get a namespace qualifier (e.g. `/catalog/orders`)

---

### B1 — Two admin URL prefixes 🔴

Routes for the same resources exist under both `/api/admin/*` and `/api/v1/admin/*`.

| Current broken paths | Standard |
|---|---|
| `/api/admin/dealers` | → `/api/v1/admin/dealers` |
| `/api/admin/batteries` | → `/api/v1/admin/batteries` |
| `/api/admin/stations` | → `/api/v1/admin/stations` |
| `/api/admin/users` | → `/api/v1/admin/users` |

- [ ] 🔴 Audit every route in `app/api/admin/` and migrate to `app/api/v1/admin/`
- [ ] 🔴 Remove `/api/admin/` prefix from `main.py` after migration
- [ ] 🔴 Update `global_admin_router` mount in `main.py` to use `/api/v1/admin` prefix

---

### B2 — Singular vs plural inconsistency 🟡

| Current | Fix | File |
|---|---|---|
| `/api/v1/location/` | → `/api/v1/locations/` | `location.py` (already have `locations.py` — merge or rename) |
| `/api/v1/warehouse` | → `/api/v1/warehouses/` | `warehouse_structure.py` (already have `warehouses.py`) |
| `/api/v1/support/faq` | → `/api/v1/support/faqs` | `support.py` |
| `/api/v1/dealer/...` (portal routes) | → `/api/v1/dealers/...` | all `dealer_portal_*.py` mounts |
| `/api/v1/dealer-stations` | → `/api/v1/dealers/stations` | `dealer_stations.py` |

- [ ] 🟡 Rename `/location/` → `/locations/` in `location.py` mount (`main.py`) and update all internal references
- [ ] 🟡 Resolve `/warehouse` vs `/warehouses` — pick `warehouses`, remove the singular mount
- [ ] 🟡 Rename `/support/faq` → `/support/faqs` in `support.py`
- [ ] 🟡 Change all `dealer_portal_*.py` mounts in `main.py` from `/dealer/portal/...` to `/dealers/me/...`
- [ ] 🟡 Move `dealer_stations.py` routes under `/dealers/stations` prefix

---

### B3 — `/me` vs `/my` inconsistency 🟡

Standard: `/me` for the authenticated user's own resource — never `/my`, never `/current`.

| Current | Fix | File |
|---|---|---|
| `GET /notifications/my` | → `GET /notifications/me` | `notifications_enhanced.py:133` |
| `GET /support/tickets/my` | → `GET /support/me/tickets` | `support.py` |
| `GET /dealer/kyc/my-status` | → `GET /dealers/me/kyc/status` | dealer kyc file |
| `GET /customer/dashboard` | → `GET /customers/me/dashboard` | `customer_dashboard.py` |

- [ ] 🟡 Rename `GET /notifications/my` → `GET /notifications/me` in `notifications_enhanced.py`
- [ ] 🟡 Rename `GET /support/tickets/my` → `GET /support/me/tickets` in `support.py`
- [ ] 🟡 Rename `/dealer/kyc/my-status` → `/dealers/me/kyc/status`
- [ ] 🟢 Rename `/customer/dashboard` → `/customers/me/dashboard`

---

### B4 — Verbs in URL paths 🟡

Grouped by module. All changes use `POST` for the new noun-based paths unless noted.

#### Auth
| Current | Fix |
|---|---|
| `POST /auth/token/refresh` (has two paths for same thing) | Keep `POST /auth/refresh`, remove `/token` alias |
| `POST /auth/verify-otp` | → `POST /auth/otp/verifications` |
| `POST /auth/verify-email` | → `POST /auth/email/verifications` |
| `POST /auth/change-password` | → `PATCH /auth/me/password` |
| `POST /auth/forgot-password` | → `POST /auth/password/reset-requests` |
| `POST /auth/resend-verification` | → `POST /auth/email/verification-requests` |
| `POST /auth/enable-2fa` | → `POST /auth/2fa` |
| `POST /auth/verify-2fa` | → `POST /auth/2fa/verifications` |
| `POST /auth/select-role` | → `PATCH /auth/me/role` |
| `POST /auth/biometric/register` | → `POST /auth/biometrics` |
| `POST /auth/security-questions/set` | → `PUT /auth/me/security-questions` |
| `POST /auth/security-questions/verify` | → `POST /auth/security-questions/verifications` |

- [ ] 🟡 Consolidate duplicate `/auth/token` and `/auth/login` (two paths that both log in) — keep `/auth/login`
- [ ] 🟡 Rename `/auth/verify-otp` → `/auth/otp/verifications`
- [ ] 🟡 Rename `/auth/change-password` → `PATCH /auth/me/password`
- [ ] 🟡 Rename `/auth/forgot-password` → `/auth/password/reset-requests`
- [ ] 🟢 Rename `/auth/enable-2fa` and `/auth/verify-2fa` to noun-based paths
- [ ] 🟢 Rename `/auth/select-role` → `PATCH /auth/me/role`
- [ ] 🟢 Rename `/auth/security-questions/set` and `/auth/security-questions/verify`

#### Batteries
| Current | Fix |
|---|---|
| `POST /batteries/scan-qr` | → `POST /batteries/qr/scans` |
| `POST /batteries/qr/generate` | → `POST /batteries/{id}/qr` |
| `POST /batteries/qr/verify` | → `POST /batteries/qr/verifications` |
| `POST /batteries/batch/import` | → `POST /batteries/imports` |
| `GET  /batteries/batch/export` | → `GET  /batteries/exports` |
| `POST /batteries/{id}/assign-station` | → `PATCH /batteries/{id}` with body `{station_id}` |
| `POST /batteries/{id}/transfer` | → `POST /batteries/{id}/transfers` |
| `GET  /batteries/low-health` | → `GET  /batteries?health_status=low` |

- [ ] 🟡 Rename `/batteries/scan-qr` → `/batteries/qr/scans`
- [ ] 🟡 Rename `/batteries/batch/import` → `/batteries/imports`
- [ ] 🟡 Rename `GET /batteries/batch/export` → `GET /batteries/exports`
- [ ] 🟡 Replace `/batteries/{id}/assign-station` with `PATCH /batteries/{id}` (body: `station_id`)
- [ ] 🟢 Replace `GET /batteries/low-health` with query param: `GET /batteries?health_status=low`
- [ ] 🟢 Rename QR generate/verify to noun paths

#### Orders (logistics)
| Current | Fix |
|---|---|
| `POST /orders/{id}/mark-in-transit` | → `PATCH /orders/{id}` with body `{status: "in_transit"}` |
| `POST /orders/{id}/mark-failed` | → `PATCH /orders/{id}` with body `{status: "failed"}` |
| `POST /orders/{id}/assign-driver` (also has `PUT`) | → `POST /orders/{id}/driver` |
| `POST /orders/{id}/proof-of-delivery` | → `POST /orders/{id}/delivery-proofs` |

- [ ] 🟡 Replace `mark-in-transit` and `mark-failed` with a single `PATCH /orders/{id}` that accepts a `status` field
- [ ] 🟡 Remove duplicate `PUT /orders/{id}/assign-driver` — keep only `POST /orders/{id}/driver`
- [ ] 🟢 Rename `/proof-of-delivery` → `/delivery-proofs`

#### Swaps
| Current | Fix |
|---|---|
| `POST /swaps/initiate` | → `POST /swaps` |
| `POST /swaps/{id}/complete` | → `PATCH /swaps/{id}` with body `{status: "completed"}` |

- [ ] 🟡 Rename `POST /swaps/initiate` → `POST /swaps`
- [ ] 🟡 Replace `POST /swaps/{id}/complete` with `PATCH /swaps/{id}`

#### Support
| Current | Fix |
|---|---|
| `POST /support/tickets/{id}/reply` | → `POST /support/tickets/{id}/messages` |
| `PUT  /support/tickets/{id}/close` | → `PATCH /support/tickets/{id}` with body `{status: "closed"}` |
| `POST /support/chat/initiate` | → `POST /support/chats` |

- [ ] 🟡 Rename `/tickets/{id}/reply` → `/tickets/{id}/messages`
- [ ] 🟡 Replace `PUT /tickets/{id}/close` with `PATCH /tickets/{id}`
- [ ] 🟡 Rename `/chat/initiate` → `/chats`

#### Wallet
| Current | Fix |
|---|---|
| `POST /wallet/recharge` | → `POST /wallet/top-ups` |
| `POST /wallet/transfer` | → `POST /wallet/transfers` (wallet_enhanced already has this) |

- [ ] 🟡 Rename `/wallet/recharge` → `/wallet/top-ups`
- [ ] 🟡 Confirm `/wallet/transfers` exists in `wallet_enhanced.py` and remove `/wallet/transfer` (singular)

#### Sessions
| Current | Fix |
|---|---|
| `GET /sessions/list` | → `GET /sessions` (list is implied) |
| `POST /sessions/{id}/revoke` | → `DELETE /sessions/{id}` |

- [ ] 🟡 Remove `GET /sessions/list` — `GET /sessions` already returns the list
- [ ] 🟡 Change `POST /sessions/{id}/revoke` → `DELETE /sessions/{id}` in `sessions.py`

#### Faqs
| Current | Fix |
|---|---|
| `POST /faqs/{id}/helpful` | → `POST /faqs/{id}/reactions` |

- [ ] 🟢 Rename `/faqs/{id}/helpful` → `/faqs/{id}/reactions`

---

### B5 — Domain name collision: `/orders` used for two different models 🟡

| Current | Domain | Model | Fix |
|---|---|---|---|
| `GET /api/v1/orders` | Logistics | `DeliveryOrder` | → `GET /api/v1/deliveries` |
| `GET /api/v1/catalog/orders` | E-commerce | `CatalogOrder` | ✓ keep — scoped under `/catalog/` |

- [ ] 🟡 Rename the logistics orders router mount from `/orders` to `/deliveries` in `main.py`
- [ ] 🟡 Update all internal cross-references and client docs that point to `/orders` (logistics)
- [ ] 🟢 Add a comment to both files documenting the domain separation

---

### B6 — `/telematics` vs `/telemetry` (two words, same concern) 🟡

| File | Current path |
|---|---|
| `telematics.py` | `/api/v1/telematics/` |
| `telemetry.py` | `/api/v1/telemetry/` |

- [ ] 🟡 Merge `telemetry.py` routes into `telematics.py` under `/api/v1/telematics/`
- [ ] 🟡 Remove the `/telemetry/` mount from `main.py`
- [ ] 🟢 Update any IoT device clients or MQTT consumers that POST to `/telemetry/`

---

### B7 — Dealer portal 4-level nesting 🟡

All `dealer_portal_*.py` files currently mount as `/dealer/portal/{resource}` — `portal` is not a resource, it just adds depth.

| Current path | Standard |
|---|---|
| `/dealer/portal/dashboard` | → `/dealers/me/dashboard` |
| `/dealer/portal/tickets` | → `/dealers/me/tickets` |
| `/dealer/portal/roles` | → `/dealers/me/roles` |
| `/dealer/portal/users` | → `/dealers/me/team` |
| `/dealer/portal/settings` | → `/dealers/me/settings` |
| `/dealer/portal/inventory` | → `/dealers/me/inventory` |
| `/dealer/portal/customers` | → `/dealers/me/customers` |

- [ ] 🟡 Update all `dealer_portal_*.py` router mounts in `main.py` to use `/dealers/me/` prefix (covered partly by B2 above — do together)
- [ ] 🟢 Rename the Python files themselves from `dealer_portal_*.py` to `dealer_*.py` for consistency (optional, low priority)

---

### B8 — Both `PATCH` and `PUT` for identical notification operations 🟢

In `notifications_enhanced.py`:
```
PATCH /notifications/{id}/read   ← canonical
PUT   /notifications/{id}/read   ← exact duplicate handler (lines 159–171)

PATCH /notifications/read-all    ← canonical
PUT   /notifications/read-all    ← exact duplicate handler (lines 192–206)
```

- [ ] 🟢 Remove `PUT /notifications/{id}/read` handler from `notifications_enhanced.py`
- [ ] 🟢 Remove `PUT /notifications/read-all` handler from `notifications_enhanced.py`

---

### B9 — `/wallet/balance` duplicates `/wallet/` 🟢

`GET /wallet/` already returns the wallet object which contains a `balance` field.
`GET /wallet/balance` returns only the balance scalar.

- [ ] 🟢 Decide: remove `/wallet/balance` (clients read `.balance` from `/wallet/`) **or** keep it as a lightweight endpoint and document that it exists for low-bandwidth clients
- [ ] 🟢 Add docstring to whichever is kept explaining the relationship

---

### B10 — Analytics path sprawl 🟢

Three different "dashboard" endpoints with no clear hierarchy:

| Path | File | Audience |
|---|---|---|
| `GET /analytics/dashboard` | `analytics.py` | Customer's own stats |
| `GET /dashboard/summary` | `dashboard.py` | Unclear |
| `GET /admin/analytics/dashboard` | `admin/analytics.py` | Admin overview |

- [ ] 🟢 Rename `GET /analytics/dashboard` → `GET /analytics/me/dashboard` (customer scoped)
- [ ] 🟢 Clarify purpose of `GET /dashboard/summary` — merge into `/analytics/me/dashboard` or rename to `/admin/analytics/summary`
- [ ] 🟢 Rename `GET /analytics/export` → `GET /analytics/me/exports`

---

### B11 — `POST` and `PUT` both registered for `/orders/{id}/assign-driver` 🟡

Both methods hit the same handler — one will silently shadow the other at runtime.

- [ ] 🟡 Keep only `POST /orders/{id}/driver` (create the driver assignment)
- [ ] 🟡 Add `DELETE /orders/{id}/driver` for unassignment
- [ ] 🟡 Remove the `PUT` alias from `orders.py`

---

## Part C — Implementation Phases

### Phase 1 — Additive (zero breaking changes)
Add new canonical routes alongside old ones. Old paths continue to work.

- [ ] Add all renamed routes as new handlers
- [ ] Mark old handlers with a `# DEPRECATED: use /new/path` comment
- [ ] Return `Deprecated` header on old paths: `Warning: 299 - "Endpoint deprecated, use /new/path"`

### Phase 2 — Redirect (low risk)
- [ ] Replace deprecated handlers with `301` redirects to new canonical paths
- [ ] Log a warning for every hit on a deprecated path

### Phase 3 — Remove (after client migration)
- [ ] Drop all deprecated route handlers
- [ ] Remove deprecation comments and redirect logic
- [ ] Update API docs and OpenAPI spec

---

## Quick Reference — Items by file

| File | Pending tasks |
|---|---|
| `app/api/v1/transactions.py` | A3-1 (canonical transaction list) |
| `app/api/v1/payments.py` | A3-1 (remove `/transactions`), A3-2 (receipt canonical) |
| `app/api/v1/wallet.py` | A3-2 (remove receipt), A3-5 (docstring), B9, B4-wallet |
| `app/api/v1/wallet_enhanced.py` | A3-5 (docstring), B4-wallet |
| `app/api/v1/dealers.py` | A3-3 (remove dashboard), B2, B7 |
| `app/api/v1/dealer_portal_*.py` | B2, B3, B7 (all portal files) |
| `app/api/v1/roles.py` | A3-4 (service unification) |
| `app/api/v1/admin_rbac.py` | A3-4 (service unification) |
| `app/api/v1/admin/roles.py` | A3-4 (service unification) |
| `app/api/v1/notifications_enhanced.py` | B3 (`/my` → `/me`), B8 (remove PUT aliases) |
| `app/api/v1/auth.py` | B4-auth (verb paths) |
| `app/api/v1/batteries.py` | B4-batteries (verb paths) |
| `app/api/v1/orders.py` | B4-orders, B5 (rename to `/deliveries`), B11 |
| `app/api/v1/swaps.py` | B4-swaps |
| `app/api/v1/support.py` | B3, B4-support |
| `app/api/v1/sessions.py` | B4-sessions (`/revoke` → DELETE) |
| `app/api/v1/faqs.py` | B4-faqs |
| `app/api/v1/telematics.py` | B6 (absorb telemetry routes) |
| `app/api/v1/telemetry.py` | B6 (merge into telematics, delete) |
| `app/api/v1/location.py` | B2 (singular → plural) |
| `app/api/v1/warehouse_structure.py` | B2 (singular → plural) |
| `app/api/v1/analytics.py` | B10 (path rename) |
| `app/api/v1/station_monitoring.py` | B4 (heartbeat verb) |
| `app/api/admin/*.py` | B1 (migrate to `/api/v1/admin/`) |
| `app/main.py` | B1, B2, B5, B6, B7 (mount prefix updates) |

---

---

## Part C — Full API Audit

> **Audit scope:** All routes in `app/api/v1/`, `app/api/v1/admin/`, `app/api/admin/`,
> `app/api/webhooks/`, `app/api/internal/`, and `app/main.py`.
>
> **Format convention**
> - `METHOD /path` — `handler()` — \[auth dependency\] — `RequestSchema → ResponseModel`
> - `none` = no Pydantic model / no dependency present
> - `*` = inline model defined in the route file itself, not in `app/schemas/`
>
> **This section is observation-only.** No fixes, no redesigns.
> Facts are labelled **FACT**. Inconsistencies are labelled **OBS** (observation).

---

### C0 — Router Mount Map (from `main.py`)

All prefixes registered on the FastAPI `app` instance. This is the ground truth for
full endpoint paths.

| Mount prefix | Router source | Tags |
|---|---|---|
| `/api/v1/auth` | `auth.router` | Auth |
| `/api/v1/auth` | `passkeys.router` | Auth Passkeys |
| `/api/v1/customer/auth` | `customer_auth.router` | Customer Auth |
| `/api/v1/customer/dashboard` | `customer_dashboard.router` | Customer Dashboard |
| `/api/v1` | `customer_reservations.router` | Customer Reservations (no sub-prefix) |
| `/api/v1/sessions` | `sessions.router` | Sessions |
| `/api/v1/users` | `users.router` | Users |
| `/api/v1` | `kyc.router` | KYC (no sub-prefix — paths start `/kyc/`) |
| `/api/v1/stations` | `stations.router` | Stations |
| `/api/v1/batteries` | `batteries.router` | Batteries |
| `/api/v1/batteries` | `battery_catalog.router` | Battery Catalog |
| `/api/v1/rentals` | `rentals.router` | Rentals |
| `/api/v1/rentals` | `rentals_enhanced.router` | Rentals Enhanced |
| `/api/v1/bookings` | `bookings.router` | Bookings |
| `/api/v1/vehicles` | `vehicles.router` | Vehicles |
| `/api/v1/swaps` | `swaps.router` | Swaps |
| `/api/v1/maintenance` | `maintenance.router` | Maintenance |
| `/api/v1/location` | `location.router` | Location (singular) |
| `/api/v1/wallet` | `wallet.router` | Wallet |
| `/api/v1/wallet` | `wallet_enhanced.router` | Wallet Enhanced |
| `/api/v1/payments` | `payments.router` | Payments |
| `/api/v1/notifications` | `notifications_enhanced.router` | Notifications |
| `/api/v1/support` | `support.router` | Support |
| `/api/v1/support` | `support_enhanced.router` | Support Enhanced |
| `/api/v1/favorites` | `favorites.router` | Favorites |
| `/api/v1/transactions` | `transactions.router` | Transactions |
| `/api/v1/settlements` | `settlements.router` | Settlements |
| `/api/v1/promo` | `promo.router` | Promo |
| `/api/v1/faqs` | `faqs.router` | FAQs |
| `/api/v1/analytics` | `analytics.router` | Analytics |
| `/api/v1/catalog` | `catalog.router` | Catalog |
| `/api/v1/orders` | `orders.router` | Orders |
| `/api/v1/orders` | `orders_realtime.router` | Orders Realtime |
| `/api/v1/logistics` | `logistics.router` | Logistics |
| `/api/v1/drivers` | `drivers.router` | Drivers |
| `/api/v1/manifests` | `manifests.router` | Manifests |
| `/api/v1/routes` | `routes.router` | Route Optimisation |
| `/api/v1/inventory` | `inventory.router` | Inventory |
| `/api/v1/stock` | `stock.router` | Stock |
| `/api/v1/warehouses` | `warehouses.router` | Warehouses |
| `/api/v1/warehouse` | `warehouse_structure.router` | Warehouse Structure (singular) |
| `/api/v1/locations` | `locations.router` | Locations Hierarchy |
| `/api/v1/location` | `location.router` | Location GPS (duplicate prefix with above) |
| `/api/v1/telematics` | `telematics.router` | Telematics |
| `/api/v1/telemetry` | `telemetry.router` | Telemetry |
| `/api/v1/iot` | `iot.router` | IoT |
| `/api/v1/fraud` | `fraud.router` | Fraud Detection |
| `/api/v1/branches` | `branches.router` | Branches |
| `/api/v1/organizations` | `organizations.router` | Organizations |
| `/api/v1/i18n` | `i18n.router` | i18n |
| `/api/v1/screens` | `screens.router` | Screens |
| `/api/v1/ml` | `ml.router` | ML |
| `/api/v1/audit` | `audit.router` | Audit Logs |
| `/api/v1/roles` | `roles.router` | Roles |
| `/api/v1/menus` | `menus.router` | Menus |
| `/api/v1/role-rights` | `role_rights.router` | Role Rights |
| `/api/v1` | `system.router` | System (no sub-prefix) |
| `/api/v1/station-monitoring` | `station_monitoring.router` | Station Monitoring |
| `/api/v1/utils` | `utils.router` | Utils |
| `/api/v1/settlements` | `settlements.router` | Settlements |
| `/api/v1/security` | `security.router` | Security |
| `/api/v1/dealer/auth` | `dealer_portal_auth.router` | Dealer Auth |
| `/api/v1/dealer/portal` | `dealer_portal_dashboard.router` | Dealer Dashboard |
| `/api/v1/dealer/portal` | `dealer_portal_tickets.router` | Dealer Tickets |
| `/api/v1/dealer/portal` | `dealer_portal_customers.router` | Dealer Customers |
| `/api/v1/dealer/portal` | `dealer_portal_settings.router` | Dealer Settings |
| `/api/v1/dealer/portal` | `dealer_portal_roles.router` | Dealer Roles |
| `/api/v1/dealer/portal` | `dealer_portal_users.router` | Dealer Users |
| `/api/v1/dealer/portal` | `dealer_portal_inventory.router` | Dealer Inventory |
| `/api/v1/dealers` | `dealers.router` | Dealers |
| `/api/v1/dealer` | `dealer_analytics.router` | Dealer Analytics |
| `/api/v1/dealer` | `dealer_campaigns.router` | Dealer Campaigns |
| `/api/v1/dealer` | `dealer_onboarding.router` | Dealer Onboarding |
| `/api/v1/dealer` | `dealer_documents.router` | Dealer Documents |
| `/api/v1/dealer-stations` | `dealer_stations.router` | Dealer Stations |
| `/api/v1/admin` | `global_admin_router` | Admin (global) |
| `/api/v1/dashboard` | `dashboard_router` | Admin Dashboard |
| `/api/v1/admin/users` | `admin_sub_users.router` | Admin: Users |
| `/api/v1/admin/faqs` | `admin_faqs.router` | Admin: FAQs |
| `/api/v1/admin/analytics` | `admin_analytics.router` | Admin: Analytics |
| `/api/v1/admin/promo` | `admin_coupons.router` | Admin: Promo |
| `/api/v1/admin/reviews` | `admin_reviews.router` | Admin: Reviews |
| `/api/v1/admin/roles` | `admin_roles.router` | Admin: Roles |
| `/api/v1/admin/legal` | `admin_legal.router` | Admin: Legal |
| `/api/v1/admin/banners` | `admin_banners.router` | Admin: Banners |
| `/api/v1/admin/media` | `admin_media.router` | Admin: Media |
| `/api/v1/admin/blogs` | `admin_blogs.router` | Admin: Blogs |
| `/api/v1/admin/kyc` | `admin_kyc.router` | Admin: KYC |
| `/api/v1/admin/stations` | `admin_stations.router` | Admin: Stations |
| `/api/v1/admin/security` | `security.router` | Admin: Security |
| `/api/v1/admin/invoices` | `admin_invoices.router` | Admin: Invoices |
| `/api/v1/admin/financial-reports` | `admin_financial_reports.router` | Admin: Financial Reports |
| `/api/v1/admin/audit-logs` | `admin_audit.router` | Admin: Audit |
| `/api/v1/admin/rbac` | `admin_rbac.router` | Admin: RBAC |
| `/api/v1/admin/dealers` | `admin_dealers.router` | Admin: Dealers |
| `/api/v1/admin/maintenance` | `maintenance.router` | Admin: Maintenance |
| `/api/webhooks/razorpay` | `razorpay_webhook.router` | Webhooks |
| `/api/internal/hotspots` | `internal_hotspots.router` | Internal |

**OBS-C0-1:** Two routers share the `/api/v1/location` prefix (`location.py` GPS tracking and `locations.py` geography hierarchy). One should be `/api/v1/locations` (already exists) and the other `/api/v1/location` — but both are currently mounted and both use the prefix.

**OBS-C0-2:** `/api/v1/warehouse` (singular, `warehouse_structure.py`) and `/api/v1/warehouses` (plural, `warehouses.py`) are both mounted. No disambiguation in mount tags.

**OBS-C0-3:** `/api/v1/telematics` and `/api/v1/telemetry` both mounted as separate routers for what the file docstrings describe as the same concern (IoT data ingestion).

**OBS-C0-4:** The dealer surface is split across five different prefix roots: `/api/v1/dealer/auth`, `/api/v1/dealer/portal`, `/api/v1/dealers`, `/api/v1/dealer`, `/api/v1/dealer-stations` — five different mount patterns for one domain.

---

### C1 — Endpoint Inventory by Domain

#### Domain: Authentication & Sessions

**File: `auth.py` — mount `/api/v1/auth`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| POST | `/register` | `register` | `UserCreate*` | `UserResponse` | none | `deps.get_db` |
| POST | `/token` | `login_access_token` | `EmailPasswordRequestForm*` | `Token` | rate\_limit 5/min | `deps.get_db` |
| POST | `/login` | `login` | `LoginRequest*` | `LoginResponse` | `Header(X-App-Scope)` | `get_session` |
| POST | `/register/request-otp` | `request_registration_otp` | `OTPRequest*` | `dict` | none | `deps.get_db` |
| POST | `/register/verify-otp` | `verify_registration_otp` | `OTPVerifyRequest*` | `Token` | none | `deps.get_db` |
| POST | `/verify-otp` | `verify_otp_alias` | `OTPVerifyRequest*` | `Token` | none | `deps.get_db` |
| POST | `/social-login` | `social_login` | `SocialLoginRequest*` | `LoginResponse` | none | `get_session` |
| POST | `/register/password` | `register_with_password` | `PasswordRegisterRequest*` | `Token` | none | `deps.get_db` |
| POST | `/refresh` | `refresh_token` | `RefreshRequest*` | `Token` | none | `get_session` |
| POST | `/logout` | `logout` | none | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/select-role` | `select_role` | `RoleSelectRequest*` | `LoginResponse` | `get_current_user` | `deps.get_db` |
| POST | `/logout-all` | `logout_all` | none | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/forgot-password` | `forgot_password` | `ForgotPasswordRequest*` | `dict` | rate\_limit 5/hr | `deps.get_db` |
| POST | `/resend-otp` | `resend_otp` | `OTPRequest*` | `dict` | rate\_limit 5/hr | `deps.get_db` |
| POST | `/email/send-verification` | `send_email_verification` | `SendEmailVerificationRequest*` | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/resend-verification` | `send_email_verification` | `SendEmailVerificationRequest*` | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/verify-email` | `verify_email` | `VerifyEmailRequest*` | `dict` | none | `deps.get_db` |
| POST | `/change-password` | `change_password` | `ChangePasswordRequest*` | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/enable-2fa` | `enable_2fa_request` | none | `TwoFASetupResponse` | `get_current_user` | `deps.get_db` |
| POST | `/verify-2fa` | `verify_2fa_and_enable` | `TwoFAVerifyRequest*` | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/2fa/disable` | `disable_2fa` | `TwoFADisableRequest*` | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/biometric/register` | `register_biometric` | `BiometricRegisterRequest*` | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/biometric-login` | `biometric_login` | `BiometricLoginRequest*` | `Token` | none | `deps.get_db` |
| GET | `/security-questions` | `get_security_questions` | none | `List[SecurityQuestionResponse]` | none | `deps.get_db` |
| POST | `/security-questions/set` | `set_security_question` | `SetSecurityQuestionRequest*` | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/security-questions/verify` | `verify_security_question` | `VerifySecurityQuestionRequest*` | `dict` | none | `deps.get_db` |
| POST | `/admin/login` | `admin_login` | `AdminLoginRequest*` | `dict` | none | `get_session` |

**FACT:** `/resend-verification` and `/email/send-verification` map to the **same handler function** `send_email_verification`.
**OBS-C1-1:** `auth.py` mixes `deps.get_db` and `get_session` across its endpoints — 22 use `deps.get_db`, 5 use `get_session` directly.
**OBS-C1-2:** 17 out of 27 response models in `auth.py` are `dict` — no structured response schema.
**OBS-C1-3:** All inline `*` schemas are defined inside `auth.py` rather than in `app/schemas/`.
**OBS-C1-4:** `/forgot-password` is rate-limited at 5/hour; `/resend-otp` is rate-limited at 5/hour; but `/register/request-otp` has no rate limit.
**OBS-C1-5:** `/admin/login` is nested inside `/auth` — serves a different user class (admin) from the same router.
**OBS-C1-6:** `POST /auth/login` and `POST /auth/token` both log in a password-authenticated user. They are registered separately and use different DB session deps.

---

**File: `customer_auth.py` — mount `/api/v1/customer/auth`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| POST | `/login` | `customer_login` | `CustomerLoginRequest*` | `CustomerAuthResponse*` | none | `deps.get_db` |
| POST | `/register` | `customer_register` | `CustomerRegisterRequest*` | `CustomerAuthResponse*` | none | `deps.get_db` |

**OBS-C1-7:** No `/refresh`, `/logout`, or `/change-password` endpoints in `customer_auth.py`. Session lifecycle management for customers using this entry point is absent.
**OBS-C1-8:** `CustomerAuthResponse` is defined inline in `customer_auth.py`, not in `app/schemas/`.

---

**File: `dealer_portal_auth.py` — mount `/api/v1/dealer/auth`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| POST | `/login` | `dealer_login` | `DealerLoginRequest*` | `dict` | none | `deps.get_db` |
| POST | `/register` | `dealer_register` | `DealerRegisterRequest*` | `DealerAuthResponse*` | none | `deps.get_db` |
| GET | `/onboarding-status` | `get_onboarding_status` | none | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/change-password` | `change_password` | `ChangePasswordRequest*` | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/refresh` | `refresh_token` | `RefreshTokenRequest*` | `DealerAuthResponse*` | none | `deps.get_db` |

**OBS-C1-9:** `dealer_portal_auth.py` has `/refresh` and `/change-password`; `customer_auth.py` does not — inconsistent coverage across auth entry points.
**OBS-C1-10:** `dealer_login` response model is `dict` (untyped) while `dealer_register` returns `DealerAuthResponse`.

---

**File: `passkeys.py` — mount `/api/v1/auth` (same prefix as `auth.py`)**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| POST | `/passkeys/register/options` | `create_registration_options` | `PasskeyRegistrationOptionsRequest` | `PasskeyOptionsResponse` | `get_current_user` | `get_session` |
| POST | `/passkeys/register/verify` | `verify_registration` | `PasskeyRegistrationVerifyRequest` | `PasskeyRegistrationVerifyResponse` | `get_current_user` | `get_session` |
| POST | `/passkeys/auth/options` | `create_authentication_options` | `PasskeyOptionsRequest` | `PasskeyOptionsResponse` | none | `get_session` |
| POST | `/passkeys/auth/verify` | `verify_authentication` | `PasskeyVerifyRequest` | `LoginResponse` | none | `get_session` |
| GET | `/passkeys` | `list_passkeys` | none | `PasskeyListResponse` | `get_current_user` | `get_session` |
| DELETE | `/passkeys/{credential_id}` | `delete_passkey` | none | `PasskeyOperationResponse` | `get_current_user` | `get_session` |

**OBS-C1-11:** `passkeys.py` exclusively uses `get_session` (direct import) while `auth.py` uses both `get_session` and `deps.get_db`.
**OBS-C1-12:** The path `/passkeys/auth/options` and `/passkeys/auth/verify` use the word `auth` as a path segment, while the parent router is already mounted at `/auth`. Full path becomes `/api/v1/auth/passkeys/auth/options` — `auth` appears twice.

---

**File: `sessions.py` — mount `/api/v1/sessions`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| GET | `/list` | `list_sessions` | none | `List[SessionResponse]` | `get_current_user` | `get_session` |
| POST | `/revoke/{session_id}` | `revoke_session` | none | `dict` | `get_current_user` | `get_session` |

**OBS-C1-13:** `GET /sessions/list` — the word `list` is redundant; the collection path `GET /sessions` already implies listing.
**OBS-C1-14:** `POST /sessions/{session_id}/revoke` uses `POST` for a deletion operation.

---

#### Domain: Users & Profile

**File: `users.py` — mount `/api/v1/users`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| POST | `/` | `create_user` | `UserCreate` | `UserResponse` | `check_permission("users","create")` | `deps.get_db` |
| GET | `/` | `list_users` | none | `UserSearchResponse` | `get_current_user` | `deps.get_db` |
| GET | `/search` | `search_users` | none | `UserSearchResponse` | `get_current_user` | `deps.get_db` |
| GET | `/me` | `get_current_user_profile` | none | `UserProfileResponse` | `get_current_user` | `deps.get_db` |
| PUT | `/me` | `update_user_profile` | `UserUpdate` | `UserProfileResponse` | `get_current_user` | `deps.get_db` |
| PATCH | `/me` | `patch_user_profile` | `UserUpdate` | `UserResponse` | `get_current_user` | `deps.get_db` |
| DELETE | `/me` | `delete_account` | `AccountDeletionRequest*` | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/me/profile-picture` | `upload_profile_picture` | file upload | `ProfilePictureResponse*` | `get_current_user` | `deps.get_db` |
| POST | `/me/avatar` | `upload_avatar` | file upload | `UserResponse` | `get_current_user` | `deps.get_db` |
| DELETE | `/me/avatar` | `delete_avatar` | none | `UserResponse` | `get_current_user` | `deps.get_db` |
| GET | `/me/addresses` | `list_addresses` | none | `List[AddressResponse]` | `get_current_user` | `deps.get_db` |
| POST | `/me/addresses` | `create_address` | `AddressCreate` | `AddressResponse` | `get_current_user` | `deps.get_db` |
| PUT | `/me/addresses/{address_id}` | `update_address` | `AddressUpdate` | `AddressResponse` | `get_current_user` | `deps.get_db` |
| PUT | `/me/addresses/{address_id}/default` | `set_default_address` | none | `AddressResponse` | `get_current_user` | `deps.get_db` |
| DELETE | `/me/addresses/{address_id}` | `delete_address` | none | none | `get_current_user` | `deps.get_db` |
| GET | `/me/sessions` | `get_user_sessions` | none | `List[UserSessionResponse*]` | `get_current_user` | `get_session` |
| DELETE | `/me/sessions/{session_id}` | `revoke_user_session` | none | `dict` | `get_current_user` | `get_session` |
| GET | `/me/login-history` | `get_login_history` | none | `LoginHistoryResponse*` | `get_current_user` | `deps.get_db` |
| GET | `/me/activity-log` | `get_activity_log` | none | `ActivityLogResponse*` | `get_current_user` | none |
| GET | `/me/membership` | `get_membership` | none | `MembershipResponse*` | `get_current_user` | `deps.get_db` |
| GET | `/me/dashboard-summary` | `get_dashboard_summary` | none | `DashboardSummaryResponse*` | `get_current_user` | `deps.get_db` |
| GET | `/me/feature-flags` | `get_feature_flags` | none | `FeatureFlagsResponse*` | `get_current_user` | none |
| GET | `/me/dashboard-widgets` | `get_dashboard_widgets` | none | `DashboardConfigResponse*` | `get_current_user` | none |
| GET | `/me/notification-preferences` | `get_notification_preferences` | none | `NotificationPreferencesResponse*` | `get_current_user` | `deps.get_db` |
| PUT | `/me/notification-preferences` | `update_notification_preferences` | `NotificationPreferencesUpdate*` | `NotificationPreferencesResponse*` | `get_current_user` | `deps.get_db` |
| GET | `/{user_id}` | `get_user` | none | `AdminUserProfileResponse*` | `get_current_user` | `get_session` |
| PUT | `/{user_id}/status` | `update_user_status` | `UserStatusUpdate*` | `UserResponse` | `get_current_user` | `get_session` |
| GET | `/{user_id}/activity` | `get_user_activity` | none | `ActivityLogResponse*` | `get_current_user` | `get_session` |
| DELETE | `/{user_id}` | `admin_delete_user` | none | `UserResponse` | `get_current_user` | `get_session` |

**OBS-C1-15:** Both `PUT /me` and `PATCH /me` exist and map to different handlers (`update_user_profile` vs `patch_user_profile`). They have the same request schema `UserUpdate`.
**OBS-C1-16:** Both `POST /me/profile-picture` and `POST /me/avatar` upload a profile image. `POST /me/avatar` is marked DEPRECATED in a code comment but still active.
**OBS-C1-17:** Session-related endpoints exist in both `users.py` (`GET /users/me/sessions`, `DELETE /users/me/sessions/{id}`) and `sessions.py` (`GET /sessions/list`, `POST /sessions/revoke/{id}`) for the same resource.
**OBS-C1-18:** `GET /users/` and `GET /users/search` — two separate handlers returning the same `UserSearchResponse`. No documented distinction in what they each do differently.
**OBS-C1-19:** `users.py` uses three different DB deps: `deps.get_db` (most endpoints), `get_session` (endpoints touching sessions and admin user ops), and `none` (feature-flags, widgets, activity-log). No consistent pattern.
**OBS-C1-20:** `DELETE /{user_id}` is accessible by any authenticated user (`get_current_user`), not just admins. No `check_permission` or superuser guard visible on this handler.

---

#### Domain: KYC

**File: `kyc.py` — mount `/api/v1` (no sub-prefix)**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| GET | `/kyc/status` | `get_kyc_status` | none | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/kyc/submit` | `submit_kyc` | Form + files | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/kyc/aadhaar-verify` | `verify_aadhaar` | Form | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/kyc/pan-verify` | `verify_pan` | Form | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/kyc/video-kyc` | `submit_video_kyc` | file upload | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/me/kyc/video-kyc/request` | `request_video_kyc` | none | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/kyc/resubmit` | `resubmit_kyc` | none | `dict` | `get_current_user` | `deps.get_db` |
| GET | `/kyc/rejection-reasons` | `get_rejection_reasons` | none | `List[RejectionReasonResponse]` | none | none |
| POST | `/kyc/utility-bill-verify` | `verify_utility_bill` | file upload | `dict` | `get_current_user` | `deps.get_db` |

**OBS-C1-21:** All 9 endpoints return `dict` — no structured response schemas.
**OBS-C1-22:** `kyc.py` is mounted at `/api/v1` with no sub-prefix, so paths have an inconsistent prefix pattern (`/kyc/submit` but also `/me/kyc/video-kyc/request`). One path uses `/me/kyc/...` and the rest use `/kyc/...` — two different sub-prefix conventions in the same file.
**OBS-C1-23:** `GET /kyc/rejection-reasons` is the only unauthenticated endpoint in this file. No `deps.get_db` or auth.
**OBS-C1-24:** No `@audit_log` decorator on any KYC submission or verification endpoint.

---

#### Domain: Stations & Monitoring

**File: `stations.py` — mount `/api/v1/stations`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| GET | `/` | `list_stations` | none | `List[StationResponse]` | `require_permission` | `deps.get_db` |
| GET | `/nearby` | `get_nearby_stations` | query params | `List[NearbyStationResponse]` | none | `deps.get_db` |
| POST | `/` | `create_station` | `StationCreate` | `StationResponse` | `get_current_active_superuser` | `deps.get_db` |
| GET | `/{station_id}` | `get_station` | none | `StationResponse` | none | `deps.get_db` |
| PUT | `/{station_id}` | `update_station` | `StationUpdate` | `StationResponse` | `get_current_active_superuser` | `deps.get_db` |
| DELETE | `/{station_id}` | `delete_station` | none | none | `get_current_active_superuser` | `deps.get_db` |
| GET | `/{station_id}/batteries` | `get_station_batteries` | none | `List[BatteryResponse]` | none | `deps.get_db` |
| GET | `/{station_id}/analytics` | `get_station_analytics` | none | `dict` | `require_permission` | `deps.get_db` |
| POST | `/{station_id}/reserve` | `reserve_station` | `ReservationCreate` | `ReservationResponse` | `get_current_user` | `deps.get_db` |

**OBS-C1-25:** `GET /stations/nearby` and `GET /stations/{station_id}` are both unauthenticated — expose location data publicly.
**OBS-C1-26:** Auth pattern is inconsistent across the file: `require_permission`, `get_current_active_superuser`, `get_current_user`, and `none` all used in the same router.
**OBS-C1-27:** `POST /{station_id}/reserve` creates a reservation from the stations router — this crosses domain boundary with `customer_reservations.py`.

---

**File: `station_monitoring.py` — mount `/api/v1/station-monitoring`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| GET | `/health` | `get_station_health` | none | `dict` | `get_current_active_admin` | `deps.get_db` |
| POST | `/heartbeat` | `station_heartbeat` | `HeartbeatPayload*` | `dict` | `require_internal_service_token` | `deps.get_db` |
| GET | `/alerts` | `get_alerts` | none | `List[AlertResponse]` | `get_current_active_admin` | `deps.get_db` |

**OBS-C1-28:** `POST /heartbeat` uses verb in path. Uses `require_internal_service_token` auth rather than user auth — different auth class from all other endpoints in the same mounted prefix.

---

#### Domain: Batteries & Inventory

**File: `batteries.py` — mount `/api/v1/batteries`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| GET | `/` | `list_batteries` | none | `DataResponse[List]` | `require_permission` | `deps.get_db` |
| POST | `/` | `create_battery` | `BatteryCreate` | `DataResponse[Battery]` | `require_permission` | `deps.get_db` |
| GET | `/{battery_id}` | `get_battery` | none | `BatteryDetailResponse` | none | `deps.get_db` |
| PUT | `/{battery_id}` | `update_battery` | `BatteryUpdate` | `BatteryResponse` | `require_permission` | `deps.get_db` |
| DELETE | `/{battery_id}` | `delete_battery` | none | none | `require_permission` | `deps.get_db` |
| POST | `/scan-qr` | `scan_qr` | `QRCodeRequest*` | `BatteryDetailResponse` | none | `deps.get_db` |
| GET | `/{battery_id}/health-history` | `get_health_history` | none | `DataResponse[List]` | none | `deps.get_db` |
| GET | `/{battery_id}/audit-logs` | `get_battery_audit_logs` | none | `DataResponse[List]` | none | `deps.get_db` |
| PUT | `/{battery_id}/status` | `update_battery_status` | `BatteryStatusUpdate*` | `BatteryResponse` | `require_permission` | `deps.get_db` |
| POST | `/{battery_id}/assign-station` | `assign_to_station` | `StationAssignRequest*` | `BatteryResponse` | `require_permission` | `deps.get_db` |
| POST | `/{battery_id}/transfer` | `transfer_battery` | `TransferRequest*` | `BatteryResponse` | `require_permission` | `deps.get_db` |
| GET | `/low-health` | `get_low_health_batteries` | none | `DataResponse[List]` | `require_permission` | `deps.get_db` |
| POST | `/qr/generate` | `generate_qr` | none | `DataResponse[dict]` | `require_permission` | `deps.get_db` |
| POST | `/qr/verify` | `verify_qr` | `QRVerifyRequest*` | `DataResponse[dict]` | none | `deps.get_db` |
| POST | `/batch/import` | `batch_import` | file upload | `DataResponse[dict]` | `require_permission` | `deps.get_db` |
| GET | `/batch/export` | `batch_export` | none | file response | `require_permission` | `deps.get_db` |

**OBS-C1-29:** `POST /scan-qr`, `GET /{id}/health-history`, `GET /{id}/audit-logs`, `POST /qr/verify` — all unauthenticated. Audit logs and health history are operational data with no access control.
**OBS-C1-30:** Response wrapper is inconsistent: some endpoints return `DataResponse[...]`, others return bare `BatteryResponse` / `BatteryDetailResponse`, others return `none`.
**OBS-C1-31:** `PUT /{battery_id}/status` and `POST /{battery_id}/assign-station` — state mutation operations use `PUT` and `POST` respectively with no consistent rule for which triggers which method.

---

#### Domain: Rentals & Bookings

**File: `rentals.py` — mount `/api/v1/rentals`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| GET | `/` | `list_rentals` (admin) | none | `List[RentalResponse]` | `get_current_active_superuser` | `deps.get_db` |
| GET | `/` | `list_rentals` | none | `List[RentalResponse]` | `get_current_active_superuser` | `deps.get_db` |
| GET | `/my` | `get_my_rentals` | none | `List[RentalResponse]` | `get_current_user` | `deps.get_db` |
| GET | `/active` | `get_active_rental` | none | `List[RentalResponse]` | `get_current_user` | `deps.get_db` |
| POST | `/` | `create_rental` | `RentalCreate` | `RentalResponse` | `get_current_user` | `deps.get_db` |
| GET | `/{rental_id}` | `get_rental` | none | `RentalResponse` | `get_current_user` | `deps.get_db` |
| POST | `/{rental_id}/return` | `return_rental` | `ReturnRequest` | `RentalResponse` | `get_current_user` | `deps.get_db` |
| PUT | `/{rental_id}` | `update_rental` | `RentalUpdate` | `RentalResponse` | `get_current_active_superuser` | `deps.get_db` |

**File: `rentals_enhanced.py` — mount `/api/v1/rentals`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| POST | `/{rental_id}/report-issue` | `report_issue` | `IssueReport*` | `dict` | `get_current_user` | `deps.get_db` |
| GET | `/{rental_id}/receipt` | `get_rental_receipt` | none | `dict` | `get_current_user` | `deps.get_db` |

**OBS-C1-32:** `GET /rentals/my` uses `/my` — inconsistent with the `/me` standard used in `users.py`, `dealers.py`, and `sessions.py`.
**OBS-C1-33:** `GET /` has a double-decorator pattern (`@router.get("/admin/all")` and `@router.get("/")`). Both map to same handler requiring `get_current_active_superuser` — the `/admin/all` path nests an admin path inside the user-facing router.

---

**File: `bookings.py` — mount `/api/v1/bookings`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| POST | `/` | `create_booking` | `BookingCreate` | `BookingResponse` | `get_current_user` | `deps.get_db` |
| GET | `/` | `list_bookings` | none | `List[BookingResponse]` | `get_current_user` | `deps.get_db` |
| GET | `/{booking_id}` | `get_booking` | none | `BookingResponse` | `get_current_user` | `deps.get_db` |
| PUT | `/{booking_id}` | `update_booking` | `BookingUpdate` | `BookingResponse` | `get_current_user` | `deps.get_db` |
| DELETE | `/{booking_id}` | `cancel_booking` | none | none | `get_current_user` | `deps.get_db` |

**OBS-C1-34:** `bookings.py` and `customer_reservations.py` both exist and both manage advance claims on stations/batteries. No documented distinction between a "booking" and a "reservation" in the codebase.

---

#### Domain: Wallet, Payments & Transactions

**File: `wallet.py` — mount `/api/v1/wallet`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| GET | `/` | `get_wallet` | none | `WalletResponse` | `get_current_user` | `deps.get_db` |
| GET | `/balance` | `get_wallet_balance` | none | `dict` | `get_current_user` | `deps.get_db` |
| GET | `/transactions` | `get_wallet_transactions` | none | `List[TransactionResponse]` | `get_current_user` | `deps.get_db` |
| POST | `/recharge` | `initiate_recharge` | `RechargeRequest*` | `dict` | `get_current_user` | `deps.get_db` |
| GET | `/payment-methods` | `list_payment_methods` | none | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/payment-methods` | `add_payment_method` | `PaymentMethodCreate*` | `dict` | `get_current_user` | `deps.get_db` |
| DELETE | `/payment-methods/{method_id}` | `delete_payment_method` | none | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/withdraw` | `request_withdrawal` | `WithdrawRequest*` | `dict` | `get_current_user` | `deps.get_db` |
| GET | `/transactions/{payment_id}/receipt` | `get_payment_receipt` | none | file response | `get_current_user` | `deps.get_db` |

**File: `wallet_enhanced.py` — mount `/api/v1/wallet`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| POST | `/withdrawals` | `withdraw_from_wallet` | `WithdrawRequest*` | `dict` | `get_current_user` | `get_session` |
| GET | `/cashback` | `get_cashback_history` | none | `dict` | `get_current_user` | `get_session` |
| POST | `/transfer` | `transfer_funds` | `TransferRequest*` | `dict` | `get_current_user` | `get_session` |

**OBS-C1-35:** `GET /wallet/` and `GET /wallet/balance` both exist on the same resource. `/wallet/` returns a full wallet object including balance; `/wallet/balance` returns only the balance scalar.
**OBS-C1-36:** `wallet.py` uses `deps.get_db`; `wallet_enhanced.py` uses `get_session` directly — two different session factories on the same `/api/v1/wallet` prefix.
**OBS-C1-37:** `/wallet/payment-methods` (wallet.py) and `/payments/methods` (payments.py) — two paths for payment method CRUD. Both are active.
**OBS-C1-38:** `/wallet/transactions` (wallet.py) and `/transactions/` (transactions.py) — two paths listing a user's transactions.

---

**File: `transactions.py` — mount `/api/v1/transactions`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| GET | `/` | `get_my_transactions` | none | `List[TransactionResponse]` | `get_current_user` | `deps.get_db` |
| GET | `/{id}/invoice` | `get_invoice` | none | `Invoice` | `get_current_user` | `deps.get_db` |

**OBS-C1-39:** `transactions.py GET /` uses `Transaction.wallet` relationship join for ownership. `payments.py GET /transactions` uses `Transaction.user_id` direct field. Both return transaction history for the authenticated user from the same table.
**OBS-C1-40:** `GET /{id}/invoice` uses `FinancialService.create_invoice()` which auto-generates an invoice if one does not exist. `payments.py GET /invoice/{id}` returns metadata only without auto-generation — different behaviour, same resource.

---

**File: `payments.py` — mount `/api/v1/payments`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| POST | `/methods` | `add_payment_method` | `PaymentMethodCreate*` | `dict` | `get_current_user` | `deps.get_db` |
| DELETE | `/methods/{method_id}` | `delete_payment_method` | none | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/methods/{method_id}/default` | `set_default_payment_method` | none | `dict` | `get_current_user` | `deps.get_db` |
| GET | `/orders/{order_id}/invoice` | `download_order_invoice` | none | PDF stream | `get_current_user` | `deps.get_db` |
| GET | `/rentals/{rental_id}/invoice` | `download_rental_invoice` | none | PDF stream | `get_current_user` | `deps.get_db` |
| GET | `/transactions` | `get_user_all_payments` | none | `DataResponse[list]` | `get_current_user` | `deps.get_db` |
| GET | `/payment-methods` | `get_payment_methods` | none | `DataResponse[dict]` | `get_current_user` | `deps.get_db` |
| GET | `/{id}` | `get_payment_detail` | none | `DataResponse[dict]` | `get_current_user` | `deps.get_db` |
| POST | `/{id}/refund` | `admin_initiate_refund` | `RefundRequest*` | `DataResponse[dict]` | `get_current_active_superuser` | `deps.get_db` |
| GET | `/{id}/refund-status` | `get_refund_status` | none | `DataResponse[dict]` | `get_current_user` | `deps.get_db` |
| GET | `/admin/payments` | `admin_get_all_payments` | none | `DataResponse[list]` | `get_current_active_superuser` | `deps.get_db` |
| GET | `/admin/revenue` | `get_revenue_dashboard` | none | `DataResponse[RevenueSummary]` | `get_current_active_superuser` | `deps.get_db` |
| GET | `/admin/revenue/by-station` | `get_revenue_by_station` | none | `DataResponse[List]` | `get_current_active_superuser` | `deps.get_db` |
| GET | `/admin/revenue/forecast` | `get_revenue_forecast` | none | `DataResponse[List]` | `get_current_active_superuser` | `deps.get_db` |
| GET | `/admin/profit-margins` | `get_profit_margins` | none | `DataResponse[List]` | `get_current_active_superuser` | `deps.get_db` |
| POST | `/orders/{order_id}/refund` | `request_refund` | `RefundRequest*` | `DataResponse[dict]` | `get_current_user` | `deps.get_db` |
| GET | `/refunds` | `get_user_refunds` | none | `DataResponse[list]` | `get_current_user` | `deps.get_db` |
| GET | `/refunds/history` | `list_refunds` | none | `list` | `get_current_user` | `deps.get_db` |
| GET | `/{transaction_id}/receipt` | `get_receipt` | none | `dict` | `get_current_user` | `deps.get_db` |
| GET | `/invoice/{transaction_id}` | `get_invoice` | none | `dict` | `get_current_user` | `deps.get_db` |
| POST | `/webhooks/razorpay` | `razorpay_webhook` | raw body | `dict` | signature verify | `deps.get_db` |
| POST | `/razorpay/webhook` | `razorpay_webhook` | raw body | `dict` | signature verify | `deps.get_db` |

**OBS-C1-41:** `POST /webhooks/razorpay` and `POST /razorpay/webhook` are two different paths registered on the **same handler** via stacked decorators — both live and both active.
**OBS-C1-42:** Admin revenue endpoints (`/admin/payments`, `/admin/revenue`, `/admin/revenue/by-station`) are nested inside the customer-facing `/payments` router rather than in an admin sub-router.
**OBS-C1-43:** `GET /payments/payment-methods` and `POST /payments/methods` — two different paths for payment methods in the same file (one GET at `/payment-methods`, one POST at `/methods`). Inconsistent sub-path naming within the same router.

---

#### Domain: Notifications

**File: `notifications_enhanced.py` — mount `/api/v1/notifications`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| GET | `/my` | `read_notifications` | none | `List[NotificationResponse]` | `get_current_user` | `get_session` |
| PATCH | `/{notification_id}/read` | `mark_notification_read` | none | `dict` | `get_current_user` | `get_session` |
| PUT | `/{notification_id}/read` | `put_mark_notification_read` | none | `dict` | `get_current_user` | `get_session` |
| PATCH | `/read-all` | `mark_all_notifications_read` | none | `dict` | `get_current_user` | `get_session` |
| PUT | `/read-all` | `put_mark_all_read` | none | `dict` | `get_current_user` | `get_session` |
| POST | `/device-token` | `register_device_token` | `DeviceTokenRequest` | `dict` | `get_current_user` | `get_session` |
| DELETE | `/device-token` | `unregister_device_token` | `DeviceTokenUnregisterRequest` | `dict` | `get_current_user` | `get_session` |
| DELETE | `/{notification_id}` | `delete_notification` | none | `dict` | `get_current_user` | `get_session` |
| DELETE | `` | `clear_all_notifications` | none | `dict` | `get_current_user` | `get_session` |
| POST | `/send` | `admin_send_notification` | `AdminNotificationSendRequest` | `dict` | `get_current_active_superuser` | `get_session` |
| POST | `/admin/bulk` | `admin_bulk_notification` | `AdminNotificationSendRequest` | `dict` | `get_current_active_superuser` | `get_session` |
| GET | `/unread-count` | `get_my_unread_count` | none | `UnreadCountResponse` | `get_current_user` | `get_session` |

**OBS-C1-44:** `PATCH /{id}/read` and `PUT /{id}/read` are registered as separate routes but map to functionally identical handlers. Same for `PATCH /read-all` and `PUT /read-all`.
**OBS-C1-45:** `GET /notifications/my` uses `/my` — inconsistent with the `/me` convention.
**OBS-C1-46:** Admin endpoints `POST /send` and `POST /admin/bulk` are mounted inside the customer-facing notifications router (not in an admin sub-router).
**OBS-C1-47:** All endpoints use `get_session` directly (not `deps.get_db`), which differs from most other v1 routers.

---

#### Domain: Support & FAQs

**File: `support.py` — mount `/api/v1/support`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| GET | `/tickets` | `list_tickets` | none | `List[TicketResponse]` | `get_current_active_superuser` | `deps.get_db` |
| GET | `/tickets/my` | `get_my_tickets` | none | `List[TicketResponse]` | `get_current_user` | `deps.get_db` |
| POST | `/tickets` | `create_ticket` | `TicketCreate` | `TicketResponse` | `get_current_user` | `deps.get_db` |
| GET | `/tickets/{ticket_id}` | `get_ticket` | none | `TicketResponse` | `get_current_user` | `deps.get_db` |
| POST | `/tickets/{ticket_id}/reply` | `reply_to_ticket` | `TicketReply` | `TicketResponse` | `get_current_user` | `deps.get_db` |
| PUT | `/tickets/{ticket_id}/close` | `close_ticket` | none | `TicketResponse` | `get_current_user` | `deps.get_db` |
| GET | `/faq` | `list_faqs` | none | `List[FAQResponse]` | none | `deps.get_db` |
| GET | `/faq/{faq_id}` | `get_faq` | none | `FAQResponse` | none | `deps.get_db` |
| POST | `/chat/initiate` | `initiate_chat` | `ChatInitiateRequest*` | `dict` | `get_current_user` | `deps.get_db` |

**File: `support_enhanced.py` — mount `/api/v1/support`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| POST | `/tickets/{ticket_id}/attachment` | `upload_ticket_attachment` | file upload | `dict` | `get_current_user` | `deps.get_db` |
| GET | `/faq/search` | `search_faq` | none | `List[FAQResponse]` | none | `deps.get_db` |

**OBS-C1-48:** `GET /support/tickets` (all tickets, requires superuser) and `GET /support/tickets/my` (own tickets) are in the same router at sibling paths.
**OBS-C1-49:** `/support/faq` (singular) is in `support.py`; `/faqs/` (plural, separate file) is mounted at a different prefix. Both serve FAQ data.
**OBS-C1-50:** `PUT /tickets/{id}/close` uses `PUT` for a state transition operation.

---

**File: `faqs.py` — mount `/api/v1/faqs`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| GET | `/` | `list_faqs` | none | `List[FAQResponse]` | none | `deps.get_db` |
| GET | `/{faq_id}` | `get_faq` | none | `FAQResponse` | none | `deps.get_db` |
| POST | `/{faq_id}/helpful` | `mark_helpful` | none | `dict` | `get_current_user` | `deps.get_db` |

**OBS-C1-51:** `faqs.py GET /` and `support.py GET /faq` both list FAQs from the same table with the same unauthenticated access pattern.

---

#### Domain: Analytics & Reporting

**File: `analytics.py` — mount `/api/v1/analytics`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| GET | `/dashboard` | `get_dashboard` | none | `DataResponse[dict]` | `get_current_user` | `deps.get_db` |
| GET | `/rental-history` | `get_rental_history_stats` | none | `DataResponse[dict]` | `get_current_user` | `deps.get_db` |
| GET | `/cost-analytics` | `get_cost_analytics` | none | `DataResponse[dict]` | `get_current_user` | `deps.get_db` |
| GET | `/usage-patterns` | `get_usage_patterns` | none | `DataResponse[dict]` | `get_current_user` | `deps.get_db` |
| GET | `/carbon-savings` | `get_carbon_savings` | none | `DataResponse[dict]` | `get_current_user` | `deps.get_db` |
| GET | `/export` | `export_analytics_data` | none | `DataResponse / CSV` | `get_current_user` | `deps.get_db` |
| GET | `/recent-activity` | `get_recent_activity` | none | `DataResponse[dict]` | `get_current_user` | `deps.get_db` |
| POST | `/reports/dashboard` | `queue_dashboard_report` | `DashboardReportRequest*` | `DataResponse[dict]` | `get_current_user` | `deps.get_db` |
| GET | `/reports/{report_id}` | `get_dashboard_report_status` | none | `DataResponse[dict]` | `get_current_user` | none |
| GET | `/reports/{report_id}/download` | `download_dashboard_report` | none | file response | `get_current_user` | none |

**OBS-C1-52:** `GET /analytics/dashboard` and `GET /analytics/recent-activity` both serve dual-audience data (customer vs admin) by inspecting `role_names` inside the handler rather than using separate endpoints or deps.
**OBS-C1-53:** `GET /analytics/export` uses a verb (`export`) in the path.

---

#### Domain: Orders (Logistics) & Catalog (E-commerce)

**OBS-C1-54:** Both `orders.py` (mounted at `/api/v1/orders`) and `catalog.py` (mounted at `/api/v1/catalog/orders`) register `GET /` and `POST /` for an "orders" resource. They operate on different models (`DeliveryOrder` vs `CatalogOrder`) but share the resource noun `orders` without any distinguishing prefix at the top level.

**OBS-C1-55:** `logistics.py` (mounted at `/api/v1/logistics`) also contains order-related endpoints (`GET /orders`, `POST /orders`, `GET /orders/{id}`, etc.) operating on yet another view of orders.

---

#### Domain: Roles & RBAC

**File: `roles.py` — mount `/api/v1/roles`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| POST | `/` | `create_role` | `RoleCreate` | `RoleRead` | `check_permission("roles","create")` | `get_db` (core) |
| GET | `/` | `read_roles` | none | `List[RoleRead]` | `get_current_user` | `get_db` (core) |
| GET | `/{role_id}` | `read_role` | none | `RoleRead` | `get_current_user` | `get_db` (core) |
| PUT | `/{role_id}` | `update_role` | `RoleUpdate` | `RoleRead` | `check_permission("roles","edit")` | `get_db` (core) |
| DELETE | `/{role_id}` | `delete_role` | none | none | `check_permission("roles","delete")` | `get_db` (core) |

**OBS-C1-56:** `roles.py` imports `from app.core.database import get_db` — a **third** DB session source distinct from both `deps.get_db` and `get_session`. This is the only file observed using `app.core.database.get_db`.

**File: `admin_rbac.py` — mount `/api/v1/admin/rbac`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| GET | `/roles` | `read_roles` | none | `List[RoleRead]` | `get_current_active_admin` | `deps.get_db` |
| POST | `/roles` | `create_role` | `RoleCreate` | `RoleRead` | `get_current_active_admin` | `deps.get_db` |
| GET | `/roles/{role_id}` | `read_role` | none | `RoleRead` | `get_current_active_admin` | `deps.get_db` |
| PUT | `/roles/{role_id}` | `update_role` | `RoleUpdate` | `RoleRead` | `get_current_active_admin` | `deps.get_db` |
| DELETE | `/roles/{role_id}` | `delete_role` | none | none | `get_current_active_admin` | `deps.get_db` |
| GET | `/permissions` | `list_permissions` | none | `List[PermissionRead]` | `get_current_active_admin` | `deps.get_db` |
| POST | `/users/{user_id}/roles` | `assign_role` | `RoleAssignRequest` | `dict` | `get_current_active_admin` | `deps.get_db` |
| DELETE | `/users/{user_id}/roles/{role_id}` | `revoke_role` | none | `dict` | `get_current_active_admin` | `deps.get_db` |

**File: `admin/roles.py` — mount `/api/v1/admin/roles`**

| Method | Path | Handler | Request Schema | Response Model | Auth | DB |
|--------|------|---------|----------------|----------------|------|----|
| GET | `/` | `list_roles` | none | `List[RoleResponse]` | `get_current_active_superuser` | `deps.get_db` |
| GET | `/permissions` | `list_permissions` | none | `List[PermissionResponse]` | `get_current_active_superuser` | `deps.get_db` |
| POST | `/` | `create_role` | `RoleCreate` | `RoleResponse` | `get_current_active_superuser` | `deps.get_db` |
| PUT | `/{id}` | `update_role` | `RoleUpdate` | `RoleResponse` | `get_current_active_superuser` | `deps.get_db` |

**OBS-C1-57:** Three separate files implement role CRUD (`roles.py`, `admin_rbac.py`, `admin/roles.py`) against the same `Role` DB table. They use three different service layers: `role_service`, raw DB queries with `selectinload`, and `rbac_service`.
**OBS-C1-58:** `GET /admin/rbac/permissions` and `GET /admin/roles/permissions` both list all permissions. Two active paths for the same resource under different admin prefixes.

---

#### Domain: Webhooks & Internal

**File: `app/api/webhooks/razorpay.py`**

| Method | Path | Handler | Auth |
|--------|------|---------|------|
| POST | `/api/webhooks/razorpay` | `razorpay_webhook_handler` | signature verification |

**OBS-C1-59:** A third Razorpay webhook path `/api/webhooks/razorpay` exists here (from the original `app/api/webhooks/` router), separate from the two paths in `payments.py` (`/api/v1/payments/webhooks/razorpay` and `/api/v1/payments/razorpay/webhook`). **Three active Razorpay webhook paths total.**

**File: `app/api/internal/hotspots.py`**

| Method | Path | Handler | Auth |
|--------|------|---------|------|
| POST | `/api/internal/hotspots/telematics/ingest` | `ingest_telematics` | `require_internal_service_token` |

---

### C2 — Cross-Cutting Inconsistencies

#### I-1: Database session dependency — three different sources

**FACT:** Three distinct DB session factories are in use across v1 route files:

| Source | Import | Used in |
|--------|--------|---------|
| `deps.get_db` | `from app.api import deps` | majority of files |
| `get_session` | `from app.db.session import get_session` | notifications, passkeys, sessions, wallet\_enhanced |
| `get_db` (core) | `from app.core.database import get_db` | `roles.py` only |

**OBS-I-1:** The three session factories may produce sessions with different lifecycle, commit, and rollback behaviour. Files that mix factories within the same router (e.g. `users.py` uses both `deps.get_db` and `get_session`) will have transactions scoped differently per endpoint.

---

#### I-2: Auth dependency — seven distinct guards

**FACT:** The following auth dependency patterns are in active use across routes:

| Dependency | Source | What it checks |
|---|---|---|
| `deps.get_current_user` | deps.py | Token valid, user active, session active (if sid present) |
| `deps.get_current_active_admin` | deps.py | `get_current_user` + admin/superuser role |
| `deps.get_current_active_superuser` | deps.py | `get_current_user` + `is_superuser` flag or `super_admin` role |
| `deps.check_permission(resource, action)` | deps.py | `get_current_user` + RBAC menu access |
| `deps.require_permission(perm_string)` | deps.py | `get_current_user` + specific permission string |
| `require_internal_service_token` | deps.py | Bearer token == `settings.INTERNAL_SERVICE_TOKEN` |
| none | — | Fully public endpoint |

**OBS-I-2:** `check_permission` and `require_permission` are two different deps that both check permissions but with different input formats and lookup paths. Both are active across different files.

---

#### I-3: Response model coverage — 40%+ of endpoints return `dict` or `Any`

**FACT:** Across all surveyed route files, approximately 40–50% of endpoints declare `response_model=dict` or omit `response_model` entirely, including:
- All 9 KYC endpoints (`kyc.py`)
- 17 of 27 auth endpoints (`auth.py`)
- All wallet enhanced endpoints (`wallet_enhanced.py`)
- Most notification endpoints (`notifications_enhanced.py`)
- Multiple dealer portal dashboard endpoints

**OBS-I-3:** Endpoints without a typed `response_model` bypass FastAPI's automatic response validation, serialisation filtering, and OpenAPI schema generation. Clients cannot rely on the generated API docs for those endpoints.

---

#### I-4: Inline Pydantic schemas mixed with `app/schemas/`

**FACT:** The following files define Pydantic models inline (inside the route file) rather than in `app/schemas/`:
- `auth.py` — 14+ inline models (`UserCreate`, `LoginRequest`, `OTPRequest`, `RefreshRequest`, etc.)
- `customer_auth.py` — 4 inline models
- `dealer_portal_auth.py` — 4 inline models
- `users.py` — 8+ inline models
- `payments.py` — 2 inline models (`RefundRequest`, `PaymentMethodCreate`)
- `wallet.py` — 3 inline models
- `batteries.py` — 6+ inline models

**OBS-I-4:** Inline schemas cannot be reused across routers. Any shared validation logic must be duplicated. Schema changes require finding definitions inside route files rather than a central location.

---

#### I-5: Audit logging — inconsistent use of `@audit_log` decorator

**FACT:** `@audit_log` is applied on:
- `PUT /users/me` — profile update
- `PUT /users/{id}/status` — admin status change
- `DELETE /users/{id}` — admin delete
- `POST /payments/orders/{id}/refund` — refund request

**FACT:** `@audit_log` is **not** applied on:
- Any KYC submission or approval endpoints
- Any authentication events (login, logout, register) — these use a separate `audit_log()` call inside the handler body, not the decorator
- Any battery assignment, transfer, or status change endpoints
- Any role assignment/revocation endpoints in `admin_rbac.py`

**OBS-I-5:** Two different audit patterns coexist: decorator `@audit_log(...)` and inline `audit_log(...)` service call. Some sensitive operations have neither.

---

#### I-6: HTTP method usage anomalies

**FACT:**
- `PUT /support/tickets/{id}/close` — `PUT` used for a state transition (not full resource replacement)
- `POST /sessions/{id}/revoke` — `POST` used for a deletion/invalidation
- `POST /swaps/initiate` — `POST` to a verb path where `POST /swaps` would be sufficient
- `POST /orders/{id}/assign-driver` AND `PUT /orders/{id}/assign-driver` — both methods registered on the same path in `orders.py`
- `GET /batteries/batch/export` — `GET` to a verb path that initiates a file generation operation

---

#### I-7: Admin endpoints inside customer-facing routers

**FACT:** The following admin-only endpoints are registered inside routers mounted at customer-facing prefixes:
- `POST /notifications/send` (superuser) — in `notifications_enhanced.py`
- `POST /notifications/admin/bulk` (superuser) — in `notifications_enhanced.py`
- `GET /payments/admin/payments` (superuser) — in `payments.py`
- `GET /payments/admin/revenue` (superuser) — in `payments.py`
- `GET /payments/admin/revenue/by-station` (superuser) — in `payments.py`
- `GET /payments/admin/revenue/forecast` (superuser) — in `payments.py`
- `GET /payments/admin/profit-margins` (superuser) — in `payments.py`
- `POST /payments/{id}/refund` (superuser) — in `payments.py`
- `GET /rentals/admin/all` (superuser) — double-decorated in `rentals.py`

**OBS-I-7:** These endpoints are protected by their auth dependency, but their paths suggest customer access. They appear in the same OpenAPI tag group as customer endpoints. They are not protected by the global `admin_deps` applied to `/api/v1/admin/` routers.

---

#### I-8: Rate limiting — only applied to auth endpoints

**FACT:** `@limiter.limit()` decorator is observed only in `auth.py`:
- `POST /auth/token` — 5 per minute
- `POST /auth/forgot-password` — 5 per hour
- `POST /auth/resend-otp` — 5 per hour

**OBS-I-8:** No rate limiting is applied to `POST /customer/auth/login`, `POST /dealer/auth/login`, any KYC upload endpoints, any payment endpoints, or any battery QR scan endpoints.

---

### C3 — Auth System Deep-Dive

#### C3.1 — All Auth-Adjacent Endpoints (complete list)

| Path | Method | File | Purpose |
|---|---|---|---|
| `/api/v1/auth/register` | POST | auth.py | Form-based registration |
| `/api/v1/auth/register/password` | POST | auth.py | JSON-based registration |
| `/api/v1/auth/register/request-otp` | POST | auth.py | OTP registration step 1 |
| `/api/v1/auth/register/verify-otp` | POST | auth.py | OTP registration step 2 + user creation |
| `/api/v1/auth/verify-otp` | POST | auth.py | OTP verify alias (same handler as above) |
| `/api/v1/auth/token` | POST | auth.py | OAuth2 form login |
| `/api/v1/auth/login` | POST | auth.py | JSON login with role selection |
| `/api/v1/auth/admin/login` | POST | auth.py | Admin login (nested in auth router) |
| `/api/v1/auth/social-login` | POST | auth.py | OAuth social login (Google/Apple/Facebook) |
| `/api/v1/auth/biometric-login` | POST | auth.py | Biometric credential login |
| `/api/v1/auth/passkeys/auth/options` | POST | passkeys.py | Passkey challenge generation |
| `/api/v1/auth/passkeys/auth/verify` | POST | passkeys.py | Passkey assertion verification + login |
| `/api/v1/auth/refresh` | POST | auth.py | Token rotation (all user types) |
| `/api/v1/auth/logout` | POST | auth.py | Single session logout |
| `/api/v1/auth/logout-all` | POST | auth.py | Global logout (all sessions) |
| `/api/v1/auth/select-role` | POST | auth.py | Post-login role selection (multi-role users) |
| `/api/v1/auth/change-password` | POST | auth.py | Authenticated password change |
| `/api/v1/auth/forgot-password` | POST | auth.py | Unauthenticated password reset OTP request |
| `/api/v1/auth/resend-otp` | POST | auth.py | Resend OTP (registration or reset) |
| `/api/v1/auth/email/send-verification` | POST | auth.py | Send email verification token |
| `/api/v1/auth/resend-verification` | POST | auth.py | Alias for above (same handler) |
| `/api/v1/auth/verify-email` | POST | auth.py | Verify email token |
| `/api/v1/auth/enable-2fa` | POST | auth.py | Initiate 2FA setup |
| `/api/v1/auth/verify-2fa` | POST | auth.py | Confirm 2FA code + enable |
| `/api/v1/auth/2fa/disable` | POST | auth.py | Disable 2FA |
| `/api/v1/auth/biometric/register` | POST | auth.py | Register biometric credential |
| `/api/v1/auth/security-questions` | GET | auth.py | List available security questions |
| `/api/v1/auth/security-questions/set` | POST | auth.py | Set user's security question |
| `/api/v1/auth/security-questions/verify` | POST | auth.py | Verify security question answer |
| `/api/v1/auth/passkeys/register/options` | POST | passkeys.py | Passkey registration challenge |
| `/api/v1/auth/passkeys/register/verify` | POST | passkeys.py | Passkey registration confirm |
| `/api/v1/auth/passkeys` | GET | passkeys.py | List user's registered passkeys |
| `/api/v1/auth/passkeys/{id}` | DELETE | passkeys.py | Delete passkey credential |
| `/api/v1/customer/auth/login` | POST | customer_auth.py | Customer JSON login |
| `/api/v1/customer/auth/register` | POST | customer_auth.py | Customer JSON registration |
| `/api/v1/dealer/auth/login` | POST | dealer_portal_auth.py | Dealer JSON login |
| `/api/v1/dealer/auth/register` | POST | dealer_portal_auth.py | Dealer JSON registration |
| `/api/v1/dealer/auth/change-password` | POST | dealer_portal_auth.py | Dealer password change |
| `/api/v1/dealer/auth/refresh` | POST | dealer_portal_auth.py | Dealer token refresh |
| `/api/v1/dealer/auth/onboarding-status` | GET | dealer_portal_auth.py | Dealer onboarding state |
| `/api/v1/sessions/list` | GET | sessions.py | List active sessions |
| `/api/v1/sessions/revoke/{id}` | POST | sessions.py | Revoke specific session |
| `/api/v1/users/me/sessions` | GET | users.py | List sessions (duplicate) |
| `/api/v1/users/me/sessions/{id}` | DELETE | users.py | Revoke session (duplicate) |

**FACT:** 44 auth-adjacent endpoints identified across 5 files.

---

#### C3.2 — Auth Flow Map

**Password Login — Entry points & behaviour**

```
POST /auth/token         → EmailPasswordRequestForm → OAuth2 form body
POST /auth/login         → LoginRequest JSON         → supports X-App-Scope header for role filtering
POST /customer/auth/login → CustomerLoginRequest JSON → email OR phone in 'email' field
POST /dealer/auth/login  → DealerLoginRequest JSON    → adds atomic failed-attempt counter
```

All four paths:
1. Look up user by email, then phone
2. Verify password via `verify_password()`
3. Check `user.status == ACTIVE`
4. Call role resolution
5. Update `user.last_login`
6. Generate `access_token` + `refresh_token`
7. Create `UserSession` record
8. Return token pair + user data

**Divergences:**
- Only `dealer_portal_auth.py` increments `user.failed_login_attempts` atomically and enforces lockout
- `auth.py /auth/token` returns a `Token` schema; `auth.py /auth/login` returns `LoginResponse` (includes permissions + menu); `customer_auth.py` returns `CustomerAuthResponse` (different shape)
- `auth.py /auth/login` sets `sid = str(session.id)` (stable integer); `auth.py /auth/token` and `customer_auth.py` set `sid = token_jti` (UUID string)

---

**OTP Registration — flow**

```
POST /auth/register/request-otp  → generates OTP, sends via SMS/email
POST /auth/register/verify-otp   → verifies OTP, creates User if not exists
POST /auth/verify-otp            → alias for verify-otp (same handler, line 523)
```

On verification:
- If user does not exist → creates new User with `status=ACTIVE`, assigns customer role via `_assign_primary_role()`
- If user exists and `status != ACTIVE` → **auto-activates** the user
- If user exists and `kyc_status == PENDING` → **auto-approves KYC**
- No audit log on auto-activation or auto-KYC-approval

---

**Social Login — flow**

```
POST /auth/social-login  → provider + token → verify with Google/Apple/Facebook
```

On new user creation:
- Sets `kyc_status = "verified"` hardcoded (line ~612)
- Access token created **without** `sid` claim (line ~660)
- `create_user_session()` called without `token_jti` parameter

---

**Passkey Login — flow**

```
POST /auth/passkeys/auth/options  → generate challenge (unauthenticated)
POST /auth/passkeys/auth/verify   → verify WebAuthn assertion → returns LoginResponse
```

On successful verify:
- Calls `AuthService.create_session()` (not `create_user_session()`)
- Access token created **without** `sid` claim
- Session record may not have `token_id` set

---

**Token Refresh — flow**

```
POST /auth/refresh         → available for all users via auth.py
POST /dealer/auth/refresh  → available for dealers via dealer_portal_auth.py
```

`/auth/refresh` (auth.py): validates session, rotates refresh token, sets `sid = str(session.id)` in new access token.
`/dealer/auth/refresh` (dealer_portal_auth.py): decodes refresh token directly, creates new access token — does **not** rotate the refresh token, does not update the session record.

---

**Logout — flow**

```
POST /auth/logout       → revokes single session, blacklists access token via TokenService
POST /auth/logout-all   → revokes all sessions, sets user.last_global_logout_at
POST /sessions/revoke/{id}  → marks session inactive, blacklists session.token_id
DELETE /users/me/sessions/{id}  → marks session inactive (users.py — different code path)
```

---

#### C3.3 — Auth Inconsistencies (evidence-based)

**AUTH-OBS-1: `sid` claim format is inconsistent across login entry points**

| Login path | `sid` value in access token |
|---|---|
| `POST /auth/token` | UUID string (token\_jti) |
| `POST /auth/login` | Stable `session.id` integer as string |
| `POST /customer/auth/login` | UUID string (token\_jti) |
| `POST /dealer/auth/login` | UUID string (token\_jti) |
| `POST /auth/passkeys/auth/verify` | Missing — no `sid` claim |
| `POST /auth/social-login` | Missing — no `sid` claim |
| `POST /auth/refresh` (new token) | Stable `session.id` integer as string |

**AUTH-OBS-2: Session validation skipped for tokens without `sid`**

`deps.get_current_user` checks `UserSession.is_active` only when `sid` is present in the token. Tokens issued by passkey and social login flows contain no `sid` — those sessions are never validated against `UserSession.is_active`. Revoking a passkey or social session has no effect on the corresponding access token until it expires naturally.

**AUTH-OBS-3: Two session creation methods with different signatures**

```python
# Used by: password login, OTP login, customer login, dealer login
AuthService.create_user_session(db, user_id, refresh_token, request, token_jti=jti)

# Used by: passkey login only
AuthService.create_session(db, user_id, access_token, refresh_token, device_info, ip_address)
```

The two methods take different arguments and may populate `UserSession.token_id` differently.

**AUTH-OBS-4: Brute-force protection exists only for dealer login**

`dealer_portal_auth.py` increments `user.failed_login_attempts` atomically at the SQL level and enforces lockout. `auth.py /auth/token`, `auth.py /auth/login`, and `customer_auth.py /customer/auth/login` have no failed-attempt tracking.

**AUTH-OBS-5: Five registration paths with different role assignment patterns**

| Path | Role assignment method | UserRole record created? |
|---|---|---|
| `POST /auth/register` | `_assign_primary_role(db, user, role)` | Yes |
| `POST /auth/register/password` | `_assign_primary_role(db, user, role)` | Yes |
| `POST /auth/register/verify-otp` | `_assign_primary_role(db, user, role)` | Yes |
| `POST /auth/social-login` | `_assign_primary_role(db, user, role)` | Yes |
| `POST /customer/auth/register` | `user.role_id = customer_role.id` direct | **No** |

`/customer/auth/register` sets `user.role_id` without inserting a `UserRole` join-table record, bypassing RBAC audit trail.

**AUTH-OBS-6: Email verification auto-approves KYC**

`POST /auth/verify-email` handler (line ~1136): sets `user.kyc_status = KYCStatus.APPROVED` on successful email token verification. No document validation occurs. No audit log for the KYC state change.

**AUTH-OBS-7: OTP verification auto-activates inactive users and auto-approves KYC**

`POST /auth/register/verify-otp` handler (lines ~485–492): if existing user has `status != ACTIVE` or `kyc_status == PENDING`, both are automatically updated to `ACTIVE`/`APPROVED`. No audit log.

**AUTH-OBS-8: Social login hardcodes `kyc_status = "verified"`**

`POST /auth/social-login` handler (line ~612): new users created via social login always receive `kyc_status="verified"` regardless of any document validation. No configurable flag controls this behaviour.

**AUTH-OBS-9: `/resend-verification` and `/email/send-verification` map to the same handler**

Both `POST /auth/email/send-verification` and `POST /auth/resend-verification` are registered as routes calling `send_email_verification()`. Two active paths, one handler.

**AUTH-OBS-10: Dealer token refresh does not rotate the refresh token**

`POST /dealer/auth/refresh` (dealer\_portal\_auth.py): decodes the incoming refresh token and issues a new access token, but does **not** issue a new refresh token. The original refresh token remains valid indefinitely until expiry. `POST /auth/refresh` (auth.py) does rotate the refresh token.

**AUTH-OBS-11: No `/logout` or `/refresh` in `customer_auth.py`**

Customer users who authenticated via `/customer/auth/login` have no customer-specific path for logout or token refresh. They must use `/auth/logout` and `/auth/refresh` from `auth.py`. This is undocumented.

**AUTH-OBS-12: Password reset OTP flow is incomplete**

`POST /auth/forgot-password` sends an OTP. No endpoint exists for `POST /auth/reset-password` (verify OTP + set new password). The reset completion step is either handled inside an existing OTP-verify endpoint (undocumented) or is not implemented.

**AUTH-OBS-13: Token blacklist targets differ between logout paths**

| Path | What is blacklisted |
|---|---|
| `POST /auth/logout` | The access token itself |
| `POST /sessions/revoke/{id}` | `session.token_id` (typically jti from refresh token) |
| `DELETE /users/me/sessions/{id}` | No blacklisting observed in handler |

The access token and `session.token_id` are different values. Blacklisting one does not necessarily block the other.

---

### C4 — Dependency Function Reference (`app/api/deps.py`)

| Function | Returns | Raises on failure | Notes |
|---|---|---|---|
| `get_current_user` | `User` | 401 invalid token; 403 inactive/deleted/global-logout | Checks `UserSession.is_active` only if `sid` present in token |
| `get_current_active_admin` | `User` | 403 not admin | Requires `is_superuser` or admin role or `user_type==ADMIN` |
| `get_current_active_superuser` | `User` | 403 not superuser | Requires `is_superuser` or `super_admin` role |
| `get_current_dealer` | `User` | 403 not dealer | Requires `is_superuser` or dealer role or `user_type==DEALER` |
| `get_current_dealer_scope_user` | `User` | 403 no dealer affiliation | Requires dealer role OR has dealer profile record |
| `get_current_driver` | `User` | 403 not driver | Requires role in `DRIVER_ROLE_NAMES` |
| `get_current_customer` | `User` | 403 not customer | Requires role in `CUSTOMER_ROLE_NAMES` |
| `get_current_logistics` | `User` | 403 not logistics | Requires `user_type==LOGISTICS` or logistics role |
| `require_role(role_name)` | Dependency callable → `User` | 403 missing role | Factory function, dynamic |
| `require_permission(perm_string)` | Dependency callable → `User` | 403 missing permission | Factory, checks permission string directly |
| `check_permission(resource, action)` | Dependency callable → `User` | 403 no RBAC access | Factory, checks via RBAC menu service |
| `require_internal_operator` | `User` | 403 not operator | Admin + logistics combined |
| `require_driver_or_internal_operator` | `User` | 403 | Driver OR operator |
| `require_customer_or_internal_operator` | `User` | 403 | Customer OR operator |
| `require_internal_service_token` | `None` | 403 invalid token | Bearer token == `settings.INTERNAL_SERVICE_TOKEN` |
| `get_active_roles_for_user_id` | `List[Role]` | — | Queries UserRole with expiry filtering |
| `get_user_role_names` | `set[str]` | — | Extracts role names from user object and flags |
| `get_dealer_profile_for_user_id` | `DealerProfile \| None` | — | Direct lookup then fallback to `created_by_dealer_id` |
| `invalidate_token_cache` | `None` | — | Removes token from in-process auth cache |
| `invalidate_user_token_cache` | `None` | — | Removes all cached tokens for a user |

**OBS-C4-1:** `check_permission` and `require_permission` are two different factories that both validate permissions but via different lookup paths. No documented rule for which to use in which context. Both are in active use across different files.

**OBS-C4-2:** `get_current_user` silently skips session validation when the token has no `sid` claim (passkey/social login). This means the same dependency provides different security guarantees depending on which login method was used.

---

### C5 — Summary Issue Index

All observations from this audit, cross-referenced.

| ID | File(s) | Category | Short description |
|---|---|---|---|
| OBS-C0-1 | main.py | Routing | Two routers share `/api/v1/location` prefix |
| OBS-C0-2 | main.py | Routing | `/warehouse` and `/warehouses` both mounted |
| OBS-C0-3 | main.py | Routing | `/telematics` and `/telemetry` both mounted |
| OBS-C0-4 | main.py | Routing | Dealer domain split across 5 prefix roots |
| OBS-C1-1 | auth.py | DB session | Mixes `deps.get_db` and `get_session` |
| OBS-C1-2 | auth.py | Response schema | 17/27 endpoints return untyped `dict` |
| OBS-C1-3 | auth.py | Schema location | All schemas defined inline |
| OBS-C1-4 | auth.py | Rate limiting | `/register/request-otp` unrate-limited |
| OBS-C1-5 | auth.py | Domain boundary | Admin login nested inside user auth router |
| OBS-C1-6 | auth.py | Duplication | `/auth/login` and `/auth/token` both perform password login |
| OBS-C1-7 | customer\_auth.py | Completeness | No refresh/logout/change-password |
| OBS-C1-8 | customer\_auth.py | Schema location | Response schema defined inline |
| OBS-C1-9 | dealer\_portal\_auth.py | Inconsistency | Has refresh + change-password; customer auth does not |
| OBS-C1-10 | dealer\_portal\_auth.py | Response schema | Login returns `dict`; register returns typed schema |
| OBS-C1-11 | passkeys.py | DB session | Uses `get_session` exclusively |
| OBS-C1-12 | passkeys.py | Naming | `/auth/passkeys/auth/...` — `auth` appears twice in path |
| OBS-C1-13 | sessions.py | Naming | `GET /sessions/list` — redundant `list` segment |
| OBS-C1-14 | sessions.py | HTTP method | `POST /sessions/{id}/revoke` for a deletion |
| OBS-C1-15 | users.py | Duplication | Both `PUT /me` and `PATCH /me` active with same schema |
| OBS-C1-16 | users.py | Duplication | Both `POST /me/profile-picture` and `POST /me/avatar` active |
| OBS-C1-17 | users.py / sessions.py | Duplication | Session management in two files at different paths |
| OBS-C1-18 | users.py | Duplication | `GET /users/` and `GET /users/search` return same type |
| OBS-C1-19 | users.py | DB session | Uses `deps.get_db`, `get_session`, and none across endpoints |
| OBS-C1-20 | users.py | Auth | `DELETE /{user_id}` accessible by any authenticated user |
| OBS-C1-21 | kyc.py | Response schema | All 9 endpoints return `dict` |
| OBS-C1-22 | kyc.py | Naming | Two sub-prefix conventions in same file (`/kyc/` and `/me/kyc/`) |
| OBS-C1-23 | kyc.py | Auth | `GET /kyc/rejection-reasons` unauthenticated |
| OBS-C1-24 | kyc.py | Audit | No `@audit_log` on any KYC operation |
| OBS-C1-25 | stations.py | Auth | `GET /nearby` and `GET /{id}` unauthenticated |
| OBS-C1-26 | stations.py | Auth | Four different auth patterns in same router |
| OBS-C1-27 | stations.py | Domain boundary | `POST /{id}/reserve` crosses into reservations domain |
| OBS-C1-28 | station\_monitoring.py | HTTP method | `POST /heartbeat` verb in path |
| OBS-C1-29 | batteries.py | Auth | Audit logs and health history publicly accessible |
| OBS-C1-30 | batteries.py | Response schema | `DataResponse[...]` mixed with bare models |
| OBS-C1-31 | batteries.py | HTTP method | `PUT` and `POST` used inconsistently for state mutations |
| OBS-C1-32 | rentals.py | Naming | `GET /rentals/my` uses `/my` instead of `/me` |
| OBS-C1-33 | rentals.py | Routing | Double-decorator places admin path inside user router |
| OBS-C1-34 | bookings.py | Domain | Overlap with `customer_reservations.py` |
| OBS-C1-35 | wallet.py | Duplication | `GET /wallet/` and `GET /wallet/balance` for same resource |
| OBS-C1-36 | wallet.py / wallet\_enhanced.py | DB session | Different session factories on same prefix |
| OBS-C1-37 | wallet.py / payments.py | Duplication | Two payment-method paths active |
| OBS-C1-38 | wallet.py / transactions.py | Duplication | Two transaction-list paths active |
| OBS-C1-39 | transactions.py / payments.py | Duplication | `GET /transactions/` vs `GET /payments/transactions` |
| OBS-C1-40 | transactions.py / payments.py | Behaviour | Invoice auto-generation vs metadata-only — same resource |
| OBS-C1-41 | payments.py | Duplication | Two Razorpay webhook paths on same handler |
| OBS-C1-42 | payments.py | Domain boundary | Admin revenue endpoints in customer-facing router |
| OBS-C1-43 | payments.py | Naming | `/payment-methods` and `/methods` in same file |
| OBS-C1-44 | notifications\_enhanced.py | Duplication | `PATCH` and `PUT` aliases for identical operations |
| OBS-C1-45 | notifications\_enhanced.py | Naming | `GET /notifications/my` uses `/my` |
| OBS-C1-46 | notifications\_enhanced.py | Domain boundary | Admin endpoints in customer-facing router |
| OBS-C1-47 | notifications\_enhanced.py | DB session | Uses `get_session` exclusively |
| OBS-C1-48 | support.py | Routing | Admin and user list endpoints at sibling paths |
| OBS-C1-49 | support.py / faqs.py | Duplication | `/support/faq` and `/faqs/` serve same data |
| OBS-C1-50 | support.py | HTTP method | `PUT` for state transition on `/close` |
| OBS-C1-51 | support.py / faqs.py | Duplication | Both list FAQs from same table |
| OBS-C1-52 | analytics.py | Auth | Role check inside handler body instead of dep |
| OBS-C1-53 | analytics.py | Naming | `GET /analytics/export` — verb in path |
| OBS-C1-54 | orders.py / catalog.py | Naming | Both use `orders` noun for different models |
| OBS-C1-55 | logistics.py | Duplication | Third `orders` endpoint set in logistics router |
| OBS-C1-56 | roles.py | DB session | Uses `app.core.database.get_db` — third DB factory |
| OBS-C1-57 | roles.py / admin\_rbac.py / admin/roles.py | Duplication | Role CRUD in three files with three service layers |
| OBS-C1-58 | admin\_rbac.py / admin/roles.py | Duplication | Two active paths listing permissions |
| OBS-C1-59 | webhooks/razorpay.py / payments.py | Duplication | Three active Razorpay webhook paths |
| OBS-I-1 | multiple | DB session | Three different session factories in use |
| OBS-I-2 | multiple | Auth | Two overlapping permission-check dep factories |
| OBS-I-3 | multiple | Response schema | ~40–50% of endpoints untyped (`dict` or no `response_model`) |
| OBS-I-4 | multiple | Schema location | Inline Pydantic models in 7+ route files |
| OBS-I-5 | multiple | Audit | Two audit patterns; many sensitive ops have neither |
| OBS-I-6 | multiple | HTTP method | `PUT` for state transitions, `POST` for deletes |
| OBS-I-7 | multiple | Domain boundary | Admin endpoints in customer-facing routers |
| OBS-I-8 | multiple | Rate limiting | Rate limiting only on three auth endpoints |
| AUTH-OBS-1 | auth stack | Auth | `sid` claim format inconsistent across login paths |
| AUTH-OBS-2 | auth stack | Auth | Session validation skipped for passkey/social tokens |
| AUTH-OBS-3 | auth stack | Auth | Two session creation methods with different signatures |
| AUTH-OBS-4 | auth stack | Auth | Brute-force protection only on dealer login |
| AUTH-OBS-5 | auth stack | Auth | Five register paths; one skips UserRole record |
| AUTH-OBS-6 | auth.py | Auth | Email verify auto-approves KYC |
| AUTH-OBS-7 | auth.py | Auth | OTP verify auto-activates users and auto-approves KYC |
| AUTH-OBS-8 | auth.py | Auth | Social login hardcodes `kyc_status="verified"` |
| AUTH-OBS-9 | auth.py | Duplication | Two paths map to same email verification handler |
| AUTH-OBS-10 | dealer\_portal\_auth.py | Auth | Dealer refresh does not rotate refresh token |
| AUTH-OBS-11 | customer\_auth.py | Completeness | No logout/refresh for customer auth entry point |
| AUTH-OBS-12 | auth.py | Completeness | Password reset OTP has no completion endpoint |
| AUTH-OBS-13 | auth stack | Auth | Token blacklist targets differ across logout paths |

---

## Implementation Update — 2026-04-21 (Fast Cutover Wave)

Applied in code:
- [x] A3-1 Removed `GET /api/v1/payments/transactions` (canonical list remains `GET /api/v1/transactions`)
- [x] A3-2 Removed `GET /api/v1/wallet/transactions/{id}/receipt` (canonical receipt remains in `payments.py`)
- [x] A3-3 Removed duplicate `GET /me/dashboard` from `dealers.py` (dealer portal dashboard remains canonical)
- [x] B3 `GET /notifications/my` renamed to `GET /notifications/me`
- [x] B8 Removed duplicate notification `PUT` aliases for read/read-all
- [x] B4 Sessions: `GET /sessions/list` -> `GET /sessions`; `POST /sessions/revoke/{id}` -> `DELETE /sessions/{id}`
- [x] B4 Support: `/tickets/my`, `/reply`, `/close`, `/chat/initiate`, `/faq` migrated to canonical noun paths
- [x] B4 Wallet: `POST /wallet/recharge` -> `POST /wallet/top-ups`; enhanced transfer path standardized to `/wallet/transfers`
- [x] B5 Logistics namespace remounted from `/api/v1/orders` to `/api/v1/deliveries`
- [x] B6 `/api/v1/telemetry` remounted into `/api/v1/telematics`
- [x] B7 Dealer portal mount topology flattened to `/api/v1/dealers/me/*`
- [x] B11 Driver assignment normalized to `POST /deliveries/{id}/driver` + `DELETE /deliveries/{id}/driver`
- [x] Razorpay webhook canonicalized to `POST /api/v1/payments/webhooks/razorpay` (legacy webhook mounts removed)
- [x] Admin/customer boundary cleanup for payments + notifications by mounting admin handlers under `/api/v1/admin/*`
- [x] CI policy guards added for forbidden legacy prefixes and touched-module `response_model=dict` usage

Artifacts added:
- `docs/audit/API_CUTOVER_CONTRACT_2026-04-21.md`
- `docs/audit/API_PATH_MIGRATION_MAP_2026-04-21.md`

## Implementation Update — 2026-04-21 (Phase 3 Consolidation)

Applied in code:
- [x] A3-4 Role service consolidation: `role_service` expanded as canonical CRUD + permission-sync layer
- [x] `rbac_service` duplicated role CRUD/list methods now delegate to `role_service`
- [x] `app/api/v1/admin/roles.py` migrated from `rbac_service` calls to `role_service`
- [x] `app/api/v1/admin_rbac.py` role endpoints (`read_roles`, `create_role`, `update_role`, `get_role_detail`, `delete_role`) now use `role_service` for core role operations
- [x] Removed duplicated in-endpoint role mutation logic in `admin_rbac.py` (single source of truth moved to service)
