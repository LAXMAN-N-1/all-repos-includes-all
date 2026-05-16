# API Path Migration Map (Fast Cutover)

## Core path remounts
- `/api/v1/customer/auth/*` -> `/api/v1/customers/auth/*`
- `/api/v1/customer/dashboard/*` -> `/api/v1/customers/me/dashboard/*`
- `/api/v1/orders/*` -> `/api/v1/deliveries/*`
- `/api/v1/dealer/portal/*` -> `/api/v1/dealers/me/*`
- `/api/v1/dealer-stations/*` -> `/api/v1/dealers/stations/*`
- `/api/v1/telemetry/*` -> `/api/v1/telematics/*`
- `/api/v1/warehouse/*` -> `/api/v1/warehouses/structure/*`
- `/api/v1/location/*` -> `/api/v1/locations/rentals/*`

## Endpoint-level migrations
- `GET /api/v1/payments/transactions` -> `GET /api/v1/transactions`
- `GET /api/v1/wallet/transactions/{id}/receipt` -> `GET /api/v1/payments/{id}/receipt`
- `GET /api/v1/dealers/me/dashboard` (legacy in dealers router) -> `GET /api/v1/dealers/me/dashboard` (portal dashboard router)
- `GET /api/v1/notifications/my` -> `GET /api/v1/notifications/me`
- `PUT /api/v1/notifications/{id}/read` -> removed; use `PATCH /api/v1/notifications/{id}/read`
- `PUT /api/v1/notifications/read-all` -> removed; use `PATCH /api/v1/notifications/read-all`
- `POST /api/v1/wallet/recharge` -> `POST /api/v1/wallet/top-ups`
- `GET /api/v1/sessions/list` -> `GET /api/v1/sessions`
- `POST /api/v1/sessions/revoke/{id}` -> `DELETE /api/v1/sessions/{id}`
- `GET /api/v1/support/tickets/my` -> `GET /api/v1/support/me/tickets`
- `POST /api/v1/support/tickets/{id}/reply` -> `POST /api/v1/support/tickets/{id}/messages`
- `PUT /api/v1/support/tickets/{id}/close` -> `PATCH /api/v1/support/tickets/{id}`
- `POST /api/v1/support/chat/initiate` -> `POST /api/v1/support/chats`
- `GET /api/v1/support/faq` -> `GET /api/v1/support/faqs`
- `GET /api/v1/support/faq/{id}` -> `GET /api/v1/support/faqs/{id}`
- `POST /api/v1/orders/{id}/proof-of-delivery` -> `POST /api/v1/deliveries/{id}/delivery-proofs`
- `PUT|POST /api/v1/orders/{id}/assign-driver` -> `POST /api/v1/deliveries/{id}/driver`
- `POST /api/v1/orders/{id}/mark-in-transit` -> removed; use `PATCH /api/v1/deliveries/{id}` with `{"status":"in_transit"}`
- `POST /api/v1/orders/{id}/mark-failed` -> removed; use `PATCH /api/v1/deliveries/{id}` with `{"status":"failed","failure_reason":"..."}`

## Admin boundary migrations
- `GET /api/v1/payments/admin/payments` -> `GET /api/v1/admin/payments/transactions`
- `GET /api/v1/payments/admin/revenue` -> `GET /api/v1/admin/payments/revenue`
- `GET /api/v1/payments/admin/revenue/by-station` -> `GET /api/v1/admin/payments/revenue/by-station`
- `GET /api/v1/payments/admin/revenue/forecast` -> `GET /api/v1/admin/payments/revenue/forecast`
- `GET /api/v1/payments/admin/profit-margins` -> `GET /api/v1/admin/payments/profit-margins`
- `POST /api/v1/payments/{id}/refund` -> `POST /api/v1/admin/payments/transactions/{id}/refund`
- `POST /api/v1/notifications/send` -> `POST /api/v1/admin/notifications/send`
- `POST /api/v1/notifications/admin/bulk` -> `POST /api/v1/admin/notifications/bulk`

## Webhooks
- Canonical Razorpay webhook: `POST /api/v1/payments/webhooks/razorpay`
- Removed mounts: `/api/v1/payments/razorpay/webhook`, `/api/webhooks/razorpay`
