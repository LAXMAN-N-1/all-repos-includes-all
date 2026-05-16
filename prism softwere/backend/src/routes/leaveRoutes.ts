import { Router } from 'express';
import { LeaveController } from '../controllers/leaveController';
import { authenticate } from '../middleware/auth';
import { requireRole } from '../middleware/rbac';
import { UserRole } from '../types/enums';
import { runValidation } from '../middleware/validation';
import { body } from 'express-validator';
import { uuidParamValidation } from '../validators';

const router = Router();

// Apply auth middleware to all routes
router.use(authenticate);

// Employee routes
router.post('/apply', LeaveController.applyLeave);
router.get('/my-leaves', LeaveController.getMyLeaves);
router.get('/my-balances', LeaveController.getMyBalances);

// Admin routes
router.get(
    '/',
    requireRole(UserRole.ADMIN),
    LeaveController.getAllLeaveRequests
);

router.patch(
    '/:id/status',
    requireRole(UserRole.ADMIN),
    runValidation([
        ...uuidParamValidation,
        body('status').isIn(['Approved', 'Rejected']).withMessage('Invalid leave status'),
        body('rejectionReason').optional().isString(),
    ]),
    LeaveController.updateLeaveStatus
);

export default router;
