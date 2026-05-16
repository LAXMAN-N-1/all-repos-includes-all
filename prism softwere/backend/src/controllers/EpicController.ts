import { Response } from 'express';
import { Op } from 'sequelize';
import { Epic, Feature, Issue, Project, User } from '../models';
import { asyncHandler, AppError } from '../middleware/errorHandler';
import { AuthRequest } from '../types/interfaces';
import { UserRole } from '../types/enums';
import { getAccessibleEpic, getAccessibleProject } from '../utils/accessControl';

export class EpicController {
    static createEpic = asyncHandler(async (req: AuthRequest, res: Response) => {
        const {
            projectId,
            name,
            description,
            startDate,
            endDate,
            status,
            priority,
            color,
            tags,
            goals,
            businessValue,
            isVisibleToClient,
        } = req.body;

        if (req.user?.role !== UserRole.ADMIN && req.user?.role !== UserRole.PROJECT_MANAGER) {
            throw new AppError('Only Project Managers and Admins can create epics', 403);
        }

        const project = await getAccessibleProject(req, projectId);

        const count = await Epic.count({ where: { projectId } });
        const key = `${project.key}-EPIC-${count + 1}`;

        const epic = await Epic.create({
            projectId,
            name,
            description,
            priority,
            status,
            startDate,
            endDate,
            color,
            ownerId: req.user!.id,
            key,
            tags: tags || [],
            goals,
            businessValue: (() => {
                const val = parseInt(String(businessValue), 10);
                if (isNaN(val)) return businessValue;
                if (val >= 70) return 'HIGH';
                if (val >= 40) return 'MEDIUM';
                return 'LOW';
            })(),
            isVisibleToClient: Boolean(isVisibleToClient),
        });

        res.status(201).json({
            message: 'Epic created successfully',
            data: epic,
        });
    });

    static getEpics = asyncHandler(async (req: AuthRequest, res: Response) => {
        const { projectId, status, search } = req.query;
        const where: any = {};
        const user = req.user!;

        if (projectId) where.projectId = projectId;
        if (status) where.status = status;
        if (search) {
            where[Op.or] = [
                { name: { [Op.iLike]: `%${search}%` } },
                { key: { [Op.iLike]: `%${search}%` } },
            ];
        }
        if (user.role === UserRole.CLIENT) {
            where.isVisibleToClient = true;
        }

        const projectWhere: any = user.role === UserRole.CLIENT
            ? { clientId: user.id }
            : { orgId: user.orgId };
        if (projectId) {
            projectWhere.id = projectId;
        }

        const epics = await Epic.findAll({
            where,
            include: [
                {
                    model: Project,
                    as: 'project',
                    attributes: ['id', 'name', 'key', 'orgId', 'clientId'],
                    where: projectWhere,
                    required: true,
                },
                { model: User, as: 'owner', attributes: ['id', 'firstName', 'lastName', 'email'] },
                {
                    model: Feature,
                    as: 'features',
                    attributes: ['id', 'name', 'status'],
                },
            ],
            order: [['createdAt', 'DESC']],
        });

        const data = epics.map(epic => {
            const features = (epic as any).features || [];
            const total = features.length;
            const completed = features.filter((f: any) => f.status === 'CLOSED' || f.status === 'DONE').length;

            return {
                ...epic.toJSON(),
                stats: {
                    totalFeatures: total,
                    completedFeatures: completed,
                    progress: total > 0 ? Math.round((completed / total) * 100) : 0,
                },
            };
        });

        res.status(200).json({ data });
    });

