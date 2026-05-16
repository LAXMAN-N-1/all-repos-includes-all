# B2B Meat Platform - Frontend Integration Guide

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture & Technology Stack](#architecture--technology-stack)
3. [Authentication & Authorization](#authentication--authorization)
4. [Core API Endpoints](#core-api-endpoints)
5. [Data Models](#data-models)
6. [Implementation Examples](#implementation-examples)
7. [Error Handling](#error-handling)
8. [Best Practices](#best-practices)

---

## 1. Project Overview

### What is This Platform?
The B2B Meat Platform is an **Enterprise Resource Planning (ERP)** system designed for wholesale meat distribution. It manages the complete business lifecycle from product catalog to invoicing and payments.

### Key Features
- **Dual Identity System**: Separate portals for Staff (internal) and Partners (B2B customers)
- **Credit-Based Ordering**: B2B partners have credit limits and payment terms
- **Automated Billing**: Scheduled invoice generation with customizable billing cycles
- **Multi-Location Support**: Partners can manage multiple delivery addresses
- **Volume Pricing**: Tiered discounts based on order quantity
- **Real-Time Inventory**: Stock tracking with low-stock alerts
- **WhatsApp Integration**: AI-powered order placement via WhatsApp

### User Roles
| Role | Identity Type | Access Level |
|------|---------------|--------------|
| **Admin** | Staff | Full system access |
| **Manager** | Staff | Operations & reporting |
| **Sales Agent** | Staff | Customer management |
| **Partner** | Customer | Own orders & invoices only |

---

## 2. Architecture & Technology Stack

### Backend
- **Framework**: FastAPI (Python 3.12+)
- **Database**: PostgreSQL with SQLAlchemy ORM
- **Authentication**: JWT tokens (OAuth2 Password Flow)
- **File Storage**: Local filesystem (invoices/PDFs)
- **API Documentation**: Auto-generated Swagger UI at `/docs`

### Base URL
```
Production: https://api.b2bmeat.com/api/v1
Development: http://localhost:8001/api/v1
```

### Response Format
All endpoints return JSON with this structure:
```json
{
  "id": 123,
  "field": "value",
  "created_at": "2026-01-27T10:00:00",
  "updated_at": "2026-01-27T10:00:00"
}
```

---

## 3. Authentication & Authorization

### Login Flow

#### Endpoint: `POST /auth/login`
**Purpose**: Unified login for both Staff and Partners

**Request Body** (form-data):
```
username: admin@b2bmeat.com
password: password123
```

**Response**:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "full_name": "John Doe",
    "email": "admin@b2bmeat.com",
    "role": "admin",
    "identity_type": "staff",
    "permissions": ["create_order", "manage_users"]
  }
}
```

**Identity Types**:
- `staff`: Internal employees (admin, manager, sales)
- `partner`: B2B customers

### Registration

#### Endpoint: `POST /auth/register`
**Purpose**: Public registration for new B2B partners

**Request Body**:
```json
{
  "name": "Restaurant ABC",
  "email": "owner@restaurantabc.com",
  "password": "securepass123",
  "phone": "+1-555-0100",
  "business_name": "Restaurant ABC LLC",
  "tax_id": "TAX-12345",
  "address": "123 Main St, New York, NY",
  "business_description": "Fine dining restaurant"
}
```

**Response**: Customer object with `status: "submitted"` and `is_verified: false`

### Using the Token
Include the token in all subsequent requests:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## 4. Core API Endpoints

### 4.1 Products

#### List Products
```
GET /products/?skip=0&limit=100
```
**Response**: Array of products with pricing, stock, and units (lbs)

#### Get Product Details
```
GET /products/{product_id}
```
**Response**: Full product details including variants and volume tiers

#### Create Product (Staff Only)
```
POST /products/
```
**Request Body**:
```json
{
  "name": "Ribeye Steak Primal Cut",
  "sku": "BF-RBY-001",
  "price": 250.00,
  "wholesale_price": 215.00,
  "unit": "10lb Primal",
  "min_order_quantity": 2,
  "stock_quantity": 120,
  "volume_tiers": {
    "10": 200.00,
    "50": 185.00
  },
  "category_id": 2,
  "is_active": true
}
```

### 4.2 Orders

#### Create Order
```
POST /orders/
```
**Request Body**:
```json
{
  "customer_id": 2,
  "items": [
    {
      "product_id": 1,
      "quantity": 10
    },
    {
      "product_id": 2,
      "quantity": 5
    }
  ],
  "location_id": 3,
  "notes": "Deliver before 10 AM",
  "po_number": "PO-12345"
}
```

**Business Rules**:
- Partners: `customer_id` is auto-filled from their profile
- Staff: Must specify `customer_id`
- System validates:
  - Stock availability
  - Minimum order quantities
  - Credit limit (order total + current balance ≤ credit limit)
  - Location ownership

**Response**: Order object with calculated `total_amount`

#### List Orders
```
GET /orders/?skip=0&limit=100
```
**Filtering**:
- Partners: See only their own orders
- Staff: See all orders

#### Update Order Status
```
PUT /orders/{order_id}
```
**Request Body**:
```json
{
  "status": "confirmed"
}
```

**Status Flow**:
```
pending → confirmed → packed → out_for_delivery → delivered
```

### 4.3 Invoices

#### List Invoices
```
GET /invoices/?skip=0&limit=100
```

#### Create Manual Invoice
```
POST /invoices/
```
**Request Body**:
```json
{
  "customer_id": 2,
  "order_id": 15,
  "discount_percentage": 5.0,
  "due_date": "2026-03-01T00:00:00"
}
```

**Auto-Calculation**:
- `subtotal` = Sum of order items
- `discount_amount` = subtotal × (discount_percentage / 100)
- `amount_due` = subtotal - discount_amount + tax_total

#### Generate Combined Statement
```
POST /invoices/generate-daily-combined?customer_id=2&discount_percentage=10.0
```
**Purpose**: Aggregates all unpaid invoices into a single statement

**Response**: Combined invoice with PDF URL

#### Pay Invoice
```
POST /invoices/{invoice_id}/pay
```
**Effect**:
- Status changes to `paid`
- Customer's credit line is restored
- Payment record is created

### 4.4 Customers

#### List Customers (Staff Only)
```
GET /customers/?skip=0&limit=100
```

#### Get Customer Profile
```
GET /customers/me
```
**Purpose**: Partners can view their own profile

#### Verify Customer (Staff Only)
```
POST /customers/{customer_id}/verify
```
**Effect**: Changes `status` to `verified` and `is_verified` to `true`

#### Manage Locations
```
GET /locations/?customer_id=2
POST /locations/
PUT /locations/{location_id}
DELETE /locations/{location_id}
```

**Location Schema**:
```json
{
  "name": "Main Kitchen",
  "address": "123 Main St",
  "city": "New York",
  "state": "NY",
  "zip_code": "10001",
  "is_default": true,
  "customer_id": 2
}
```

### 4.5 Analytics (Staff Only)

#### Performance Metrics
```
GET /analytics/performance
```
**Response**:
```json
{
  "revenue": {"value": 125000, "growth": 15.5},
  "orders": {"value": 450, "growth": 8.2},
  "aov": {"value": 278.50, "growth": 6.7},
  "active_partners": 42
}
```

#### Sales Trends
```
GET /analytics/sales/trends?days=30
```

#### Top Products
```
GET /analytics/products/top?limit=10
```

#### Credit Risk Monitor
```
GET /analytics/risk?threshold_percent=0.8
```
**Purpose**: Lists customers using >80% of their credit limit

---

## 5. Data Models

### Product
```typescript
interface Product {
  id: number;
  name: string;
  sku: string;
  price: number;              // Retail price
  wholesale_price: number;    // B2B base price
  unit: string;               // "10lb Primal", "Case (10 units)"
  min_order_quantity: number;
  stock_quantity: number;
  volume_tiers: {             // Bulk discounts
    [quantity: string]: number;
  };
  category_id: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}
```

### Order
```typescript
interface Order {
  id: number;
  customer_id: number;
  location_id?: number;
  total_amount: number;
  status: "pending" | "confirmed" | "packed" | "out_for_delivery" | "delivered";
  payment_status: "pending" | "paid";
  payment_terms: string;      // "Net 30", "Due on Receipt"
  po_number?: string;
  notes?: string;
  items: OrderItem[];
  created_at: string;
  updated_at: string;
}

interface OrderItem {
  id: number;
  product_id: number;
  quantity: number;
  unit_price: number;         // Price at time of order
  total_price: number;
  product: Product;
}
```

### Invoice
```typescript
interface Invoice {
  id: number;
  customer_id: number;
  order_id: number;
  subtotal: number;
  tax_total: number;
  discount_percentage: number;
  discount_amount: number;
  amount_due: number;
  status: "draft" | "sent" | "paid" | "cancelled";
  due_date: string;
  pdf_url: string;
  created_at: string;
}
```

### Customer
```typescript
interface Customer {
  id: number;
  name: string;
  email: string;
  phone: string;
  business_name: string;
  tax_id: string;
  address: string;
  customer_type: "b2b";
  credit_limit: number;
  current_balance: number;    // Outstanding debt
  is_verified: boolean;
  status: "submitted" | "verified" | "suspended";
  billing_cycle: "weekly" | "10_days" | "monthly";
  payment_due_day: number;    // Day of month (1-31)
  created_at: string;
}
```

---

## 6. Implementation Examples

### React/TypeScript Example

#### Authentication Hook
```typescript
import { useState } from 'react';

interface AuthResponse {
  access_token: string;
  token_type: string;
  user: {
    full_name: string;
    email: string;
    role: string;
    identity_type: 'staff' | 'partner';
  };
}

export const useAuth = () => {
  const [token, setToken] = useState<string | null>(
    localStorage.getItem('access_token')
  );

  const login = async (email: string, password: string) => {
    const formData = new FormData();
    formData.append('username', email);
    formData.append('password', password);

    const response = await fetch('http://localhost:8001/api/v1/auth/login', {
      method: 'POST',
      body: formData,
    });

    if (!response.ok) {
      throw new Error('Login failed');
    }

    const data: AuthResponse = await response.json();
    localStorage.setItem('access_token', data.access_token);
    localStorage.setItem('user', JSON.stringify(data.user));
    setToken(data.access_token);
    return data;
  };

  const logout = () => {
    localStorage.removeItem('access_token');
    localStorage.removeItem('user');
    setToken(null);
  };

  return { token, login, logout, isAuthenticated: !!token };
};
```

#### API Client
```typescript
const API_BASE = 'http://localhost:8001/api/v1';

export const apiClient = {
  get: async <T>(endpoint: string): Promise<T> => {
    const token = localStorage.getItem('access_token');
    const response = await fetch(`${API_BASE}${endpoint}`, {
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    });
    
    if (!response.ok) {
      throw new Error(`API Error: ${response.statusText}`);
    }
    
    return response.json();
  },

  post: async <T>(endpoint: string, data: any): Promise<T> => {
    const token = localStorage.getItem('access_token');
    const response = await fetch(`${API_BASE}${endpoint}`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });
    
    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.detail || 'Request failed');
    }
    
    return response.json();
  },
};
```

#### Creating an Order
```typescript
import { apiClient } from './apiClient';

interface CreateOrderRequest {
  customer_id?: number;
  items: Array<{
    product_id: number;
    quantity: number;
  }>;
  location_id?: number;
  notes?: string;
}

export const createOrder = async (orderData: CreateOrderRequest) => {
  try {
    const order = await apiClient.post('/orders/', orderData);
    console.log('Order created:', order);
    return order;
  } catch (error) {
    console.error('Failed to create order:', error);
    throw error;
  }
};

// Usage
const handlePlaceOrder = async () => {
  await createOrder({
    items: [
      { product_id: 1, quantity: 10 },
      { product_id: 2, quantity: 5 },
    ],
    location_id: 3,
    notes: 'Urgent delivery',
  });
};
```

---

## 7. Error Handling

### HTTP Status Codes
| Code | Meaning | Common Causes |
|------|---------|---------------|
| 200 | Success | Request completed |
| 400 | Bad Request | Invalid input, validation failed |
| 401 | Unauthorized | Missing or invalid token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 500 | Server Error | Backend issue |

### Error Response Format
```json
{
  "detail": "Credit limit exceeded. Available credit: $500.00"
}
```

### Common Errors

#### Credit Limit Exceeded
```json
{
  "detail": "Order total ($1,500.00) exceeds available credit ($500.00)"
}
```
**Solution**: Display current balance and suggest payment

#### Insufficient Stock
```json
{
  "detail": "Insufficient stock for Ribeye Steak. Only 5 available."
}
```
**Solution**: Update cart with available quantity

#### Unverified Partner
```json
{
  "detail": "Your business account is not verified yet. Please contact support."
}
```
**Solution**: Show verification pending message

---

## 8. Best Practices

### Security
1. **Never store passwords**: Only store JWT tokens
2. **Token expiration**: Tokens expire after 60 minutes
3. **Refresh strategy**: Re-login when 401 is received
4. **HTTPS only**: Use HTTPS in production

### Performance
1. **Pagination**: Always use `skip` and `limit` parameters
2. **Caching**: Cache product catalog for 5 minutes
3. **Debouncing**: Debounce search inputs (300ms)
4. **Lazy loading**: Load images on scroll

### UX Recommendations
1. **Credit indicator**: Show remaining credit prominently
2. **Stock warnings**: Alert when adding low-stock items
3. **Order confirmation**: Show estimated delivery date
4. **Invoice downloads**: Provide PDF download links
5. **Real-time updates**: Poll order status every 30 seconds

### Testing
1. **Test accounts**:
   - Staff: `admin@b2bmeat.com` / `password123`
   - Partner: `chef@steakhouse.com` / `password123`
2. **Swagger UI**: Available at `http://localhost:8001/docs`
3. **Test data**: Run `python app/db/seed_b2b.py` to populate database

---

## Quick Start Checklist

- [ ] Set up authentication flow
- [ ] Implement product catalog with search
- [ ] Build shopping cart with credit validation
- [ ] Create order placement flow
- [ ] Add order history view
- [ ] Implement invoice management
- [ ] Add location management (for partners)
- [ ] Build analytics dashboard (for staff)
- [ ] Test all user roles
- [ ] Handle error states gracefully

---

## Support & Resources

- **API Documentation**: http://localhost:8001/docs
- **Database Schema**: See `docs/product_schema.md`
- **Invoice API**: See `docs/invoice_api.md`
- **Backend Repository**: Contact your team lead

For questions, contact the backend team or refer to the auto-generated Swagger documentation.
