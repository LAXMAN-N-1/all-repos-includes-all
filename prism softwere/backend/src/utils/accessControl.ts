import { Includeable } from 'sequelize';
import { AppError } from '../middleware/errorHandler';
import { Epic, Feature, Issue, Project, Sprint } from '../models';
import { AuthRequest } from '../types/interfaces';
import { UserRole } from '../types/enums';

type AuthenticatedUser = NonNullable<AuthRequest['user']>;

const getAuthenticatedUser = (req: AuthRequest): AuthenticatedUser => {
    if (!req.user) {
        throw new AppError('Authentication required', 401);
    }
    return req.user;
};

export const isClientUser = (req: AuthRequest): boolean => {
    const user = getAuthenticatedUser(req);
    return user.role === UserRole.CLIENT;
};

export const assertProjectAccess = (
    req: AuthRequest,
    project: Pick<Project, 'orgId' | 'clientId'>,
    deniedMessage = 'Access denied'
): void => {
    const user = getAuthenticatedUser(req);

    if (user.role === UserRole.CLIENT) {
        if (project.clientId !== user.id) {
            throw new AppError(deniedMessage, 403);
        }
        return;
    }

    if (project.orgId !== user.orgId) {
        throw new AppError(deniedMessage, 403);
    }
};

export const getAccessibleProject = async (
    req: AuthRequest,
    projectId: string | undefined,
    deniedMessage = 'Access denied'
): Promise<Project> => {
    if (!projectId) {
        throw new AppError('Project ID is required', 400);
    }
    const project = await Project.findByPk(projectId);
    if (!project) {
        throw new AppError('Project not found', 404);
    }

    assertProjectAccess(req, project, deniedMessage);
    return project;
};

export const getAccessibleIssue = async (
    req: AuthRequest,
    issueId: string | undefined,
    options?: {
        deniedMessage?: string;
        requireClientVisible?: boolean;
        include?: Includeable[];
    }
): Promise<Issue> => {
    if (!issueId) {
        throw new AppError('Issue ID is required', 400);
    }
    const issue = await Issue.findByPk(issueId, {
        include: options?.include ?? [
            {
                model: Project,
                as: 'project',
            },
        ],
    });

    if (!issue) {
        throw new AppError('Issue not found', 404);
    }

    const project = issue.get('project') as Project | undefined;
    if (!project) {
        const loadedProject = await Project.findByPk(issue.projectId);
        if (!loadedProject) {
            throw new AppError('Project not found', 404);
        }
        assertProjectAccess(req, loadedProject, options?.deniedMessage);
    } else {
        assertProjectAccess(req, project, options?.deniedMessage);
    }

    if (options?.requireClientVisible && isClientUser(req) && !issue.isClientVisible) {
        throw new AppError(options.deniedMessage || 'Access denied', 403);
    }

    return issue;
};

export const getAccessibleSprint = async (
    req: AuthRequest,
    sprintId: string | undefined,
    deniedMessage = 'Access denied'
): Promise<Sprint> => {
    if (!sprintId) {
        throw new AppError('Sprint ID is required', 400);
    }
    const sprint = await Sprint.findByPk(sprintId, {
        include: [
            {
                model: Project,
                as: 'project',
            },
        ],
    });

    if (!sprint) {
        throw new AppError('Sprint not found', 404);
    }

    const project = sprint.get('project') as Project | undefined;
    if (!project) {
        throw new AppError('Project not found', 404);
    }

    assertProjectAccess(req, project, deniedMessage);
    return sprint;
};

export const getAccessibleEpic = async (
    req: AuthRequest,
    epicId: string | undefined,
    deniedMessage = 'Access denied'
): Promise<Epic> => {
    if (!epicId) {
        throw new AppError('Epic ID is required', 400);
    }
    const epic = await Epic.findByPk(epicId, {
        include: [
            {
                model: Project,
                as: 'project',
            },
        ],
    });

    if (!epic) {
        throw new AppError('Epic not found', 404);
    }

    const project = epic.get('project') as Project | undefined;
    if (!project) {
        throw new AppError('Project not found', 404);
    }

    assertProjectAccess(req, project, deniedMessage);
    return epic;
};

export const getAccessibleFeature = async (
    req: AuthRequest,
    featureId: string | undefined,
    deniedMessage = 'Access denied'
): Promise<Feature> => {
    if (!featureId) {
        throw new AppError('Feature ID is required', 400);
    }
    const feature = await Feature.findByPk(featureId, {
        include: [
            {
                model: Project,
                as: 'project',
            },
        ],
    });

    if (!feature) {
        throw new AppError('Feature not found', 404);
    }

    const project = feature.get('project') as Project | undefined;
    if (!project) {
        throw new AppError('Project not found', 404);
    }

    assertProjectAccess(req, project, deniedMessage);
    return feature;
};
