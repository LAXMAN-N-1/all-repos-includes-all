#!/usr/bin/env node

require('ts-node/register/transpile-only');

const fs = require('fs');
const path = require('path');
const ts = require('typescript');
const request = require('supertest');
const { QueryTypes } = require('sequelize');

process.env.NODE_ENV = process.env.NODE_ENV || 'test';
process.env.DB_HOST = process.env.DB_HOST || '127.0.0.1';
process.env.DB_PORT = process.env.DB_PORT || '5432';
process.env.DB_NAME = process.env.DB_NAME || 'project_management';
process.env.DB_SSL = process.env.DB_SSL || 'false';

const app = require('../src/server').default;
const sequelize = require('../src/config/database').default;
const {
    User,
    Organization,
    Project,
    ProjectMember,
    Issue,
    Sprint,
    Epic,
    Feature,
    Milestone,
    WorkLog,
    Notification,
    Attachment,
    AuditLog,
    Attendance,
    LeaveRequest,
    EmployeeDetails,
    Settings,
} = require('../src/models');
const IssueLinkModel = require('../src/models/IssueLink').default;
const { AuthService } = require('../src/services/authService');

const API_VERSION = process.env.API_VERSION || 'v1';
const HTTP_METHODS = new Set(['get', 'post', 'put', 'patch', 'delete']);
const METHOD_ORDER = new Map([
    ['GET', 1],
    ['POST', 2],
    ['PUT', 3],
    ['PATCH', 4],
    ['DELETE', 5],
]);
const INVALID_UUID = 'not-a-uuid';

const PUBLIC_ROUTES = new Set([
    `/api/${API_VERSION}`,
    `/api/${API_VERSION}/auth/login`,
    `/api/${API_VERSION}/auth/refresh-token`,
    `/api/${API_VERSION}/auth/forgot-password`,
    `/api/${API_VERSION}/auth/reset-password`,
]);

const CROSS_ORG_STATUS_CODES = new Set([403, 404]);
const toRouteKey = (method, routePath) => `${method.toUpperCase()} ${routePath}`;
const CROSS_ORG_BODY_ROUTE_KEYS = new Set([
    toRouteKey('POST', `/api/${API_VERSION}/issues`),
    toRouteKey('POST', `/api/${API_VERSION}/issues/create-story`),
    toRouteKey('POST', `/api/${API_VERSION}/issues/create-subtask`),
    toRouteKey('POST', `/api/${API_VERSION}/issues/assign-sprint`),
    toRouteKey('POST', `/api/${API_VERSION}/sprints`),
    toRouteKey('POST', `/api/${API_VERSION}/epics`),
    toRouteKey('POST', `/api/${API_VERSION}/features`),
    toRouteKey('POST', `/api/${API_VERSION}/time/time-entries`),
]);
const CROSS_ORG_QUERY_ROUTE_KEYS = new Set([
    toRouteKey('GET', `/api/${API_VERSION}/analytics/velocity`),
    toRouteKey('GET', `/api/${API_VERSION}/analytics/team-performance`),
]);

const CROSS_ORG_PREFIXES = [
    `projects`,
    `issues`,
    `sprints`,
    `epics`,
    `features`,
    `milestones`,
    `client/projects`,
    `users`,
    `attendance/employee`,
    `leaves`,
    `notifications`,
    `time/time-entries`,
    `analytics`,
];

let uniqueCounter = 0;
const nextUnique = (prefix) => `${prefix}-${Date.now()}-${++uniqueCounter}`;

const normalizePath = (...parts) => {
    const joined = parts.filter(Boolean).join('/');
    const normalized = joined.replace(/\/+/g, '/').replace(/\/$/, '');
    return normalized || '/';
};

const getLine = (sourceFile, node) => sourceFile.getLineAndCharacterOfPosition(node.getStart()).line + 1;

const getLiteralArg = (arg) => {
    if (!arg) return null;
    if (ts.isStringLiteral(arg) || ts.isNoSubstitutionTemplateLiteral(arg)) return arg.text;
    return null;
};

const collectRouterCalls = (sourceFile) => {
    const calls = [];

    const visit = (node) => {
        if (ts.isCallExpression(node) && ts.isPropertyAccessExpression(node.expression)) {
            const objectExpr = node.expression.expression;
            const property = node.expression.name.text;
            if (ts.isIdentifier(objectExpr) && objectExpr.text === 'router') {
                calls.push({
                    method: property,
                    args: node.arguments,
                    line: getLine(sourceFile, node),
                });
            }
        }
        ts.forEachChild(node, visit);
    };

    visit(sourceFile);
    return calls;
};

const collectImportMap = (sourceFile) => {
    const importMap = new Map();

    for (const statement of sourceFile.statements) {
        if (!ts.isImportDeclaration(statement) || !statement.importClause || !statement.importClause.name) {
            continue;
        }

        if (!ts.isStringLiteral(statement.moduleSpecifier)) {
            continue;
        }

        const modulePath = statement.moduleSpecifier.text;
        if (!modulePath.startsWith('./')) {
            continue;
        }

        importMap.set(statement.importClause.name.text, modulePath.replace('./', ''));
    }

    return importMap;
};

const parseRoutesFromFile = (filePath, mountPath) => {
    if (!fs.existsSync(filePath)) {
        return [];
    }

    const content = fs.readFileSync(filePath, 'utf8');
    const sourceFile = ts.createSourceFile(filePath, content, ts.ScriptTarget.Latest, true, ts.ScriptKind.TS);
    const calls = collectRouterCalls(sourceFile);

    const routes = [];
    for (const call of calls) {
        if (!HTTP_METHODS.has(call.method)) {
            continue;
        }

        const routePath = getLiteralArg(call.args[0]);
        if (!routePath) {
            continue;
        }

        const relativePath = routePath === '/' ? '' : routePath;
        const fullPath = normalizePath(`/api/${API_VERSION}`, mountPath, relativePath);
        routes.push({
            method: call.method.toUpperCase(),
            path: fullPath,
            source: `${path.relative(process.cwd(), filePath)}:${call.line}`,
        });
    }

    return routes;
};

