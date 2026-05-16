# HRMS Frontend

Modern Human Resource Management System with dynamic layout and role-based screen assignment.

## Features

- 🎨 Dynamic Layout System
- 🔐 Role-Based Access Control (RBAC)
- 📱 Responsive Design
- 🎯 Screen Assignment per Employee
- 💼 Leave Management
- ⏰ Attendance Tracking
- 💰 Payroll Management
- 📊 Reports & Analytics

## Tech Stack

- **Framework:** Next.js 14 (App Router)
- **Language:** TypeScript
- **Styling:** TailwindCSS
- **State Management:** Zustand
- **Forms:** React Hook Form + Zod
- **Icons:** Lucide React
- **HTTP Client:** Axios

## Getting Started

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Set up environment variables:**
   ```bash
   cp .env.local.example .env.local
   ```
   Update `NEXT_PUBLIC_API_URL` with your backend URL.

3. **Run development server:**
   ```bash
   npm run dev
   ```

4. **Open browser:**
   ```
   http://localhost:3001
   ```

## Project Structure

```
hrms-frontend/
├── app/                    # Next.js app directory
│   ├── (auth)/            # Auth pages
│   ├── (dashboard)/       # Dashboard pages
│   └── layout.tsx
├── components/
│   ├── common/            # Reusable components
│   ├── layout/            # Layout components
│   ├── screens/           # Screen components
│   └── admin/             # Admin components
├── lib/
│   ├── api.ts             # API client
│   └── hooks/             # Custom hooks
├── store/                 # Zustand stores
├── types/                 # TypeScript types
└── public/                # Static assets
```

## User Roles

- **Admin:** Full system access, user management, screen assignment
- **Manager:** Team management, approvals, reports
- **HR:** Employee management, payroll, leave management
- **Employee:** Self-service features

## Demo Credentials

- Admin: `admin@company.com` / `admin123`
- Manager: `manager@company.com` / `manager123`
- Employee: `emp@company.com` / `emp123`

## API Integration

Update the API base URL in `.env.local`:

```env
NEXT_PUBLIC_API_URL=http://localhost:8000/api
```

Required backend endpoints:
- `/auth/login` - User authentication
- `/auth/me` - Get current user
- `/users/:id/screens` - Get/assign user screens
- `/screens` - List all available screens

## Building for Production

```bash
npm run build
npm start
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Submit a pull request

## License

MIT
