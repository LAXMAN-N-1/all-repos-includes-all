// ============================================
// USER & AUTH TYPES
// ============================================
export enum UserRole {
  ADMIN = "admin",
  MANAGER = "manager",
  EMPLOYEE = "employee",
  HR = "hr"
}

export interface User {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  avatar?: string;
  department?: string;
  designation?: string;
}

export interface AuthResponse {
  access_token: string;
  token_type: string;
  user: User;
}

// ============================================
// SCREEN CONFIGURATION TYPES
// ============================================
export interface Screen {
  id: string;
  name: string;
  path: string;
  icon: string;
  component: string;
  description?: string;
  category?: string;
  permissions?: string[];
  order?: number;
}

export interface UserScreenAssignment {
  userId: string;
  screenIds: string[];
  customOrder?: number[];
}

// ============================================
// NAVIGATION TYPES
// ============================================
export interface NavItem {
  id: string;
  label: string;
  path: string;
  icon: string;
  badge?: number;
  children?: NavItem[];
}

// ============================================
// LEAVE MANAGEMENT TYPES
// ============================================
export enum LeaveType {
  CASUAL = "casual",
  SICK = "sick",
  VACATION = "vacation",
  UNPAID = "unpaid"
}

export enum LeaveStatus {
  PENDING = "pending",
  APPROVED = "approved",
  REJECTED = "rejected",
  CANCELLED = "cancelled"
}

export interface LeaveRequest {
  id: string;
  userId: string;
  type: LeaveType;
  startDate: string;
  endDate: string;
  days: number;
  reason: string;
  status: LeaveStatus;
  approvedBy?: string;
  createdAt: string;
}

export interface LeaveBalance {
  userId: string;
  casual: number;
  sick: number;
  vacation: number;
  year: number;
}

// ============================================
// ATTENDANCE TYPES
// ============================================
export interface Attendance {
  id: string;
  userId: string;
  date: string;
  checkIn: string;
  checkOut?: string;
  status: "present" | "absent" | "half-day" | "leave";
  workHours?: number;
  location?: string;
}

export interface AttendanceSummary {
  userId: string;
  month: number;
  year: number;
  totalDays: number;
  presentDays: number;
  absentDays: number;
  leaveDays: number;
  halfDays: number;
}

// ============================================
// PAYROLL TYPES
// ============================================
export interface Payslip {
  id: string;
  userId: string;
  month: number;
  year: number;
  basicSalary: number;
  allowances: number;
  deductions: number;
  netSalary: number;
  paymentDate: string;
  status: "pending" | "processed" | "paid";
}

// ============================================
// DASHBOARD TYPES
// ============================================
export interface DashboardStats {
  totalEmployees: number;
  presentToday: number;
  onLeave: number;
  pendingApprovals: number;
}