const parseRouteInventory = () => {
    const routesDir = path.join(__dirname, '..', 'src', 'routes');
    const indexPath = path.join(routesDir, 'index.ts');
    const indexContent = fs.readFileSync(indexPath, 'utf8');
    const indexSource = ts.createSourceFile(indexPath, indexContent, ts.ScriptTarget.Latest, true, ts.ScriptKind.TS);

    const importMap = collectImportMap(indexSource);
    const calls = collectRouterCalls(indexSource);

    const mountedRouters = [];
    const rootRoutes = [];

    for (const call of calls) {
        if (call.method === 'use') {
            const mountPath = getLiteralArg(call.args[0]);
            const routerArg = call.args[1];
            if (!mountPath || !routerArg || !ts.isIdentifier(routerArg)) {
                continue;
            }
            const routeFile = importMap.get(routerArg.text);
            if (!routeFile) {
                continue;
            }
            mountedRouters.push({ mountPath, routeFile });
            continue;
        }

        if (!HTTP_METHODS.has(call.method)) {
            continue;
        }

        const routePath = getLiteralArg(call.args[0]);
        if (!routePath) {
            continue;
        }

        const relativePath = routePath === '/' ? '' : routePath;
        rootRoutes.push({
            method: call.method.toUpperCase(),
            path: normalizePath(`/api/${API_VERSION}`, relativePath),
            source: `${path.relative(process.cwd(), indexPath)}:${call.line}`,
        });
    }

    const discovered = [...rootRoutes];

    for (const mount of mountedRouters) {
        const routeFilePath = path.join(routesDir, `${mount.routeFile}.ts`);
        discovered.push(...parseRoutesFromFile(routeFilePath, mount.mountPath));
    }

    const unique = new Map();
    for (const route of discovered) {
        const key = `${route.method} ${route.path}`;
        if (!unique.has(key)) {
            unique.set(key, route);
        }
    }

    return Array.from(unique.values()).sort((a, b) => {
        if (a.path === b.path) {
            return (METHOD_ORDER.get(a.method) ?? 99) - (METHOD_ORDER.get(b.method) ?? 99);
        }

        if (a.path.startsWith(`${b.path}/`)) {
            return -1;
        }

        if (b.path.startsWith(`${a.path}/`)) {
            return 1;
        }

        return a.path.localeCompare(b.path);
    });
};

const isProtectedRoute = (routePath) => !PUBLIC_ROUTES.has(routePath);

const routeStartsWith = (routePath, suffix) => routePath.startsWith(`/api/${API_VERSION}/${suffix}`);

const hasPathParam = (routePath) => routePath.includes('/:');
const hasTenantPrefix = (routePath) => CROSS_ORG_PREFIXES.some((prefix) => routeStartsWith(routePath, prefix));

const isCrossOrgCapableRoute = (route) => {
    const routeKey = toRouteKey(route.method, route.path);

    if (!isProtectedRoute(route.path)) {
        return false;
    }

    if (CROSS_ORG_BODY_ROUTE_KEYS.has(routeKey) || CROSS_ORG_QUERY_ROUTE_KEYS.has(routeKey)) {
        return true;
    }

    if (!hasTenantPrefix(route.path) || !hasPathParam(route.path)) {
        return false;
    }

    if (route.path.endsWith('/settings/:key')) {
        return false;
    }

    if (route.path.endsWith('/time/time-entries/summary/:period')) {
        return false;
    }

    return true;
};

const buildPathParams = (routePath, mode, ctx) => {
    const scopedCtx = mode === 'crossOrg' ? ctx.otherOrg : ctx;

    return routePath.replace(/:([A-Za-z0-9_]+)/g, (_full, rawKey) => {
        const key = String(rawKey).toLowerCase();

        if (mode === 'validation') {
            if (key === 'period') return 'bad-period';
            if (key === 'key') return 'invalid key';
            return INVALID_UUID;
        }

        if (key === 'period') return 'weekly';
        if (key === 'key') return 'ui.theme';
        if (key === 'projectid') {
            if (routePath.includes('/files') || routePath.includes('/attachments')) {
                return scopedCtx.uploadProject.id;
            }
            return scopedCtx.project.id;
        }
        if (key === 'sprintid') return scopedCtx.sprint.id;
        if (key === 'issueid') return routePath.includes('/attachments') ? scopedCtx.uploadIssue.id : scopedCtx.issue.id;
        if (key === 'epicid') return scopedCtx.epic.id;
        if (key === 'featureid') return scopedCtx.feature.id;
        if (key === 'userid') return scopedCtx.users.employee.id;
        if (key === 'fileid') {
            if (routeStartsWith(routePath, 'projects/')) return scopedCtx.projectFileId;
            return scopedCtx.issueAttachmentId;
        }
        if (key === 'linkid') return scopedCtx.linkId;

        if (key === 'id') {
            if (routeStartsWith(routePath, 'users/')) return scopedCtx.users.employee.id;
            if (routeStartsWith(routePath, 'projects/') && (routePath.includes('/attachments') || routePath.includes('/files'))) return scopedCtx.uploadProject.id;
            if (routeStartsWith(routePath, 'projects/')) return scopedCtx.project.id;
            if (routeStartsWith(routePath, 'issues/attachments/')) return scopedCtx.issueAttachmentId;
            if (routeStartsWith(routePath, 'issues/')) return scopedCtx.issue.id;
            if (routeStartsWith(routePath, 'sprints/') && routePath.endsWith('/complete')) return scopedCtx.activeSprint.id;
            if (routeStartsWith(routePath, 'sprints/')) return scopedCtx.sprint.id;
            if (routeStartsWith(routePath, 'epics/')) return scopedCtx.epic.id;
            if (routeStartsWith(routePath, 'features/')) return scopedCtx.feature.id;
            if (routeStartsWith(routePath, 'milestones/')) return scopedCtx.milestone.id;
            if (routeStartsWith(routePath, 'notifications/')) return scopedCtx.notification.id;
            if (routeStartsWith(routePath, 'attendance/')) return scopedCtx.attendance.id;
            if (routeStartsWith(routePath, 'leaves/')) return scopedCtx.leaveRequest.id;
            if (routeStartsWith(routePath, 'time/time-entries/')) return scopedCtx.workLog.id;
            if (routeStartsWith(routePath, 'client/projects/')) return scopedCtx.project.id;
            return scopedCtx.issue.id;
        }

        return scopedCtx.issue.id;
    });
};

