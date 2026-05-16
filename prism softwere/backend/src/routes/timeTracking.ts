import express from 'express';
import TimeTrackingController from '../controllers/timeTrackingController';
import { authenticate } from '../middleware/auth';
import { runValidation } from '../middleware/validation';
import { body, param } from 'express-validator';
import { uuidParamValidation } from '../validators';

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// Time entry CRUD
router.post(
    '/time-entries',
    runValidation([
        body('issueId').isUUID().withMessage('Valid issue ID is required'),
        body('timeSpent').isFloat({ min: 0 }).withMessage('Valid time spent is required'),
        body('date').optional().isISO8601(),
        body('description').optional().isString(),
    ]),
    TimeTrackingController.createTimeEntry
);
router.get('/time-entries', TimeTrackingController.getTimeEntries);
router.get(
    '/time-entries/:id',
    runValidation(uuidParamValidation),
    TimeTrackingController.getTimeEntry
);
router.put(
    '/time-entries/:id',
    runValidation([
        ...uuidParamValidation,
        body('timeSpent').optional().isFloat({ min: 0 }),
        body('date').optional().isISO8601(),
        body('description').optional().isString(),
    ]),
    TimeTrackingController.updateTimeEntry
);
router.delete(
    '/time-entries/:id',
    runValidation(uuidParamValidation),
    TimeTrackingController.deleteTimeEntry
);

// Time summaries
router.get(
    '/time-entries/summary/:period',
    runValidation([
        param('period').isIn(['daily', 'weekly', 'monthly']).withMessage('Invalid period'),
    ]),
    TimeTrackingController.getTimeSummary
);

export default router;
