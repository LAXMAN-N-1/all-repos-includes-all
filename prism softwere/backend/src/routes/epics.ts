import { Router } from 'express';
import { EpicController } from '../controllers/EpicController';
import { authenticate, isAdminOrScrumMaster } from '../middleware/auth';
import { runValidation } from '../middleware/validation';
import { body } from 'express-validator';
import { uuidParamValidation } from '../validators';

const router = Router();

router.use(authenticate);

router.post(
    '/',
    isAdminOrScrumMaster,
    runValidation([
        body('projectId').isUUID().withMessage('Valid project ID is required'),
        body('name').trim().notEmpty().withMessage('Epic name is required'),
    ]),
    EpicController.createEpic
);

router.get('/', EpicController.getEpics);

router.get(
    '/:id',
    runValidation(uuidParamValidation),
    EpicController.getEpicById
);

router.put(
    '/:id',
    isAdminOrScrumMaster,
    runValidation([
        ...uuidParamValidation,
        body('name').optional().trim().notEmpty(),
    ]),
    EpicController.updateEpic
);

router.delete(
    '/:id',
    isAdminOrScrumMaster,
    runValidation(uuidParamValidation),
    EpicController.deleteEpic
);

// Close epic
router.post(
    '/:id/close',
    runValidation(uuidParamValidation),
    EpicController.closeEpic
);

export default router;
