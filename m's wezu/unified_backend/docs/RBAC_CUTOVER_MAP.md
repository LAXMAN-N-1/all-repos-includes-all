# RBAC Cutover Migration Map

Canonical RBAC namespace: `/api/v1/rbac/*`

## Legacy to Canonical

- `/api/v1/admin/rbac/*` -> `/api/v1/rbac/*`
- `/api/v1/roles/*` -> `/api/v1/rbac/roles/*`
- `/api/v1/menus/*` -> `/api/v1/rbac/menus/*`
- `/api/v1/role-rights/*` -> `/api/v1/rbac/role-rights/*`

## Legacy behavior during cutover window

All legacy RBAC endpoints return:

- `410 Gone`
- JSON body:
  - `code`
  - `message`
  - `replacement`
  - `docs_url`
  - `sunset_at`
- headers:
  - `Warning`
  - `Deprecation`
  - `Sunset`
  - `Link`

## Canonical RBAC resources

- `/api/v1/rbac/roles`
- `/api/v1/rbac/permissions`
- `/api/v1/rbac/assignments`
- `/api/v1/rbac/menus`
- `/api/v1/rbac/role-rights`
- `/api/v1/rbac/access-paths`
