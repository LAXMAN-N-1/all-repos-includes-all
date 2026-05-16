# Pharma ERP - Role-Based API Documentation

## Overview
This document outlines the API endpoints accessible to each user role within the Pharma ERP system.

**Base URL:** `http://localhost:8000`  
**Swagger UI:** `http://localhost:8000/docs`

---

## 🔐 Authentication

All endpoints (except Login/Register) require a Bearer Token.

### Login
- **Endpoint:** `POST /api/v1/auth/login`
- **Body:** `{"email": "user@example.com", "password": "password"}`
- **Response:** `{"access_token": "...", "token_type": "bearer", "user": {...}}`

### Customer Registration
- **Endpoint:** `POST /api/v1/auth/register`
- **Body:** `{"email": "...", "password": "...", "full_name": "...", "phone": "..."}`
- **Note:** `organization_id` defaults to 1 (hidden from customer)

---

## 👥 Access by Role

### 1. HQ_ADMIN (Superuser)
**Responsibility:** Global System Administration, Master Data Management, Organization Setup.
*Access: Full System Access.*

| Domain | Method | Endpoint | Description |
|--------|--------|----------|-------------|
| **Organization** | GET/POST/PUT/DELETE | `/api/v1/users` | Manage all system users |
| | GET/POST/PUT/DELETE | `/api/v1/stores` | Manage stores |
| | GET/POST/PUT/DELETE | `/api/v1/roles` | Manage roles & permissions |
| **Catalog** | GET/POST/PUT/DELETE | `/api/v1/medicines` | Manage master medicine catalog |
| **Suppliers** | GET/POST/PUT/DELETE | `/api/v1/suppliers` | Manage suppliers (ORG scope default). |
| | POST | `/api/v1/suppliers/{id}/approve` | Approve supplier registration |
| **Analytics** | GET | `/api/v1/analytics/audit` | View system-wide audit logs |
| | GET | `/api/v1/analytics/controlled-substances` | DEA Compliance reports |

---

### 2. STORE_ADMIN (Store Manager)
**Responsibility:** Store Operations, Inventory Management, Procurement, Staff Oversight.
*Access: Limited to Assigned Store(s).*

| Domain | Method | Endpoint | Description |
|--------|--------|----------|-------------|
| **Inventory** | GET | `/api/v1/inventory` | List store inventory |
| | POST | `/api/v1/inventory` | Add new batch/stock |
| | PUT | `/api/v1/inventory/{id}` | Update batch details |
| | POST | `/api/v1/inventory/adjust` | Adjust stock level (Audit) |
| | GET | `/api/v1/inventory/alerts` | View low stock/expiry alerts |
| **Procurement** | GET | `/api/v1/procurement` | List Purchase Orders |
| | POST | `/api/v1/procurement` | Create PO |
| | POST | `/api/v1/procurement/{id}/submit` | Submit PO for approval |
| | POST | `/api/v1/procurement/{id}/receive` | Receive goods into inventory |
| **Orders** | GET | `/api/v1/orders` | View store orders |
| | PUT | `/api/v1/orders/{id}/status` | Update order status |
| **Suppliers** | GET | `/api/v1/suppliers` | List Organization & Own Store Suppliers |
| | POST | `/api/v1/suppliers` | Create Local Supplier (Store Scope) |
| **Prescriptions** | GET | `/api/v1/prescriptions/pending` | View verification queue |

---

### 3. PHARMACIST (Staff)
**Responsibility:** Dispensing, Prescription Verification, Sales, Stock Checking.
*Access: Limited to Assigned Store(s).*

| Domain | Method | Endpoint | Description |
|--------|--------|----------|-------------|
| **Prescriptions** | GET | `/api/v1/prescriptions/pending` | View pending prescriptions |
| | PUT | `/api/v1/prescriptions/{id}/verify` | Verify prescription (Clinical check) |
| | POST | `/api/v1/prescriptions/{id}/filled` | Mark prescription as Filled |
| **Orders** | GET | `/api/v1/orders` | View active orders |
| | PUT | `/api/v1/orders/{id}/status` | Mark Ready for Pickup / Completed |
| | PUT | `/api/v1/orders/{id}/payment` | Process payment |
| **Inventory** | GET | `/api/v1/inventory` | Check medicine availability |
| | POST | `/api/v1/inventory/adjust` | Report breakage/loss (Audit) |
| **POS** | GET | `/api/v1/medicines/search` | Search medicines for sale |

---