const isUploadRoute = (routePath) => routePath.includes('/attachments') || routePath.includes('/files');

const buildBody = (method, routePath, probe, ctx) => {
    if (method === 'GET' || method === 'DELETE') {
        return undefined;
    }

    if (probe === 'validation') {
        if (routePath.endsWith('/auth/login')) {
            return { email: 'invalid-email', password: '' };
        }
        if (routePath.endsWith('/auth/refresh-token')) {
            return {};
        }
        if (routePath.endsWith('/auth/forgot-password')) {
            return { email: 'invalid-email' };
        }
        if (routePath.endsWith('/auth/reset-password')) {
            return { token: '', newPassword: 'short' };
        }
        if (routePath.endsWith('/auth/change-password')) {
            return { oldPassword: '', newPassword: 'short' };
        }
        if (routePath.endsWith('/settings/test-email')) {
            return { host: '', to: 'invalid' };
        }
        return {};
    }

    const scopedCtx = probe === 'crossOrg' ? ctx.otherOrg : ctx;

    // Auth
    if (routePath.endsWith('/auth/login')) {
        return { email: ctx.users.admin.email, password: ctx.password };
    }
    if (routePath.endsWith('/auth/refresh-token')) {
        return { refreshToken: ctx.refreshToken };
    }
    if (routePath.endsWith('/auth/forgot-password')) {
        return { email: ctx.users.admin.email };
    }
    if (routePath.endsWith('/auth/reset-password')) {
        return { token: ctx.resetToken, newPassword: 'password123' };
    }
    if (routePath.endsWith('/auth/change-password')) {
        return { oldPassword: ctx.password, newPassword: ctx.password };
    }

    // Users
    if (routePath === `/api/${API_VERSION}/users` && method === 'POST') {
        return {
            email: `${nextUnique('user')}@test.local`,
            password: 'password123',
            firstName: 'Sweep',
            lastName: 'User',
            role: 'EMPLOYEE',
        };
    }
    if (routeStartsWith(routePath, 'users/') && method === 'PUT') {
        return { firstName: 'Updated', lastName: 'User' };
    }
    if (routePath.endsWith('/users/bulk')) {
        return {
            users: [
                {
                    email: `${nextUnique('bulk')}@test.local`,
                    firstName: 'Bulk',
                    lastName: 'User',
                },
            ],
        };
    }
    if (routePath.endsWith('/users/bulk-action')) {
        return { userIds: [scopedCtx.users.employee.id], action: 'ACTIVATE' };
    }
    if (routePath.endsWith('/change-password')) {
        return { currentPassword: ctx.password, newPassword: 'password123' };
    }

    // Projects
    if (routePath === `/api/${API_VERSION}/projects` && method === 'POST') {
        return {
            name: `Sweep Project ${uniqueCounter + 1}`,
            key: `SP${String((uniqueCounter + 1) % 10000).padStart(2, '0')}`,
            description: 'Created by API sweep',
            leadId: scopedCtx.users.admin.id,
            projectManagerId: scopedCtx.users.projectManager.id,
            scrumMasterId: scopedCtx.users.scrumMaster.id,
            clientId: scopedCtx.users.client.id,
            visibility: 'PRIVATE',
            usesEpics: true,
            usesSprints: true,
            type: 'SCRUM',
        };
    }
    if (routeStartsWith(routePath, 'projects/') && method === 'PUT') {
        return { name: 'Updated Project Name' };
    }
    if (routePath.endsWith('/members') && method === 'POST') {
        return { userId: scopedCtx.users.outsider.id, role: 'MEMBER' };
    }

    // Issues
    if (routePath === `/api/${API_VERSION}/issues` && method === 'POST') {
        return {
            projectId: scopedCtx.project.id,
            title: `Sweep Issue ${uniqueCounter + 1}`,
            type: 'TASK',
            priority: 'MEDIUM',
            assigneeId: scopedCtx.users.employee.id,
            reporterId: scopedCtx.users.admin.id,
        };
    }
    if (routePath.endsWith('/issues/create-story')) {
        return {
            projectId: scopedCtx.project.id,
            epicId: scopedCtx.epic.id,
            title: `Story ${uniqueCounter + 1}`,
            description: 'Story from sweep',
            assigneeId: scopedCtx.users.employee.id,
            storyPoints: 3,
        };
    }
    if (routePath.endsWith('/issues/create-subtask')) {
        return {
            parentId: scopedCtx.issue.id,
            title: `Subtask ${uniqueCounter + 1}`,
            description: 'Subtask from sweep',
        };
    }
    if (routePath.endsWith('/issues/assign-sprint')) {
        return { issueIds: [scopedCtx.issue.id], sprintId: scopedCtx.sprint.id };
    }
    if (routePath.endsWith('/client-approval')) {
        return { status: 'APPROVED', feedback: 'Looks good' };
    }
    if (routePath.endsWith('/move-to-sprint')) {
        return { sprintId: scopedCtx.sprint.id };
    }
    if (routeStartsWith(routePath, 'issues/') && routePath.endsWith('/status')) {
        return { status: 'IN_PROGRESS' };
    }
    if (routePath.endsWith('/links')) {
        return { targetIssueId: scopedCtx.linkCandidateIssue.id, type: 'RELATES_TO' };
    }
    if (routePath.endsWith('/comments')) {
        return { content: 'Sweep comment', isClientVisible: true };
    }
    if (routePath.endsWith('/worklog')) {
        return {
            timeSpent: 1,
            date: new Date().toISOString(),
            description: 'Sweep work log',
        };
    }
    if (routeStartsWith(routePath, 'issues/') && method === 'PUT') {
        return { title: 'Updated issue title' };
    }

    // Sprints
    if (routePath === `/api/${API_VERSION}/sprints` && method === 'POST') {
        const startDate = new Date();
        const endDate = new Date(startDate.getTime() + 7 * 24 * 60 * 60 * 1000);
        return {
            projectId: scopedCtx.project.id,
            name: `Sweep Sprint ${uniqueCounter + 1}`,
            startDate: startDate.toISOString(),
            endDate: endDate.toISOString(),
            goal: 'Sweep sprint goal',
        };
    }
    if (routeStartsWith(routePath, 'sprints/') && method === 'PUT') {
        return { name: 'Updated sprint name' };
    }

    // Epics / Features
    if (routePath === `/api/${API_VERSION}/epics` && method === 'POST') {
        return {
            projectId: scopedCtx.project.id,
            name: `Sweep Epic ${uniqueCounter + 1}`,
            ownerId: scopedCtx.users.projectManager.id,
        };
    }
    if (routeStartsWith(routePath, 'epics/') && method === 'PUT') {
        return { name: 'Updated epic name' };
    }
    if (routePath === `/api/${API_VERSION}/features` && method === 'POST') {
        return {
            projectId: scopedCtx.project.id,
            name: `Sweep Feature ${uniqueCounter + 1}`,
            ownerId: scopedCtx.users.projectManager.id,
        };
    }
    if (routeStartsWith(routePath, 'features/') && method === 'PUT') {
        return { name: 'Updated feature name' };
    }

    // Milestones
    if (routePath.includes('/milestones') && method === 'POST') {
        return {
            name: `Sweep Milestone ${uniqueCounter + 1}`,
            description: 'Created by API sweep',
            status: 'UPCOMING',
            dueDate: new Date().toISOString(),
        };
    }
    if (routePath.includes('/milestones') && method === 'PATCH') {
        return {
            name: 'Updated milestone',
            status: 'IN_PROGRESS',
        };
    }

    // Time tracking
    if (routePath.endsWith('/time/time-entries') && method === 'POST') {
        return {
            issueId: scopedCtx.issue.id,
            timeSpent: 1.5,
            date: new Date().toISOString(),
            description: 'Sweep time entry',
        };
    }
    if (routeStartsWith(routePath, 'time/time-entries/') && method === 'PUT') {
        return {
            timeSpent: 2,
            description: 'Updated sweep entry',
        };
    }

    // Leaves
    if (routePath.endsWith('/leaves/apply')) {
        const today = new Date().toISOString().slice(0, 10);
        return {
            leaveType: 'Annual',
            startDate: today,
            endDate: today,
            daysCount: 1,
            reason: 'Sweep leave request',
            contactNumber: '9999999999',
        };
    }
    if (routePath.includes('/leaves/') && routePath.endsWith('/status')) {
        return { status: 'Approved' };
    }

    // Attendance
    if (routePath.endsWith('/attendance/check-in')) {
        return { workLocation: 'Office', notes: 'Sweep check-in' };
    }
    if (routePath.includes('/attendance/') && routePath.endsWith('/status')) {
        return { status: 'Approved' };
    }

    // Notifications
    if (routePath.endsWith('/read')) {
        return {};
    }

    // Settings
    if (routePath.startsWith(`/api/${API_VERSION}/settings/`) && method === 'PUT') {
        return {
            value: { enabled: true, updatedAt: new Date().toISOString() },
            description: 'Updated by API sweep',
        };
    }
    if (routePath.endsWith('/settings/test-email')) {
        return {
            host: 'smtp.example.com',
            port: 587,
            user: 'sweep@example.com',
            pass: 'example-password',
            from: 'sweep@example.com',
            to: 'recipient@example.com',
        };
    }

    // Portal settings
    if (routePath.endsWith('/portal-settings') && method === 'PUT') {
        return {
            clientPortalEnabled: true,
            defaultTaskVisibility: false,
            allowClientFileUpload: true,
            maxFileUploadSizeMB: 10,
            emailNotificationsEnabled: true,
            requireApprovalForTasks: false,
        };
    }

    return {};
};

