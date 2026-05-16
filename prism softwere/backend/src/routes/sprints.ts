import { Router } from 'express';
import { SprintController } from '../controllers/sprintController';
import { authenticate, isScrumMaster } from '../middleware/auth';
import { check, param } from 'express-validator';
import { validate } from '../middleware/validation';

const router = Router();

// Validation middleware
const sprintValidation = [
    check('projectId').isUUID().withMessage('Valid Project ID is required'),
    check('name').notEmpty().withMessage('Sprint name is required'),
    check('startDate').isISO8601().withMessage('Valid start date is required'),
    check('endDate').isISO8601().withMessage('Valid end date is required'),
    validate
];

const sprintIdParamValidation = [
    param('id').isUUID().withMessage('Invalid sprint ID format'),
    validate,
];

const projectIdParamValidation = [
    param('projectId').isUUID().withMessage('Invalid project ID format'),
    validate,
];

// Routes
router.use(authenticate);

// Create Sprint
router.post(
    '/',
    isScrumMaster, // Only Scrum Masters (or Admins) can manage sprints
    sprintValidation,
    SprintController.createSprint
);

// Get All Sprints
router.get(
    '/',
    SprintController.getAllSprints
);

// Get Sprint Statistics
router.get(
    '/:id/statistics',
    sprintIdParamValidation,
    SprintController.getSprintStatistics
);

// Get Project Sprints
router.get(
    '/project/:projectId',
    projectIdParamValidation,
    SprintController.getProjectSprints
);

// Start Sprint
router.post(
    '/:id/start',
    isScrumMaster,
    sprintIdParamValidation,
    SprintController.startSprint
);

// Complete Sprint
router.post(
    '/:id/complete',
    isScrumMaster,
    sprintIdParamValidation,
    SprintController.completeSprint
);

// Update Sprint
router.put(
    '/:id',
    isScrumMaster,
    sprintIdParamValidation,
    SprintController.updateSprint
);

// Delete Sprint
router.delete(
    '/:id',
    isScrumMaster,
    sprintIdParamValidation,
    SprintController.deleteSprint
);

export default router;
