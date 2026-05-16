import { Response } from 'express';
import { AuthRequest } from '../types/interfaces';
import { Issue, User, Project, Sprint, Comment, Attachment, WorkLog, AuditLog, Feature, Epic } from '../models';
import IssueLink, { LinkType } from '../models/IssueLink';
import { AppError, asyncHandler } from '../middleware/errorHandler';
import { AuditAction, UserRole, IssueType, IssueStatus } from '../types/enums';
import { getOffset, getPaginationMeta, generateIssueKey, extractMentions } from '../utils/helpers';
import { NotificationService } from '../services/notificationService';
import { EmailService } from '../services/emailService';
import { Op } from 'sequelize';
import { io } from '../server';
import {
    assertProjectAccess,
    getAccessibleEpic,
    getAccessibleFeature,
    getAccessibleIssue,
    getAccessibleProject,
    getAccessibleSprint,
} from '../utils/accessControl';

export class IssueController {
    // Get all issues (with filters)
    static getAllIssues = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 20;
        const projectId = req.query.projectId as string;
        const sprintId = req.query.sprintId as string;
        const assigneeId = req.query.assigneeId as string;
        const status = req.query.status as string;
        const priority = req.query.priority as string;
        const type = req.query.type as string;
        const requestedSortBy = (req.query.sortBy as string) || 'createdAt';
        const sortOrder = (req.query.sortOrder as string || 'DESC').toUpperCase();
        const search = req.query.search as string;
        const clientApprovalStatus = req.query.clientApprovalStatus as string;
        const user = req.user!;
        const sortBy = ['createdAt', 'updatedAt', 'priority', 'status', 'dueDate'].includes(requestedSortBy)
            ? requestedSortBy
            : 'createdAt';

        const where: any = {};
        const projectWhere: any = user.role === UserRole.CLIENT
            ? { clientId: user.id }
            : { orgId: user.orgId };

        if (projectId) where.projectId = projectId;
        if (sprintId) where.sprintId = sprintId;
        if (assigneeId) where.assigneeId = assigneeId;
        if (status) {
            const statuses = status.split(',').map((s: string) => s.trim());
            where.status = statuses.length === 1 ? statuses[0] : { [Op.in]: statuses };
        }
        if (priority) {
            const priorities = priority.split(',').map((p: string) => p.trim());
            where.priority = priorities.length === 1 ? priorities[0] : { [Op.in]: priorities };
        }
        if (type) {
            const types = type.split(',').map((t: string) => t.trim());
            where.type = types.length === 1 ? types[0] : { [Op.in]: types };
        }
        if (clientApprovalStatus) where.clientApprovalStatus = clientApprovalStatus;

        if (search) {
            where[Op.or] = [
                { title: { [Op.iLike]: `%${search}%` } },
                { key: { [Op.iLike]: `%${search}%` } }
            ];
        }

        if (user.role === UserRole.CLIENT) {
            where.isClientVisible = true;
        }

        const order: any[][] = [];
        if (sortBy === 'dueDate') {
            // For due date, we might want nulls last
            order.push([sortBy, sortOrder]);
        } else {
            order.push([sortBy, sortOrder]);
        }


        const { count, rows } = await Issue.findAndCountAll({
            where,
            limit,
            offset: getOffset(page, limit),
            order: order as any,
            include: [
                {
                    model: User,
                    as: 'assignee',
                    attributes: ['id', 'firstName', 'lastName', 'email'],
                },
                {
                    model: User,
                    as: 'reporter',
                    attributes: ['id', 'firstName', 'lastName', 'email'],
                },
                {
                    model: Project,
                    as: 'project',
                    where: projectWhere,
                    required: true,
                    attributes: ['id', 'name', 'key'],
                },
                {
                    model: Sprint,
                    as: 'sprint',
                    attributes: ['id', 'name', 'status'],
                },
                {
                    model: Epic,
                    as: 'epic',
                    attributes: ['id', 'name', 'key', 'status'],
                },
                {
                    model: Feature,
                    as: 'feature',
                    attributes: ['id', 'name', 'key'],
                },
            ],
        });

