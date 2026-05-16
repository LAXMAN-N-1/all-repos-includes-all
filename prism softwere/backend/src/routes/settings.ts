import { Router } from 'express';
import { authenticate, isAdmin } from '../middleware/auth';
import { SettingsController } from '../controllers/settingsController';
import { runValidation } from '../middleware/validation';
import { body, param } from 'express-validator';

const router = Router();

router.use(authenticate);
router.use(isAdmin); // Only admins can manage settings

// Get all settings
router.get('/', SettingsController.getSettings);

// Get specific setting
router.get('/:key', SettingsController.getSettings);

// Update setting
router.put(
    '/:key',
    runValidation([
        param('key').trim().notEmpty().withMessage('Setting key is required'),
        body('value').exists().withMessage('Setting value is required'),
        body('description').optional().isString(),
    ]),
    SettingsController.updateSetting
);

// Test email
router.post('/test-email', SettingsController.testEmail);

export default router;
