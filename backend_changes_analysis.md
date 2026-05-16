# Backend Codebase Changes Analysis (Production to Main)

This document provides a detailed analysis of the changes introduced to the backend repository (`meat_backend`) between the `Production` branch creation and the current `main` branch. 

## High-Level Summary
Since the `Production` branch was separated from `main`, there have been **13 key commits** affecting the backend codebase. The changes are grouped into three major categories:

1. **New Features & Business Logic** (Stripe, Currency, Wishlist)
2. **Bug Fixes & Test Hardening** (WhatsApp sync, B2B validations)
3. **DevOps, CI/CD, and Structural Chores** (Dockerization, Monorepo restructuring)

---

## 1. New Features & Business Logic

### Currency & Payment Updates
- **Commit**: `b83cc62`
- **Details**: 
  - Added support for **INR (₹)** currency formatting and handling.
  - Enabled **Stripe test mode** integration.
  - Cleaned up local development files by deleting the `.env.development` override.
  - Introduced mock **test invoices** to help test payment workflows.

### Customer Storefront & Wishlist
- **Commit**: `47f80b5`
- **Details**: 
  - Created a new **Wishlist model** in the database.
  - Added new **Customer Storefront APIs** to allow users to save and retrieve items from their wishlist.

---

## 2. Bug Fixes & Test Hardening

**WhatsApp Integration**
- **Commit**: `e5ff636`
- **Details**: Hardened the **WhatsApp checkout sync** mechanism. This ensures better reliability when state changes during the WhatsApp cart-to-checkout flow.

**B2B Logic & Customer Auto-Verification**
- **Commit**: `cd2a0cb`: Updated user registration tests to reflect a new behavior where customers are **auto-verified**.
- **Commit**: `7c890c3`: Aligned API tests with **strict B2B validations** and successfully re-enabled customer **credit limits**.

**Testing/QA Stabilizations**
- **Commit**: `3a09145`: Fixed CI failures by ensuring required environment variables (`SECRET_KEY`, `STRIPE`) are injected properly during `conftest.py` setup before the app is imported.
- **Commit**: `d94ee12`: Resolved 4 lingering backend test assertions, correcting mock database checks and enforcing strict text return values.
- **Commit**: `8a5c7ec`: Fixed broken legacy imports that were failing tests due to a recent restructure in features/routing.

---

## 3. DevOps, CI/CD, and Structural Chores

### Monorepo Re-organization
- **Commit**: `c134529`
- **Details**: **Major restructuring** step moving all backend codebase files into a dedicated `meat_backend/` subfolder, helping isolate backend logic from mobile/frontend apps in the broader monorepo.
- **Commit**: `d7f4ad1`: Cleaned up duplicated structures and made layout modifications after the wishlist APIs were created.
- **Commit**: `c3f2097`: Consolidated static routing folders, relocated miscellaneous scripts, and removed old "production" environments to clean up the architecture.

### Docker Initialization
- **Commit**: `5d63e4f` (Tag: `v1.0.0`)
- **Details**: Prepared the backend for production release by setting up **Docker / docker-compose**, adding environment templates ([.env.example](file:///Users/murari/Desktop/Meat2restaurant/meat_backend/.env.example)), and writing an updated [README.md](file:///Users/murari/Desktop/Meat2restaurant/README.md).

### Database Testing Environment
- **Commit**: `3a1d995`
- **Details**: Exposed a mapping for the **Postgres container** to CI environments. Overrode default SQLite functionality to perform "live" test suite runs against an actual PostgreSQL database, ensuring closer parity to the production environment.
