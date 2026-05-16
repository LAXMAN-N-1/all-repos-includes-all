import { Router } from 'express';
import { IssueController } from '../controllers/issueController';
import { authenticate } from '../middleware/auth';
import { createIssueValidation, updateIssueValidation, createCommentValidation, createWorkLogValidation, uuidParamValidation, paginationValidation, issueIdParamValidation, projectIdParamValidation } from '../validators';
import { runValidation } from '../middleware/validation';
import upload from '../middleware/upload';
import { AttachmentController } from '../controllers/attachmentController';
import { body, param } from 'express-validator';
import { requireRole } from '../middleware/rbac';
import { UserRole } from '../types/enums';

const router = Router();

// All routes require authentication
router.use(authenticate);

// Get issues assigned to current user
router.get(
    '/my-issues',
    runValidation(paginationValidation),
    IssueController.getMyIssues
);

// Get hierarchy
router.get(
    '/hierarchy/:projectId',
    runValidation([...projectIdParamValidation, ...paginationValidation]),
    IssueController.getHierarchy
);

// Get issue children
router.get(
    '/:id/children',
    runValidation(uuidParamValidation),
    IssueController.getChildren
);

// Create Story
router.post(
    '/create-story',
    requireRole(UserRole.ADMIN, UserRole.PROJECT_MANAGER, UserRole.SCRUM_MASTER, UserRole.EMPLOYEE),
    runValidation([
        body('projectId').isUUID().withMessage('Valid project ID is required'),
        body('epicId').isUUID().withMessage('Valid epic ID is required'),
        body('featureId').optional().isUUID().withMessage('Valid feature ID is required'),
        body('title').trim().notEmpty().withMessage('Title is required'),
        body('assigneeId').optional().isUUID(),
        body('storyPoints').optional().isInt({ min: 0 }),
    ]),
    IssueController.createStory
);

// Create Subtask
router.post(
    '/create-subtask',
    requireRole(UserRole.ADMIN, UserRole.PROJECT_MANAGER, UserRole.SCRUM_MASTER, UserRole.EMPLOYEE),
    runValidation([
        body('parentId').isUUID().withMessage('Valid parent issue ID is required'),
        body('title').trim().notEmpty().withMessage('Title is required'),
        body('assigneeId').optional().isUUID(),
    ]),
    IssueController.createSubtask
);

// Move issue to sprint
router.put(
    '/:id/move-to-sprint',
    runValidation([
        ...uuidParamValidation,
        body('sprintId').isUUID().withMessage('Valid sprint ID is required'),
    ]),
    IssueController.moveIssueToSprint
);

// Get all issues (with filters)
router.get(
    '/',
    runValidation(paginationValidation),
    IssueController.getAllIssues
);

// Get backlog issues for a project
router.get(
    '/project/:projectId/backlog',
    runValidation([...projectIdParamValidation, ...paginationValidation]),
    IssueController.getBacklog
);

// Get issue by ID
router.get(
    '/:id',
    runValidation(uuidParamValidation),
    IssueController.getIssueById
);

// Create issue
router.post(
    '/',
    runValidation(createIssueValidation),
    IssueController.createIssue
);



// Assign issues to sprint
router.post(
    '/assign-sprint',
    runValidation([
        body('issueIds').isArray({ min: 1 }).withMessage('Issue IDs are required'),
        body('issueIds.*').isUUID().withMessage('Issue ID must be a UUID'),
        body('sprintId').optional({ nullable: true }).isUUID().withMessage('Valid sprint ID is required'),
    ]),
    IssueController.assignSprint
);

// Update issue status
router.put(
    '/:id/status',
    runValidation([
        ...uuidParamValidation,
        body('status')
            .isIn(['TODO', 'IN_PROGRESS', 'IN_REVIEW', 'DONE', 'BLOCKED', 'CANCELLED'])
            .withMessage('Invalid issue status'),
    ]),
    IssueController.updateStatus
);

// Client approval endpoint (for clients to approve/reject tasks)
router.patch(
    '/:id/client-approval',
    runValidation([
        ...uuidParamValidation,
        body('status').isIn(['APPROVED', 'CHANGES_REQUESTED', 'REJECTED']).withMessage('Invalid approval status'),
        body('feedback').optional().isString(),
    ]),
    IssueController.clientApproval
);

// Update issue
router.put(
    '/:id',
    runValidation([...uuidParamValidation, ...updateIssueValidation]),
    IssueController.updateIssue
);

// Delete issue
router.delete(
    '/:id',
    runValidation(uuidParamValidation),
    IssueController.deleteIssue
);

// Get comments for issue
router.get(
    '/:issueId/comments',
    runValidation(issueIdParamValidation),
    IssueController.getComments
);

// Add comment to issue (with optional file attachments)
router.post(
    '/:issueId/comments',
    upload.array('files', 5),
    runValidation(createCommentValidation),
    IssueController.addComment
);

// Add work log to issue
router.post(
    '/:issueId/worklog',
    runValidation(createWorkLogValidation),
    IssueController.addWorkLog
);

// Issue Linking
router.post(
    '/:id/links',
    runValidation([
        ...uuidParamValidation,
        body('targetIssueId').isUUID().withMessage('Valid target issue ID is required'),
    ]),
    IssueController.addLink
);

router.delete(
    '/:id/links/:linkId',
    runValidation([
        ...uuidParamValidation,
        param('linkId').isUUID().withMessage('Invalid link ID format'),
    ]),
    IssueController.removeLink
);

// Issue History
router.get(
    '/:id/history',
    runValidation(uuidParamValidation),
    IssueController.getHistory
);

// Upload attachment (Using multer middleware)
router.post(
    '/:issueId/attachments',
    runValidation(issueIdParamValidation),
    upload.single('file'),
    AttachmentController.uploadAttachment
);

router.delete(
    '/attachments/:id',
    runValidation(uuidParamValidation),
    AttachmentController.deleteAttachment
);

export default router;