    static getEpicById = asyncHandler(async (req: AuthRequest, res: Response) => {
        const { id } = req.params;
        const epic = await getAccessibleEpic(req, id);

        if (req.user?.role === UserRole.CLIENT && !epic.isVisibleToClient) {
            throw new AppError('Access denied', 403);
        }

        await epic.reload({
            include: [
                {
                    model: Project,
                    as: 'project',
                    attributes: ['id', 'orgId', 'clientId'],
                },
                { model: User, as: 'owner', attributes: ['id', 'firstName', 'lastName', 'email'] },
                {
                    model: Feature,
                    as: 'features',
                    include: [
                        { model: Issue, as: 'issues', attributes: ['id', 'status', 'type'] },
                    ],
                },
            ],
        });

        const features = (epic as any).features || [];
        const totalFeatures = features.length;
        const completedFeatures = features.filter((f: any) => f.status === 'CLOSED' || f.status === 'DONE').length;

        const epicData = {
            ...epic.toJSON(),
            stats: {
                totalFeatures,
                completedFeatures,
                progress: totalFeatures > 0 ? Math.round((completedFeatures / totalFeatures) * 100) : 0,
            },
        };

        res.status(200).json({ data: epicData });
    });

    static updateEpic = asyncHandler(async (req: AuthRequest, res: Response) => {
        const { id } = req.params;
        const { name, description, status, priority, startDate, endDate, color, ownerId, goals, tags } = req.body;

        if (req.user?.role !== UserRole.ADMIN && req.user?.role !== UserRole.PROJECT_MANAGER) {
            throw new AppError('Only Project Managers and Admins can update epics', 403);
        }

        const epic = await getAccessibleEpic(req, id);
        await epic.update({
            name,
            description,
            status,
            priority,
            startDate,
            endDate,
            color,
            ownerId,
            goals,
            tags,
        });

        res.status(200).json({
            message: 'Epic updated successfully',
            data: epic,
        });
    });

    static deleteEpic = asyncHandler(async (req: AuthRequest, res: Response) => {
        const { id } = req.params;

        if (req.user?.role !== UserRole.ADMIN && req.user?.role !== UserRole.PROJECT_MANAGER) {
            throw new AppError('Only Project Managers and Admins can delete epics', 403);
        }

        const epic = await getAccessibleEpic(req, id);
        await epic.destroy();

        res.status(200).json({ message: 'Epic deleted successfully' });
    });

    static closeEpic = asyncHandler(async (req: AuthRequest, res: Response) => {
        const { id } = req.params;
        const { resolution, targetEpicId, notes } = req.body;

        if (req.user?.role !== UserRole.ADMIN && req.user?.role !== UserRole.PROJECT_MANAGER) {
            throw new AppError('Only Project Managers and Admins can close epics', 403);
        }

        const epic = await getAccessibleEpic(req, id);

        if (resolution === 'MOVE') {
            if (!targetEpicId || targetEpicId === id) {
                throw new AppError('A different target epic is required for MOVE resolution', 400);
            }
            const targetEpic = await getAccessibleEpic(req, targetEpicId);
            if (targetEpic.projectId !== epic.projectId) {
                throw new AppError('Target epic must belong to the same project', 400);
            }
        }

        const features = await Feature.findAll({
            where: { epicId: id },
        });
        const openFeatures = features.filter(
            feature => feature.status !== 'CLOSED' && feature.status !== 'DONE'
        );

        if (openFeatures.length > 0) {
            const featureIds = openFeatures.map(f => f.id);

            if (resolution === 'MOVE' && targetEpicId) {
                await Feature.update({ epicId: targetEpicId }, { where: { id: featureIds } });
            } else if (resolution === 'BACKLOG') {
                await Feature.update({ epicId: null }, { where: { id: featureIds } });
            } else if (resolution === 'CANCEL') {
                await Feature.update({ status: 'CLOSED' }, { where: { id: featureIds } });
            }
        }

        const completionNotes = notes ? `\n\n[Completion Notes]: ${notes}` : '';
        const description = `${epic.description || ''}${completionNotes}`.trim();

        await epic.update({
            status: 'CLOSED',
            description: description || epic.description,
        });

        res.status(200).json({
            message: 'Epic closed successfully',
            data: epic,
        });
    });
}