const chooseHappyToken = (routePath, ctx) => {
    if (!isProtectedRoute(routePath)) {
        return null;
    }

    if (routeStartsWith(routePath, 'client/')) return ctx.tokens.client;
    if (routePath.endsWith('/client-approval')) return ctx.tokens.client;
    if (routePath.endsWith('/attendance/check-in')) {
        return ctx.tokens.scrumMaster;
    }
    if (routePath.endsWith('/attendance/check-out') || routePath.endsWith('/attendance/my-attendance')) {
        return ctx.tokens.employee;
    }
    if (routeStartsWith(routePath, 'leaves/apply') || routePath.endsWith('/leaves/my-leaves') || routePath.endsWith('/leaves/my-balances')) {
        return ctx.tokens.employee;
    }
    if (routeStartsWith(routePath, 'notifications')) return ctx.tokens.employee;
    if (routeStartsWith(routePath, 'time/')) return ctx.tokens.employee;

    return ctx.tokens.admin;
};

const chooseAuthzFailureToken = (routePath, ctx) => {
    if (!isProtectedRoute(routePath)) {
        return null;
    }

    if (routeStartsWith(routePath, 'client/')) return ctx.tokens.admin;
    if (routePath.endsWith('/attendance') || routePath.includes('/attendance/employee/') || routePath.endsWith('/attendance/:id/status')) {
        return ctx.tokens.employee;
    }
    if (routePath.endsWith('/leaves') || routePath.includes('/leaves/') && routePath.endsWith('/status')) {
        return ctx.tokens.employee;
    }
    if (routeStartsWith(routePath, 'settings') || routeStartsWith(routePath, 'portal-settings') || routeStartsWith(routePath, 'audit-logs')) {
        return ctx.tokens.employee;
    }

    return null;
};

