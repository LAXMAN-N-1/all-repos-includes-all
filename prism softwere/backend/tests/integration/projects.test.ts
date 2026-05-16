import request from 'supertest';
import app from '../../src/server';
import { ProjectMember, User, Organization } from '../../src/models';
import { resetDatabase } from '../utils/db';

describe('Project API', () => {
    let adminToken: string;
    let scrumToken: string;
    let adminId: string;
    let scrumId: string;
    let memberId: string;
    let externalLeadId: string;
    let externalProjectManagerId: string;
    let externalScrumMasterId: string;
    let externalClientId: string;
    let projectAssignedToScrumId: string;
    let projectHiddenFromScrumId: string;

    beforeAll(async () => {
        await resetDatabase();

        const org = await Organization.create({
            name: 'Project Test Org',
            subscriptionPlan: 'PREMIUM',
            maxUsers: 50,
            ssoEnabled: false,
            settings: {},
        });
        const externalOrg = await Organization.create({
            name: 'External Project Test Org',
            subscriptionPlan: 'PREMIUM',
            maxUsers: 50,
            ssoEnabled: false,
            settings: {},
        });

        const admin = await User.create({
            email: 'admin@test.com',
            username: 'admin',
            passwordHash: 'placeholder',
            firstName: 'Admin',
            lastName: 'User',
            role: 'ADMIN',
            orgId: org.id,
            profileData: {},
            mfaEnabled: false,
            isActive: true,
        });
        await admin.setPassword('password123');
        await admin.save();
        adminId = admin.id;

        const scrum = await User.create({
            email: 'scrum@test.com',
            username: 'scrum',
            passwordHash: 'placeholder',
            firstName: 'Scrum',
            lastName: 'Master',
            role: 'SCRUM_MASTER',
            orgId: org.id,
            profileData: {},
            mfaEnabled: false,
            isActive: true,
        });
        await scrum.setPassword('password123');
        await scrum.save();
        scrumId = scrum.id;

        const member = await User.create({
            email: 'member@test.com',
            username: 'member',
            passwordHash: 'placeholder',
            firstName: 'Team',
            lastName: 'Member',
            role: 'EMPLOYEE',
            orgId: org.id,
            profileData: {},
            mfaEnabled: false,
            isActive: true,
        });
        await member.setPassword('password123');
        await member.save();
        memberId = member.id;

        const externalLead = await User.create({
            email: 'external-lead@test.com',
            username: 'externallead',
            passwordHash: 'placeholder',
            firstName: 'External',
            lastName: 'Lead',
            role: 'ADMIN',
            orgId: externalOrg.id,
            profileData: {},
            mfaEnabled: false,
            isActive: true,
        });
        await externalLead.setPassword('password123');
        await externalLead.save();
        externalLeadId = externalLead.id;

        const externalPM = await User.create({
            email: 'external-pm@test.com',
            username: 'externalpm',
            passwordHash: 'placeholder',
            firstName: 'External',
            lastName: 'PM',
            role: 'PROJECT_MANAGER',
            orgId: externalOrg.id,
            profileData: {},
            mfaEnabled: false,
            isActive: true,
        });
        await externalPM.setPassword('password123');
        await externalPM.save();
        externalProjectManagerId = externalPM.id;

        const externalSM = await User.create({
            email: 'external-sm@test.com',
            username: 'externalsm',
            passwordHash: 'placeholder',
            firstName: 'External',
            lastName: 'SM',
            role: 'SCRUM_MASTER',
            orgId: externalOrg.id,
            profileData: {},
            mfaEnabled: false,
            isActive: true,
        });
        await externalSM.setPassword('password123');
        await externalSM.save();
        externalScrumMasterId = externalSM.id;

        const externalClient = await User.create({
            email: 'external-client@test.com',
            username: 'externalclient',
            passwordHash: 'placeholder',
            firstName: 'External',
            lastName: 'Client',
            role: 'CLIENT',
            orgId: externalOrg.id,
            profileData: {},
            mfaEnabled: false,
            isActive: true,
        });
        await externalClient.setPassword('password123');
        await externalClient.save();
        externalClientId = externalClient.id;

        const adminLogin = await request(app)
            .post('/api/v1/auth/login')
            .send({
                email: 'admin@test.com',
                password: 'password123',
            });
        adminToken = adminLogin.body.data.accessToken;

        const scrumLogin = await request(app)
            .post('/api/v1/auth/login')
            .send({
                email: 'scrum@test.com',
                password: 'password123',
            });
        scrumToken = scrumLogin.body.data.accessToken;

        const assignedProjectResponse = await request(app)
            .post('/api/v1/projects')
            .set('Authorization', `Bearer ${adminToken}`)
            .send({
                name: 'Alpha Assigned Project',
                key: 'ALPA',
                description: 'Visible to scrum member',
                leadId: adminId,
            });
        projectAssignedToScrumId = assignedProjectResponse.body.data.project.id;

        await ProjectMember.create({
            projectId: projectAssignedToScrumId,
            userId: scrumId,
            role: 'SCRUM_MASTER',
            accessLevel: 'APPROVER',
        });

        const hiddenProjectResponse = await request(app)
            .post('/api/v1/projects')
            .set('Authorization', `Bearer ${adminToken}`)
            .send({
                name: 'Alpha Hidden Project',
                key: 'ALPH',
                description: 'Should not be visible to scrum user search',
                leadId: adminId,
            });
        projectHiddenFromScrumId = hiddenProjectResponse.body.data.project.id;
    });

    describe('POST /api/v1/projects', () => {
        it('creates a new project', async () => {
            const response = await request(app)
                .post('/api/v1/projects')
                .set('Authorization', `Bearer ${adminToken}`)
                .send({
                    name: 'Test Project',
                    key: 'TEST',
                    description: 'A test project',
                    leadId: adminId,
                });

            expect(response.status).toBe(201);
            expect(response.body.success).toBe(true);
            expect(response.body.data.project.name).toBe('Test Project');
            expect(response.body.data.project.key).toBe('TEST');
        });

        it('fails with duplicate project key', async () => {
            const response = await request(app)
                .post('/api/v1/projects')
                .set('Authorization', `Bearer ${adminToken}`)
                .send({
                    name: 'Another Project',
                    key: 'TEST',
                    description: 'Duplicate key',
                    leadId: adminId,
                });

            expect(response.status).toBe(400);
            expect(response.body.success).toBe(false);
        });

        it('rejects cross-org lead assignment during create', async () => {
            const response = await request(app)
                .post('/api/v1/projects')
                .set('Authorization', `Bearer ${adminToken}`)
                .send({
                    name: 'Cross Org Lead Project',
                    key: 'XORG',
                    description: 'Should fail',
                    leadId: externalLeadId,
                });

            expect(response.status).toBe(403);
            expect(response.body.success).toBe(false);
        });
    });

    describe('GET /api/v1/projects', () => {
        it('lists projects for admin', async () => {
            const response = await request(app)
                .get('/api/v1/projects')
                .set('Authorization', `Bearer ${adminToken}`);

            expect(response.status).toBe(200);
            expect(response.body.success).toBe(true);
            expect(Array.isArray(response.body.data.projects)).toBe(true);
        });

        it('supports pagination', async () => {
            const response = await request(app)
                .get('/api/v1/projects?page=1&limit=5')
                .set('Authorization', `Bearer ${adminToken}`);

            expect(response.status).toBe(200);
            expect(response.body.data.pagination).toBeDefined();
            expect(response.body.data.pagination.page).toBe(1);
            expect(response.body.data.pagination.limit).toBe(5);
        });

        it('keeps scrum-member scope when search is applied', async () => {
            const response = await request(app)
                .get('/api/v1/projects?search=Alpha')
                .set('Authorization', `Bearer ${scrumToken}`);

            expect(response.status).toBe(200);
            expect(response.body.success).toBe(true);
            const projectIds = response.body.data.projects.map((p: any) => p.id);

            expect(projectIds).toContain(projectAssignedToScrumId);
            expect(projectIds).not.toContain(projectHiddenFromScrumId);
        });
    });

    describe('PUT /api/v1/projects/:id', () => {
        it('rejects cross-org project manager assignment', async () => {
            const response = await request(app)
                .put(`/api/v1/projects/${projectAssignedToScrumId}`)
                .set('Authorization', `Bearer ${adminToken}`)
                .send({ projectManagerId: externalProjectManagerId });

            expect(response.status).toBe(403);
            expect(response.body.success).toBe(false);
        });

        it('rejects cross-org scrum master assignment', async () => {
            const response = await request(app)
                .put(`/api/v1/projects/${projectAssignedToScrumId}`)
                .set('Authorization', `Bearer ${adminToken}`)
                .send({ scrumMasterId: externalScrumMasterId });

            expect(response.status).toBe(403);
            expect(response.body.success).toBe(false);
        });

        it('rejects cross-org client assignment', async () => {
            const response = await request(app)
                .put(`/api/v1/projects/${projectAssignedToScrumId}`)
                .set('Authorization', `Bearer ${adminToken}`)
                .send({ clientId: externalClientId });

            expect(response.status).toBe(403);
            expect(response.body.success).toBe(false);
        });
    });

    describe('Members API', () => {
        it('adds a member to project', async () => {
            const response = await request(app)
                .post(`/api/v1/projects/${projectAssignedToScrumId}/members`)
                .set('Authorization', `Bearer ${adminToken}`)
                .send({
                    userId: memberId,
                    role: 'MEMBER',
                });

            expect(response.status).toBe(201);
            expect(response.body.success).toBe(true);
        });

        it('rejects cross-org member assignment (including clients)', async () => {
            const response = await request(app)
                .post(`/api/v1/projects/${projectAssignedToScrumId}/members`)
                .set('Authorization', `Bearer ${adminToken}`)
                .send({
                    userId: externalClientId,
                    role: 'CLIENT',
                });

            expect(response.status).toBe(403);
            expect(response.body.success).toBe(false);
        });

        it('returns 404 for unknown user assignment', async () => {
            const response = await request(app)
                .post(`/api/v1/projects/${projectAssignedToScrumId}/members`)
                .set('Authorization', `Bearer ${adminToken}`)
                .send({
                    userId: '11111111-1111-4111-8111-111111111111',
                    role: 'MEMBER',
                });

            expect(response.status).toBe(404);
            expect(response.body.success).toBe(false);
        });

        it('validates member removal userId from route params', async () => {
            const response = await request(app)
                .delete(`/api/v1/projects/${projectAssignedToScrumId}/members/not-a-uuid`)
                .set('Authorization', `Bearer ${adminToken}`);

            expect(response.status).toBe(400);
            expect(response.body.success).toBe(false);
        });

        it('removes a member from project', async () => {
            const response = await request(app)
                .delete(`/api/v1/projects/${projectAssignedToScrumId}/members/${memberId}`)
                .set('Authorization', `Bearer ${adminToken}`);

            expect(response.status).toBe(200);
            expect(response.body.success).toBe(true);
        });
    });
});