        res.json({
            success: true,
            data: {
                issues: rows,
                pagination: getPaginationMeta(page, limit, count),
            },
        });
    });

    // Get issue by ID
    static getIssueById = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;

        const issue = await getAccessibleIssue(req, id, {
            requireClientVisible: true,
            include: [
                {
                    model: User,
                    as: 'assignee',
                    attributes: ['id', 'firstName', 'lastName', 'email'],
                },
                {
                    model: User,
                    as: 'reporter',
                    attributes: ['id', 'firstName', 'lastName', 'email'],
                },
                {
                    model: Project,
                    as: 'project',
                    attributes: ['id', 'name', 'key', 'orgId', 'clientId'],
                },
                {
                    model: Sprint,
                    as: 'sprint',
                    attributes: ['id', 'name', 'status', 'startDate', 'endDate'],
                },
                {
                    model: Issue,
                    as: 'subtasks',
                    attributes: ['id', 'key', 'title', 'status', 'assigneeId'],
                },
                {
                    model: Comment,
                    as: 'comments',
                    required: false,
                    where: req.user && req.user.role === UserRole.CLIENT ? { isClientVisible: true } : undefined,
                    include: [
                        {
                            model: User,
                            as: 'user',
                            attributes: ['id', 'firstName', 'lastName', 'email', 'role'],
                        },
                    ],
                },
                {
                    model: Attachment,
                    as: 'attachments',
                },
                {
                    model: IssueLink,
                    as: 'links',
                    include: [
                        {
                            model: Issue,
                            as: 'relatedIssue',
                            attributes: ['id', 'key', 'title', 'status'],
                        }
                    ]
                },
                {
                    model: WorkLog,
                    as: 'workLogs',
                    include: [
                        {
                            model: User,
                            as: 'user',
                            attributes: ['id', 'firstName', 'lastName'],
                        },
                    ],
                },
                {
                    model: Epic,
                    as: 'epic',
                    attributes: ['id', 'name', 'key', 'status'],
                },
                {
                    model: Feature,
                    as: 'feature',
                    attributes: ['id', 'name', 'key'],
                },
            ],
        });

        res.json({
            success: true,
            data: { issue },
        });
    });

    // Create issue
    static createIssue = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const {
            projectId,
            title,
            description,
            type,
            priority,
            assigneeId,
            sprintId,
            parentId,
            storyPoints,
            estimatedHours,
            dueDate,
            labels,
            customFields,
            isClientVisible,
            epicId,
            featureId,
            fixVersion,
        } = req.body;

        const project = await getAccessibleProject(req, projectId);
        if (type === IssueType.EPIC) {
            throw new AppError('Issue type EPIC is no longer supported on /issues. Use /api/v1/epics instead.', 400);
        }

        let finalEpicId: string | null = epicId || null;
        let finalFeatureId: string | null = featureId || null;
        let finalSprintId: string | null = sprintId || null;
        let finalParentId: string | null = parentId || null;

        if (type !== IssueType.SUBTASK && finalParentId) {
            throw new AppError('Only SUBTASK issues can set parentId', 400);
        }

        if (finalSprintId) {
            const sprint = await getAccessibleSprint(req, finalSprintId);
            if (sprint.projectId !== project.id) {
                throw new AppError('Sprint must belong to the same project', 400);
            }
        }

        if (finalEpicId) {
            const epic = await getAccessibleEpic(req, finalEpicId);
            if (epic.projectId !== project.id) {
                throw new AppError('Epic must belong to the same project', 400);
            }
        }

        if (finalFeatureId) {
            const feature = await getAccessibleFeature(req, finalFeatureId);
            if (feature.projectId !== project.id) {
                throw new AppError('Feature must belong to the same project', 400);
            }
            if (finalEpicId && feature.epicId && feature.epicId !== finalEpicId) {
                throw new AppError('Feature must belong to the provided epic', 400);
            }
            if (!finalEpicId && feature.epicId) {
                finalEpicId = feature.epicId;
            }
        }

        if (type === IssueType.STORY && !finalEpicId && !finalFeatureId) {
            throw new AppError('Stories must be linked to an epic or feature', 400);
        }

        if (type === IssueType.SUBTASK) {
            if (!finalParentId) {
                throw new AppError('Sub-tasks must have a parent issue', 400);
            }
            const parent = await getAccessibleIssue(req, finalParentId, { requireClientVisible: true });
            if (parent.projectId !== project.id) {
                throw new AppError('Parent issue must belong to the same project', 400);
            }
            if (parent.type === IssueType.SUBTASK) {
                throw new AppError('Sub-task parent cannot be another sub-task', 400);
            }
            if (parent.type === IssueType.EPIC) {
                throw new AppError('Sub-task parent cannot be an epic', 400);
            }

            finalSprintId = parent.sprintId || null;
            finalEpicId = parent.epicId || finalEpicId;
            finalFeatureId = parent.featureId || finalFeatureId;
        }

        // Get next issue number for project
        const lastIssue = await Issue.findOne({
            where: { projectId },
            order: [['issueNumber', 'DESC']],
        });
        const issueNumber = (lastIssue?.issueNumber || 0) + 1;
        const key = generateIssueKey(project.key, issueNumber);

        // Create issue
        const issue = await Issue.create({
            projectId,
            issueNumber,
            key,
            type,
            status: 'TODO' as any,
            priority: priority || 'MEDIUM',
            title,
            description,
            assigneeId,
            reporterId: req.user!.id,
            sprintId: finalSprintId,
            parentId: finalParentId || undefined,
            storyPoints,
            estimatedHours,
            actualHours: 0,
            dueDate,
            orderIndex: 0, // Default to 0, or logic to put at end
            labels: labels || [],
            customFields: customFields || {},
            isClientVisible: req.user?.role === UserRole.CLIENT ? true : (isClientVisible || false),
            epicId: finalEpicId || null,
            featureId: finalFeatureId || null,
            fixVersion: fixVersion || null,
        });

        // Update Sprint Progress
        if (finalSprintId) {
            await IssueController.recalculateSprintProgress(finalSprintId);
        }

        // Notify assignee
        if (assigneeId && assigneeId !== req.user!.id) {
            const assignee = await User.findByPk(assigneeId);
            if (assignee) {
                await NotificationService.notifyIssueAssignment(
                    assigneeId,
                    issue.key,
                    issue.title,
                    req.user!.id
                );

                try {
                    await EmailService.sendIssueAssignmentEmail(
                        assignee.email,
                        assignee.fullName,
                        issue.key,
                        issue.title,
                        req.user!.email || 'Team Member'
                    );
                } catch (error) {
                    // Email failure shouldn't stop issue creation
                }
            }
        }

        // Emit real-time event
        io.to(`project:${projectId}`).emit('issue:created', issue);

        // Audit log
        await AuditLog.create({
            userId: req.user!.id,
            action: AuditAction.CREATE,
            resource: 'issue',
            resourceId: issue.id,
            details: { key: issue.key, title: issue.title },
            ipAddress: req.ip,
            userAgent: req.get('user-agent'),
        });

        res.status(201).json({
            success: true,
            message: 'Issue created successfully',
            data: { issue },
        });
    });

    // Update issue
    static updateIssue = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;
        const {
            title,
            description,
            type,
            status,
            priority,
            assigneeId,
            sprintId,
            storyPoints,
            estimatedHours,
            dueDate,
            labels,
            customFields,
            isClientVisible,
            clientApprovalStatus,
            epicId,
            featureId,
            fixVersion,
        } = req.body;

        if (req.user?.role === UserRole.CLIENT) {
            throw new AppError('Clients cannot update issues directly', 403);
        }
        const issue = await getAccessibleIssue(req, id);
        if (type === IssueType.EPIC) {
            throw new AppError('Issue type EPIC is no longer supported on /issues. Use /api/v1/epics instead.', 400);
        }
        if (type && type !== issue.type && (type === IssueType.SUBTASK || issue.type === IssueType.SUBTASK)) {
            throw new AppError('Changing sub-task type is not supported', 400);
        }
        if (issue.type === IssueType.SUBTASK && (sprintId !== undefined || epicId !== undefined || featureId !== undefined)) {
            throw new AppError('Sub-task sprint and hierarchy are inherited from the parent issue', 400);
        }

        const oldAssigneeId = issue.assigneeId;
        const oldStatus = issue.status;

        // Update fields
        if (title) issue.title = title;
        if (description !== undefined) issue.description = description;
        if (type) issue.type = type;
        if (status) issue.status = status;
        if (priority) issue.priority = priority;
        if (assigneeId !== undefined) issue.assigneeId = assigneeId;
        if (sprintId !== undefined) issue.sprintId = sprintId;
        if (storyPoints !== undefined) issue.storyPoints = storyPoints;
        if (estimatedHours !== undefined) issue.estimatedHours = estimatedHours;
        if (dueDate !== undefined) issue.dueDate = dueDate;
        if (labels) issue.labels = labels;
        if (customFields) issue.customFields = { ...issue.customFields, ...customFields };
        if (isClientVisible !== undefined) issue.isClientVisible = isClientVisible;
        if (epicId !== undefined) issue.epicId = epicId;
        if (featureId !== undefined) issue.featureId = featureId;
        if (fixVersion !== undefined) issue.fixVersion = fixVersion;

        if (sprintId !== undefined && sprintId !== null) {
            const sprint = await getAccessibleSprint(req, sprintId);
            if (sprint.projectId !== issue.projectId) {
                throw new AppError('Sprint must belong to the same project', 400);
            }
        }

        if (epicId !== undefined && epicId !== null) {
            const epic = await getAccessibleEpic(req, epicId);
            if (epic.projectId !== issue.projectId) {
                throw new AppError('Epic must belong to the same project', 400);
            }
        }

        if (featureId !== undefined && featureId !== null) {
            const feature = await getAccessibleFeature(req, featureId);
            if (feature.projectId !== issue.projectId) {
                throw new AppError('Feature must belong to the same project', 400);
            }
            if (epicId !== undefined && epicId !== null && feature.epicId && feature.epicId !== epicId) {
                throw new AppError('Feature must belong to the provided epic', 400);
            }
        }

        // Client Approval Logic
        if (clientApprovalStatus) {
            // Only allow Clients to set 'APPROVED' | 'CHANGES_REQUESTED' | 'REJECTED'
            // Only allow Admin/Team to set 'PENDING'
            // For simplicity in MVP: Allow update if role authorized
            issue.clientApprovalStatus = clientApprovalStatus;
        }

        await issue.save();

        // Recalculate sprint progress if status or story points changed
        if ((status && status !== oldStatus) || storyPoints !== undefined) {
            if (issue.sprintId) {
                await IssueController.recalculateSprintProgress(issue.sprintId);
            }
        }

        // Notify on assignee change
        if (assigneeId && assigneeId !== oldAssigneeId) {
            await NotificationService.notifyIssueAssignment(
                assigneeId,
                issue.key,
                issue.title,
                req.user!.id
            );
        }

        // Notify on status change
        if (status && status !== oldStatus && issue.assigneeId) {
            await NotificationService.notifyIssueUpdate(
                issue.assigneeId,
                issue.key,
                `Status changed to ${status}`
            );
        }

        // Emit real-time event
        io.to(`project:${issue.projectId}`).emit('issue:updated', issue);

        // Audit log
        await AuditLog.create({
            userId: req.user!.id,
            action: AuditAction.UPDATE,
            resource: 'issue',
            resourceId: issue.id,
            details: { key: issue.key, changes: req.body },
            ipAddress: req.ip,
            userAgent: req.get('user-agent'),
        });

        res.json({
            success: true,
            message: 'Issue updated successfully',
            data: { issue },
        });
    });

    // Delete issue
    static deleteIssue = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;

        if (req.user?.role === UserRole.CLIENT) {
            throw new AppError('Clients cannot delete issues', 403);
        }
        const issue = await getAccessibleIssue(req, id);

        // Audit log
        await AuditLog.create({
            userId: req.user!.id,
            action: AuditAction.DELETE,
            resource: 'issue',
            resourceId: issue.id,
            details: { key: issue.key, title: issue.title },
            ipAddress: req.ip,
            userAgent: req.get('user-agent'),
        });

        const projectId = issue.projectId;
        await issue.destroy();

        // Emit real-time event
        io.to(`project:${projectId}`).emit('issue:deleted', { id });

        res.json({
            success: true,
            message: 'Issue deleted successfully',
        });
    });

    // Get comments for an issue
    static getComments = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { issueId } = req.params;

        await getAccessibleIssue(req, issueId, { requireClientVisible: true });

        // Build query - clients can only see client-visible comments
        const where: any = { issueId };
        if (req.user?.role === UserRole.CLIENT) {
            where.isClientVisible = true;
        }

        const comments = await Comment.findAll({
            where,
            include: [
                {
                    model: User,
                    as: 'user',
                    attributes: ['id', 'firstName', 'lastName', 'email', 'role']
                },
                {
                    model: Attachment,
                    as: 'attachments',
                    attributes: ['id', 'filename', 'originalName', 'mimetype', 'size', 'fileUrl', 'createdAt'],
                },
            ],
            order: [['createdAt', 'ASC']]
        });

        res.json({
            success: true,
            data: { comments }
        });
    });

    // Add comment to issue (with optional file attachments)
    static addComment = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { issueId } = req.params;
        const { content, isClientVisible, mentionIds } = req.body;

        const issue = await getAccessibleIssue(req, issueId, { requireClientVisible: true });

        // Resolve mentions — frontend sends an array of user IDs directly
        let mentionedUserIds: string[] = [];
        if (mentionIds) {
            try {
                mentionedUserIds = typeof mentionIds === 'string' ? JSON.parse(mentionIds) : mentionIds;
            } catch {
                mentionedUserIds = [];
            }
        }

        // Fallback: also extract @mentions from content text
        const textMentions = extractMentions(content);
        if (textMentions.length > 0 && mentionedUserIds.length === 0) {
            const users = await User.findAll({
                where: {
                    [Op.or]: [
                        { email: { [Op.in]: textMentions } },
                        { username: { [Op.in]: textMentions } },
                    ],
                },
            });
            mentionedUserIds.push(...users.map(u => u.id));
        }

        // Determine comment visibility
        let commentVisibility = true;
        if (req.user?.role !== UserRole.CLIENT) {
            commentVisibility = isClientVisible !== undefined
                ? (typeof isClientVisible === 'string' ? isClientVisible === 'true' : isClientVisible)
                : true;
        }

        // Create comment
        const comment = await Comment.create({
            issueId: issueId!,
            userId: req.user!.id,
            content,
            mentions: mentionedUserIds,
            isClientVisible: commentVisibility,
        });

        // Handle file attachments (multer puts files on req.files)
        const files = req.files as Express.Multer.File[] | undefined;
        const attachments: any[] = [];
        if (files && files.length > 0) {
            for (const file of files) {
                const attachment = await Attachment.create({
                    commentId: comment.id,
                    issueId: issueId!,
                    projectId: null,
                    userId: req.user!.id,
                    filename: file.filename,
                    originalName: file.originalname,
                    mimetype: file.mimetype,
                    size: file.size,
                    path: file.path,
                    fileUrl: `/uploads/${file.filename}`,
                });
                attachments.push(attachment);
            }
        }

        // Notify mentioned users
        for (const userId of mentionedUserIds) {
            await NotificationService.notifyMention(userId, issue.key, req.user!.id);
        }

        // Emit real-time event
        io.to(`project:${issue.projectId}`).emit('comment:created', {
            ...comment.toJSON(),
            attachments,
        });

        res.status(201).json({
            success: true,
            message: 'Comment added successfully',
            data: {
                comment: {
                    ...comment.toJSON(),
                    attachments,
                },
            },
        });
    });

    // Add work log
    static addWorkLog = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { issueId } = req.params;
        const { timeSpent, date, description } = req.body;

        if (req.user?.role === UserRole.CLIENT) {
            throw new AppError('Clients cannot add work logs', 403);
        }
        const issue = await getAccessibleIssue(req, issueId);

        const workLog = await WorkLog.create({
            issueId: issueId!,
            userId: req.user!.id,
            timeSpent,
            date,
            description,
        });

        // Update actual hours on issue
        // Update actual hours on issue
        issue.actualHours = (Number(issue.actualHours) || 0) + Number(timeSpent);
        await issue.save();

        res.status(201).json({
            success: true,
            message: 'Work log added successfully',
            data: { workLog },
        });
    });
    // Get backlog issues (issues not assigned to any sprint)
    static getBacklog = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { projectId } = req.params;
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 50; // Higher limit for backlog
        const user = req.user!;

        await getAccessibleProject(req, projectId);

        const where: any = {
            projectId,
            sprintId: null // Explicitly look for null sprintId
        };

        // Optional filters for backlog
        if (req.query.type) where.type = req.query.type;
        if (req.query.priority) where.priority = req.query.priority;
        if (req.query.search) {
            where[Op.or] = [
                { title: { [Op.iLike]: `%${req.query.search}%` } },
                { key: { [Op.iLike]: `%${req.query.search}%` } }
            ];
        }
        if (user.role === UserRole.CLIENT) {
            where.isClientVisible = true;
        }

        const { count, rows } = await Issue.findAndCountAll({
            where,
            limit,
            offset: getOffset(page, limit),
            order: [['issueNumber', 'DESC']], // Newest first by default, simplified ranking
            include: [
                {
                    model: User,
                    as: 'assignee',
                    attributes: ['id', 'firstName', 'lastName', 'email'],
                },
                {
                    model: Sprint,
                    as: 'sprint',
                    attributes: ['id', 'name'],
                },
            ],
        });

        res.json({
            success: true,
            data: {
                issues: rows,
                pagination: getPaginationMeta(page, limit, count),
            },
        });
    });

    // Assign multiple issues to a sprint (or move to backlog if sprintId is null)
    static assignSprint = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { sprintId, issueIds } = req.body; // sprintId can be null to move to backlog

        if (!Array.isArray(issueIds) || issueIds.length === 0) {
            throw new AppError('issueIds array is required', 400);
        }

        const issues = await Issue.findAll({
            where: { id: { [Op.in]: issueIds } },
            include: [
                {
                    model: Project,
                    as: 'project',
                    attributes: ['id', 'orgId', 'clientId'],
                },
            ],
        });
        if (issues.length !== issueIds.length) {
            throw new AppError('One or more issues not found', 404);
        }

        const projectIds = Array.from(new Set(issues.map(issue => issue.projectId)));
        if (projectIds.length !== 1) {
            throw new AppError('All issues must belong to the same project', 400);
        }

        const issueProject = issues[0]?.get('project') as Project | undefined;
        if (!issueProject) {
            throw new AppError('Project not found', 404);
        }
        assertProjectAccess(req, issueProject);

        if (req.user?.role === UserRole.CLIENT) {
            throw new AppError('Clients cannot reassign sprint issues', 403);
        }
        if (issues.some((issue) => issue.type === IssueType.EPIC)) {
            throw new AppError('Epic issues are not supported on /issues. Use /epics for epic lifecycle.', 400);
        }
        if (issues.some((issue) => issue.type === IssueType.SUBTASK)) {
            throw new AppError('Sub-tasks inherit sprint from their parent issue', 400);
        }

        // Verify sprint exists if not null and scoped to same project
        if (sprintId) {
            const sprint = await getAccessibleSprint(req, sprintId);
            if (sprint.projectId !== issueProject.id) {
                throw new AppError('Sprint must belong to the same project as issues', 400);
            }
        }

        // Update issues
        await Issue.update(
            { sprintId },
            {
                where: {
                    id: { [Op.in]: issueIds }
                }
            }
        );

        res.json({
            success: true,
            message: `Updated ${issueIds.length} issues`,
        });
    });

    // Update issue status (Drag-and-Drop)
    static updateStatus = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;
        const { status } = req.body;

        if (req.user?.role === UserRole.CLIENT) {
            throw new AppError('Clients cannot change issue status directly', 403);
        }
        const issue = await getAccessibleIssue(req, id);

        const oldStatus = issue.status;
        issue.status = status;
        await issue.save();

        if (oldStatus !== status && issue.assigneeId) {
            await NotificationService.notifyIssueUpdate(
                issue.assigneeId,
                issue.key,
                `Status changed to ${status}`
            );
        }

        // Audit log (simplified)
        await AuditLog.create({
            userId: req.user!.id,
            action: AuditAction.STATUS_CHANGE,
            resource: 'issue',
            resourceId: issue.id,
            details: { from: oldStatus, to: status },
            ipAddress: req.ip,
            userAgent: req.get('user-agent'),
        });

        res.json({
            success: true,
            data: { issue }
        });
    });
    // Get issues assigned to the current user
    static getMyIssues = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 20;
        const status = req.query.status as string; // Optional filter
        const role = req.query.role as string || 'assignee'; // 'assignee' or 'reporter'
        const priority = req.query.priority as string;
        const type = req.query.type as string;
        const projectId = req.query.projectId as string;
        const search = req.query.search as string;
        const user = req.user!;
        const projectWhere: any = user.role === UserRole.CLIENT
            ? { clientId: user.id }
            : { orgId: user.orgId };

        const where: any = {};

        if (role === 'reporter') {
            where.reporterId = req.user!.id;
        } else {
            where.assigneeId = req.user!.id;
        }

        if (status) {
            where.status = status;
        }
        // If no status provided, we usually show active issues, BUT for "All" tab in frontend we might pass nothing.
        // Let's assume if status is undefined, we return everything (or frontend passes specific statuses).
        // The previous logic was: where.status = { [Op.notIn]: ['DONE', 'CANCELLED'] };
        // I will change it to: if explicitly "ALL" or undefined, return all?
        // Actually adhering to Jira, "My Requests" usually defaults to Open.
        // Let's keep the filter optional but if not provided, don't filter by status (return all).

        if (priority) where.priority = priority;
        if (type) where.type = type;
        if (projectId) where.projectId = projectId;

        if (search) {
            where[Op.or] = [
                { title: { [Op.iLike]: `%${search}%` } },
                { key: { [Op.iLike]: `%${search}%` } }
            ];
        }

        const { count, rows } = await Issue.findAndCountAll({
            where,
            limit,
            offset: getOffset(page, limit),
            order: [
                ['updatedAt', 'DESC'], // Recently updated first
            ],
            include: [
                {
                    model: Project,
                    as: 'project',
                    where: projectWhere,
                    required: true,
                    attributes: ['id', 'name', 'key'],
                },
                {
                    model: Sprint,
                    as: 'sprint',
                    attributes: ['id', 'name', 'endDate'],
                },
            ],
        });

        res.json({
            success: true,
            data: {
                issues: rows,
                pagination: getPaginationMeta(page, limit, count),
            },
        });
    });

    // Client approval endpoint (for clients to approve/reject tasks)
    static clientApproval = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;
        const { status, feedback } = req.body;

        // Only clients can use this endpoint
        if (req.user?.role !== UserRole.CLIENT) {
            throw new AppError('Only clients can approve tasks', 403);
        }

        const issue = await getAccessibleIssue(req, id, { requireClientVisible: true });
        const project = issue.get('project') as Project;

        // Update approval status
        issue.clientApprovalStatus = status;
        if (feedback) {
            issue.clientFeedback = feedback;
        }
        await issue.save();

        // Notify project lead or assignee
        const notifyUserId = issue.assigneeId || project.leadId;
        if (notifyUserId) {
            await NotificationService.notifyIssueUpdate(
                notifyUserId,
                issue.key,
                `Client ${status === 'APPROVED' ? 'approved' : status === 'CHANGES_REQUESTED' ? 'requested changes for' : 'rejected'} this task`
            );
        }

        // Emit real-time event
        io.to(`project:${issue.projectId}`).emit('issue:client-approval', {
            issueId: issue.id,
            status,
            feedback,
        });

        // Audit log
        await AuditLog.create({
            userId: req.user!.id,
            action: AuditAction.UPDATE,
            resource: 'issue',
            resourceId: issue.id,
            details: { action: 'client_approval', status, feedback },
            ipAddress: req.ip,
            userAgent: req.get('user-agent'),
        });

        res.json({
            success: true,
            message: 'Approval status updated successfully',
            data: { issue },
        });
    });

    // --- JIRA-LIKE HIERARCHY METHODS ---

    // Get Hierarchy (Epics -> Features -> Issues -> Subtasks)
    static getHierarchy = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { projectId } = req.params;
        await getAccessibleProject(req, projectId);
        const isClient = req.user?.role === UserRole.CLIENT;
        const issueVisibilityWhere = isClient ? { isClientVisible: true } : undefined;

        const epics = await Epic.findAll({
            where: { projectId, ...(isClient ? { isVisibleToClient: true } : {}) },
            include: [
                {
                    model: Feature,
                    as: 'features',
                    required: false,
                    include: [
                        {
                            model: Issue,
                            as: 'issues',
                            required: false,
                            where: issueVisibilityWhere,
                            include: [
                                {
                                    model: Issue,
                                    as: 'subtasks',
                                    required: false,
                                    where: issueVisibilityWhere,
                                },
                            ],
                        },
                    ],
                },
                {
                    model: Issue,
                    as: 'issues',
                    required: false,
                    where: { ...(issueVisibilityWhere || {}), featureId: null },
                    include: [
                        {
                            model: Issue,
                            as: 'subtasks',
                            required: false,
                            where: issueVisibilityWhere,
                        },
                    ],
                },
            ],
            order: [['createdAt', 'ASC']],
        });

        const unassignedFeatures = await Feature.findAll({
            where: { projectId, epicId: null },
            include: [
                {
                    model: Issue,
                    as: 'issues',
                    required: false,
                    where: issueVisibilityWhere,
                    include: [
                        {
                            model: Issue,
                            as: 'subtasks',
                            required: false,
                            where: issueVisibilityWhere,
                        },
                    ],
                },
            ],
            order: [['createdAt', 'ASC']],
        });

        const unassignedIssues = await Issue.findAll({
            where: {
                projectId,
                parentId: { [Op.is]: null },
                epicId: { [Op.is]: null },
                featureId: { [Op.is]: null },
                ...(issueVisibilityWhere || {}),
            } as any,
            include: [
                {
                    model: Issue,
                    as: 'subtasks',
                    required: false,
                    where: issueVisibilityWhere,
                },
            ],
            order: [['orderIndex', 'ASC'], ['createdAt', 'ASC']],
        });

        res.json({
            success: true,
            data: {
                epics,
                unassignedFeatures,
                unassignedIssues,
                unassigned: unassignedIssues,
            },
        });
    });

    // Get direct issue children (subtasks)
    static getChildren = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;
        const parent = await getAccessibleIssue(req, id, { requireClientVisible: true });
        const isClient = req.user?.role === UserRole.CLIENT;

        if (parent.type === IssueType.SUBTASK) {
            res.json({ success: true, data: { children: [] } });
            return;
        }

        const children = await Issue.findAll({
            where: {
                parentId: parent.id,
                ...(isClient ? { isClientVisible: true } : {}),
            },
            order: [['createdAt', 'ASC']],
        });

        res.json({ success: true, data: { children } });
    });

    // Create Story specifically
    static createStory = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { title, description, epicId, featureId, assigneeId, storyPoints, priority, projectId } = req.body;

        if (req.user?.role === UserRole.CLIENT) {
            throw new AppError('Clients cannot create stories', 403);
        }
        if (!epicId) {
            throw new AppError('Epic ID is required for a Story', 400);
        }

        const project = await getAccessibleProject(req, projectId);
        const epic = await getAccessibleEpic(req, epicId);
        if (epic.projectId !== project.id) {
            throw new AppError('Epic must belong to the same project', 400);
        }

        let resolvedFeatureId: string | null = null;
        if (featureId) {
            const feature = await getAccessibleFeature(req, featureId);
            if (feature.projectId !== project.id) {
                throw new AppError('Feature must belong to the same project', 400);
            }
            if (feature.epicId && feature.epicId !== epic.id) {
                throw new AppError('Feature must belong to the provided epic', 400);
            }
            resolvedFeatureId = feature.id;
        }

        const lastIssue = await Issue.findOne({ where: { projectId }, order: [['issueNumber', 'DESC']] });
        const issueNumber = (lastIssue?.issueNumber || 0) + 1;
        const key = generateIssueKey(project.key, issueNumber);

        const story = await Issue.create({
            projectId,
            issueNumber,
            key,
            title,
            description,
            type: IssueType.STORY,
            epicId: epic.id,
            featureId: resolvedFeatureId,
            assigneeId,
            storyPoints,
            priority: priority || 'MEDIUM',
            reporterId: req.user!.id,
            status: IssueStatus.TODO as any,
            orderIndex: 0,
            labels: [],
            customFields: {},
            isClientVisible: false,
        });

        res.status(201).json({ success: true, data: { issue: story } });
    });

    // Create Subtask specifically
    static createSubtask = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { title, description, parentId, assigneeId, priority } = req.body;

        if (req.user?.role === UserRole.CLIENT) {
            throw new AppError('Clients cannot create sub-tasks', 403);
        }
        if (!parentId) {
            throw new AppError('Parent issue ID is required', 400);
        }

        const parent = await getAccessibleIssue(req, parentId);
        if ([IssueType.SUBTASK, IssueType.EPIC].includes(parent.type)) {
            throw new AppError('Sub-task parent must be a non-epic work item', 400);
        }

        const lastIssue = await Issue.findOne({ where: { projectId: parent.projectId }, order: [['issueNumber', 'DESC']] });
        const issueNumber = (lastIssue?.issueNumber || 0) + 1;
        const project = await getAccessibleProject(req, parent.projectId);
        const key = generateIssueKey(project.key, issueNumber);

        const subtask = await Issue.create({
            projectId: parent.projectId,
            issueNumber,
            key,
            title,
            description,
            type: IssueType.SUBTASK,
            parentId,
            epicId: parent.epicId || null,
            featureId: parent.featureId || null,
            sprintId: parent.sprintId || null,
            assigneeId: assigneeId || parent.assigneeId,
            priority: priority || parent.priority,
            reporterId: req.user!.id,
            status: IssueStatus.TODO as any,
            orderIndex: 0,
            labels: [],
            customFields: {},
            isClientVisible: false,
        });

        res.status(201).json({ success: true, data: { issue: subtask } });
    });

    // Move issue to sprint
    static moveIssueToSprint = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;
        const { sprintId } = req.body;

        if (req.user?.role === UserRole.CLIENT) {
            throw new AppError('Clients cannot move issues between sprints', 403);
        }
        const issue = await getAccessibleIssue(req, id, { include: ['subtasks', { model: Project, as: 'project' }] });

        if (issue.type === IssueType.EPIC) {
            throw new AppError('Epic issues are not supported on /issues. Use /epics for epic lifecycle.', 400);
        }
        if (issue.type === IssueType.SUBTASK) {
            throw new AppError('Sub-tasks inherit sprint from the parent issue', 400);
        }

        if (sprintId) {
            const sprint = await getAccessibleSprint(req, sprintId);
            if (sprint.projectId !== issue.projectId) {
                throw new AppError('Sprint must belong to the same project', 400);
            }
        }

        issue.sprintId = sprintId || null;
        await issue.save();

        if ((issue as any).subtasks && (issue as any).subtasks.length > 0) {
            await Issue.update({ sprintId: sprintId || null }, { where: { parentId: id } });
        }

        res.json({ success: true, message: 'Issue and subtasks moved' });
    });

    // Helper: Recalculate sprint progress with weighted completion
    private static async recalculateSprintProgress(sprintId: string | null): Promise<void> {
        if (!sprintId) return;

        const sprint = await Sprint.findByPk(sprintId);
        if (!sprint) return;

        // Get all issues in this sprint
        const issues = await Issue.findAll({
            where: { sprintId },
            attributes: ['id', 'status', 'storyPoints']
        });

        if (issues.length === 0) {
            sprint.completedPoints = 0;
            await sprint.save();
            return;
        }

        // Calculate weighted completion
        // TODO = 0%, IN_PROGRESS = 50%, IN_REVIEW = 75%, DONE = 100%
        const statusWeights: Record<string, number> = {
            'TODO': 0,
            'IN_PROGRESS': 0.5,
            'IN_REVIEW': 0.75,
            'DONE': 1.0,
            'BLOCKED': 0,
            'CANCELLED': 0
        };

        let weightedPoints = 0;
        let totalPoints = 0;

        issues.forEach(issue => {
            const points = issue.storyPoints || 0;
            const weight = statusWeights[issue.status] || 0;

            weightedPoints += points * weight;
            totalPoints += points;
        });

        // Update sprint with calculated values
        sprint.totalPoints = totalPoints;
        sprint.completedPoints = Math.round(weightedPoints * 10) / 10; // Round to 1 decimal
        await sprint.save();
    }

    // --- ISSUE LINKING ---

    // Add Link
    static addLink = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;
        const { targetIssueId, type } = req.body;

        const sourceIssue = await getAccessibleIssue(req, id);
        const targetIssue = await getAccessibleIssue(req, targetIssueId);

        if (!sourceIssue || !targetIssue) throw new AppError('Issue not found', 404);
        if (id === targetIssueId) throw new AppError('Cannot link issue to itself', 400);
        if (sourceIssue.projectId !== targetIssue.projectId) {
            throw new AppError('Issues must belong to the same project', 400);
        }

        // Check if link exists
        const existingLink = await IssueLink.findOne({
            where: {
                sourceIssueId: id,
                targetIssueId,
                type: type as LinkType
            }
        });

        if (existingLink) throw new AppError('Link already exists', 400);

        const link = await IssueLink.create({
            sourceIssueId: id || '',
            targetIssueId,
            type: type as LinkType
        });

        // Reciprocal link logic placeholder removed for now to fix build errors
        // TODO: Implement reciprocal linking (e.g. A blocks B -> B is blocked by A)

        // Audit Log
        await AuditLog.create({
            userId: req.user!.id,
            action: AuditAction.UPDATE,
            resource: 'issue',
            resourceId: id,
            details: { action: 'add_link', targetIssueId, type },
            ipAddress: req.ip,
            userAgent: req.get('user-agent'),
        });

        res.status(201).json({ success: true, data: { link } });
    });

    // Remove Link
    static removeLink = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id, linkId } = req.params;
        await getAccessibleIssue(req, id);

        const link = await IssueLink.findOne({ where: { id: linkId, sourceIssueId: id } });
        if (!link) throw new AppError('Link not found', 404);

        await link.destroy();

        res.json({ success: true, message: 'Link removed' });
    });
    // Get Issue History (Audit Logs)
    static getHistory = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;
        await getAccessibleIssue(req, id, { requireClientVisible: true });

        const logs = await AuditLog.findAll({
            where: {
                resource: 'issue',
                resourceId: id,
            },
            include: [
                {
                    model: User,
                    as: 'user',
                    attributes: ['id', 'firstName', 'lastName', 'email', 'role'], // Avatar?
                },
            ],
            order: [['createdAt', 'DESC']],
        });

        res.json({
            success: true,
            data: {
                history: logs,
            },
        });
    });
}