const chooseCrossOrgToken = (routePath, ctx) => chooseHappyToken(routePath, ctx);

const buildQuery = (method, routePath, probe, ctx) => {
    const routeKey = toRouteKey(method, routePath);

    if (method !== 'GET') {
        return undefined;
    }

    if (routePath.endsWith('/analytics/export')) {
        if (probe === 'validation') {
            return { type: 'invalid' };
        }
        return { type: 'issues' };
    }

    if (probe === 'validation') {
        if (CROSS_ORG_QUERY_ROUTE_KEYS.has(routeKey)) {
            return { projectId: INVALID_UUID };
        }
    }

    if (probe === 'crossOrg') {
        if (CROSS_ORG_QUERY_ROUTE_KEYS.has(routeKey)) {
            return { projectId: ctx.otherOrg.project.id };
        }
    }

    return undefined;
};

const sendRequest = async ({ method, reqPath, routePath, body, query, token, isValidationProbe }) => {
    let req = request(app)[method.toLowerCase()](reqPath);

    if (token) {
        req = req.set('Authorization', `Bearer ${token}`);
    }

    if (query) {
        req = req.query(query);
    }

    if (isUploadRoute(routePath) && method === 'POST' && !isValidationProbe) {
        req = req.field('description', 'Sweep upload').attach('file', Buffer.from('sweep-file-content'), 'sweep.txt');
        return req;
    }

    if (body !== undefined) {
        req = req.send(body);
    }

    return req;
};

const ensureSettingsTable = async () => {
    try {
        await Settings.sync();
    } catch (_error) {
        // If this fails, sweep will still run and report endpoints as needed.
    }
};

const ensureCanonicalIssueSchema = async () => {
    const issueTable = await sequelize.getQueryInterface().describeTable('Issues');
    const requiredColumns = ['epic_id', 'feature_id', 'order_index', 'is_client_visible', 'client_approval_status'];
    const missingColumns = requiredColumns.filter((column) => !issueTable[column]);

    if (missingColumns.length > 0) {
        throw new Error(`Missing canonical Issues schema columns: ${missingColumns.join(', ')}. Run migrations before audit.`);
    }
};

const ensureAttachmentSchema = async () => {
    const attachmentTable = await sequelize.getQueryInterface().describeTable('Attachments');
    if (attachmentTable.issueId && attachmentTable.issueId.allowNull === false) {
        throw new Error('Attachments.issueId must be nullable. Run migrations before audit.');
    }
};

const resetDatabase = async () => {
    await sequelize.authenticate();

    const tables = await sequelize.query(
        `SELECT tablename
         FROM pg_tables
         WHERE schemaname = 'public'
           AND tablename <> 'SequelizeMeta'`,
        { type: QueryTypes.SELECT }
    );

    if (tables.length === 0) {
        return;
    }

    const tableNames = tables.map((t) => `"${t.tablename}"`).join(', ');
    await sequelize.query(`TRUNCATE TABLE ${tableNames} RESTART IDENTITY CASCADE;`);
};

const createUser = async ({ email, username, role, orgId, password }) => {
    const user = await User.create({
        email,
        username,
        passwordHash: 'placeholder',
        firstName: role,
        lastName: 'Sweep',
        role,
        orgId,
        profileData: {},
        mfaEnabled: false,
        isActive: true,
    });

    await user.setPassword(password);
    await user.save();
    return user;
};

