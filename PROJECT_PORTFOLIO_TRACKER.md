# WEZU Portfolio Analysis Tracker

Last updated: 2026-04-03 (Asia/Kolkata)
Scope root: `/Users/murari/Desktop/wezu_battery_app`

## 1) Executive Snapshot

This workspace is a multi-repo platform with one central backend and multiple Flutter client apps for different personas.

- Core backend: `backend` (FastAPI monolith with broad domain coverage).
- Web/admin-style clients: `frontend_admin`, `wezu_dealer` (Flutter web-capable).
- Mobile-first clients: `frontend_customer`, `frontend_logistic`, `wezu-delivery-app`.
- Shared package: `ls_flutter_kit` (reusable Flutter kit, not a hostable runtime).

High-level architecture reality:

- All frontends depend on backend APIs.
- Backend depends on PostgreSQL + Redis, with optional/partial MQTT and Mongo use.
- External integrations include payments, OTP/SMS, email, maps, push, and error monitoring.

## 2) Repository Inventory (Operational Lens)

| Repo | Role | Clean LOC | Test Files | CI Workflow | Primary Deployable Artifact |
|---|---:|---:|---:|---|---|
| `backend` | Core API/services | 85,311 | 159 | Yes (`.github/workflows/backend-cicd.yml`) | Containerized API service |
| `frontend_admin` | Admin control panel | 96,879 | 1 | No | Flutter web/mobile app build |
| `frontend_customer` | Customer app | 54,516 | 1 | No | Flutter app build |
| `frontend_logistic` | Logistics app | 29,927 | 1 | No | Flutter app build |
| `wezu-delivery-app` | Delivery partner app | 24,423 | 2 | No | Flutter app build |
| `wezu_dealer` | Dealer portal | 34,289 | 0 | No | Flutter web/mobile app build |
| `ls_flutter_kit` | Shared package | 5,233 | 1 | No | Dart/Flutter package |

## 3) Backend Deep Analysis (`backend`)

### 3.1 Domain and API Scale

- Router includes in app bootstrap: 50.
- API route decorators found: 971.
  - `GET`: 504
  - `POST`: 279
  - `PUT`: 95
  - `PATCH`: 33
  - `DELETE`: 59
  - `WebSocket`: 1

Major domains present:

- Auth/session/RBAC.
- Customer flows: rentals, swaps, wallet, support.
- Admin flows: finance, audits, CMS, users.
- Dealer flows: onboarding, portal, docs, analytics.
- Logistics and telematics/IoT.

### 3.2 Runtime Stack

- Python 3.11+, FastAPI, SQLModel/SQLAlchemy, Alembic.
- Redis (rate limiting/cache/sessions).
- Optional MongoDB pathways.
- APScheduler-based background jobs.
- MQTT via `paho-mqtt`.
- WebSocket manager for battery stream updates.
- Integrations visible in dependencies: Razorpay, Twilio, SendGrid, Firebase Admin, boto3, Sentry, Prometheus libs.

### 3.3 Infra Artifacts Present

- Dockerfile (multi-stage, gunicorn/uvicorn worker).
- Local/prod Docker Compose files.
- K8s manifests (deployment/service/ingress/HPA/configmap + secret example).
- Backend-only CI pipeline with lint/test/build/push/deploy.

### 3.4 Operational Risks / Drift

- Doc drift: architecture docs mention Celery, code path is APScheduler-centric.
- Config mismatch:
  - `app/integrations/aws_s3.py` reads `settings.AWS_S3_BUCKET`.
  - Settings currently define `AWS_BUCKET_NAME`.
- Some integrations reference undeclared settings (`PAN_API_KEY`, `AADHAAR_API_KEY`, `GST_API_KEY`).
- Admin monitoring endpoints labeled metrics are application JSON summaries, not Prometheus scrape endpoints.
- Storage paths are mixed between local `uploads/*` and S3 logic.

### 3.5 Scheduler/Batch Reality

Configured jobs include:

- Daily: revenue aggregation, inventory sync, late fee calc, commissions, fraud score recalculation.
- Hourly/interval: health checks, geofence checks, stock alerts, overdue rentals, station monitor (2-min), charging optimization.
- Monthly: settlement/reconciliation/archival/batch payout.

Operational implication:

- If scheduler is enabled in multiple replicas, duplicate execution risk exists unless isolated to a single worker role.

### 3.6 Testing Signal

- Attempted local test run with SQLite fallback resulted in heavy failures.
- Main failure class observed:
  - PostgreSQL-oriented teardown (`TRUNCATE ... CASCADE`) incompatible with SQLite.
