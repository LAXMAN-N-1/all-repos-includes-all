import { Response } from 'express';
import { AuthRequest } from '../types/interfaces';
import { Project, User, Organization, ProjectMember, Issue, AuditLog } from '../models';
import sequelize from '../config/database';
import { AppError, asyncHandler } from '../middleware/errorHandler';
import { AuditAction, UserRole, ProjectStatus } from '../types/enums';
import { getOffset, getPaginationMeta } from '../utils/helpers';
import { Op } from 'sequelize';
import { assertProjectAccess, getAccessibleProject } from '../utils/accessControl';

export class ProjectController {
    private static async assertUserInOrg(
        userId: string | null | undefined,
        orgId: string,
        notFoundMessage: string
    ): Promise<User | null> {
        if (!userId) {
            return null;
        }

        const user = await User.findByPk(userId);
        if (!user) {
            throw new AppError(notFoundMessage, 404);
        }

        if (user.orgId !== orgId) {
            throw new AppError('Access denied', 403);
        }

        return user;
    }

    private static async assertUsersInOrg(userIds: string[], orgId: string): Promise<void> {
        const uniqueUserIds = Array.from(new Set(userIds.filter(Boolean)));
        if (uniqueUserIds.length === 0) {
            return;
        }

        const users = await User.findAll({
            where: {
                id: { [Op.in]: uniqueUserIds },
            },
            attributes: ['id', 'orgId'],
        });

        if (users.length !== uniqueUserIds.length) {
            throw new AppError('User not found', 404);
        }

        if (users.some((user) => user.orgId !== orgId)) {
            throw new AppError('Access denied', 403);
        }
    }

    // Get all projects
    static getAllProjects = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 10;
        const search = req.query.search as string;
        const status = req.query.status as string;

        const andFilters: any[] = [];

        // Filter by role
        if (req.user?.role === UserRole.CLIENT) {
            // Clients see projects assigned to them specifically
            andFilters.push({ clientId: req.user.id });
        } else if (req.user?.role === UserRole.PROJECT_MANAGER) {
            // Project Managers see projects they manage
            andFilters.push({ projectManagerId: req.user.id });
        } else if (req.user?.role === UserRole.SCRUM_MASTER) {
            // Scrum Masters see only projects they are members of
            // We need to fetch project IDs first or use a subquery/include with where
            // For simplicity, let's fetch IDs from ProjectMember
            const memberProjects = await ProjectMember.findAll({
                where: { userId: req.user.id },
                attributes: ['projectId']
            });
            const projectIds = memberProjects.map(mp => mp.projectId);

            // Also include projects where they are Lead (though lead should be a member)
            andFilters.push({ orgId: req.user.orgId });
            andFilters.push({
                [Op.or]: [
                    { id: { [Op.in]: projectIds } },
                    { leadId: req.user.id }
                ]
            });
        } else if (req.user?.role === UserRole.EMPLOYEE) {
            // Employees only see projects they are a member of
            const memberProjects = await ProjectMember.findAll({
                where: { userId: req.user.id },
                attributes: ['projectId']
            });
            const projectIds = memberProjects.map(mp => mp.projectId);
            andFilters.push({ orgId: req.user.orgId });
            andFilters.push({
                [Op.or]: [
                    { id: { [Op.in]: projectIds } },
                    { leadId: req.user.id }
                ]
            });
        } else {
            // ADMIN and other roles see all org projects
            andFilters.push({ orgId: req.user?.orgId });
        }

        // Search filter
        if (search) {
            andFilters.push({
                [Op.or]: [
                    { name: { [Op.iLike]: `%${search}%` } },
                    { key: { [Op.iLike]: `%${search}%` } },
                    { description: { [Op.iLike]: `%${search}%` } },
                ]
            });
        }

        // Status filter
        if (status) {
            andFilters.push({ status });
        }
        const where = andFilters.length > 0 ? { [Op.and]: andFilters } : {};

        const { count, rows } = await Project.findAndCountAll({
            where,
            limit,
            offset: getOffset(page, limit),
            order: [['createdAt', 'DESC']],
            include: [
                {
                    model: User,
                    as: 'lead',
                    attributes: ['id', 'firstName', 'lastName', 'email'],
                },
                {
                    model: Organization,
                    as: 'organization',
                    attributes: ['id', 'name'],
                },
            ],
        });