### 4. CUSTOMER (End User)
**Responsibility:** Self-service Order Placement, Prescription Upload, Profile Management.
*Access: Own Data Only.*

| Domain | Method | Endpoint | Description |
|--------|--------|----------|-------------|
| **Auth** | POST | `/api/v1/auth/register` | Register new account |
| | POST | `/api/v1/auth/login` | Login |
| **Shopping** | GET | `/api/v1/medicines` | Browse medicines |
| | GET | `/api/v1/medicines/search?q=` | Search medicines |
| | POST | `/api/v1/orders` | Place an order |
| | GET | `/api/v1/orders/my` | View my orders |
| | DELETE | `/api/v1/orders/{id}` | Cancel order (if eligible) |
| **Prescriptions** | POST | `/api/v1/prescriptions/upload` | Upload via URL |
| | POST | `/api/v1/prescriptions/upload-file` | **Upload file directly** (multipart/form-data) |
| | GET | `/api/v1/prescriptions` | View my prescriptions |
| | GET | `/api/v1/prescriptions/{id}/availability` | **Check medicine availability** ⭐ |
| **Profile** | GET | `/api/v1/auth/me` | View profile |

---

## 📊 Dashboard Access
All authenticated users can access the dashboard. The content is personalized by role.

- **Endpoint:** `GET /api/v1/dashboard/stats`
- **Endpoint:** `GET /api/v1/dashboard/menus` (Returns authorized menu tree)

---

## � Payment Gateway (Razorpay)

Integrated payment processing for online order payments.

### Payment Endpoints

| Role | Method | Endpoint | Description |
|------|--------|----------|-------------|
| **All Authenticated** | POST | `/api/v1/payments/create/{order_id}` | Create Razorpay order for payment |
| **All Authenticated** | POST | `/api/v1/payments/verify` | Verify payment after checkout |
| **All Authenticated** | GET | `/api/v1/payments/{order_id}/status` | Get payment status |
| **HQ_ADMIN, STORE_ADMIN** | POST | `/api/v1/payments/{order_id}/refund` | Initiate full/partial refund |
| **Public (Webhook)** | POST | `/api/v1/payments/webhook` | Razorpay webhook handler |

### Payment Flow

1. **Create Payment Order:**
   ```
   POST /api/v1/payments/create/123
   Response: { razorpay_order_id, razorpay_key, amount, currency }
   ```

2. **After Razorpay Checkout - Verify Payment:**
   ```
   POST /api/v1/payments/verify
   Body: { order_id, razorpay_order_id, razorpay_payment_id, razorpay_signature }
   ```

3. **Check Payment Status:**
   ```
   GET /api/v1/payments/123/status
   Response: { payment_status, is_paid, razorpay_payment_id }
   ```

4. **Initiate Refund (Admin Only):**
   ```
   POST /api/v1/payments/123/refund
   Body: { reason: "Customer request", amount: 500.00 }  // amount optional
   ```

---

## 📊 Reports & Export

Export data to Excel and PDF formats.

### Report Endpoints

| Report | Method | Endpoint | Format | Access |
|--------|--------|----------|--------|--------|
| **Inventory** | GET | `/api/v1/reports/inventory/export` | Excel/PDF | HQ_ADMIN, STORE_ADMIN |
| **Orders** | GET | `/api/v1/reports/orders/export` | Excel/PDF | HQ_ADMIN, STORE_ADMIN |
| **Prescriptions** | GET | `/api/v1/reports/prescriptions/export` | PDF | HQ_ADMIN, STORE_ADMIN, PHARMACIST |
| **Sales** | GET | `/api/v1/reports/sales/export` | Excel/PDF | HQ_ADMIN, STORE_ADMIN |

### Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `format` | string | `excel` or `pdf` (default: excel) |
| `store_id` | int | Filter by store (optional) |
| `date_from` | date | Start date filter (YYYY-MM-DD) |
| `date_to` | date | End date filter (YYYY-MM-DD) |

### Example Usage

```
GET /api/v1/reports/sales/export?format=pdf&date_from=2026-01-01&date_to=2026-01-31
→ Downloads: sales_report.pdf
```

---

## 💡 Common Status Codes
- `200 OK`: Success (GET/PUT)
- `201 Created`: Resource created (POST)
- `400 Bad Request`: Validation error
- `401 Unauthorized`: Invalid/Missing Token
- `403 Forbidden`: Role not authorized for this action
- `404 Not Found`: Resource does not exist