- Latest run summary captured:
  - 125 failed, 60 passed, 442 errors.
- Conclusion:
  - Test suite assumes PostgreSQL semantics and needs stable dedicated DB in CI/dev parity.

## 4) Frontend Project Analysis

## 4.1 `frontend_admin`

Purpose:

- Enterprise-style admin console with broad modules:
  - dashboard analytics, inventory, rentals, dealers, finance, logistics, CMS, support, audit, settings.

Tech:

- Flutter + Riverpod + GoRouter + Dio + secure storage.

Deployment notes:

- API base URL hardcoded to `http://127.0.0.1:8000`.
- Google Maps placeholders still present.
- Android release uses debug signing config.
- Minimal tests.

## 4.2 `frontend_customer`

Purpose:

- Customer lifecycle: auth/onboarding, map/station discovery, rental/wallet/payment/profile/support.

Tech:

- Flutter + Riverpod/Provider mix + Dio + `flutter_dotenv`.
- Maps/location packages and social login deps.
- Firebase deps in `pubspec`, but no Firebase config files found (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`).

Deployment notes:

- Multiple fallback/local API URL paths.
- Hardcoded Google Maps keys found in iOS/web files.
- `NSAllowsArbitraryLoads=true` in iOS Info.plist.
- Cleartext traffic enabled in Android manifest.
- Significant mock/simulated behavior remains in auth/rental/payment/support paths.

## 4.3 `frontend_logistic`

Purpose:

- Logistics operations app: orders, fleet, inventory, dashboard, tracking.

Tech:

- Flutter + Riverpod + GoRouter + Dio + smart retry.
- Hive-based offline caching for orders/inventory.

Deployment notes:

- Default API base URL local (`127.0.0.1`) with `dart-define` override option.
- Contains `useMocks` branch in API client.
- Debug logging includes token print statements in auth interceptor.
- Release signing still debug config.

## 4.4 `wezu-delivery-app`

Purpose:

- Delivery partner workflow with wallet/earnings/orders/docs/settings.

Tech:

- Flutter + Provider + HTTP.

Deployment notes:

- Many flows are mock-first (auth/session/profile/order lifecycle).
- Several services target `https://api.wezu.app`, but backend routes may not align 1:1 with expected contract in code.
- `lib/config/api_config.dart` and `lib/config/theme_config.dart` are empty placeholders.
- Android manifest lacks explicit internet permission declaration.

## 4.5 `wezu_dealer`

Purpose:

- Dealer portal with dashboard/stations/inventory/sales/customers/tickets/docs/campaigns/analytics/roles.

Tech:

- Flutter + Riverpod + GoRouter + Dio + secure storage + Freezed.

Deployment notes:

- API base hardcoded to `http://127.0.0.1:8000`.
- Some station/detail/analytics sections still use mock data pathways.
- Android manifest lacks explicit internet permission declaration.
- Release signing uses debug config.

## 4.6 `ls_flutter_kit`

Purpose:

- Shared internal package for theme, network helpers, widgets, auth utility patterns.

Tech:

- Flutter package, Dio, Riverpod, UI utilities.

Deploy impact:

- Not hosted as a service.
- Needs semantic versioning and dependency governance across consuming apps.

## 5) Hosting and AWS Service Mapping

## 5.1 Core AWS Baseline (Recommended)

- Networking:
  - VPC, public/private subnets, route tables, NAT.
  - Security groups, NACL baseline.
- Runtime:
  - ECR for backend images.
  - ECS Fargate (recommended) or EKS for backend API + optional worker role.
  - ALB + ACM + Route53.
- Data:
  - RDS PostgreSQL (or managed Postgres-compatible option with required extensions).
  - ElastiCache Redis.
  - S3 for documents/media/invoices + CloudFront (optional but recommended).
- Secrets and config:
  - AWS Secrets Manager (or SSM Parameter Store) with strict IAM.
- Observability:
  - CloudWatch Logs/metrics/alarms.
  - Optionally OpenSearch/X-Ray/Grafana stack depending on depth required.
- Security:
  - WAF on ALB.
  - IAM least privilege + KMS-managed encryption.

## 5.2 Non-AWS Dependencies to Plan

- Payments: Razorpay.
- SMS/OTP: Twilio or MSG91.
- Email: SendGrid.
- Push: Firebase FCM.
- Maps/sign-in: Google APIs + Apple Sign-In.
- Error monitoring: Sentry.
- MQTT broker:
  - AWS IoT Core, or
  - self-managed broker (Mosquitto/EMQX) in container/K8s.

## 5.3 Frontend Hosting Model

- Web targets (`frontend_admin`, `wezu_dealer`, optional web builds):
  - S3 static hosting + CloudFront + TLS/domain routing.
- Mobile targets:
  - App Store / Play Store release pipeline (not hosted web runtime).

## 6) Security and Readiness Tracker

Legend:

- `[ ]` Not started
- `[~]` In progress / partially present
- `[x]` Done

### 6.1 Secrets and Credential Hygiene

- [ ] Remove hardcoded API keys from source and rotate impacted credentials.
- [ ] Move all app/backend secrets to managed secret store.
- [ ] Add secret scanning in CI (all repos).
- [ ] Replace test/demo seed key-like strings in seed modules where applicable.

### 6.2 Transport and App Security

- [ ] Disable cleartext traffic for production Android builds.
- [ ] Remove `NSAllowsArbitraryLoads=true` for production iOS builds.
- [ ] Add strict CORS/allowed-host governance by environment.
- [ ] Add WAF rules and rate-limit policy review.

### 6.3 Auth and Token Safety

- [ ] Remove token/debug prints from client interceptors/repositories.
- [ ] Add structured redaction policy for logs.
- [ ] Validate refresh-token behavior consistently across apps.

### 6.4 Build and Release Governance

- [ ] Add release signing configs/keystore management for all Android apps.
- [ ] Add iOS signing/provisioning release checklist.
- [ ] Add per-repo CI/CD for frontends.
- [ ] Enforce branch protections and PR checks in all repos.

## 7) Environment and Lifecycle Tracker

## 7.1 Environment Standardization

- [ ] Define `dev`, `staging`, `prod` env matrices for each repo.
- [ ] Replace hardcoded localhost URLs with environment injection.
- [ ] Create central config contract (required env vars by app/service).

## 7.2 Backend Runtime Roles

- [ ] Split API and scheduler into separate deploy roles or single-leader scheduler.
- [ ] Define migration policy (`alembic upgrade head`) in deployment pipeline.
- [ ] Add startup/readiness checks for external integrations.

## 7.3 Data and Backup

- [ ] Establish RDS backup and restore drills.
- [ ] Define retention/archival policy for telemetry, logs, uploads.
- [ ] Validate GDPR/PII handling and data minimization where applicable.

## 7.4 Testing and Quality Gates

- [ ] Normalize backend tests for consistent DB backend in CI (PostgreSQL test DB).
- [ ] Expand frontend tests beyond smoke templates.
- [ ] Add contract/integration tests between backend and each persona app.

## 8) Evidence Pointers (Key Files)

- Backend config and startup:
  - `backend/app/core/config.py`
  - `backend/app/main.py`
- Backend infra:
  - `backend/Dockerfile`
  - `backend/docker-compose.yml`
  - `backend/prod/docker-compose.yml`
  - `backend/k8s/*`
  - `backend/.github/workflows/backend-cicd.yml`
- Frontend API client entry points:
  - `frontend_admin/lib/core/api/api_client.dart`
  - `frontend_customer/lib/core/constants/api_constants.dart`
  - `frontend_logistic/lib/config/app_constants.dart`
  - `wezu_dealer/lib/core/api/api_client.dart`
  - `wezu-delivery-app/lib/services/wallet_service.dart`
- Security-relevant client files:
  - `frontend_customer/ios/Runner/AppDelegate.swift`
  - `frontend_customer/web/index.html`
  - `frontend_customer/ios/Runner/Info.plist`
  - `frontend_customer/android/app/src/main/AndroidManifest.xml`

## 9) Priority Action Plan (Suggested)

P0 (immediate, deployment blocking):

1. Secrets/key cleanup + rotation.
2. Remove hardcoded localhost URLs and set env-based config.
3. Finalize production signing and release configs for mobile/web targets.
4. Resolve backend config drifts (`AWS_S3_BUCKET` vs `AWS_BUCKET_NAME`, undeclared settings references).

P1 (short term):

1. Add frontend CI pipelines with build/test/lint.
2. Separate scheduler execution role and harden job idempotency.
3. Normalize backend test environment to Postgres in CI.

P2 (medium term):

1. Contract tests for each app persona against backend.
2. Better observability and SLO dashboards.
3. Cost/performance tuning and autoscaling policy validation.

---

This file is intended as the living tracker for portfolio-level technical due diligence, deployment planning, and lifecycle governance.
