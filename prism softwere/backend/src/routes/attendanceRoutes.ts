import { Router } from 'express';
import { AttendanceController } from '../controllers/attendanceController';
import { authenticate } from '../middleware/auth';
import { requireRole } from '../middleware/rbac';
import { UserRole } from '../types/enums';
import { runValidation } from '../middleware/validation';
import { body, param } from 'express-validator';
import { uuidParamValidation } from '../validators';

const router = Router();

// Apply auth middleware to all routes
router.use(authenticate);

// Employee routes
router.post('/check-in', AttendanceController.checkIn);
router.post('/check-out', AttendanceController.checkOut);
router.get('/my-attendance', AttendanceController.getMyAttendance);

// Admin routes
router.get(
    '/employee/:userId',
    requireRole(UserRole.ADMIN),
    runValidation([
        param('userId').isUUID().withMessage('Invalid user ID format'),
    ]),
    AttendanceController.getEmployeeAttendance
);

router.patch(
    '/:id/status',
    requireRole(UserRole.ADMIN),
    runValidation([
        ...uuidParamValidation,
        body('status').isIn(['Approved', 'Rejected']).withMessage('Invalid approval status'),
        body('rejectionReason').optional().isString(),
    ]),
    AttendanceController.updateStatus
);

router.get(
    '/',
    requireRole(UserRole.ADMIN),
    AttendanceController.getAllAttendance
);

export default router;
