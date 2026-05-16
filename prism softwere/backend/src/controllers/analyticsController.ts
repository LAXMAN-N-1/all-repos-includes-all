import { Response } from 'express';
import { AuthRequest } from '../types/interfaces';
import { Issue, Sprint, Project, User, WorkLog, AuditLog, Attachment } from '../models';
import { AppError, asyncHandler } from '../middleware/errorHandler';
import { Op } from 'sequelize';
import sequelize from '../config/database';
import * as os from 'os';
import { getAccessibleProject, getAccessibleSprint } from '../utils/accessControl';
import { UserRole } from '../types/enums';


export class AnalyticsController {
    // Get dashboard overview
    static getDashboard = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { orgId } = req.user!;
        const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);

        // Get counts
        const [projectCount, issueCount, activeSprintCount, userCount, activeUsers24h] = await Promise.all([
            Project.count({ where: { orgId } }),
            Issue.count({
                include: [{
                    model: Project,
                    as: 'project',
                    where: { orgId },
                    attributes: [],
                }],
            }),
            Sprint.count({
                where: { status: 'ACTIVE' },
                include: [{
                    model: Project,
                    as: 'project',
                    where: { orgId },
                    attributes: [],
                }],
            }),
            User.count({ where: { orgId, isActive: true } }),
            // Count unique users with audit logs in last 24h
            AuditLog.count({
                distinct: true,
                col: 'userId',
                include: [{
                    model: User,
                    as: 'user',
                    where: { orgId },
                    attributes: [],
                }],
                where: {
                    createdAt: { [Op.gte]: oneDayAgo },
                    userId: { [Op.ne]: null as any }
                }
            })
        ]);

        // Mock System Health (for demo purposes)
        // In production, use 'os' module or cloud watch metrics
        const systemHealth = {
            cpuUsage: Math.floor(Math.random() * 30) + 10, // 10-40%
            memoryUsage: Math.floor(Math.random() * 40) + 20, // 20-60%
            uptime: process.uptime(),
            status: 'HEALTHY'
        };

        const projectAttachmentAggregate = await Attachment.findAll({
            where: { projectId: { [Op.ne]: null } },
            attributes: [[sequelize.fn('COALESCE', sequelize.fn('SUM', sequelize.col('Attachment.size')), 0), 'total']],
            include: [{
                model: Project,
                as: 'project',
                where: { orgId },
                attributes: [],
            }],
            raw: true,
        });
        const issueAttachmentAggregate = await Attachment.findAll({
            where: { issueId: { [Op.ne]: null } },
            attributes: [[sequelize.fn('COALESCE', sequelize.fn('SUM', sequelize.col('Attachment.size')), 0), 'total']],
            include: [{
                model: Issue,
                as: 'issue',
                attributes: [],
                include: [{
                    model: Project,
                    as: 'project',
                    where: { orgId },
                    attributes: [],
                }],
            }],
            raw: true,
        });
        const projectAttachmentBytes = Number((projectAttachmentAggregate[0] as any)?.total || 0);
        const issueAttachmentBytes = Number((issueAttachmentAggregate[0] as any)?.total || 0);
        const storageBytes = projectAttachmentBytes + issueAttachmentBytes;
        const storageUsage = {
            usedBytes: storageBytes,
            limitBytes: 5 * 1024 * 1024 * 1024, // 5GB limit example
            percentage: (storageBytes / (5 * 1024 * 1024 * 1024)) * 100
        };

        // Get issue breakdown by status
        const issuesByStatus = await Issue.findAll({
            attributes: [
                'status',
                [sequelize.fn('COUNT', sequelize.col('Issue.id')), 'count'],
            ],
            include: [{
                model: Project,
                as: 'project',
                where: { orgId },
                attributes: [],
            }],
            group: ['Issue.status'],
            raw: true,
        });

        // Get issue breakdown by priority
        const issuesByPriority = await Issue.findAll({
            attributes: [
                'priority',
                [sequelize.fn('COUNT', sequelize.col('Issue.id')), 'count'],
            ],
            include: [{
                model: Project,
                as: 'project',
                where: { orgId },
                attributes: [],
            }],
            group: ['Issue.priority'],
            raw: true,
        });

        // Get recent activity
        const recentActivity = await AuditLog.findAll({
            limit: 10,
            order: [['createdAt', 'DESC']],
            include: [{
                model: User,
                as: 'user',
                where: { orgId },
                attributes: ['id', 'firstName', 'lastName', 'email'],
            }],
        });

        res.json({
            success: true,
            data: {
                overview: {
                    projects: projectCount,
                    issues: issueCount,
                    activeSprints: activeSprintCount,
                    totalUsers: userCount, // Aligning with frontend expectations if adjusted
                    activeUsers: userCount, // Explicitly providing activeUsers to match current frontend interface
                    activeUsers24h,
                },
                systemHealth,
                storageUsage,
                issuesByStatus,
                issuesByPriority,
                recentActivity,
            },
        });
    });

    // Get velocity chart data
    static getVelocityChart = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { projectId } = req.query;
        const user = req.user!;

        const where: any = { status: 'COMPLETED' };
        if (projectId) {
            where.projectId = projectId;
        }
        const projectWhere: any = user.role === UserRole.CLIENT
            ? { clientId: user.id }
            : { orgId: user.orgId };
        if (projectId) {
            projectWhere.id = projectId;
            await getAccessibleProject(req, String(projectId));
        }

        const completedSprints = await Sprint.findAll({
            where,
            include: [{
                model: Project,
                as: 'project',
                where: projectWhere,
                attributes: [],
            }],
            order: [['endDate', 'ASC']],
            limit: 10,
            attributes: ['id', 'name', 'velocity', 'capacity', 'startDate', 'endDate'],
        });

        const velocityData = completedSprints.map(sprint => ({
            sprintName: sprint.name,
            velocity: sprint.velocity || 0,
            capacity: sprint.capacity || 0,
            completionRate: sprint.capacity ? ((sprint.velocity || 0) / sprint.capacity) * 100 : 0,
        }));

        res.json({
            success: true,
            data: { velocityData },
        });
    });

    // Get burndown chart data
    static getBurndownChart = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { sprintId } = req.params;

        const sprint = await getAccessibleSprint(req, sprintId);
        await sprint.reload({
            include: [{
                model: Issue,
                as: 'issues',
                attributes: ['id', 'storyPoints', 'status', 'updatedAt'],
            }],
        });

        if (!sprint.startDate || !sprint.endDate) {
            throw new AppError('Sprint dates are required for burndown calculation', 400);
        }

        const issues = sprint.issues || [];
        const totalPoints = issues.reduce((sum: number, issue: any) => sum + (issue.storyPoints || 0), 0);

        // Calculate ideal burndown
        const sprintDays = Math.ceil(
            (new Date(sprint.endDate).getTime() - new Date(sprint.startDate).getTime()) / (1000 * 60 * 60 * 24)
        );

        const idealBurndown = Array.from({ length: sprintDays + 1 }, (_, i) => ({
            day: i,
            points: totalPoints - (totalPoints / sprintDays) * i,
        }));

        // Calculate actual burndown (simplified - in production, track daily)
        const completedPoints = issues
            .filter((issue: any) => issue.status === 'DONE')
            .reduce((sum: number, issue: any) => sum + (issue.storyPoints || 0), 0);

        const actualBurndown = [
            { day: 0, points: totalPoints },
            { day: sprintDays, points: totalPoints - completedPoints },
        ];

        res.json({
            success: true,
            data: {
                sprint: {
                    name: sprint.name,
                    startDate: sprint.startDate,
                    endDate: sprint.endDate,
                    totalPoints,
                    completedPoints,
                },
                idealBurndown,
                actualBurndown,
            },
        });
    });

    // Get team performance metrics
    static getTeamPerformance = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { projectId } = req.query;
        const { orgId } = req.user!;

        if (projectId) {
            await getAccessibleProject(req, String(projectId));
        }

        const where: any = { orgId, isActive: true };

        const users = await User.findAll({
            where,
            attributes: ['id', 'firstName', 'lastName', 'email'],
        });

        const performanceData = await Promise.all(
            users.map(async (user) => {
                const issueWhere: any = { assigneeId: user.id };
                if (projectId) {
                    issueWhere.projectId = projectId;
                }

                const [assignedIssues, completedIssues, totalWorkLog] = await Promise.all([
                    Issue.count({
                        where: issueWhere,
                        include: [{
                            model: Project,
                            as: 'project',
                            where: { orgId },
                            attributes: [],
                        }],
                    }),
                    Issue.count({
                        where: { ...issueWhere, status: 'DONE' },
                        include: [{
                            model: Project,
                            as: 'project',
                            where: { orgId },
                            attributes: [],
                        }],
                    }),
                    WorkLog.sum('timeSpent', { where: { userId: user.id } }),
                ]);

                return {
                    user: {
                        id: user.id,
                        name: `${user.firstName} ${user.lastName}`,
                        email: user.email,
                    },
                    metrics: {
                        assignedIssues,
                        completedIssues,
                        completionRate: assignedIssues > 0 ? (completedIssues / assignedIssues) * 100 : 0,
                        totalHoursLogged: totalWorkLog || 0,
                    },
                };
            })
        );

        res.json({
            success: true,
            data: { teamPerformance: performanceData },
        });
    });

    // Get project health metrics
    static getProjectHealth = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { projectId } = req.params;

        const project = await getAccessibleProject(req, projectId);
        const scopedProjectId = project.id;

        // Get issue metrics
        const [totalIssues, overdueIssues, blockedIssues, criticalIssues] = await Promise.all([
            Issue.count({ where: { projectId: scopedProjectId } }),
            Issue.count({
                where: {
                    projectId: scopedProjectId,
                    dueDate: { [Op.lt]: new Date() },
                    status: { [Op.notIn]: ['DONE'] },
                },
            }),
            Issue.count({ where: { projectId: scopedProjectId, status: 'BLOCKED' } }),
            Issue.count({ where: { projectId: scopedProjectId, priority: 'CRITICAL' } }),
        ]);

        // Get sprint progress
        const activeSprint = await Sprint.findOne({
            where: { projectId: scopedProjectId, status: 'ACTIVE' },
            include: [{
                model: Issue,
                as: 'issues',
                attributes: ['id', 'status', 'storyPoints'],
            }],
        });

        let sprintProgress = null;
        if (activeSprint) {
            const issues = activeSprint.issues || [];
            const totalPoints = issues.reduce((sum: number, i: any) => sum + (i.storyPoints || 0), 0);
            const completedPoints = issues
                .filter((i: any) => i.status === 'DONE')
                .reduce((sum: number, i: any) => sum + (i.storyPoints || 0), 0);

            sprintProgress = {
                sprintName: activeSprint.name,
                totalPoints,
                completedPoints,
                progress: totalPoints > 0 ? (completedPoints / totalPoints) * 100 : 0,
            };
        }

        // Calculate health score (0-100)
        const healthScore = Math.max(
            0,
            100 -
            (overdueIssues * 10) -
            (blockedIssues * 15) -
            (criticalIssues * 5)
        );

        res.json({
            success: true,
            data: {
                project: {
                    id: project.id,
                    name: project.name,
                    key: project.key,
                },
                metrics: {
                    totalIssues,
                    overdueIssues,
                    blockedIssues,
                    criticalIssues,
                },
                sprintProgress,
                healthScore,
                healthStatus: healthScore >= 80 ? 'HEALTHY' : healthScore >= 60 ? 'WARNING' : 'CRITICAL',
            },
        });
    });
    // Get personal statistics for the current user
    static getPersonalStats = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const userId = req.user!.id;
        const now = new Date();
        const startOfWeek = new Date(now.getFullYear(), now.getMonth(), now.getDate() - now.getDay());
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

        // Parallel fetch for efficiency
        const [
            activeIssues,
            completedThisWeek,
            completedThisMonth,
            totalStoryPoints,
            avgCompletionTime
        ] = await Promise.all([
            // 1. Count Active Issues
            Issue.count({
                where: {
                    assigneeId: userId,
                    status: { [Op.notIn]: ['DONE', 'CANCELLED'] }
                }
            }),

            // 2. Completed This Week
            Issue.count({
                where: {
                    assigneeId: userId,
                    status: 'DONE',
                    updatedAt: { [Op.gte]: startOfWeek }
                }
            }),

            // 3. Completed This Month
            Issue.count({
                where: {
                    assigneeId: userId,
                    status: 'DONE',
                    updatedAt: { [Op.gte]: startOfMonth }
                }
            }),

            // 4. Total Story Points Delivered (All time)
            Issue.sum('storyPoints', {
                where: {
                    assigneeId: userId,
                    status: 'DONE'
                }
            }),

            // 5. Calculate Average Completion Time (Simplified: Based on estimated vs actual hours if available, otherwise 0)
            // Note: A more accurate way involves WorkLogs, but for quick stats, we can use actualHours if filled, or diff between createdAt and updatedAt for DONE issues
            // Here we will use a simple average of actualHours for DONE issues
            Issue.findAll({
                where: {
                    assigneeId: userId,
                    status: 'DONE',
                    actualHours: { [Op.gt]: 0 }
                },
                attributes: [[sequelize.fn('AVG', sequelize.col('actualHours')), 'avgTime']],
                raw: true
            })
        ]);

        const avgHours = (avgCompletionTime as any)[0]?.avgTime || 0;

        // Get recent activity for this user
        const recentActivity = await AuditLog.findAll({
            where: { userId },
            limit: 5,
            order: [['createdAt', 'DESC']],
            attributes: ['id', 'action', 'resource', 'details', 'createdAt']
        });

        res.json({
            success: true,
            data: {
                activeIssues,
                completedThisWeek,
                completedThisMonth,
                velocity: totalStoryPoints || 0,
                avgCompletionTime: parseFloat(avgHours).toFixed(1),
                recentActivity
            }
        });
    });
    // Get client statistics (High level project overview)
    static getClientStats = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const user = req.user!;
        const allowedRoles = [
            UserRole.ADMIN,
            UserRole.PROJECT_MANAGER,
            UserRole.SCRUM_MASTER,
            UserRole.CLIENT,
        ];

        if (!allowedRoles.includes(user.role)) {
            throw new AppError('Insufficient permissions', 403);
        }

        const projectWhere: any = user.role === UserRole.CLIENT
            ? { clientId: user.id }
            : { orgId: user.orgId };

        // 1. Total Projects
        const totalProjects = await Project.count({ where: projectWhere });

        // 2. Active Projects
        const activeProjects = await Project.count({
            where: { ...projectWhere, status: 'ACTIVE' },
        });

        // 3. Total Budget (Sum of budget column in scoped projects)
        const totalBudget = await Project.sum('budget', { where: projectWhere }) || 0;

        // 4. Completed Issues (Across scoped projects)
        const completedIssues = await Issue.count({
            include: [{
                model: Project,
                as: 'project',
                where: projectWhere,
                attributes: [],
            }],
            where: { status: 'DONE' },
        });

        // 5. Total Issues (Across scoped projects)
        const totalIssues = await Issue.count({
            include: [{
                model: Project,
                as: 'project',
                where: projectWhere,
                attributes: [],
            }],
        });

        // 6. Overall Progress
        const overallProgress = totalIssues > 0 ? Math.round((completedIssues / totalIssues) * 100) : 0;

        res.json({
            success: true,
            data: {
                totalProjects,
                activeProjects,
                totalBudget,
                completedDeliverables: completedIssues,
                overallProgress,
            }
        });
    });
    // Get System Health (Real OS metrics)
    static getSystemHealth = asyncHandler(async (_req: AuthRequest, res: Response): Promise<void> => {
        const cpus = os.cpus();
        const cpuUsage = cpus.reduce((acc, cpu) => {
            const total = Object.values(cpu.times).reduce((a, b) => a + b);
            const idle = cpu.times.idle;
            return acc + ((total - idle) / total);
        }, 0) / cpus.length * 100;

        const totalMem = os.totalmem();
        const freeMem = os.freemem();
        const usedMem = totalMem - freeMem;

        const healthData = {
            cpuUsage: parseFloat(cpuUsage.toFixed(1)),
            memoryUsage: parseFloat(((usedMem / totalMem) * 100).toFixed(1)),
            uptime: os.uptime(),
            loadAverage: os.loadavg(),
            platform: os.platform(),
            release: os.release(),
            status: 'HEALTHY'
        };

        res.json({
            success: true,
            data: healthData
        });
    });

    // Get Database Statistics
    static getDatabaseStats = asyncHandler(async (_req: AuthRequest, res: Response): Promise<void> => {
        // Raw queries for Postgres
        const [dbSizeResult] = await sequelize.query(
            "SELECT pg_size_pretty(pg_database_size(current_database())) as size"
        );

        const [connectionsResult] = await sequelize.query(
            "SELECT count(*) as count FROM pg_stat_activity"
        );

        // Cache hit ratio
        const [cacheHitResult] = await sequelize.query(
            "SELECT sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) * 100 as ratio FROM pg_statio_user_tables"
        );

        res.json({
            success: true,
            data: {
                size: (dbSizeResult[0] as any).size,
                connections: parseInt((connectionsResult[0] as any).count),
                cacheHitRatio: parseFloat((cacheHitResult[0] as any).ratio || 0).toFixed(2)
            }
        });
    });

    // Get Growth Statistics (Users/Projects over time)
    static getGrowthStats = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { orgId } = req.user!;
        const sixMonthsAgo = new Date();
        sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);

        // Group by month
        const usersByMonth = await User.findAll({
            attributes: [
                [sequelize.fn('date_trunc', 'month', sequelize.col('createdAt')), 'month'],
                [sequelize.fn('count', '*'), 'count']
            ],
            where: {
                orgId,
                createdAt: { [Op.gte]: sixMonthsAgo }
            },
            group: ['month'],
            order: [[sequelize.col('month'), 'ASC']],
            raw: true
        });

        const projectsByMonth = await Project.findAll({
            attributes: [
                [sequelize.fn('date_trunc', 'month', sequelize.col('createdAt')), 'month'],
                [sequelize.fn('count', '*'), 'count']
            ],
            where: {
                orgId,
                createdAt: { [Op.gte]: sixMonthsAgo }
            },
            group: ['month'],
            order: [[sequelize.col('month'), 'ASC']],
            raw: true
        });

        res.json({
            success: true,
            data: {
                userGrowth: usersByMonth,
                projectGrowth: projectsByMonth
            }
        });
    });

    // Get Resolution Rate (Created vs Done)
    static getResolutionRate = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { orgId } = req.user!;
        const sixMonthsAgo = new Date();
        sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);

        // Created Issues by month
        const createdByMonth = await Issue.findAll({
            attributes: [
                [sequelize.fn('date_trunc', 'month', sequelize.col('Issue.createdAt')), 'month'],
                [sequelize.fn('count', '*'), 'count']
            ],
            include: [{
                model: Project,
                as: 'project',
                where: { orgId },
                attributes: []
            }],
            where: {
                createdAt: { [Op.gte]: sixMonthsAgo }
            },
            group: ['month'],
            order: [[sequelize.col('month'), 'ASC']],
            raw: true
        });

        // Resolved (Done) Issues by month (using updatedAt for simplicity as closed date)
        const resolvedByMonth = await Issue.findAll({
            attributes: [
                [sequelize.fn('date_trunc', 'month', sequelize.col('Issue.updatedAt')), 'month'],
                [sequelize.fn('count', '*'), 'count']
            ],
            include: [{
                model: Project,
                as: 'project',
                where: { orgId },
                attributes: []
            }],
            where: {
                status: 'DONE',
                updatedAt: { [Op.gte]: sixMonthsAgo }
            },
            group: ['month'],
            order: [[sequelize.col('month'), 'ASC']],
            raw: true
        });

        res.json({
            success: true,
            data: {
                created: createdByMonth,
                resolved: resolvedByMonth
            }
        });
    });

    // Generate Export Report (CSV)
    static exportReport = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { type } = req.query; // 'issues', 'users', 'audit'
        const { orgId } = req.user!;

        if (!['issues', 'users', 'audit'].includes(String(type))) {
            throw new AppError('Invalid export type', 400);
        }

        let data: any[] = [];
        let headers: string[] = [];

        if (type === 'issues') {
            const issues = await Issue.findAll({
                include: [{
                    model: Project,
                    as: 'project',
                    where: { orgId }
                }],
                raw: true,
                nest: true
            });
            headers = ['ID', 'Key', 'Title', 'Status', 'Priority', 'Type', 'Project', 'Created At'];
            data = issues.map((i: any) => [
                i.id, i.key, `"${i.title.replace(/"/g, '""')}"`, i.status, i.priority, i.type, i.project.name, i.createdAt
            ]);
        } else if (type === 'users') {
            const users = await User.findAll({ where: { orgId }, raw: true });
            headers = ['ID', 'Name', 'Email', 'Role', 'Status', 'Created At'];
            data = users.map((u: any) => [
                u.id, `"${u.firstName} ${u.lastName}"`, u.email, u.role, u.isActive ? 'Active' : 'Inactive', u.createdAt
            ]);
        } else if (type === 'audit') {
            const logs = await AuditLog.findAll({
                include: [{
                    model: User,
                    as: 'user',
                    where: { orgId },
                    attributes: ['email']
                }],
                limit: 1000,
                order: [['createdAt', 'DESC']],
                raw: true,
                nest: true
            });
            headers = ['ID', 'User', 'Action', 'Resource', 'Timestamp'];
            data = logs.map((l: any) => [
                l.id, l.user?.email || 'System', l.action, l.resource, l.createdAt
            ]);
        }

        // CSV Construction
        const csvContent = [
            headers.join(','),
            ...data.map(row => row.join(','))
        ].join('\n');

        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', `attachment; filename=${type}_report_${Date.now()}.csv`);
        res.send(csvContent);
    });
}
