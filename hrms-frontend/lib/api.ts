import axios from 'axios';

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor - Add auth token
api.interceptors.request.use(
  (config) => {
    if (typeof window !== 'undefined') {
      const token = localStorage.getItem('token');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor - Handle errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      if (typeof window !== 'undefined') {
        localStorage.removeItem('token');
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
);

// ============================================
// AUTH APIS
// ============================================
export const authAPI = {
  login: (email: string, password: string) => 
    api.post('/auth/login', { email, password }),
  register: (data: any) => 
    api.post('/auth/register', data),
  logout: () => 
    api.post('/auth/logout'),
  getCurrentUser: () => 
    api.get('/auth/me'),
};

// ============================================
// SCREEN MANAGEMENT APIS
// ============================================
export const screenAPI = {
  getAllScreens: () => 
    api.get('/screens'),
  getUserScreens: (userId: string) => 
    api.get(`/users/${userId}/screens`),
  assignScreens: (userId: string, screenIds: string[]) => 
    api.post(`/users/${userId}/screens`, { screen_ids: screenIds }),
  updateScreenOrder: (userId: string, order: string[]) => 
    api.put(`/users/${userId}/screens/order`, { order }),
};

// ============================================
// USER MANAGEMENT APIS
// ============================================
export const userAPI = {
  getAllUsers: () => 
    api.get('/users'),
  getUser: (userId: string) => 
    api.get(`/users/${userId}`),
  updateUser: (userId: string, data: any) => 
    api.put(`/users/${userId}`, data),
  deleteUser: (userId: string) => 
    api.delete(`/users/${userId}`),
};

// ============================================
// LEAVE MANAGEMENT APIS
// ============================================
export const leaveAPI = {
  getMyLeaves: () => 
    api.get('/leave/my'),
  applyLeave: (data: any) => 
    api.post('/leave', data),
  getLeaveBalance: () => 
    api.get('/leave/balance'),
  approveLeave: (leaveId: string) => 
    api.put(`/leave/${leaveId}/approve`),
  rejectLeave: (leaveId: string, reason: string) => 
    api.put(`/leave/${leaveId}/reject`, { reason }),
};

// ============================================
// ATTENDANCE APIS
// ============================================
export const attendanceAPI = {
  checkIn: () => 
    api.post('/attendance/check-in'),
  checkOut: () => 
    api.post('/attendance/check-out'),
  getMyAttendance: (month: number, year: number) => 
    api.get(`/attendance/my?month=${month}&year=${year}`),
  getAttendanceSummary: () => 
    api.get('/attendance/summary'),
};

// ============================================
// PAYROLL APIS
// ============================================
export const payrollAPI = {
  getMyPayslips: () => 
    api.get('/payroll/my'),
  downloadPayslip: (payslipId: string) => 
    api.get(`/payroll/${payslipId}/download`, { responseType: 'blob' }),
};

// ============================================
// DASHBOARD APIS
// ============================================
export const dashboardAPI = {
  getStats: () => 
    api.get('/dashboard/stats'),
  getRecentActivity: () => 
    api.get('/dashboard/activity'),
};

export default api;