        res.json({
            success: true,
            data: {
                projects: rows,
                pagination: getPaginationMeta(page, limit, count),
            },
        });
    });

    // Get project by ID
    static getProjectById = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;

        const project = await Project.findByPk(id, {
            include: [
                {
                    model: User,
                    as: 'lead',
                    attributes: ['id', 'firstName', 'lastName', 'email'],
                },
                {
                    model: Organization,
                    as: 'organization',
                    attributes: ['id', 'name'],
                },
                {
                    model: User,
                    as: 'members',
                    attributes: ['id', 'firstName', 'lastName', 'email', 'role'],
                    through: { attributes: ['role'] },
                },
            ],
        });

        if (!project) {
            throw new AppError('Project not found', 404);
        }

        assertProjectAccess(req, project);

        // Calculate stats
        const totalIssues = await Issue.count({ where: { projectId: id } });
        const openIssues = await Issue.count({ where: { projectId: id, status: { [Op.notIn]: ['DONE', 'CANCELLED'] } } });
        const inProgressIssues = await Issue.count({ where: { projectId: id, status: 'IN_PROGRESS' } });
        const completedIssues = await Issue.count({ where: { projectId: id, status: 'DONE' } });
        // Assuming we have Sprint model linked
        // const activeSprints = await Sprint.count({ where: { projectId: id, status: 'ACTIVE' } });
        // For now, placeholder or fetch if relation exists
        const activeSprints = 0; // TODO: Link Sprint model

        // Fetch recent activity (Last 5 issues created/updated)
        // We can check both createdAt and updatedAt. simplifying to just latest issues by updatedAt
        const recentIssues = await Issue.findAll({
            where: { projectId: id },
            order: [['updatedAt', 'DESC']],
            limit: 5,
            include: [
                { model: User, as: 'reporter', attributes: ['id', 'firstName', 'lastName'] },
                { model: User, as: 'assignee', attributes: ['id', 'firstName', 'lastName'] }
            ]
        });

        const recentActivity = recentIssues.map((issue: any) => {
            const isCreation = issue.createdAt.getTime() === issue.updatedAt.getTime();
            const action = isCreation ? 'created issue' : 'updated issue';
            return {
                id: issue.id,
                user: issue.reporter?.firstName + ' ' + issue.reporter?.lastName,
                action,
                target: issue.key,
                time: issue.updatedAt
            };
        });

        // Priority Breakdown
        const priorityStats = await Issue.findAll({
            where: { projectId: id },
            attributes: ['priority', [sequelize.fn('COUNT', sequelize.col('priority')), 'count']],
            group: ['priority'],
            raw: true
        });

        const priorityBreakdown = {
            CRITICAL: 0,
            HIGH: 0,
            MEDIUM: 0,
            LOW: 0,
            ...Object.fromEntries(priorityStats.map((s: any) => [s.priority, parseInt(s.count)]))
        };

        const projectData = {
            ...project.toJSON(),
            members: ((project as any).members || []).map((m: any) => ({
                ...m.toJSON ? m.toJSON() : m,
                name: `${m.firstName || ''} ${m.lastName || ''}`.trim() || m.email || 'Unknown User'
            })),
            usesEpics: !!project.usesEpics,
            usesSprints: !!project.usesSprints,
            stats: {
                totalIssues,
                openIssues,
                inProgressIssues,
                completedIssues,
                activeSprints,
                priorityBreakdown
            },
            recentActivity
        };

        res.json({
            success: true,
            data: { project: projectData },
        });
    });

    // Create project
    static createProject = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { name, key, description, leadId, clientId, projectManagerId, scrumMasterId, visibility, startDate, endDate, budget, clientConfig, addClient, clientDetails, type, usesEpics, usesSprints, memberIds } = req.body;

        console.log('--- Project Creation Started ---');
        console.log('Payload:', JSON.stringify(req.body, null, 2));

        // Check if project key already exists
        const existingProject = await Project.findOne({ where: { key: key.toUpperCase() } });
        if (existingProject) {
            throw new AppError('Project key already exists', 400);
        }

        // Verify lead exists
        const leadIdToCheck = leadId || req.user!.id;
        await ProjectController.assertUserInOrg(leadIdToCheck, req.user!.orgId, 'Project lead not found');

        // Verify assigned users are org-bound
        await ProjectController.assertUserInOrg(projectManagerId, req.user!.orgId, 'Project Manager not found');
        await ProjectController.assertUserInOrg(scrumMasterId, req.user!.orgId, 'Scrum Master not found');
        await ProjectController.assertUserInOrg(clientId, req.user!.orgId, 'Client not found');

        let createdClientId = clientId;

        // Handle Client Creation if requested
        if (addClient && clientDetails) {
            const { name: cName, email: cEmail, phone: cPhone, username: cUsername, password: cPassword } = clientDetails;

            // Check if user exists
            let clientUser = await User.findOne({
                where: {
                    [Op.or]: [{ email: cEmail }, { username: cUsername }]
                }
            });

            if (!clientUser) {
                // Create new Client User
                const bcrypt = require('bcryptjs');
                const salt = await bcrypt.genSalt(10);
                const passwordHash = await bcrypt.hash(cPassword, salt);

                // Split name
                const nameParts = cName.split(' ');
                const firstName = nameParts[0];
                const lastName = nameParts.length > 1 ? nameParts.slice(1).join(' ') : '';

                clientUser = await User.create({
                    firstName,
                    lastName: lastName || 'Client',
                    email: cEmail,
                    username: cUsername,
                    phone: cPhone,
                    passwordHash,
                    role: UserRole.CLIENT,
                    orgId: req.user!.orgId, // Add to same org
                    forcePasswordChange: true,
                    isActive: true,
                    createdBy: req.user!.id,
                    profileData: {},
                    mfaEnabled: false
                });
            } else if (clientUser.orgId !== req.user!.orgId) {
                throw new AppError('Access denied', 403);
            }
            createdClientId = clientUser.id;
        }

        // Normalize visibility and status to uppercase for ENUM compatibility
        const normalizedVisibility = (visibility || 'PRIVATE').toUpperCase();
        const normalizedStatus = ProjectStatus.ACTIVE;

        console.log('Attempting Project.create with normalized data:', {
            name,
            key: key.toUpperCase(),
            orgId: req.user!.orgId,
            leadId: leadId || req.user!.id,
            status: normalizedStatus,
            visibility: normalizedVisibility
        });

        // Create project
        const project = await Project.create({
            name,
            key: key.toUpperCase(),
            description,
            orgId: req.user!.orgId,
            leadId: leadId || req.user!.id,
            clientId: createdClientId || null,
            projectManagerId: projectManagerId || null,
            scrumMasterId: scrumMasterId || null,
            settings: {},
            clientConfig: clientConfig || { showBudget: false, allowTaskCreation: false },
            status: normalizedStatus as any,
            visibility: normalizedVisibility as any,
            startDate,
            endDate,
            budget: budget ? parseFloat(budget.toString()) : undefined,
            type: type || 'SCRUM',
            usesEpics: usesEpics !== undefined ? usesEpics : true,
            usesSprints: usesSprints !== undefined ? usesSprints : false,
        });

        console.log('Project created successfully:', project.id);

        // Add lead as project member
        await ProjectMember.create({
            projectId: project.id,
            userId: leadId || req.user!.id,
            role: 'LEAD',
            accessLevel: 'APPROVER'
        });

        // If client was created/assigned, add them as member too
        if (createdClientId) {
            if (createdClientId !== (leadId || req.user!.id)) {
                await ProjectMember.create({
                    projectId: project.id,
                    userId: createdClientId,
                    role: 'CLIENT',
                    accessLevel: clientDetails?.accessLevel || 'VIEW_ONLY'
                });
            }
        }

        // Add Project Manager as member
        if (projectManagerId) {
            if (projectManagerId !== (leadId || req.user!.id)) {
                await ProjectMember.create({
                    projectId: project.id,
                    userId: projectManagerId,
                    role: 'PROJECT_MANAGER',
                    accessLevel: 'APPROVER'
                });
            }
        }

        // Add Scrum Master as member
        if (scrumMasterId) {
            if (scrumMasterId !== (leadId || req.user!.id)) {
                await ProjectMember.create({
                    projectId: project.id,
                    userId: scrumMasterId,
                    role: 'SCRUM_MASTER',
                    accessLevel: 'APPROVER'
                });
            }
        }

        // Add team members if provided
        if (memberIds && Array.isArray(memberIds) && memberIds.length > 0) {
            const membersToAdd = memberIds.filter((id: string) =>
                id !== (leadId || req.user!.id) && id !== createdClientId
            );

            if (membersToAdd.length > 0) {
                await ProjectController.assertUsersInOrg(membersToAdd, req.user!.orgId);
                const projectMembers = membersToAdd.map((userId: string) => ({
                    projectId: project.id,
                    userId,
                    role: 'MEMBER',
                    accessLevel: 'COMMENTER' as any
                }));
                await ProjectMember.bulkCreate(projectMembers);
            }
        }

        // Audit log
        await AuditLog.create({
            userId: req.user!.id,
            action: AuditAction.CREATE,
            resource: 'project',
            resourceId: project.id,
            details: { name: project.name, key: project.key, createdClient: !!addClient },
            ipAddress: req.ip,
            userAgent: req.get('user-agent'),
        });

        console.log('--- Project Creation Completed Successfully ---');

        res.status(201).json({
            success: true,
            message: 'Project created successfully',
            data: { project },
        });
    });

    // Update project
    static updateProject = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;
        const { name, description, leadId, clientId, status, visibility, startDate, endDate, budget, settings, clientConfig } = req.body;

        const project = await Project.findByPk(id);
        if (!project) {
            throw new AppError('Project not found', 404);
        }

        assertProjectAccess(req, project);

        // Update fields
        if (name) project.name = name;
        if (description !== undefined) project.description = description;
        if (leadId) {
            await ProjectController.assertUserInOrg(leadId, project.orgId, 'Project lead not found');
            project.leadId = leadId;
        }
        // Handle Project Manager Update
        const { projectManagerId, scrumMasterId } = req.body;
        if (projectManagerId !== undefined) {
            await ProjectController.assertUserInOrg(
                projectManagerId,
                project.orgId,
                'Project Manager not found'
            );
            project.projectManagerId = projectManagerId;
            if (projectManagerId) {
                const existingMember = await ProjectMember.findOne({ where: { projectId: project.id, userId: projectManagerId } });
                if (!existingMember) {
                    await ProjectMember.create({
                        projectId: project.id,
                        userId: projectManagerId,
                        role: 'PROJECT_MANAGER',
                        accessLevel: 'APPROVER'
                    });
                }
            }
        }
        // Handle Scrum Master Update
        if (scrumMasterId !== undefined) {
            await ProjectController.assertUserInOrg(
                scrumMasterId,
                project.orgId,
                'Scrum Master not found'
            );
            project.scrumMasterId = scrumMasterId;
            if (scrumMasterId) {
                const existingMember = await ProjectMember.findOne({ where: { projectId: project.id, userId: scrumMasterId } });
                if (!existingMember) {
                    await ProjectMember.create({
                        projectId: project.id,
                        userId: scrumMasterId,
                        role: 'SCRUM_MASTER',
                        accessLevel: 'APPROVER'
                    });
                }
            }
        }
        if (clientId !== undefined) {
            await ProjectController.assertUserInOrg(clientId, project.orgId, 'Client not found');
            project.clientId = clientId;
        }
        if (status) project.status = status;
        if (visibility) project.visibility = visibility;
        if (startDate) project.startDate = startDate;
        if (endDate) project.endDate = endDate;
        if (budget !== undefined) {
            project.budget = budget === null ? undefined : budget;
        }

        if (settings) project.settings = { ...project.settings, ...settings };
        if (clientConfig) project.clientConfig = { ...project.clientConfig, ...clientConfig };

        await project.save();

        // Audit log
        await AuditLog.create({
            userId: req.user!.id,
            action: AuditAction.UPDATE,
            resource: 'project',
            resourceId: project.id,
            details: { changes: req.body },
            ipAddress: req.ip,
            userAgent: req.get('user-agent'),
        });

        res.json({
            success: true,
            message: 'Project updated successfully',
            data: { project },
        });
    });

    // Delete project
    static deleteProject = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;

        const project = await Project.findByPk(id);
        if (!project) {
            throw new AppError('Project not found', 404);
        }

        // Only admins can delete projects
        if (req.user?.role !== UserRole.ADMIN) {
            throw new AppError('Only admins can delete projects', 403);
        }
        assertProjectAccess(req, project);

        // Audit log before deletion
        await AuditLog.create({
            userId: req.user!.id,
            action: AuditAction.DELETE,
            resource: 'project',
            resourceId: project.id,
            details: { name: project.name, key: project.key },
            ipAddress: req.ip,
            userAgent: req.get('user-agent'),
        });

        await project.destroy();

        res.json({
            success: true,
            message: 'Project deleted successfully',
        });
    });

    // Get project members
    static getProjectMembers = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;

        await getAccessibleProject(req, id);

        const members = await ProjectMember.findAll({
            where: { projectId: id },
            include: [
                {
                    model: User,
                    as: 'user',
                    attributes: ['id', 'firstName', 'lastName', 'email', 'role'],
                },
            ],
        });

        res.json({
            success: true,
            data: { members },
        });
    });

    // Add project member
    static addProjectMember = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;
        const { userId, role } = req.body;

        const project = await getAccessibleProject(req, id);

        // Check if user exists
        const user = await User.findByPk(userId);
        if (!user) {
            throw new AppError('User not found', 404);
        }
        if (user.orgId !== project.orgId) {
            throw new AppError('Access denied', 403);
        }

        // Check if already a member
        const existingMember = await ProjectMember.findOne({
            where: { projectId: id, userId },
        });
        if (existingMember) {
            throw new AppError('User is already a project member', 400);
        }

        // Add member
        const member = await ProjectMember.create({
            projectId: id!,
            userId,
            role: role || 'MEMBER',
        });

        // Audit log
        await AuditLog.create({
            userId: req.user!.id,
            action: AuditAction.CREATE,
            resource: 'project_member',
            resourceId: member.id,
            details: { projectId: id, userId, role: member.role },
            ipAddress: req.ip,
            userAgent: req.get('user-agent'),
        });

        res.status(201).json({
            success: true,
            message: 'Member added to project',
            data: { member },
        });
    });

    // Remove project member
    static removeProjectMember = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id, userId } = req.params;
        await getAccessibleProject(req, id);

        const member = await ProjectMember.findOne({
            where: { projectId: id, userId },
        });

        if (!member) {
            throw new AppError('Member not found in project', 404);
        }

        // Audit log
        await AuditLog.create({
            userId: req.user!.id,
            action: AuditAction.DELETE,
            resource: 'project_member',
            resourceId: member.id,
            details: { projectId: id, userId },
            ipAddress: req.ip,
            userAgent: req.get('user-agent'),
        });

        await member.destroy();

        res.json({
            success: true,
            message: 'Member removed from project',
        });
    });

    // Get project issues
    static getProjectIssues = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 20;

        await getAccessibleProject(req, id);
        const where: any = { projectId: id };
        if (req.user?.role === UserRole.CLIENT) {
            where.isClientVisible = true;
        }

        const { count, rows } = await Issue.findAndCountAll({
            where,
            limit,
            offset: getOffset(page, limit),
            order: [['createdAt', 'DESC']],
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

    // Get projects for client (based on orgId)
    static getClientProjects = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { orgId, id: userId, role } = req.user!;
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 10;
        const search = req.query.search as string;

        const where: any = role === UserRole.CLIENT ? { clientId: userId } : { orgId };

        if (search) {
            where[Op.or] = [
                { name: { [Op.iLike]: `%${search}%` } },
                { key: { [Op.iLike]: `%${search}%` } },
            ];
        }

        const { count, rows } = await Project.findAndCountAll({
            where,
            limit,
            offset: getOffset(page, limit),
            order: [['createdAt', 'DESC']],
            include: [
                {
                    model: User,
                    as: 'lead',
                    attributes: ['id', 'firstName', 'lastName', 'email'],
                },
            ],
            attributes: ['id', 'name', 'key', 'description', 'status', 'startDate', 'endDate', 'budget'],
        });

        const projectsWithProgress = await Promise.all(rows.map(async (project) => {
            const completedIssues = await Issue.count({
                where: { projectId: project.id, status: 'DONE' }
            });
            const totalIssues = await Issue.count({
                where: { projectId: project.id }
            });

            return {
                ...project.toJSON(),
                progress: totalIssues > 0 ? Math.round((completedIssues / totalIssues) * 100) : 0,
            };
        }));

        res.json({
            success: true,
            data: {
                projects: projectsWithProgress,
                pagination: getPaginationMeta(page, limit, count),
            },
        });
    });
}
