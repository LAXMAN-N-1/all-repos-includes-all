import request from 'supertest';
import app from '../../src/server';
import { Issue, Organization, Project, User } from '../../src/models';
import { resetDatabase } from '../utils/db';

describe('Analytics API', () => {
    let adminToken: string;
    let pmToken: string;
    let scrumToken: string;
    let employeeToken: string;
    let clientToken: string;
    let orgId: string;
    let clientId: string;

    const createUser = async (
        orgIdValue: string,
        email: string,
        username: string,
        role: string
    ): Promise<User> => {
        const user = await User.create({
            email,
            username,
            passwordHash: 'placeholder',
            firstName: role,
            lastName: 'User',
            role: role as any,
            orgId: orgIdValue,
            profileData: {},
            mfaEnabled: false,
            isActive: true,
        });
        await user.setPassword('password123');
        await user.save();
        return user;
    };

    const login = async (email: string): Promise<string> => {
        const response = await request(app)
            .post('/api/v1/auth/login')
            .send({
                email,
                password: 'password123',
            });

        return response.body.data.accessToken;
    };

    beforeAll(async () => {
        await resetDatabase();

        const org = await Organization.create({
            name: 'Analytics Test Org',
            subscriptionPlan: 'PREMIUM',
            maxUsers: 50,
            ssoEnabled: false,
            settings: {},
        });
        orgId = org.id;

        const otherOrg = await Organization.create({
            name: 'Analytics Other Org',
            subscriptionPlan: 'PREMIUM',
            maxUsers: 50,
            ssoEnabled: false,
            settings: {},
        });

        const admin = await createUser(org.id, 'analytics-admin@test.com', 'analyticsadmin', 'ADMIN');
        const pm = await createUser(org.id, 'analytics-pm@test.com', 'analyticspm', 'PROJECT_MANAGER');
        const scrum = await createUser(org.id, 'analytics-scrum@test.com', 'analyticsscrum', 'SCRUM_MASTER');
        const employee = await createUser(org.id, 'analytics-employee@test.com', 'analyticsemployee', 'EMPLOYEE');
        const client = await createUser(org.id, 'analytics-client@test.com', 'analyticsclient', 'CLIENT');
        const otherClient = await createUser(org.id, 'analytics-client2@test.com', 'analyticsclient2', 'CLIENT');

        const otherOrgAdmin = await createUser(otherOrg.id, 'analytics-other-admin@test.com', 'analyticsotheradmin', 'ADMIN');

        clientId = client.id;

        adminToken = await login(admin.email);
        pmToken = await login(pm.email);
        scrumToken = await login(scrum.email);
        employeeToken = await login(employee.email);
        clientToken = await login(client.email);

        const clientOwnedProject = await Project.create({
            name: 'Client Owned Project',
            key: 'CLNT',
            description: 'Visible to analytics client',
            orgId: org.id,
            leadId: admin.id,
            clientId: client.id,
            projectManagerId: pm.id,
            scrumMasterId: scrum.id,
            settings: {},
            clientConfig: { showBudget: false, allowTaskCreation: false },
            status: 'ACTIVE',
            visibility: 'PRIVATE',
            usesEpics: true,
            usesSprints: true,
            type: 'SCRUM',
        });

        const otherClientProject = await Project.create({
            name: 'Other Client Project',
            key: 'OCLN',
            description: 'Should not be visible to first client analytics',
            orgId: org.id,
            leadId: admin.id,
            clientId: otherClient.id,
            projectManagerId: pm.id,
            scrumMasterId: scrum.id,
            settings: {},
            clientConfig: { showBudget: false, allowTaskCreation: false },
            status: 'ACTIVE',
            visibility: 'PRIVATE',
            usesEpics: true,
            usesSprints: true,
            type: 'SCRUM',
        });

        const otherOrgProject = await Project.create({
            name: 'Other Org Project',
            key: 'OTHR',
            description: 'Should not affect org A analytics',
            orgId: otherOrg.id,
            leadId: otherOrgAdmin.id,
            settings: {},
            clientConfig: { showBudget: false, allowTaskCreation: false },
            status: 'ACTIVE',
            visibility: 'PRIVATE',
            usesEpics: true,
            usesSprints: true,
            type: 'SCRUM',
        });

        await Issue.bulkCreate([
            {
                projectId: clientOwnedProject.id,
                issueNumber: 1,
                key: 'CLNT-1',
                type: 'TASK',
                status: 'DONE',
                priority: 'MEDIUM',
                title: 'Client project done issue',
                reporterId: admin.id,
                assigneeId: employee.id,
                orderIndex: 0,
                labels: [],
                customFields: {},
                isClientVisible: true,
            },
            {
                projectId: clientOwnedProject.id,
                issueNumber: 2,
                key: 'CLNT-2',
                type: 'TASK',
                status: 'TODO',
                priority: 'MEDIUM',
                title: 'Client project open issue',
                reporterId: admin.id,
                assigneeId: employee.id,
                orderIndex: 1,
                labels: [],
                customFields: {},
                isClientVisible: true,
            },
            {
                projectId: otherClientProject.id,
                issueNumber: 1,
                key: 'OCLN-1',
                type: 'TASK',
                status: 'DONE',
                priority: 'MEDIUM',
                title: 'Other client done issue',
                reporterId: admin.id,
                assigneeId: employee.id,
                orderIndex: 0,
                labels: [],
                customFields: {},
                isClientVisible: true,
            },
            {
                projectId: otherOrgProject.id,
                issueNumber: 1,
                key: 'OTHR-1',
                type: 'TASK',
                status: 'DONE',
                priority: 'MEDIUM',
                title: 'Other org done issue',
                reporterId: otherOrgAdmin.id,
                assigneeId: otherOrgAdmin.id,
                orderIndex: 0,
                labels: [],
                customFields: {},
                isClientVisible: true,
            },
        ]);
    });

    describe('GET /api/v1/analytics/client-stats', () => {
        it('denies employee role', async () => {
            const response = await request(app)
                .get('/api/v1/analytics/client-stats')
                .set('Authorization', `Bearer ${employeeToken}`);

            expect(response.status).toBe(403);
            expect(response.body.success).toBe(false);
        });

        it('returns client-scoped stats for client role', async () => {
            const response = await request(app)
                .get('/api/v1/analytics/client-stats')
                .set('Authorization', `Bearer ${clientToken}`);

            expect(response.status).toBe(200);
            expect(response.body.success).toBe(true);
            expect(response.body.data.totalProjects).toBe(1);
            expect(response.body.data.activeProjects).toBe(1);
            expect(response.body.data.completedDeliverables).toBe(1);
            expect(response.body.data.overallProgress).toBe(50);
        });

        it('returns org-scoped stats for admin, PM, and scrum master', async () => {
            const [adminResponse, pmResponse, scrumResponse] = await Promise.all([
                request(app)
                    .get('/api/v1/analytics/client-stats')
                    .set('Authorization', `Bearer ${adminToken}`),
                request(app)
                    .get('/api/v1/analytics/client-stats')
                    .set('Authorization', `Bearer ${pmToken}`),
                request(app)
                    .get('/api/v1/analytics/client-stats')
                    .set('Authorization', `Bearer ${scrumToken}`),
            ]);

            for (const response of [adminResponse, pmResponse, scrumResponse]) {
                expect(response.status).toBe(200);
                expect(response.body.success).toBe(true);
                expect(response.body.data.totalProjects).toBe(2);
                expect(response.body.data.activeProjects).toBe(2);
                expect(response.body.data.completedDeliverables).toBe(2);
                expect(response.body.data.overallProgress).toBe(67);
            }
        });

        it('keeps stats isolated to the authenticated org', async () => {
            const response = await request(app)
                .get('/api/v1/analytics/client-stats')
                .set('Authorization', `Bearer ${adminToken}`);

            expect(response.status).toBe(200);
            expect(response.body.success).toBe(true);
            expect(response.body.data.totalProjects).toBe(2);
            expect(response.body.data.completedDeliverables).toBe(2);
            expect(response.body.data.totalProjects).not.toBeGreaterThan(2);
            expect(orgId).toBeDefined();
            expect(clientId).toBeDefined();
        });
    });
});
