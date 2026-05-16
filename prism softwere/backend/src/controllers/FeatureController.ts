import { Response } from 'express';
import { Epic, Feature, Issue, Project, User } from '../models';
import { asyncHandler, AppError } from '../middleware/errorHandler';
import { AuthRequest } from '../types/interfaces';
import { UserRole } from '../types/enums';
import { getAccessibleEpic, getAccessibleFeature, getAccessibleProject } from '../utils/accessControl';

export class FeatureController {
    static createFeature = asyncHandler(async (req: AuthRequest, res: Response) => {
        const {
            epicId,
            projectId,
            name,
            description,
            priority,
            startDate,
            endDate,
            storyPoints,
            color,
            ownerId,
            tags,
            acceptanceCriteria,
        } = req.body;

        const role = req.user?.role?.toUpperCase();
        if (
            role !== UserRole.ADMIN &&
            role !== UserRole.PROJECT_MANAGER &&
            role !== UserRole.SCRUM_MASTER
        ) {
            throw new AppError('Only Admins, Project Managers, and Scrum Masters can create features', 403);
        }

        if (!projectId) {
            throw new AppError('Project ID is required', 400);
        }

        const project = await getAccessibleProject(req, projectId);
        const normalizedEpicId = epicId && epicId.trim() !== '' ? epicId : null;
        if (normalizedEpicId) {
            const epic = await getAccessibleEpic(req, normalizedEpicId);
            if (epic.projectId !== project.id) {
                throw new AppError('Epic must belong to the same project', 400);
            }
        }

        const count = await Feature.count({ where: { projectId } });
        const key = `${project.key}-FEAT-${count + 1}`;

        const feature = await Feature.create({
            epicId: normalizedEpicId,
            projectId,
            name,
            description,
            priority,
            startDate: startDate || null,
            endDate: endDate || null,
            storyPoints: storyPoints || 0,
            color,
            ownerId: ownerId || null,
            key,
            status: 'TO_DO',
            tags: tags || [],
            acceptanceCriteria,
        });

        res.status(201).json({
            message: 'Feature created successfully',
            data: feature,
        });
    });

    static getFeatures = asyncHandler(async (req: AuthRequest, res: Response) => {
        const { projectId, epicId, status } = req.query;
        const user = req.user!;

        const where: any = {};
        if (projectId) where.projectId = projectId;
        if (epicId) where.epicId = epicId;
        if (status) where.status = status;

        const projectWhere: any = user.role === UserRole.CLIENT
            ? { clientId: user.id }
            : { orgId: user.orgId };
        if (projectId) {
            projectWhere.id = projectId;
        }

        const include: any[] = [
            {
                model: Project,
                as: 'project',
                attributes: ['id', 'name', 'key', 'orgId', 'clientId'],
                where: projectWhere,
                required: true,
            },
            { model: User, as: 'owner', attributes: ['id', 'firstName', 'lastName', 'email'] },
            { model: Epic, as: 'epic', attributes: ['id', 'name', 'key', 'color', 'isVisibleToClient'] },
            {
                model: Issue,
                as: 'issues',
                where: user.role === UserRole.CLIENT ? { isClientVisible: true } : undefined,
                required: false,
                attributes: ['id', 'status', 'storyPoints', 'type'],
            },
        ];

        if (user.role === UserRole.CLIENT) {
            include[2].where = { isVisibleToClient: true };
            include[2].required = false;
        }

        const features = await Feature.findAll({
            where,
            include,
            order: [['createdAt', 'DESC']],
        });

        const data = features.map(feature => {
            const issues = (feature as any).issues || [];
            const total = issues.length;
            const completed = issues.filter((i: any) => i.status === 'DONE').length;

            return {
                ...feature.toJSON(),
                stats: {
                    totalIssues: total,
                    completedIssues: completed,
                    progress: total > 0 ? Math.round((completed / total) * 100) : 0,
                },
            };
        });

        res.status(200).json({ data });
    });

    static getFeatureById = asyncHandler(async (req: AuthRequest, res: Response) => {
        const { id } = req.params;
        const feature = await getAccessibleFeature(req, id);

        if (req.user?.role === UserRole.CLIENT && feature.epicId) {
            const epic = await Epic.findByPk(feature.epicId);
            if (epic && !epic.isVisibleToClient) {
                throw new AppError('Access denied', 403);
            }
        }

        await feature.reload({
            include: [
                {
                    model: Project,
                    as: 'project',
                    attributes: ['id', 'orgId', 'clientId'],
                },
                { model: User, as: 'owner', attributes: ['id', 'firstName', 'lastName', 'email'] },
                { model: Epic, as: 'epic', attributes: ['id', 'name', 'key', 'color', 'isVisibleToClient'] },
                {
                    model: Issue,
                    as: 'issues',
                    where: req.user?.role === UserRole.CLIENT ? { isClientVisible: true } : undefined,
                    required: false,
                    include: [
                        { model: User, as: 'assignee', attributes: ['id', 'firstName', 'lastName'] },
                    ],
                },
            ],
        });

        const issues = (feature as any).issues || [];
        const total = issues.length;
        const completed = issues.filter((i: any) => i.status === 'DONE').length;

        const featureData = {
            ...feature.toJSON(),
            stats: {
                totalIssues: total,
                completedIssues: completed,
                progress: total > 0 ? Math.round((completed / total) * 100) : 0,
            },
        };

        res.status(200).json({ data: featureData });
    });

    static updateFeature = asyncHandler(async (req: AuthRequest, res: Response) => {
        const { id } = req.params;
        const {
            name,
            description,
            status,
            priority,
            startDate,
            endDate,
            storyPoints,
            color,
            ownerId,
            epicId,
            acceptanceCriteria,
        } = req.body;

        if (
            req.user?.role !== UserRole.ADMIN &&
            req.user?.role !== UserRole.PROJECT_MANAGER &&
            req.user?.role !== UserRole.SCRUM_MASTER
        ) {
            throw new AppError('Only Admins, Project Managers, and Scrum Masters can update features', 403);
        }

        const feature = await getAccessibleFeature(req, id);
        if (epicId) {
            const epic = await getAccessibleEpic(req, epicId);
            if (epic.projectId !== feature.projectId) {
                throw new AppError('Epic must belong to the same project', 400);
            }
        }

        await feature.update({
            name,
            description,
            status,
            priority,
            startDate,
            endDate,
            storyPoints,
            color,
            ownerId,
            epicId,
            acceptanceCriteria,
        });

        res.status(200).json({
            message: 'Feature updated successfully',
            data: feature,
        });
    });

    static deleteFeature = asyncHandler(async (req: AuthRequest, res: Response) => {
        const { id } = req.params;

        if (
            req.user?.role !== UserRole.ADMIN &&
            req.user?.role !== UserRole.PROJECT_MANAGER &&
            req.user?.role !== UserRole.SCRUM_MASTER
        ) {
            throw new AppError('Only Admins, Project Managers, and Scrum Masters can delete features', 403);
        }

        const feature = await getAccessibleFeature(req, id);
        await feature.destroy();

        res.status(200).json({ message: 'Feature deleted successfully' });
    });
}
