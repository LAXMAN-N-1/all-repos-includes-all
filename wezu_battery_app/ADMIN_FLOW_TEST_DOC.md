# WEZU Admin Panel — Flow Test Documentation

**Version:** 1.0  
**Platform:** WEZU Battery Swap Admin Panel (Flutter Web)  
**Backend:** FastAPI + PostgreSQL  
**Environment:** `https://api1.powerfrill.com`  
**Prepared By:** QA / Engineering  
**Date:** 2026-04-30

---

## Table of Contents

1. [Overview & Architecture](#1-overview--architecture)
2. [Setup Order & Dependencies](#2-setup-order--dependencies)
3. [Flow 1 — Admin Bootstrap & RBAC Setup](#3-flow-1--admin-bootstrap--rbac-setup)
4. [Flow 2 — Location & Zone Configuration](#4-flow-2--location--zone-configuration)
5. [Flow 3 — Dealer Onboarding & Approval](#5-flow-3--dealer-onboarding--approval)
6. [Flow 4 — Station Creation & Configuration](#6-flow-4--station-creation--configuration)
7. [Flow 5 — Battery Onboarding & Inventory Setup](#7-flow-5--battery-onboarding--inventory-setup)
8. [Flow 6 — Customer User Management & KYC](#8-flow-6--customer-user-management--kyc)
9. [Flow 7 — Rental Operations & Monitoring](#9-flow-7--rental-operations--monitoring)
10. [Flow 8 — Logistics & Delivery Management](#10-flow-8--logistics--delivery-management)
11. [Flow 9 — Battery Health & Maintenance](#11-flow-9--battery-health--maintenance)
12. [Flow 10 — Revenue, Settlements & Finance](#12-flow-10--revenue-settlements--finance)
13. [Flow 11 — CMS & Content Management](#13-flow-11--cms--content-management)
14. [Flow 12 — Notifications & Communications](#14-flow-12--notifications--communications)
15. [Flow 13 — Audit, Fraud & Security](#15-flow-13--audit-fraud--security)
16. [Flow 14 — System Settings & Health](#16-flow-14--system-settings--health)
17. [End-to-End Master Flow](#17-end-to-end-master-flow)
18. [Test Data Reference](#18-test-data-reference)
19. [Known Issues & Limitations](#19-known-issues--limitations)

---

## 1. Overview & Architecture

### What is the Admin Panel?

The WEZU Admin Panel is the central command system for the entire battery swap platform. Admins use it to bootstrap the system, onboard dealers and stations, manage the battery fleet, monitor rentals, and run the business end-to-end.

### System Components Involved in Admin Flows

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Admin Frontend | Flutter Web (GoRouter, 83 routes) | All admin UI workflows |
| Backend API | FastAPI (27 admin modules) | Business logic & data |
| Database | PostgreSQL (197 models) | Persistent state |
| Cache | Redis | Session & real-time data |
| IoT/MQTT | MQTT Broker | Station & battery telemetry |

### Entity Dependency Map

Understanding what must exist before what is critical for testing in the correct order.

```
System Config
    └── RBAC Roles & Permissions
            └── Admin Groups
                    └── Admin Users
                            └── Locations / Zones
                                    └── Dealers (Approved)
                                            └── Stations
                                                    └── Battery Catalog / Spec
                                                            └── Batteries (Assigned to Station)
                                                                    └── Customers (KYC Verified)
                                                                            └── Rentals / Swaps
                                                                                    └── Payments / Settlements
```

> **Rule:** Never skip a level in this chain. A station without an approved dealer, or a rental without a KYC-verified customer, will fail validation.

---

## 2. Setup Order & Dependencies

The following table defines the mandatory creation order. Each item requires all items above it to be in place.

| Step | Entity | Route | Depends On | Blocking? |
|------|--------|-------|-----------|-----------|
| 1 | RBAC Roles | `/user-master/roles` | None | Yes |
| 2 | RBAC Permissions | `/user-master/roles` | Roles | Yes |
| 3 | Admin Groups | `/user-master/groups` | None | Yes |
| 4 | Admin Users | `/user-master` | Roles, Groups | Yes |
| 5 | System Config (General Settings) | `/settings` | None | Yes |
| 6 | Feature Flags | `/settings/features` | None | No |
| 7 | Locations / Zones | `/locations` | None | Yes |
| 8 | Dealer Profile + KYC Approval | `/dealers/registrations` | Locations | Yes |
| 9 | Station Creation | `/stations` | Approved Dealer, Location | Yes |
| 10 | Battery Catalog / Spec | (via Battery creation) | None | Yes |
| 11 | Battery Onboarding | `/fleet/batteries` | Station | Yes |
| 12 | Stock Assignment | `/fleet/stock` | Batteries, Station | Yes |
| 13 | Customer User + KYC | `/users` | None | Partial |
| 14 | Rental Activation | `/rentals/active` | Customer KYC, Battery at Station | Yes |
| 15 | Logistics Orders | `/logistics/orders` | Station, Driver | No |

---

## 3. Flow 1 — Admin Bootstrap & RBAC Setup

### 3.1 Purpose

Before any operational work, the admin system itself must be configured — roles defined, permissions mapped, groups created, and admin users provisioned. This is the foundation everything else rests on.

### 3.2 Prerequisites

- Backend is running and accessible
- Super Admin credentials exist (seed or manual DB insert)
- Admin panel URL is reachable

---

### TC-01: Super Admin Login

| Field | Value |
|-------|-------|
| Test Case ID | TC-ADMIN-001 |
| Screen | `/login` |
| Priority | Critical |

**Steps:**

1. Navigate to the admin panel URL
2. Enter super admin email and password
3. Click **Login**
4. Observe redirect

**Expected Result:**
- Redirected to `/dashboard`
- Dashboard shows global stats cards (total users, stations, batteries, active rentals)
- Sidebar navigation is fully visible with all modules
- JWT token stored securely in FlutterSecureStorage

**Failure Cases:**
- Wrong credentials → show "Invalid credentials" error, no redirect
- Account inactive → show "Account suspended" message
- Network failure → show connection error toast

---

### TC-02: Create RBAC Roles

| Field | Value |
|-------|-------|
| Test Case ID | TC-ADMIN-002 |
| Screen | `/user-master/roles` |
| Priority | Critical |

**Steps:**

1. Navigate to **User Master → Roles & Permissions**
2. Click **+ New Role**
3. Fill in:
   - Name: `Operations Admin`
   - Description: `Manages stations, batteries, and logistics`
4. Save
5. Repeat for the following roles:

| Role Name | Scope |
|-----------|-------|
| Super Admin | Full access |
| Operations Admin | Stations, batteries, logistics |
| Finance Admin | Revenue, settlements, invoices |
| Support Manager | Tickets, KYC, user management |
| KYC Reviewer | KYC documents only |
| Security Admin | Audit logs, fraud, security settings |
| CMS Editor | Blogs, FAQs, banners, legal docs |

**Expected Result:**
- Each role appears in the roles list
- Role has a unique ID assigned
- Roles are filterable and searchable

---

### TC-03: Assign Permissions to Roles

| Field | Value |
|-------|-------|
| Test Case ID | TC-ADMIN-003 |
| Screen | `/user-master/roles` |
| Priority | Critical |

**Steps:**

1. Click on **Operations Admin** role
2. Navigate to Permissions tab
3. Enable the following permissions:
   - `stations:read`, `stations:write`, `stations:delete`
   - `batteries:read`, `batteries:write`
   - `logistics:read`, `logistics:write`
   - `rentals:read`
4. Save permissions

**Expected Result:**
- Permissions saved and reflected in role detail
- A user assigned this role can access exactly and only these modules
- Attempting to access finance routes with this role returns `403 Forbidden`

---

### TC-04: Create Admin Groups

| Field | Value |
|-------|-------|
| Test Case ID | TC-ADMIN-004 |
| Screen | `/user-master/groups` |
| Priority | High |

**Steps:**

1. Navigate to **User Master → Groups**
2. Click **+ New Group**
3. Create groups:

| Group Name | Description |
|------------|-------------|
| Operations Team | Handles day-to-day station ops |
| Finance Team | Revenue and settlements |
| Support Team | Customer and dealer support |
| Security Team | Audit and fraud monitoring |

**Expected Result:**
- Groups appear in list with member count (0 initially)
- Groups are assignable when creating admin users

---

### TC-05: Create Admin Users

| Field | Value |
|-------|-------|
| Test Case ID | TC-ADMIN-005 |
| Screen | `/user-master` |
| Priority | Critical |

**Steps:**

1. Navigate to **User Master**
2. Click **+ Add Admin User**
3. Fill in:
   - Full Name: `Rajan Kumar`
   - Email: `rajan@wezu.in`
   - Role: `Operations Admin`
   - Group: `Operations Team`
4. Save
5. Verify user receives invite email with one-time login link

**Expected Result:**
- User appears in admin user list
- Role and group are correctly displayed
- User can log in and is restricted to Operations Admin permissions
- Access log entry created for user creation

---

### TC-06: Verify Access Logs for Admin Actions

| Field | Value |
|-------|-------|
| Test Case ID | TC-ADMIN-006 |
| Screen | `/user-master/logs` |
| Priority | Medium |

**Steps:**

1. Navigate to **User Master → Access Logs**
2. Filter by action: `USER_CREATED`

**Expected Result:**
- Log entries appear for TC-05 user creations
- Each entry shows: admin who performed action, timestamp, IP address, affected user

---

## 4. Flow 2 — Location & Zone Configuration

### 4.1 Purpose

Stations are tied to locations. Before a station can be created, a city or zone must exist in the system.

---

### TC-07: Create Location / Zone

| Field | Value |
|-------|-------|
| Test Case ID | TC-LOC-001 |
| Screen | `/locations` |
| Priority | High |

**Steps:**

1. Navigate to **Locations**
2. Click **+ Add Location**
3. Fill in:
   - City: `Hyderabad`
   - State: `Telangana`
   - Country: `India`
   - PIN Code Range: `500001–500089`
   - Zone Code: `HYD-CENTRAL`
4. Save

**Expected Result:**
- Location appears in the list with zone code
- Location is now available in the station creation dropdown

---

## 5. Flow 3 — Dealer Onboarding & Approval

### 5.1 Purpose

Dealers own and operate stations. The admin approves dealer applications before stations can go live. This flow covers reviewing an inbound dealer application through all 8 stages to activation.

### 5.2 Prerequisites

- Location/Zone created (TC-LOC-001)
- Dealer has submitted application via the dealer portal

---

### TC-08: View Pending Dealer Applications

| Field | Value |
|-------|-------|
| Test Case ID | TC-DEALER-001 |
| Screen | `/dealers/registrations` |
| Priority | Critical |

**Steps:**

1. Navigate to **Dealers → Registrations**
2. Filter by status: `SUBMITTED`

**Expected Result:**
- Applications appear with dealer name, city, submission date
- Each application shows current stage badge

---

### TC-09: Review Dealer Business Details

| Field | Value |
|-------|-------|
| Test Case ID | TC-DEALER-002 |
| Screen | `/dealers` |
| Priority | Critical |

**Steps:**

1. Click on a pending dealer
2. Review the following tabs:
   - **Business Info:** Company name, GST number, PAN number, address
   - **Contact:** Owner name, phone, email
   - **Bank Details:** Account number, IFSC, cancelled cheque
3. Verify all fields are populated correctly

**Expected Result:**
- All business information is visible and accurate
- Bank details display (partially masked for security)

---

### TC-10: Review Dealer KYC Documents

| Field | Value |
|-------|-------|
| Test Case ID | TC-DEALER-003 |
| Screen | `/dealers/kyc` |
| Priority | Critical |

**Steps:**

1. Navigate to **Dealers → KYC**
2. Open pending KYC for the dealer
3. Review documents:
   - GST Certificate (valid, matches business name)
   - PAN Card (individual/company)
   - Shop Registration Certificate
   - Cancelled Cheque (bank account matches provided details)
4. Mark each document as **Verified**

**Expected Result:**
- Document thumbnails/PDFs are viewable in panel
- Each document has Approve / Reject action
- On all approved → KYC status updates to `VERIFIED`

---

### TC-11: Progress Application Through Stages

| Field | Value |
|-------|-------|
| Test Case ID | TC-DEALER-004 |
| Screen | `/dealers/registrations` |
| Priority | Critical |

**Steps:**

Progress the application through each stage using `PATCH /api/admin/dealers/{dealer_id}/applications/{app_id}/stage`:

| Stage | Action | Who |
|-------|--------|-----|
| `SUBMITTED` | Automated system checks | System |
| `AUTOMATED_CHECKS_PASSED` | Manual review initiated | Admin |
| `KYC_SUBMITTED` | KYC documents received | Dealer |
| `MANUAL_REVIEW_PASSED` | Admin approves manual review | Admin |
| `FIELD_VISIT_SCHEDULED` | Admin schedules field visit | Admin |
| `FIELD_VISIT_COMPLETED` | Field agent marks complete | Field Agent |
| `APPROVED` | Admin grants final approval | Admin |
| `TRAINING_COMPLETED` | Dealer completes onboarding | Dealer |
| `ACTIVE` | Full access granted | System |

**Expected Result:**
- Stage badge updates after each transition
- Dealer receives notification at each major stage (approved, rejected)
- On `ACTIVE` → dealer can log into dealer portal and create/manage stations

---

### TC-12: Reject Dealer Application

| Field | Value |
|-------|-------|
| Test Case ID | TC-DEALER-005 |
| Screen | `/dealers/registrations` |
| Priority | High |

**Steps:**

1. Open any application at `MANUAL_REVIEW_PASSED` stage
2. Click **Reject**
3. Fill in rejection reason: `Incomplete KYC - GST certificate expired`
4. Confirm rejection

**Expected Result:**
- Application status changes to `REJECTED`
- Dealer receives rejection notification with reason
- Application is visible in "Rejected" filter tab
- Dealer can re-apply after correcting issues

---

### TC-13: Configure Dealer Commission Structure

| Field | Value |
|-------|-------|
| Test Case ID | TC-DEALER-006 |
| Screen | `/dealers/commissions` |
| Priority | High |

**Steps:**

1. Open an `ACTIVE` dealer
2. Navigate to **Commissions** tab
3. Configure:
   - Commission Type: `Percentage`
   - Rate: `15%` per completed rental
   - Minimum Monthly: `₹5,000`
   - Settlement Cycle: `Monthly`
4. Save

**Expected Result:**
- Commission config saved and visible in dealer profile
- Commission calculations will apply to all future rentals at this dealer's stations
- Commission logs will be auto-generated on settlement runs

---

## 6. Flow 4 — Station Creation & Configuration

### 6.1 Purpose

Stations are the physical swap points where customers exchange batteries. This flow covers creating a station, assigning it to a dealer, setting up slots, and verifying it comes online.

### 6.2 Prerequisites

- Dealer is `ACTIVE` (TC-DEALER-004)
- Location exists (TC-LOC-001)

---

### TC-14: Create a New Station

| Field | Value |
|-------|-------|
| Test Case ID | TC-STATION-001 |
| Screen | `/stations` |
| Priority | Critical |

**Steps:**

1. Navigate to **Stations**
2. Click **+ Add Station**
3. Fill in:

| Field | Value |
|-------|-------|
| Station Name | `WEZU Ameerpet Hub` |
| Dealer | `Ravi Batteries Pvt Ltd` |
| Address | `6-3-249, Road No. 1, Ameerpet, Hyderabad` |
| City | `Hyderabad` |
| Latitude | `17.4375` |
| Longitude | `78.4482` |
| Station Type | `Automated` |
| Total Slots | `10` |
| Power Rating | `3.3 kW per slot` |
| Charger Type | `Type-2` |
| Operating Hours | `06:00 – 22:00` |
| Is 24/7 | `No` |
| Low Stock Threshold | `2` |

4. Save

**Expected Result:**
- Station created with unique Station ID
- Station appears in list with status `PENDING_SETUP`
- Station appears as a pin on the map view at `/stations/map`
- Dealer is notified of new station creation

---

### TC-15: Verify Station Appears on Map View

| Field | Value |
|-------|-------|
| Test Case ID | TC-STATION-002 |
| Screen | `/stations/map` |
| Priority | High |

**Steps:**

1. Navigate to **Stations → Map View**
2. Find the newly created station pin
3. Click on pin

**Expected Result:**
- Station pin visible at correct coordinates
- Popup shows: name, dealer, slot count, status
- Clicking opens full station details

---

### TC-16: Create Station Maintenance Checklist Template

| Field | Value |
|-------|-------|
| Test Case ID | TC-STATION-003 |
| Screen | `/stations/maintenance` |
| Priority | Medium |

**Steps:**

1. Open station detail
2. Navigate to **Maintenance** tab
3. Click **Create Checklist Template**
4. Add checklist items:
   - Inspect slot locks for wear
   - Verify network connectivity
   - Check battery charging status per slot
   - Clean station exterior
   - Test emergency stop button
5. Set frequency: `Weekly`
6. Save

**Expected Result:**
- Template saved and linked to this station
- Maintenance schedule shows next due date
- Field agents will see this checklist when logging maintenance visits

---

### TC-17: Schedule a Maintenance Visit

| Field | Value |
|-------|-------|
| Test Case ID | TC-STATION-004 |
| Screen | `/stations/maintenance` |
| Priority | Medium |

**Steps:**

1. Open the station
2. Click **Schedule Maintenance**
3. Fill in:
   - Type: `Routine`
   - Assigned Agent: `field_agent@wezu.in`
   - Scheduled Date: `2026-05-05`
   - Notes: `Monthly routine check`
4. Save

**Expected Result:**
- Maintenance record created with status `SCHEDULED`
- Assigned agent notified
- Maintenance history log updated

---

## 7. Flow 5 — Battery Onboarding & Inventory Setup

### 7.1 Purpose

Batteries are the core asset. This flow covers registering individual batteries, assigning them to stations, and monitoring stock levels.

### 7.2 Prerequisites

- Station exists (TC-STATION-001)

---

### TC-18: Add a Single Battery

| Field | Value |
|-------|-------|
| Test Case ID | TC-BAT-001 |
| Screen | `/fleet/batteries` |
| Priority | Critical |

**Steps:**

1. Navigate to **Fleet → Batteries**
2. Click **+ Add Battery**
3. Fill in:

| Field | Value |
|-------|-------|
| Serial Number | `WEZU-BAT-HYD-00001` |
| QR Code Data | `QR-WEZU-00001` |
| Battery Type | `Lithium Iron Phosphate (LFP)` |
| Capacity | `2.5 kWh` |
| Voltage | `48V` |
| Manufacturer | `WEZU OEM` |
| Manufacture Date | `2025-01-15` |
| Purchase Cost | `₹18,000` |
| Warranty Expiry | `2028-01-15` |
| Current Location | `Station: WEZU Ameerpet Hub` |
| Status | `Available` |

4. Save

**Expected Result:**
- Battery registered with unique Battery ID
- Appears in batteries list with status `Available`
- Serial number and QR code are marked as unique (duplicate check enforced)
- Battery health initialized as `GOOD`

---

### TC-19: Bulk Import Batteries via CSV

| Field | Value |
|-------|-------|
| Test Case ID | TC-BAT-002 |
| Screen | `/fleet/bulk` |
| Priority | High |

**Steps:**

1. Navigate to **Fleet → Bulk Import/Export**
2. Download the CSV template
3. Fill in 20 battery records following the template format
4. Upload the CSV
5. Review validation summary (errors, duplicates, warnings)
6. Confirm import

**Expected Result:**
- Valid rows imported successfully
- Duplicate serial numbers flagged as errors (not imported)
- Invalid rows listed with specific error reasons
- Import summary shows: `20 processed, 19 imported, 1 failed`
- All imported batteries visible in batteries list at the assigned station

---

### TC-20: Assign Battery to Station Slot

| Field | Value |
|-------|-------|
| Test Case ID | TC-BAT-003 |
| Screen | `/fleet/batteries` |
| Priority | Critical |

**Steps:**

1. Open battery `WEZU-BAT-HYD-00001`
2. Click **Assign to Slot**
3. Select station: `WEZU Ameerpet Hub`
4. Select slot: `Slot 3`
5. Confirm assignment

**Expected Result:**
- Battery status changes to `Charging` (since it's in a slot)
- Station stock count increments
- Slot 3 shows the battery's serial number in station detail view

---

### TC-21: View Stock Levels by Station

| Field | Value |
|-------|-------|
| Test Case ID | TC-BAT-004 |
| Screen | `/fleet/stock` |
| Priority | High |

**Steps:**

1. Navigate to **Fleet → Stock Levels**
2. Filter by station: `WEZU Ameerpet Hub`

**Expected Result:**
- Stock table shows: available batteries, charging, rented out, under maintenance
- Low stock warning if available count is at or below threshold (set to 2 in TC-14)
- Export button available for stock report

---

### TC-22: Transfer Stock Between Stations

| Field | Value |
|-------|-------|
| Test Case ID | TC-BAT-005 |
| Screen | `/fleet/stock` |
| Priority | Medium |

**Steps:**

1. Navigate to **Fleet → Stock Levels**
2. Click **Transfer Stock**
3. Fill in:
   - From Station: `WEZU Ameerpet Hub`
   - To Station: `WEZU Kukatpally Hub`
   - Battery: Select `WEZU-BAT-HYD-00003`
   - Reason: `Rebalancing stock`
4. Confirm

**Expected Result:**
- Battery location updated to destination station
- Audit trail entry created for the transfer
- Source station stock decrements, destination increments

---

### TC-23: View Audit Trail

| Field | Value |
|-------|-------|
| Test Case ID | TC-BAT-006 |
| Screen | `/fleet/audit` |
| Priority | Medium |

**Steps:**

1. Navigate to **Fleet → Audit Trail**
2. Filter by battery: `WEZU-BAT-HYD-00001`

**Expected Result:**
- All movement events listed: created, assigned to slot, transferred
- Each entry shows: timestamp, action, performed by, from/to location
- Export to CSV works

---

## 8. Flow 6 — Customer User Management & KYC

### 8.1 Purpose

Customers must register and pass KYC before they can rent batteries. This flow covers how admins verify customers and manage their accounts.

---

### TC-24: View Customer User List

| Field | Value |
|-------|-------|
| Test Case ID | TC-USER-001 |
| Screen | `/users` |
| Priority | High |

**Steps:**

1. Navigate to **Users**
2. Apply filters: Status = `Active`, KYC = `Pending`

**Expected Result:**
- Users matching filters appear in table
- Columns: name, email, phone, KYC status, registration date, last active
- Search by name/email/phone works

---

### TC-25: Review Customer KYC

| Field | Value |
|-------|-------|
| Test Case ID | TC-USER-002 |
| Screen | `/users` (KYC detail) |
| Priority | Critical |

**Steps:**

1. Click on a customer with `KYC: Pending`
2. Navigate to **KYC** tab
3. Review submitted documents:
   - Aadhaar Card (front and back)
   - PAN Card
   - Selfie with ID
4. Verify details match (name, DOB, address)
5. Click **Approve KYC**

**Expected Result:**
- KYC status updates to `Verified`
- Customer receives notification: "Your KYC is approved. You can now rent batteries."
- Customer now eligible to start rentals
- KYC approval event logged in audit trail

---

### TC-26: Reject Customer KYC

| Field | Value |
|-------|-------|
| Test Case ID | TC-USER-003 |
| Screen | `/users` |
| Priority | High |

**Steps:**

1. Open a pending KYC customer
2. Review documents (blurry Aadhaar found)
3. Click **Reject KYC**
4. Enter reason: `Aadhaar card image is not legible. Please re-upload a clear photo.`
5. Confirm

**Expected Result:**
- KYC status updates to `Rejected`
- Customer notified with the rejection reason
- Customer can re-submit corrected documents
- Re-submission triggers another review cycle

---

### TC-27: Suspend a Customer Account

| Field | Value |
|-------|-------|
| Test Case ID | TC-USER-004 |
| Screen | `/users` |
| Priority | High |

**Steps:**

1. Open a customer profile
2. Click **Suspend Account**
3. Enter reason: `Multiple overdue rentals with no payment`
4. Confirm suspension

**Expected Result:**
- Account status changes to `Suspended`
- Customer cannot log into the app or start new rentals
- Active rentals (if any) are flagged for review
- Suspension reason and admin action logged in audit trail

---

### TC-28: Reactivate a Suspended Account

| Field | Value |
|-------|-------|
| Test Case ID | TC-USER-005 |
| Screen | `/users` |
| Priority | Medium |

**Steps:**

1. Filter users by status: `Suspended`
2. Open the suspended customer
3. Click **Reactivate**
4. Confirm

**Expected Result:**
- Account status returns to `Active`
- Customer can log in and rent again
- Reactivation event logged

---

## 9. Flow 7 — Rental Operations & Monitoring

### 9.1 Purpose

Rentals are the core revenue event. This flow covers monitoring active rentals, reviewing rental history, tracking battery swaps, and managing late fees.

### 9.2 Prerequisites

- KYC-verified customer exists (TC-USER-002)
- Battery available at station (TC-BAT-003)

---

### TC-29: Monitor Active Rentals

| Field | Value |
|-------|-------|
| Test Case ID | TC-RENTAL-001 |
| Screen | `/rentals/active` |
| Priority | Critical |

**Steps:**

1. Navigate to **Rentals → Active**
2. Observe the live rental table
3. Click on any active rental

**Expected Result:**
- Table shows: rental ID, customer name, battery serial, station, start time, duration, amount accrued
- Detail view shows: full rental timeline, battery health at start, current GPS (if applicable)
- Real-time refresh updates duration and amount

---

### TC-30: Force End a Rental

| Field | Value |
|-------|-------|
| Test Case ID | TC-RENTAL-002 |
| Screen | `/rentals/active` |
| Priority | High |

**Steps:**

1. Open an active rental
2. Click **Force End Rental**
3. Enter reason: `Customer requested remote end via support call`
4. Confirm

**Expected Result:**
- Rental status changes to `Completed`
- Final amount calculated (up to force-end time)
- Battery marked as `Returned` and available at station
- Customer notified with invoice

---

### TC-31: View Rental History

| Field | Value |
|-------|-------|
| Test Case ID | TC-RENTAL-003 |
| Screen | `/rentals/history` |
| Priority | Medium |

**Steps:**

1. Navigate to **Rentals → History**
2. Filter by: Date Range = last 7 days, Station = `WEZU Ameerpet Hub`

**Expected Result:**
- Completed rentals shown with total amount, duration, and battery used
- Sortable by date, amount, duration
- Export to CSV functional

---

### TC-32: Review Battery Swap Transactions

| Field | Value |
|-------|-------|
| Test Case ID | TC-RENTAL-004 |
| Screen | `/rentals/swaps` |
| Priority | High |

**Steps:**

1. Navigate to **Rentals → Battery Swaps**
2. View swap transaction list
3. Click on a swap record

**Expected Result:**
- Swap record shows: swap ID, customer, returned battery serial, issued battery serial, station, timestamp
- Both batteries' health snapshots at time of swap visible
- Associated rental ID linked

---

### TC-33: Identify and Flag Overdue Rentals / Late Fees

| Field | Value |
|-------|-------|
| Test Case ID | TC-RENTAL-005 |
| Screen | `/rentals/late-fees` |
| Priority | High |

**Steps:**

1. Navigate to **Rentals → Late Fees**
2. View list of overdue rentals

**Expected Result:**
- Overdue rentals shown with: customer name, rental start, expected end, actual duration, late fee amount
- Late fee calculated based on configured rate (e.g., ₹10/hour after 24 hours)
- Option to waive fee manually with reason
- Automatic notifications sent to customers with outstanding late fees

---

### TC-34: View Purchase Orders

| Field | Value |
|-------|-------|
| Test Case ID | TC-RENTAL-006 |
| Screen | `/rentals/purchases` |
| Priority | Medium |

**Steps:**

1. Navigate to **Rentals → Purchase Orders**
2. Filter by status: `Completed`

**Expected Result:**
- Purchase orders visible with: customer, battery model, purchase price, date
- Clear distinction from rental history
- Export functional

---

## 10. Flow 8 — Logistics & Delivery Management

### 10.1 Purpose

Logistics manages the physical movement of batteries between warehouses, stations, and customers. This covers order creation, driver assignment, live tracking, and returns.

---

### TC-35: Create a Delivery Order

| Field | Value |
|-------|-------|
| Test Case ID | TC-LOG-001 |
| Screen | `/logistics/orders` |
| Priority | High |

**Steps:**

1. Navigate to **Logistics → Orders**
2. Click **+ New Order**
3. Fill in:
   - Source: `Central Warehouse, Hyderabad`
   - Destination: `WEZU Kukatpally Hub`
   - Battery Count: `5`
   - Priority: `Normal`
   - Notes: `Replenishment stock transfer`
4. Save

**Expected Result:**
- Order created with tracking number (e.g., `WZL-20260430-001`)
- Status: `Pending`
- Order visible in the logistics orders list

---

### TC-36: Assign Driver to Delivery Order

| Field | Value |
|-------|-------|
| Test Case ID | TC-LOG-002 |
| Screen | `/logistics/orders` + `/logistics/drivers` |
| Priority | High |

**Steps:**

1. Open the delivery order from TC-35
2. Click **Assign Driver**
3. Select available driver: `Suresh Kumar (DL: MH-123456)`
4. Confirm assignment

**Expected Result:**
- Order status updates to `Assigned`
- Driver notified via app notification
- Driver appears in order detail

---

### TC-37: Track Delivery in Real Time

| Field | Value |
|-------|-------|
| Test Case ID | TC-LOG-003 |
| Screen | `/logistics/tracking` |
| Priority | High |

**Steps:**

1. Navigate to **Logistics → Live Tracking**
2. Select the active delivery order

**Expected Result:**
- Map shows driver's current GPS location
- ETA to destination displayed
- Battery count and order details visible on panel
- Location updates every 30 seconds

---

### TC-38: Mark Delivery as Completed

| Field | Value |
|-------|-------|
| Test Case ID | TC-LOG-004 |
| Screen | `/logistics/orders` |
| Priority | High |

**Steps:**

1. Open the in-progress order
2. Observe driver marks delivery complete from delivery app
3. Admin side verifies order status update

**Expected Result:**
- Order status changes to `Delivered`
- Proof of delivery (photo, signature) attached to order record
- Destination station stock level increments by 5
- Delivery completion time logged

---

### TC-39: Create a Return Request

| Field | Value |
|-------|-------|
| Test Case ID | TC-LOG-005 |
| Screen | `/logistics/returns` |
| Priority | Medium |

**Steps:**

1. Navigate to **Logistics → Returns**
2. Click **+ New Return**
3. Fill in:
   - Battery: `WEZU-BAT-HYD-00005`
   - Reason: `Battery health degraded — returning to warehouse for inspection`
   - Source: `WEZU Ameerpet Hub`
   - Destination: `Central Warehouse`
4. Submit

**Expected Result:**
- Return order created and linked to battery
- Battery status changes to `In Transit`
- Return order visible in returns list with tracking

---

## 11. Flow 9 — Battery Health & Maintenance

### 11.1 Purpose

Battery health directly affects service quality and safety. This flow covers monitoring health indicators, recording maintenance work, and tracking battery lifecycle.

---

### TC-40: View Battery Health Dashboard

| Field | Value |
|-------|-------|
| Test Case ID | TC-HEALTH-001 |
| Screen | `/fleet/health` |
| Priority | High |

**Steps:**

1. Navigate to **Fleet → Battery Health**
2. Observe health distribution chart

**Expected Result:**
- Health statuses shown: `Excellent`, `Good`, `Fair`, `Poor`, `Critical`, `Damaged`
- Pie chart / bar chart with counts per category
- List of critical batteries with quick-action button

---

### TC-41: Drill into a Critical Battery

| Field | Value |
|-------|-------|
| Test Case ID | TC-HEALTH-002 |
| Screen | `/fleet/health` |
| Priority | Critical |

**Steps:**

1. Filter health status: `Critical`
2. Click on a critical battery

**Expected Result:**
- Battery detail shows:
  - Current State of Charge (SoC)
  - Internal resistance reading
  - Temperature (current and historical chart)
  - Cycle count (e.g., `1,240 / 2,000 rated cycles`)
  - Last inspection date
  - Last maintenance date
- Alert badge displayed
- Action buttons: `Send to Maintenance`, `Retire Battery`

---

### TC-42: Log Battery Maintenance

| Field | Value |
|-------|-------|
| Test Case ID | TC-HEALTH-003 |
| Screen | `/fleet/health` or `/fleet/batteries` |
| Priority | High |

**Steps:**

1. Open the critical battery from TC-41
2. Click **Send to Maintenance**
3. Fill in maintenance record:
   - Maintenance Type: `Cell Replacement`
   - Technician: `Suresh Tech`
   - Parts Replaced: `Cell pack 3`
   - Cost: `₹3,200`
   - Notes: `Pack 3 showed >30% capacity degradation`
4. Save

**Expected Result:**
- Battery status changes to `Under Maintenance`
- Battery removed from available inventory
- Maintenance record attached to battery history
- Maintenance cost logged for analytics

---

### TC-43: Mark Maintenance Complete and Return to Service

| Field | Value |
|-------|-------|
| Test Case ID | TC-HEALTH-004 |
| Screen | `/fleet/batteries` |
| Priority | High |

**Steps:**

1. Open the battery in `Under Maintenance` status
2. Click **Mark Maintenance Complete**
3. Update health status to `Good`
4. Set location back to station
5. Confirm

**Expected Result:**
- Battery status returns to `Available`
- Health status updated
- Maintenance record closed with completion date
- Battery re-appears in station stock

---

### TC-44: Retire a Battery

| Field | Value |
|-------|-------|
| Test Case ID | TC-HEALTH-005 |
| Screen | `/fleet/batteries` |
| Priority | Medium |

**Steps:**

1. Open a battery with `Damaged` health and high cycle count
2. Click **Retire Battery**
3. Enter reason: `End of useful life — 2,100+ cycles, capacity below 70%`
4. Confirm

**Expected Result:**
- Battery status set to `Retired`
- Battery removed from all active inventory counts
- Battery history preserved for audit
- Total lifecycle (days in service, total rentals, revenue generated) visible in detail view

---

## 12. Flow 10 — Revenue, Settlements & Finance

### 12.1 Purpose

Finance flows cover reviewing revenue analytics, generating dealer settlement reports, and managing invoices and late fee waivers.

---

### TC-45: View Revenue Analytics

| Field | Value |
|-------|-------|
| Test Case ID | TC-FIN-001 |
| Screen | `/dashboard/analytics` |
| Priority | High |

**Steps:**

1. Navigate to **Dashboard → Analytics**
2. Select time range: `This Month`
3. Review metrics:
   - Total Revenue
   - Revenue by Station
   - Revenue by Dealer
   - Average Rental Duration
   - Top Customers by Spend

**Expected Result:**
- All metrics populated with real data
- Charts are interactive (hover for exact values)
- Data matches manual calculation from rental history

---

### TC-46: View Dealer Commission Summary

| Field | Value |
|-------|-------|
| Test Case ID | TC-FIN-002 |
| Screen | `/dealers/commissions` |
| Priority | High |

**Steps:**

1. Navigate to **Dealers → Commissions**
2. Select a dealer
3. View commission earned this month

**Expected Result:**
- Commission summary shows: total rentals processed, gross revenue, commission rate, commission earned
- Breakdown by station
- Settlement status: `Pending`, `Processed`, `Disputed`

---

### TC-47: Generate and View Invoice

| Field | Value |
|-------|-------|
| Test Case ID | TC-FIN-003 |
| Screen | `/rentals/history` |
| Priority | Medium |

**Steps:**

1. Open a completed rental
2. Click **View Invoice**

**Expected Result:**
- Invoice PDF generated with:
  - Invoice number, date
  - Customer name, address
  - Battery serial, rental duration
  - Hourly rate, subtotal, GST, total
  - Payment method and status
- Download button functional

---

## 13. Flow 11 — CMS & Content Management

### 13.1 Purpose

The CMS manages customer-facing content: blogs, FAQs, banners, and legal documents.

---

### TC-48: Create a Blog Post

| Field | Value |
|-------|-------|
| Test Case ID | TC-CMS-001 |
| Screen | `/cms/blogs/new` |
| Priority | Medium |

**Steps:**

1. Navigate to **CMS → Blogs → New Blog**
2. Fill in:
   - Title: `How Battery Swapping Works`
   - Slug: `how-battery-swapping-works`
   - Category: `Education`
   - Content: (rich text body)
   - Featured Image: upload
   - Status: `Draft`
3. Save draft
4. Click **Publish**

**Expected Result:**
- Blog saved as draft initially
- On publish: status changes to `Published`, visible timestamp set
- Blog appears in public-facing customer app

---

### TC-49: Manage FAQ Entries

| Field | Value |
|-------|-------|
| Test Case ID | TC-CMS-002 |
| Screen | `/cms/faqs` |
| Priority | Low |

**Steps:**

1. Navigate to **CMS → FAQs**
2. Click **+ New FAQ**
3. Fill in:
   - Question: `What happens if I return the battery late?`
   - Answer: `A late fee of ₹10/hour will be charged after the first 24 hours.`
   - Category: `Pricing`
4. Save

**Expected Result:**
- FAQ visible in list
- Displayed in customer app FAQ section

---

### TC-50: Create a Marketing Banner

| Field | Value |
|-------|-------|
| Test Case ID | TC-CMS-003 |
| Screen | `/cms/banners/new` |
| Priority | Medium |

**Steps:**

1. Navigate to **CMS → Banners → New Banner**
2. Fill in:
   - Title: `Summer Sale — 20% off rentals`
   - Image: upload
   - Deep Link: `/offers/summer-sale`
   - Start Date: `2026-05-01`
   - End Date: `2026-05-31`
   - Target: `All Users`
3. Publish

**Expected Result:**
- Banner appears in the customer app home screen during the specified date range
- Expired banners automatically hidden

---

### TC-51: Upload Legal Document

| Field | Value |
|-------|-------|
| Test Case ID | TC-CMS-004 |
| Screen | `/cms/legal/new` |
| Priority | High |

**Steps:**

1. Navigate to **CMS → Legal → New Document**
2. Select type: `Privacy Policy`
3. Enter version: `v2.1`
4. Paste/upload content
5. Publish

**Expected Result:**
- New version published, previous version archived (not deleted)
- Customer app displays the latest version
- Version history visible in admin

---

## 14. Flow 12 — Notifications & Communications

---

### TC-52: Send a Push Notification

| Field | Value |
|-------|-------|
| Test Case ID | TC-NOTIF-001 |
| Screen | `/notifications/send` |
| Priority | Medium |

**Steps:**

1. Navigate to **Notifications → Send Push**
2. Fill in:
   - Title: `New Station Now Open!`
   - Body: `Visit our new WEZU Hub at Kukatpally for fast battery swaps.`
   - Target: `All Active Users`
   - Schedule: `Send Now`
3. Click **Send**

**Expected Result:**
- Notification sent to all targeted users
- Notification log entry created with delivery stats
- Users receive push notification on their devices

---

### TC-53: Create Automated Notification Trigger

| Field | Value |
|-------|-------|
| Test Case ID | TC-NOTIF-002 |
| Screen | `/notifications/triggers` |
| Priority | Medium |

**Steps:**

1. Navigate to **Notifications → Automated Triggers**
2. Click **+ New Trigger**
3. Configure:
   - Event: `RENTAL_OVERDUE`
   - Delay: `1 hour after due time`
   - Channel: `Push + SMS`
   - Message: `Your rental is overdue. Please return the battery to avoid late fees.`
4. Enable trigger

**Expected Result:**
- Trigger saved and active
- Next time a rental goes overdue, notification fires automatically after 1 hour

---

## 15. Flow 13 — Audit, Fraud & Security

---

### TC-54: View Audit Logs

| Field | Value |
|-------|-------|
| Test Case ID | TC-AUDIT-001 |
| Screen | `/audit/logs` |
| Priority | High |

**Steps:**

1. Navigate to **Audit → Logs**
2. Filter by: entity type = `Battery`, action = `TRANSFER`

**Expected Result:**
- All battery transfer actions listed with: admin user, timestamp, from/to location, battery serial
- Logs are read-only (cannot be edited or deleted)
- Export to CSV functional

---

### TC-55: View and Investigate Fraud Alerts

| Field | Value |
|-------|-------|
| Test Case ID | TC-AUDIT-002 |
| Screen | `/audit/fraud` |
| Priority | High |

**Steps:**

1. Navigate to **Audit → Fraud Dashboard**
2. Review active fraud alerts
3. Click on a suspicious alert (e.g., `Multiple rentals from same device in different cities within 1 hour`)

**Expected Result:**
- Alert details show triggering event, user, device fingerprint, location data
- Admin can: Mark as False Positive, Escalate, or Suspend User
- Action logged in fraud audit trail

---

### TC-56: Configure Security Settings

| Field | Value |
|-------|-------|
| Test Case ID | TC-AUDIT-003 |
| Screen | `/audit/security` |
| Priority | High |

**Steps:**

1. Navigate to **Audit → Security Settings**
2. Configure:
   - Minimum Password Length: `12`
   - Require 2FA for Admins: `Enabled`
   - Session Timeout: `60 minutes`
   - Max Failed Login Attempts: `5`
   - Account Lockout Duration: `30 minutes`
3. Save

**Expected Result:**
- Settings saved and immediately applied
- Admin users prompted to set up 2FA on next login if not already configured

---

## 16. Flow 14 — System Settings & Health

---

### TC-57: Configure General Settings

| Field | Value |
|-------|-------|
| Test Case ID | TC-SETTINGS-001 |
| Screen | `/settings` |
| Priority | High |

**Steps:**

1. Navigate to **Settings → General**
2. Configure:
   - Company Name: `WEZU Energy Pvt Ltd`
   - Currency: `INR`
   - Timezone: `Asia/Kolkata`
   - Support Email: `support@wezu.in`
   - Default Language: `English`
3. Save

**Expected Result:**
- Settings saved and reflected across all admin screens
- Currency symbol `₹` appears in all financial displays

---

### TC-58: Manage API Keys

| Field | Value |
|-------|-------|
| Test Case ID | TC-SETTINGS-002 |
| Screen | `/settings/api-keys` |
| Priority | High |

**Steps:**

1. Navigate to **Settings → API Keys**
2. Click **+ New API Key**
3. Fill in:
   - Name: `Razorpay Production`
   - Scope: `payments`
4. Copy the generated key
5. Enable the key

**Expected Result:**
- Key appears in list with masked value
- Status: `Active`
- Key can be toggled active/inactive
- Deletion requires confirmation

---

### TC-59: Check System Health

| Field | Value |
|-------|-------|
| Test Case ID | TC-SETTINGS-003 |
| Screen | `/settings/health` |
| Priority | Critical |

**Steps:**

1. Navigate to **Settings → System Health**

**Expected Result:**
All components show status indicators:

| Service | Expected Status |
|---------|----------------|
| Database (PostgreSQL) | Green / Healthy |
| Cache (Redis) | Green / Healthy |
| MQTT Broker | Green / Connected |
| Payment Gateway (Razorpay) | Green / Connected |
| SMS Provider | Green / Connected |
| Storage (S3/CDN) | Green / Connected |
| CPU Usage | < 80% |
| Memory Usage | < 80% |
| Disk Usage | < 85% |

- Any service showing Red triggers an alert notification to the Security/DevOps admin

---

### TC-60: Toggle Feature Flags

| Field | Value |
|-------|-------|
| Test Case ID | TC-SETTINGS-004 |
| Screen | `/settings/features` |
| Priority | Medium |

**Steps:**

1. Navigate to **Settings → Feature Flags**
2. Toggle `BATTERY_PURCHASE_ENABLED` to `OFF`
3. Verify in customer app that battery purchase option is hidden

**Expected Result:**
- Feature disabled immediately (no app restart required)
- Customer app no longer shows purchase option
- Toggle back to `ON` re-enables feature instantly

---

## 17. End-to-End Master Flow

This section describes the complete journey from a blank system to a fully operational rental completing successfully. Follow this sequence in order for full regression testing.

```
[PHASE 1 — FOUNDATION]
TC-ADMIN-001  Login as Super Admin
TC-ADMIN-002  Create RBAC Roles (all 7 roles)
TC-ADMIN-003  Assign Permissions to Roles
TC-ADMIN-004  Create Admin Groups (4 groups)
TC-ADMIN-005  Create Admin Users (Operations, Finance, Support admins)
TC-SETTINGS-001 Configure General Settings
TC-SETTINGS-003 Verify System Health (all green)

[PHASE 2 — GEOGRAPHY]
TC-LOC-001    Create Location (Hyderabad, HYD-CENTRAL zone)

[PHASE 3 — DEALER SETUP]
TC-DEALER-001 View Pending Dealer Application
TC-DEALER-002 Review Business Details
TC-DEALER-003 Review and Approve KYC Documents
TC-DEALER-004 Progress Application → ACTIVE
TC-DEALER-006 Configure Commission (15%, monthly settlement)

[PHASE 4 — STATION SETUP]
TC-STATION-001 Create Station (WEZU Ameerpet Hub, 10 slots)
TC-STATION-002 Verify on Map View
TC-STATION-003 Create Maintenance Checklist Template

[PHASE 5 — BATTERY FLEET]
TC-BAT-001    Add first battery (WEZU-BAT-HYD-00001)
TC-BAT-002    Bulk import 20 batteries via CSV
TC-BAT-003    Assign battery to station slot
TC-BAT-004    Verify stock levels show correctly

[PHASE 6 — CUSTOMER ONBOARDING]
TC-USER-001   View customer list
TC-USER-002   Approve customer KYC

[PHASE 7 — FIRST RENTAL]
TC-RENTAL-001 Observe rental become active (customer initiates via app)
TC-RENTAL-004 View swap transaction if customer swaps battery
TC-RENTAL-003 Rental completes → appears in history
TC-FIN-003    Generate invoice for completed rental

[PHASE 8 — SETTLEMENT]
TC-FIN-002    View dealer commission earned
TC-AUDIT-001  Verify all actions logged in audit trail

[RESULT: System fully operational — end-to-end rental cycle complete]
```

---

## 18. Test Data Reference

### Admin Users

| Name | Email | Role | Group |
|------|-------|------|-------|
| Super Admin | admin@wezu.in | Super Admin | — |
| Rajan Kumar | rajan@wezu.in | Operations Admin | Operations Team |
| Priya Sharma | priya@wezu.in | Finance Admin | Finance Team |
| Arjun Mehta | arjun@wezu.in | Support Manager | Support Team |

### Dealer

| Field | Value |
|-------|-------|
| Company Name | Ravi Batteries Pvt Ltd |
| GST | 36AABCR1234D1Z5 |
| City | Hyderabad |
| Commission | 15% monthly |

### Station

| Field | Value |
|-------|-------|
| Name | WEZU Ameerpet Hub |
| Station ID | STN-HYD-001 |
| Slots | 10 |
| Type | Automated |
| Low Stock Threshold | 2 |

### Battery

| Field | Value |
|-------|-------|
| Serial | WEZU-BAT-HYD-00001 |
| QR Code | QR-WEZU-00001 |
| Type | LFP 2.5 kWh |
| Status | Available |

### Customer

| Field | Value |
|-------|-------|
| Name | Anil Reddy |
| Email | anil@test.in |
| KYC Status | Verified |

---

## 19. Known Issues & Limitations

The following issues were identified during codebase audit. Test cases touching these areas may produce inconsistent results until resolved.

| Issue ID | Area | Description | Severity |
|----------|------|-------------|----------|
| BUG-001 | Settings → General | `POST /api/admin/settings/general` returns `400 Bad Request` | High |
| BUG-002 | Settings → General | `PATCH /api/admin/settings/general/{id}` returns `405 Method Not Allowed` | High |
| BUG-003 | Settings → API Keys | `POST /api/admin/settings/api-keys` returns `400` — `permissions` field not recognized by backend | High |
| BUG-004 | Settings → Feature Flags | Feature flags are fully mocked in frontend — no backend persistence | Medium |
| BUG-005 | Settings → Webhooks | Webhooks screen is mocked — no backend endpoint exists | Medium |

> TC-SETTINGS-001 and TC-SETTINGS-002 will fail until BUG-001, BUG-002, and BUG-003 are resolved.  
> TC-SETTINGS-004 will not persist across sessions until BUG-004 is resolved.

---

*End of Document*

*WEZU Admin Panel — Flow Test Documentation v1.0*  
*For internal QA and engineering use only.*
