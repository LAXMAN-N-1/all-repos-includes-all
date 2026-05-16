import { Response } from 'express';
import { AuthRequest } from '../types/interfaces';
import { Sprint, Issue, Project, SprintMember, User } from '../models';
import { AppError, asyncHandler } from '../middleware/errorHandler';
import { SprintStatus, IssueStatus, UserRole } from '../types/enums';
import { Op } from 'sequelize';
import sequelize from '../config/database';
import { assertProjectAccess, getAccessibleProject, getAccessibleSprint } from '../utils/accessControl';

export class SprintController {
    // Create a new sprint
    static createSprint = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const {
            projectId,
            name,
            startDate,
            endDate,
            goal,
            key,
            notes,
            plannedPoints,
            burnDownConfig,
            teamMembers,        // Array of user IDs
            status              // Optional initial status
        } = req.body;

        await getAccessibleProject(req, projectId);

        // Auto-generate key if not provided
        let sprintKey = key;
        if (!sprintKey) {
            const projectData = await Project.findByPk(projectId);
            if (projectData) {
                // Let's stick to "SPRINT-X" pattern as requested, or "PROJ-Sprint-X". User example: "Sprint ID: SPRINT-404"

                // Find latest sprint for this project to get the number
                const lastSprint = await Sprint.findOne({
                    where: { projectId },
                    order: [['createdAt', 'DESC']],
                    attributes: ['key']
                });

                let nextNum = 1;
                if (lastSprint && lastSprint.key) {
                    const match = lastSprint.key.match(/SPRINT-(\d+)/);
                    if (match && match[1]) {
                        nextNum = parseInt(match[1]) + 1;
                    }
                }
                sprintKey = `SPRINT-${nextNum}`;
            }
        }

        const newSprint = await Sprint.create({
            projectId,
            name,
            startDate,
            endDate,
            goal,
            key: sprintKey,
            notes,
            plannedPoints,
            burnDownConfig,
            status: status || SprintStatus.PLANNED
        });

        // Add Team Members
        if (teamMembers && Array.isArray(teamMembers) && teamMembers.length > 0) {
            const memberData = teamMembers.map((userId: string) => ({
                sprintId: newSprint.id,
                userId,
                capacityHours: 0
            }));
            await SprintMember.bulkCreate(memberData);
        }

        // Fetch complete sprint with members
        const sprint = await Sprint.findByPk(newSprint.id, {
            include: ['members']
        });