const buildOrgFixtures = async ({ password, orgName, suffix, keyPrefix, issueAttachmentId, projectFileId }) => {
    const org = await Organization.create({
        name: orgName,
        subscriptionPlan: 'FREE',
        maxUsers: 50,
        ssoEnabled: false,
        settings: {},
    });

    const users = {
        admin: await createUser({
            email: `sweep-${suffix}-admin@test.local`,
            username: `sweep${suffix}admin`,
            role: 'ADMIN',
            orgId: org.id,
            password,
        }),
        scrumMaster: await createUser({
            email: `sweep-${suffix}-sm@test.local`,
            username: `sweep${suffix}sm`,
            role: 'SCRUM_MASTER',
            orgId: org.id,
            password,
        }),
        projectManager: await createUser({
            email: `sweep-${suffix}-pm@test.local`,
            username: `sweep${suffix}pm`,
            role: 'PROJECT_MANAGER',
            orgId: org.id,
            password,
        }),
        employee: await createUser({
            email: `sweep-${suffix}-employee@test.local`,
            username: `sweep${suffix}employee`,
            role: 'EMPLOYEE',
            orgId: org.id,
            password,
        }),
        client: await createUser({
            email: `sweep-${suffix}-client@test.local`,
            username: `sweep${suffix}client`,
            role: 'CLIENT',
            orgId: org.id,
            password,
        }),
        outsider: await createUser({
            email: `sweep-${suffix}-outsider@test.local`,
            username: `sweep${suffix}outsider`,
            role: 'EMPLOYEE',
            orgId: org.id,
            password,
        }),
    };

    await EmployeeDetails.create({
        userId: users.employee.id,
        department: 'Engineering',
        designation: 'Developer',
        employeeId: `${keyPrefix}-EMP-001`,
        dateOfJoining: '2024-01-01',
        employmentType: 'Full-time',
        reportingManagerId: users.projectManager.id,
        workLocation: 'Hybrid',
        officeLocation: 'HQ',
        shiftTiming: '09:00-18:00',
        annualLeaveBalance: 20,
        sickLeaveBalance: 10,
        casualLeaveBalance: 5,
        otherLeaveBalance: 5,
    });

    const project = await Project.create({
        name: `Sweep Project ${suffix.toUpperCase()}`,
        key: keyPrefix,
        description: `Project for API sweep (${suffix})`,
        orgId: org.id,
        leadId: users.admin.id,
        clientId: users.client.id,
        projectManagerId: users.projectManager.id,
        scrumMasterId: users.scrumMaster.id,
        settings: {},
        clientConfig: { showBudget: false, allowTaskCreation: false },
        status: 'ACTIVE',
        visibility: 'PRIVATE',
        usesEpics: true,
        usesSprints: true,
        type: 'SCRUM',
    });

    const uploadProject = await Project.create({
        name: `Sweep Upload Project ${suffix.toUpperCase()}`,
        key: `${keyPrefix}U`,
        description: `Attachment target project (${suffix})`,
        orgId: org.id,
        leadId: users.admin.id,
        clientId: users.client.id,
        projectManagerId: users.projectManager.id,
        scrumMasterId: users.scrumMaster.id,
        settings: {},
        clientConfig: { showBudget: false, allowTaskCreation: false },
        status: 'ACTIVE',
        visibility: 'PRIVATE',
        usesEpics: true,
        usesSprints: true,
        type: 'SCRUM',
    });

    const activeSprintProject = await Project.create({
        name: `Sweep Active Sprint Project ${suffix.toUpperCase()}`,
        key: `${keyPrefix}S`,
        description: `Active sprint project (${suffix})`,
        orgId: org.id,
        leadId: users.admin.id,
        clientId: users.client.id,
        projectManagerId: users.projectManager.id,
        scrumMasterId: users.scrumMaster.id,
        settings: {},
        clientConfig: { showBudget: false, allowTaskCreation: false },
        status: 'ACTIVE',
        visibility: 'PRIVATE',
        usesEpics: true,
        usesSprints: true,
        type: 'SCRUM',
    });

    await ProjectMember.bulkCreate([
        { projectId: project.id, userId: users.admin.id, role: 'LEAD' },
        { projectId: project.id, userId: users.scrumMaster.id, role: 'SCRUM_MASTER' },
        { projectId: project.id, userId: users.projectManager.id, role: 'PROJECT_MANAGER' },
        { projectId: project.id, userId: users.employee.id, role: 'MEMBER' },
        { projectId: project.id, userId: users.client.id, role: 'CLIENT' },
    ]);

    const sprintStart = new Date();
    const sprintEnd = new Date(sprintStart.getTime() + 14 * 24 * 60 * 60 * 1000);
    const sprint = await Sprint.create({
        projectId: project.id,
        name: `Sweep Sprint ${suffix.toUpperCase()}`,
        startDate: sprintStart,
        endDate: sprintEnd,
        status: 'PLANNED',
    });

    const activeSprint = await Sprint.create({
        projectId: activeSprintProject.id,
        name: `Sweep Active Sprint ${suffix.toUpperCase()}`,
        startDate: sprintStart,
        endDate: sprintEnd,
        status: 'ACTIVE',
    });

    const epic = await Epic.create({
        projectId: project.id,
        name: `Sweep Epic ${suffix.toUpperCase()}`,
        ownerId: users.projectManager.id,
        status: 'OPEN',
        priority: 'MEDIUM',
        tags: [],
    });

    const feature = await Feature.create({
        projectId: project.id,
        epicId: epic.id,
        name: `Sweep Feature ${suffix.toUpperCase()}`,
        ownerId: users.projectManager.id,
        status: 'TO_DO',
        priority: 'MEDIUM',
        tags: [],
    });

    const issue = await Issue.create({
        projectId: project.id,
        issueNumber: 1,
        key: `${keyPrefix}-1`,
        type: 'TASK',
        status: 'TODO',
        priority: 'MEDIUM',
        title: `Sweep seeded issue ${suffix.toUpperCase()}`,
        assigneeId: users.employee.id,
        reporterId: users.admin.id,
        sprintId: sprint.id,
        epicId: epic.id,
        featureId: feature.id,
        orderIndex: 0,
        labels: [],
        customFields: {},
        isClientVisible: true,
    });

    const linkTargetIssue = await Issue.create({
        projectId: project.id,
        issueNumber: 2,
        key: `${keyPrefix}-2`,
        type: 'TASK',
        status: 'TODO',
        priority: 'MEDIUM',
        title: `Sweep link target issue ${suffix.toUpperCase()}`,
        assigneeId: users.employee.id,
        reporterId: users.admin.id,
        sprintId: sprint.id,
        epicId: epic.id,
        featureId: feature.id,
        orderIndex: 1,
        labels: [],
        customFields: {},
        isClientVisible: true,
    });

    const linkCandidateIssue = await Issue.create({
        projectId: project.id,
        issueNumber: 3,
        key: `${keyPrefix}-3`,
        type: 'TASK',
        status: 'TODO',
        priority: 'MEDIUM',
        title: `Sweep link candidate issue ${suffix.toUpperCase()}`,
        assigneeId: users.employee.id,
        reporterId: users.admin.id,
        sprintId: sprint.id,
        epicId: epic.id,
        featureId: feature.id,
        orderIndex: 2,
        labels: [],
        customFields: {},
        isClientVisible: true,
    });

    const uploadIssue = await Issue.create({
        projectId: uploadProject.id,
        issueNumber: 1,
        key: `${keyPrefix}U-1`,
        type: 'TASK',
        status: 'TODO',
        priority: 'MEDIUM',
        title: `Sweep upload issue ${suffix.toUpperCase()}`,
        assigneeId: users.employee.id,
        reporterId: users.admin.id,
        orderIndex: 0,
        labels: [],
        customFields: {},
        isClientVisible: true,
    });

    const seededLink = await IssueLinkModel.create({
        sourceIssueId: issue.id,
        targetIssueId: linkTargetIssue.id,
        type: 'RELATES_TO',
    });

    const uploadsDir = path.join(process.cwd(), 'uploads');
    fs.mkdirSync(uploadsDir, { recursive: true });
    const issueAttachmentName = `sweep-issue-${suffix}.txt`;
    const projectFileName = `sweep-project-${suffix}.txt`;
    const issueAttachmentPath = path.join(uploadsDir, issueAttachmentName);
    const projectFilePath = path.join(uploadsDir, projectFileName);
    fs.writeFileSync(issueAttachmentPath, `seed issue attachment ${suffix}`);
    fs.writeFileSync(projectFilePath, `seed project file ${suffix}`);

    await Attachment.create({
        id: issueAttachmentId,
        issueId: uploadIssue.id,
        projectId: null,
        userId: users.employee.id,
        filename: issueAttachmentName,
        originalName: `issue-${suffix}.txt`,
        mimetype: 'text/plain',
        size: Buffer.byteLength(`seed issue attachment ${suffix}`),
        path: issueAttachmentPath,
        fileUrl: `/uploads/${issueAttachmentName}`,
    });

    await Attachment.create({
        id: projectFileId,
        issueId: null,
        projectId: uploadProject.id,
        userId: users.employee.id,
        filename: projectFileName,
        originalName: `project-${suffix}.txt`,
        mimetype: 'text/plain',
        size: Buffer.byteLength(`seed project file ${suffix}`),
        path: projectFilePath,
        fileUrl: `/uploads/${projectFileName}`,
    });

    const milestone = await Milestone.create({
        projectId: project.id,
        name: `Sweep milestone ${suffix.toUpperCase()}`,
        status: 'UPCOMING',
        tasksTotal: 0,
        tasksCompleted: 0,
    });

    const workLog = await WorkLog.create({
        issueId: issue.id,
        userId: users.employee.id,
        timeSpent: 1,
        date: new Date(),
        description: `Seeded work log (${suffix})`,
    });

    const notification = await Notification.create({
        userId: users.employee.id,
        type: 'SYSTEM',
        title: `Seed notification ${suffix.toUpperCase()}`,
        message: 'Seed message',
        data: {},
        isRead: false,
    });

    await AuditLog.create({
        userId: users.admin.id,
        action: 'CREATE',
        resource: 'seed',
        resourceId: project.id,
        details: { source: 'api-sweep', suffix },
        ipAddress: '127.0.0.1',
        userAgent: 'api-sweep-script',
    });

    const today = new Date().toISOString().slice(0, 10);
    const attendance = await Attendance.create({
        userId: users.employee.id,
        date: today,
        checkInTime: new Date(),
        status: 'Present',
        approvalStatus: 'Pending',
        workLocation: 'Office',
    });

    const leaveRequest = await LeaveRequest.create({
        userId: users.employee.id,
        leaveType: 'Annual',
        startDate: today,
        endDate: today,
        daysCount: 1,
        reason: `Seed leave request (${suffix})`,
        status: 'Pending',
    });

    const tokens = {
        admin: AuthService.generateAccessToken(users.admin.id, users.admin.email, users.admin.role, users.admin.orgId),
        scrumMaster: AuthService.generateAccessToken(users.scrumMaster.id, users.scrumMaster.email, users.scrumMaster.role, users.scrumMaster.orgId),
        projectManager: AuthService.generateAccessToken(users.projectManager.id, users.projectManager.email, users.projectManager.role, users.projectManager.orgId),
        employee: AuthService.generateAccessToken(users.employee.id, users.employee.email, users.employee.role, users.employee.orgId),
        client: AuthService.generateAccessToken(users.client.id, users.client.email, users.client.role, users.client.orgId),
    };

    return {
        org,
        users,
        tokens,
        project,
        uploadProject,
        sprint,
        activeSprint,
        issue,
        linkTargetIssue,
        linkCandidateIssue,
        uploadIssue,
        epic,
        feature,
        milestone,
        workLog,
        attendance,
        leaveRequest,
        notification,
        issueAttachmentId,
        projectFileId,
        linkId: seededLink.id,
    };
};

