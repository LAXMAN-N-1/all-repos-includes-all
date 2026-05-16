# API3 Backend Compatibility Report

Checked on: 2026-04-24 (IST)
Target backend: `https://api3.powerfrill.com`

Update on 2026-04-25:
- Dealer frontend now uses Supabase login/token refresh directly.
- Backend identity check switched to `GET /api/v1/auth/me`.
- Dealer feature routes remapped to `/api/v1/dealers/*` surfaces.

## Connectivity

- `GET /` -> `200` (`{"message":"Welcome to WEZU Energy API","version":"2.0.3"}`)
- `GET /api/v1/health` -> `200`
- `GET /health` -> `200`

## Dealer App Route Compatibility (Current App Contract)

Current dealer frontend expects routes such as:

- `/api/v1/dealer/auth/login`
- `/api/v1/dealer/portal/*`
- `/api/v1/dealer-stations/*`

Observed on API3:

- `/api/v1/dealer/auth/login` -> `404`
- `/api/v1/dealer/portal/dashboard` -> `404`
- `/api/v1/dealer-stations` -> `404`
- Most `/api/v1/dealer/*` endpoints -> `404`

## Auth Migration Responses on API3

Legacy auth endpoints (for example `/api/v1/auth/login`) return `410` with:

- `code: legacy_endpoint_removed`
- `replacement: /api/v1/auth/me`
- `docs_url: https://api3.powerfrill.com/docs/auth-migration`

However, no usable credential login route for this dealer app contract was discoverable during probe.

## Endpoints That Exist But Require Bearer Token

These returned `401 token_missing` (endpoint exists, token required):

- `/api/v1/dealers/me/commissions`
- `/api/v1/dealers/me/bank-account`
- `/api/v1/dealers/settlements`
- `/api/v1/batteries`
- `/api/v1/analytics/dealer/overview`

## Practical Impact

This duplicated dealer frontend is correctly wired to API3, but full login + portal flows cannot work until API3 exposes compatible dealer auth/portal endpoints (or an adapter mapping is provided).
