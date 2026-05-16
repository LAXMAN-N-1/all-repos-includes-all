import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { NotificationController } from '../controllers/notificationController';
import { paginationValidation, uuidParamValidation } from '../validators';
import { runValidation } from '../middleware/validation';

const router = Router();

router.use(authenticate);

// Get my notifications
router.get(
    '/',
    runValidation(paginationValidation),
    NotificationController.getMyNotifications
);

// Mark as read (specific ID or 'all')
router.put(
    '/read-all',
    NotificationController.markAllAsRead
);

router.put(
    '/:id/read',
    runValidation(uuidParamValidation),
    NotificationController.markAsRead
);

export default router;
