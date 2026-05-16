import { Router } from 'express';
import { FeatureController } from '../controllers/FeatureController';
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
        body('name').trim().notEmpty().withMessage('Feature name is required'),
    ]),
    FeatureController.createFeature
);

router.get('/', FeatureController.getFeatures);

router.get(
    '/:id',
    runValidation(uuidParamValidation),
    FeatureController.getFeatureById
);

router.put(
    '/:id',
    isAdminOrScrumMaster,
    runValidation([
        ...uuidParamValidation,
        body('name').optional().trim().notEmpty(),
    ]),
    FeatureController.updateFeature
);

router.delete(
    '/:id',
    isAdminOrScrumMaster,
    runValidation(uuidParamValidation),
    FeatureController.deleteFeature
);

export default router;
