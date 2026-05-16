import { useAuthStore } from '@/store/authStore';
import { UserRole } from '@/types';

export function useRole() {
  const { user } = useAuthStore();

  const isAdmin = user?.role === UserRole.ADMIN;
  const isManager = user?.role === UserRole.MANAGER;
  const isHR = user?.role === UserRole.HR;
  const isEmployee = user?.role === UserRole.EMPLOYEE;

  const canManageUsers = isAdmin || isHR;
  const canApproveLeave = isAdmin || isManager || isHR;
  const canViewReports = isAdmin || isManager || isHR;
  const canManagePayroll = isAdmin || isHR;

  return {
    user,
    isAdmin,
    isManager,
    isHR,
    isEmployee,
    canManageUsers,
    canApproveLeave,
    canViewReports,
    canManagePayroll,
  };
}
