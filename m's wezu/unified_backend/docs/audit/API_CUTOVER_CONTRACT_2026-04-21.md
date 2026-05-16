# API Fast Cutover Contract

## Effective date
- Published: 2026-04-21
- Hard cutover release target: 2026-05-15
- Legacy endpoints removed at cutover (no redirect compatibility window).

## Client upgrade requirement
All API clients (mobile, web, admin, internal) must ship against canonical `/api/v1/**` paths before 2026-05-15.

## Breaking policy
- Legacy aliases are removed (or remounted under canonical path only).
- Canonical method/path contracts are enforced.
- `404/405/410` on removed paths is expected behavior after cutover.

## Mandatory migration scope
- Dealer portal URLs: `/api/v1/dealer/portal/**` -> `/api/v1/dealers/me/**`
- Legacy `/my` user scope -> `/me`
- Logistics `/orders` namespace -> `/deliveries`
- Session revocation `POST /sessions/revoke/{id}` -> `DELETE /sessions/{id}`
- Wallet topup `POST /wallet/recharge` -> `POST /wallet/top-ups`
- Support ticket routes moved to canonical noun paths

## Enforcement in CI
- No duplicate `(method, path)` route registrations
- No new legacy prefixes: `/api/admin`, `/api/v1/dealer/portal`, `/my`
- No explicit `response_model=dict` in migrated route modules
