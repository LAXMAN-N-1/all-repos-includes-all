import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { DailyReportController } from '../controllers/dailyReportController';

const router = Router();

router.use(authenticate);

// Get project reports (admin/pm/sm view)
router.get('/:projectId', DailyReportController.getProjectReports);

// Get my report for today
router.get('/:projectId/my', DailyReportController.getMyReport);

// Submit morning standup
router.post('/:projectId/standup', DailyReportController.submitStandup);

// Add hourly tracking entry
router.post('/:projectId/entry', DailyReportController.addEntry);

// Report a blocker
router.post('/:projectId/blocker', DailyReportController.addBlocker);

// Submit evening summary
router.post('/:projectId/summary', DailyReportController.submitSummary);

// Add comment to a report
router.post('/:reportId/comment', DailyReportController.addComment);

// Comment actions
router.patch('/comments/:commentId/react', DailyReportController.reactToComment);
router.patch('/comments/:commentId/pin', DailyReportController.pinComment);
router.put('/comments/:commentId', DailyReportController.editComment);
router.delete('/comments/:commentId', DailyReportController.deleteComment);

// Send reminder
router.post('/:reportId/remind', DailyReportController.sendReminder);

// Resolve a blocker
router.patch('/entries/:entryId/resolve', DailyReportController.resolveBlocker);

export default router;