const buildSeedContext = async () => {
    const password = 'password123';

    const primary = await buildOrgFixtures({
        password,
        orgName: 'API Sweep Org A',
        suffix: 'a',
        keyPrefix: 'SWA',
        issueAttachmentId: '44444444-4444-4444-8444-444444444444',
        projectFileId: '55555555-5555-4555-8555-555555555555',
    });

    const otherOrg = await buildOrgFixtures({
        password,
        orgName: 'API Sweep Org B',
        suffix: 'b',
        keyPrefix: 'SWB',
        issueAttachmentId: '66666666-6666-4666-8666-666666666666',
        projectFileId: '77777777-7777-4777-8777-777777777777',
    });

    try {
        await Settings.create({
            key: 'ui.theme',
            value: { theme: 'light' },
            description: 'Seed setting',
            updatedBy: primary.users.admin.id,
        });
    } catch (_error) {
        // Keep sweep moving even if settings table/schema differs.
    }

    const refreshToken = AuthService.generateRefreshToken(primary.users.admin.id);
    primary.users.admin.refreshToken = refreshToken;
    await primary.users.admin.save();

    const resetToken = AuthService.generatePasswordResetToken(primary.users.admin.id);
    primary.users.admin.resetPasswordToken = AuthService.hashToken(resetToken);
    primary.users.admin.resetPasswordExpires = new Date(Date.now() + 60 * 60 * 1000);
    await primary.users.admin.save();

    return {
        password,
        ...primary,
        refreshToken,
        resetToken,
        otherOrg,
    };
};

const runProbe = async ({ route, probe, ctx }) => {
    const pathMode = probe === 'validation' ? 'validation' : probe === 'crossOrg' ? 'crossOrg' : 'success';
    const reqPath = buildPathParams(route.path, pathMode, ctx);
    const body = buildBody(route.method, route.path, probe, ctx);
    const query = buildQuery(route.method, route.path, probe, ctx);

    let token = null;
    if (probe === 'happy') {
        token = chooseHappyToken(route.path, ctx);
    } else if (probe === 'authz') {
        token = chooseAuthzFailureToken(route.path, ctx);
    } else if (probe === 'validation') {
        token = isProtectedRoute(route.path) ? chooseHappyToken(route.path, ctx) : null;
    } else if (probe === 'crossOrg') {
        token = chooseCrossOrgToken(route.path, ctx);
    }

    try {
        const response = await sendRequest({
            method: route.method,
            reqPath,
            routePath: route.path,
            body,
            query,
            token,
            isValidationProbe: probe === 'validation',
        });

        return {
            status: response.status,
            samplePath: reqPath,
            sampleBody: body,
            sampleQuery: query,
            error:
                response.status >= 500
                    ? (response.body && Object.keys(response.body).length > 0
                        ? JSON.stringify(response.body)
                        : response.text || 'Server error')
                    : null,
        };
    } catch (error) {
        return {
            status: 599,
            samplePath: reqPath,
            sampleBody: body,
            sampleQuery: query,
            error: error instanceof Error ? error.message : String(error),
        };
    }
};