        res.status(201).json({
            success: true,
            data: { sprint }
        });
    });

    // Get all sprints (filtered by org via project)
    static getAllSprints = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const user = req.user!;
        const { limit } = req.query;
        const projectWhere: any = user.role === UserRole.CLIENT
            ? { clientId: user.id }
            : { orgId: user.orgId };

        const sprints = await Sprint.findAll({
            include: [{
                model: Project,
                as: 'project',
                where: projectWhere,
                attributes: ['id', 'name', 'key']
            }, {
                model: Issue,
                as: 'issues',
                where: user.role === UserRole.CLIENT ? { isClientVisible: true } : undefined,
                required: false,
                attributes: ['id', 'status', 'storyPoints']
            }, {
                model: SprintMember,
                as: 'sprintMembers',
                include: [{
                    model: User,
                    as: 'user',
                    attributes: ['id', 'firstName', 'lastName', 'email']
                }]
            }],
            limit: limit ? parseInt(limit as string) : undefined,
            order: [['startDate', 'DESC']]
        });

        res.json({
            success: true,
            data: { sprints }
        });
    });

    // Get all sprints for a project
    static getProjectSprints = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { projectId } = req.params;
        const { status } = req.query;
        const user = req.user!;

        await getAccessibleProject(req, projectId);

        const where: any = { projectId };
        if (status) {
            where.status = status;
        }

        const sprints = await Sprint.findAll({
            where,
            include: [{
                model: Issue,
                as: 'issues',
                where: user.role === UserRole.CLIENT ? { isClientVisible: true } : undefined,
                required: false,
                attributes: ['id', 'key', 'title', 'status', 'storyPoints', 'assigneeId', 'priority', 'type']
            }, {
                model: SprintMember,
                as: 'sprintMembers',
                include: [{
                    model: User,
                    as: 'user',
                    attributes: ['id', 'firstName', 'lastName', 'email']
                }]
            }],
            order: [['startDate', 'ASC']]
        });

        res.json({
            success: true,
            data: { sprints }
        });
    });

    // Start a sprint
    static startSprint = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;

        const sprint = await getAccessibleSprint(req, id);

        if (sprint.status !== SprintStatus.PLANNED) {
            throw new AppError('Only planned sprints can be started', 400);
        }

        // Check if there are any other active sprints for this project
        const activeSprint = await Sprint.findOne({
            where: {
                projectId: sprint.projectId,
                status: SprintStatus.ACTIVE,
                id: { [Op.ne]: id }
            }
        });

        if (activeSprint) {
            throw new AppError('Project already has an active sprint', 400);
        }

        sprint.status = SprintStatus.ACTIVE;
        await sprint.save();

        res.json({
            success: true,
            data: { sprint }
        });
    });

    // Complete a sprint
    static completeSprint = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;
        const { moveIssuesToSprintId } = req.body; // Optional: ID of next sprint to move incomplete issues to

        const scopedSprint = await getAccessibleSprint(req, id);
        const completedSprint = await sequelize.transaction(async (transaction) => {
            const sprint = await Sprint.findByPk(scopedSprint.id, {
                transaction,
                lock: transaction.LOCK.UPDATE,
            });

            if (!sprint) {
                throw new AppError('Sprint not found', 404);
            }

            if (sprint.status !== SprintStatus.ACTIVE) {
                throw new AppError('Only active sprints can be completed', 400);
            }

            const incompleteIssueIds = (await Issue.findAll({
                where: {
                    sprintId: sprint.id,
                    status: { [Op.ne]: IssueStatus.DONE },
                },
                attributes: ['id'],
                transaction,
            })).map((issue) => issue.id);

            if (moveIssuesToSprintId) {
                if (moveIssuesToSprintId === sprint.id) {
                    throw new AppError('Target sprint must be different from the sprint being completed', 400);
                }

                const nextSprint = await Sprint.findByPk(moveIssuesToSprintId, {
                    transaction,
                    lock: transaction.LOCK.UPDATE,
                });

                if (!nextSprint) {
                    throw new AppError('Sprint not found', 404);
                }

                const nextProject = await Project.findByPk(nextSprint.projectId, {
                    attributes: ['id', 'orgId', 'clientId'],
                    transaction,
                });
                if (!nextProject) {
                    throw new AppError('Project not found', 404);
                }

                assertProjectAccess(req, nextProject);

                if (nextSprint.projectId !== sprint.projectId) {
                    throw new AppError('Target sprint must be in the same project', 400);
                }
            }

            if (incompleteIssueIds.length > 0) {
                await Issue.update(
                    { sprintId: moveIssuesToSprintId || null },
                    {
                        where: {
                            id: { [Op.in]: incompleteIssueIds },
                        },
                        transaction,
                    }
                );
            }

            sprint.status = SprintStatus.COMPLETED;
            await sprint.save({ transaction });
            return sprint;
        });

        res.json({
            success: true,
            data: { sprint: completedSprint }
        });
    });


    // Get Sprint Statistics (Burn-down)
    static getSprintStatistics = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;
        const user = req.user!;

        const sprint = await getAccessibleSprint(req, id);
        await sprint.reload({
            include: [{
                model: Issue,
                as: 'issues',
                where: user.role === UserRole.CLIENT ? { isClientVisible: true } : undefined,
                required: false,
            }],
        });

        const issues = sprint.issues || [];
        const totalPoints = issues.reduce((sum, issue) => sum + (issue.storyPoints || 0), 0);
        const completedPoints = issues
            .filter(i => i.status === IssueStatus.DONE)
            .reduce((sum, issue) => sum + (issue.storyPoints || 0), 0);

        // Burn-down Data Generation
        const burnDownNodes: { date: string; ideal: number; actual: number }[] = [];

        if (sprint.startDate && sprint.endDate) {
            const start = new Date(sprint.startDate);
            const end = new Date(sprint.endDate);
            const now = new Date();
            const todayStr = now.toISOString().split('T')[0]!;

            // Normalize dates to midnight
            start.setHours(0, 0, 0, 0);
            end.setHours(0, 0, 0, 0);

            const totalDays = Math.ceil((end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24));
            const pointsPerDay = totalDays > 0 ? totalPoints / totalDays : 0;

            let currentDate = new Date(start);
            let dayIndex = 0;

            // Generate points for each day of the sprint
            while (currentDate <= end) {
                const dateStr = currentDate.toISOString().split('T')[0]!;

                // Ideal line: specific depletion per day
                const ideal = Math.max(0, totalPoints - (pointsPerDay * dayIndex));

                // Actual line
                // Sum of points of issues that were DONE on or before this date
                // We use updatedAt as proxy for completedAt.
                // NOTE: This assumes issues don't get updated after being marked DONE.
                let completedOnDate = 0;

                // Only calculate actual if date is in past or today
                if (dateStr <= todayStr!) {
                    completedOnDate = issues
                        .filter(i => {
                            if (i.status !== IssueStatus.DONE) return false;
                            const updated = new Date(i.updatedAt!);
                            const updatedStr = updated.toISOString().split('T')[0]!;
                            return updatedStr <= dateStr;
                        })
                        .reduce((sum, i) => sum + (i.storyPoints || 0), 0);
                }

                burnDownNodes.push({
                    date: dateStr,
                    ideal: Math.round(ideal * 10) / 10,
                    actual: dateStr <= todayStr! ? totalPoints - completedOnDate : (null as any) // null for future actuals
                });

                // Next day
                currentDate.setDate(currentDate.getDate() + 1);
                dayIndex++;
            }
        }

        res.json({
            success: true,
            data: {
                totalPoints,
                completedPoints,
                burnDown: burnDownNodes
            }
        });
    });

    // Update Sprint
    public static updateSprint = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;
        const { name, startDate, endDate, goal, status, notes, capacity, plannedPoints } = req.body;

        const sprint = await getAccessibleSprint(req, id);

        await sprint.update({
            name,
            startDate,
            endDate,
            goal,
            status,
            notes,
            capacity,
            plannedPoints
        });

        res.json({
            success: true,
            data: { sprint }
        });
    });

    // Delete Sprint
    public static deleteSprint = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;

        const scopedSprint = await getAccessibleSprint(req, id);
        await sequelize.transaction(async (transaction) => {
            const sprint = await Sprint.findByPk(scopedSprint.id, {
                transaction,
                lock: transaction.LOCK.UPDATE,
            });

            if (!sprint) {
                throw new AppError('Sprint not found', 404);
            }

            if (![SprintStatus.PLANNED, SprintStatus.CANCELLED].includes(sprint.status)) {
                throw new AppError('Only planned or cancelled sprints can be deleted', 400);
            }

            await Issue.update(
                { sprintId: null },
                {
                    where: { sprintId: id },
                    transaction,
                }
            );

            await SprintMember.destroy({
                where: { sprintId: id },
                transaction,
            });

            await sprint.destroy({ transaction });
        });

        res.json({
            success: true,
            message: 'Sprint deleted successfully'
        });
    });
}