const generateReport = ({ routes, results }) => {
    const happy2xx = results.filter((r) => r.happy.status >= 200 && r.happy.status < 300).length;
    const authzExpected = results.filter((r) => r.protected).length;
    const authzBlocked = results.filter((r) => r.protected && [401, 403].includes(r.authz.status)).length;
    const validationClientErrors = results.filter((r) => [400, 404, 409, 422].includes(r.validation.status)).length;
    const crossOrgExpected = results.filter((r) => r.crossOrgApplicable).length;
    const crossOrgBlocked = results.filter(
        (r) => r.crossOrgApplicable && CROSS_ORG_STATUS_CODES.has(r.crossOrg.status)
    ).length;

    const fiveXx = results.filter(
        (r) =>
            r.happy.status >= 500 ||
            r.authz.status >= 500 ||
            r.validation.status >= 500 ||
            (r.crossOrgApplicable && r.crossOrg.status >= 500)
    );

    const lines = [];
    lines.push('# Backend API Sweep Report');
    lines.push('');
    lines.push(`- Date: ${new Date().toISOString()}`);
    lines.push(`- Routes discovered: ${routes.length}`);
    lines.push(`- Happy-path 2xx count: ${happy2xx}`);
    lines.push(`- Authz denial checks (401/403) passed: ${authzBlocked}/${authzExpected}`);
    lines.push(`- Validation probes returning client errors (4xx): ${validationClientErrors}/${results.length}`);
    lines.push(`- Cross-org denial checks (403/404) passed: ${crossOrgBlocked}/${crossOrgExpected}`);
    lines.push(`- Routes with any 5xx probe: ${fiveXx.length}`);
    lines.push('');

    if (fiveXx.length > 0) {
        lines.push('## High-Risk Findings');
        lines.push('');
        for (const row of fiveXx) {
            const crossOrgStatus = row.crossOrgApplicable ? row.crossOrg.status : '-';
            lines.push(
                `- [PRODUCTION_RISK] \`${row.method} ${row.path}\` -> happy:${row.happy.status}, authz:${row.authz.status}, validation:${row.validation.status}, crossOrg:${crossOrgStatus} (${row.source})`
            );
        }
        lines.push('');
    }

    lines.push('## Matrix');
    lines.push('');
    lines.push('| Method | Path | Protected | Happy | Authz | Validation | Cross-Org | Source |');
    lines.push('|---|---|---:|---:|---:|---:|---:|---|');
    for (const row of results) {
        const crossOrgStatus = row.crossOrgApplicable ? row.crossOrg.status : '-';
        lines.push(
            `| ${row.method} | \`${row.path}\` | ${row.protected ? 'Yes' : 'No'} | ${row.happy.status} | ${row.authz.status} | ${row.validation.status} | ${crossOrgStatus} | ${row.source} |`
        );
    }
    lines.push('');

    lines.push('## Notes');
    lines.push('');
    lines.push('- Happy probe uses role-aware seed tokens and fixture IDs where possible.');
    lines.push('- Authz probe checks denial behavior (missing or wrong-role token).');
    lines.push('- Validation probe uses malformed params/body and should not produce 5xx responses.');
    lines.push('- Cross-org probe reuses authenticated org-A tokens against org-B resource IDs; expected denial is 403/404.');

    return lines.join('\n');
};

const main = async () => {
    const routes = parseRouteInventory();

    await ensureSettingsTable();
    await ensureCanonicalIssueSchema();
    await ensureAttachmentSchema();

    const results = [];

    for (const route of routes) {
        await resetDatabase();
        const ctx = await buildSeedContext();

        const protectedRoute = isProtectedRoute(route.path);
        const crossOrgApplicable = isCrossOrgCapableRoute(route);

        const happy = await runProbe({ route, probe: 'happy', ctx });
        const authz = protectedRoute
            ? await runProbe({ route, probe: 'authz', ctx })
            : { status: 0, samplePath: route.path, sampleBody: undefined, error: null };
        const validation = await runProbe({ route, probe: 'validation', ctx });
        const crossOrg = crossOrgApplicable
            ? await runProbe({ route, probe: 'crossOrg', ctx })
            : { status: 0, samplePath: route.path, sampleBody: undefined, sampleQuery: undefined, error: null };

        results.push({
            ...route,
            protected: protectedRoute,
            crossOrgApplicable,
            happy,
            authz,
            validation,
            crossOrg,
        });
    }

    const reportsDir = path.join(__dirname, '..', 'reports');
    fs.mkdirSync(reportsDir, { recursive: true });

    const reportPath = path.join(reportsDir, 'backend-api-sweep-report.md');
    fs.writeFileSync(reportPath, generateReport({ routes, results }), 'utf8');

    const inventoryPath = path.join(reportsDir, 'route-inventory.json');
    fs.writeFileSync(inventoryPath, JSON.stringify(routes, null, 2), 'utf8');

    const resultsPath = path.join(reportsDir, 'route-probe-results.json');
    fs.writeFileSync(resultsPath, JSON.stringify(results, null, 2), 'utf8');

    console.log(`Wrote API sweep report: ${reportPath}`);
    console.log(`Wrote route inventory: ${inventoryPath}`);
    console.log(`Wrote probe results: ${resultsPath}`);

    await sequelize.close();
};

main().catch(async (error) => {
    console.error('API sweep failed:', error);
    try {
        await sequelize.close();
    } catch (_error) {
        // ignore
    }
    process.exit(1);
});
