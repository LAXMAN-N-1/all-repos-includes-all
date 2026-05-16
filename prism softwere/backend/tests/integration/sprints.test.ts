import request from 'supertest';
import app from '../../src/server';
import { Issue, Organization, Project, Sprint, SprintMember, User } from '../../src/models';
import { resetDatabase } from '../utils/db';

interface SeedContext {
    scrumToken: string;
    activeSprintId: string;
    carryOverSprintId: string;
    otherProjectSprintId: string;
    plannedDeleteSprintId: string;
    incompleteIssueId: string;
    deleteSprintIssueId: string;
    deleteSprintMemberId: string;
}

describe('Sprint API', () => {
    let ctx: SeedContext;

    const createUser = async (
        orgId: string,
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
            orgId,
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

    const seed = async (): Promise<SeedContext> => {
        await resetDatabase();

        const org = await Organization.create({
            name: 'Sprint Test Org',
            subscriptionPlan: 'PREMIUM',
            maxUsers: 50,
            ssoEnabled: false,
            settings: {},
        });

        const scrum = await createUser(org.id, 'sprint-scrum@test.com', 'sprintscrum', 'SCRUM_MASTER');
        const employee = await createUser(org.id, 'sprint-employee@test.com', 'sprintemployee', 'EMPLOYEE');

        const scrumToken = await login(scrum.email);

        const projectA = await Project.create({
            name: 'Sprint Project A',
            key: 'SPRA',
            description: 'Primary project',
            orgId: org.id,
            leadId: scrum.id,
            projectManagerId: scrum.id,
            scrumMasterId: scrum.id,
            settings: {},
            clientConfig: { showBudget: false, allowTaskCreation: false },
            status: 'ACTIVE',
            visibility: 'PRIVATE',
            usesEpics: true,
            usesSprints: true,
            type: 'SCRUM',
        });

        const projectB = await Project.create({
            name: 'Sprint Project B',
            key: 'SPRB',
            description: 'Secondary project',
            orgId: org.id,
            leadId: scrum.id,
            projectManagerId: scrum.id,
            scrumMasterId: scrum.id,
            settings: {},
            clientConfig: { showBudget: false, allowTaskCreation: false },
            status: 'ACTIVE',
            visibility: 'PRIVATE',
            usesEpics: true,
            usesSprints: true,
            type: 'SCRUM',
        });

        const now = new Date();
        const nextWeek = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

        const activeSprint = await Sprint.create({
            projectId: projectA.id,
            name: 'Active Sprint',
            startDate: now,
            endDate: nextWeek,
            status: 'ACTIVE',
        });

        const carryOverSprint = await Sprint.create({
            projectId: projectA.id,
            name: 'Carry Sprint',
            startDate: now,
            endDate: nextWeek,
            status: 'PLANNED',
        });

        const otherProjectSprint = await Sprint.create({
            projectId: projectB.id,
            name: 'Other Project Sprint',
            startDate: now,
            endDate: nextWeek,
            status: 'PLANNED',
        });

        const plannedDeleteSprint = await Sprint.create({
            projectId: projectA.id,
            name: 'Delete Sprint',
            startDate: now,
            endDate: nextWeek,
            status: 'PLANNED',
        });

        const incompleteIssue = await Issue.create({
            projectId: projectA.id,
            issueNumber: 1,
            key: 'SPRA-1',
            type: 'TASK',
            status: 'TODO',
            priority: 'MEDIUM',
            title: 'Incomplete sprint issue',
            reporterId: scrum.id,
            assigneeId: employee.id,
            sprintId: activeSprint.id,
            orderIndex: 0,
            labels: [],
            customFields: {},
            isClientVisible: true,
        });

        await Issue.create({
            projectId: projectA.id,
            issueNumber: 2,
            key: 'SPRA-2',
            type: 'TASK',
            status: 'DONE',
            priority: 'MEDIUM',
            title: 'Completed sprint issue',
            reporterId: scrum.id,
            assigneeId: employee.id,
            sprintId: activeSprint.id,
            orderIndex: 1,
            labels: [],
            customFields: {},
            isClientVisible: true,
        });

        const deleteSprintIssue = await Issue.create({
            projectId: projectA.id,
            issueNumber: 3,
            key: 'SPRA-3',
            type: 'TASK',
            status: 'TODO',
            priority: 'MEDIUM',
            title: 'Delete sprint issue',
            reporterId: scrum.id,
            assigneeId: employee.id,
            sprintId: plannedDeleteSprint.id,
            orderIndex: 2,
            labels: [],
            customFields: {},
            isClientVisible: true,
        });

        const deleteSprintMember = await SprintMember.create({
            sprintId: plannedDeleteSprint.id,
            userId: employee.id,
            capacityHours: 8,
        });

        return {
            scrumToken,
            activeSprintId: activeSprint.id,
            carryOverSprintId: carryOverSprint.id,
            otherProjectSprintId: otherProjectSprint.id,
            plannedDeleteSprintId: plannedDeleteSprint.id,
            incompleteIssueId: incompleteIssue.id,
            deleteSprintIssueId: deleteSprintIssue.id,
            deleteSprintMemberId: deleteSprintMember.id,
        };
    };

    beforeEach(async () => {
        ctx = await seed();
    });

    describe('POST /api/v1/sprints/:id/complete', () => {
        it('completes active sprint and carries over incomplete issues in the same project', async () => {
            const response = await request(app)
                .post(`/api/v1/sprints/${ctx.activeSprintId}/complete`)
                .set('Authorization', `Bearer ${ctx.scrumToken}`)
                .send({ moveIssuesToSprintId: ctx.carryOverSprintId });

            expect(response.status).toBe(200);
            expect(response.body.success).toBe(true);

            const updatedIssue = await Issue.findByPk(ctx.incompleteIssueId);
            const updatedSprint = await Sprint.findByPk(ctx.activeSprintId);

            expect(updatedIssue?.sprintId).toBe(ctx.carryOverSprintId);
            expect(updatedSprint?.status).toBe('COMPLETED');
        });

        it('rejects carry-over target sprint from a different project', async () => {
            const response = await request(app)
                .post(`/api/v1/sprints/${ctx.activeSprintId}/complete`)
                .set('Authorization', `Bearer ${ctx.scrumToken}`)
                .send({ moveIssuesToSprintId: ctx.otherProjectSprintId });

            expect(response.status).toBe(400);
            expect(response.body.success).toBe(false);
        });

        it('rolls back issue moves when completion fails after updates start', async () => {
            const saveSpy = jest
                .spyOn(Sprint.prototype, 'save')
                .mockRejectedValueOnce(new Error('forced complete failure'));

            const response = await request(app)
                .post(`/api/v1/sprints/${ctx.activeSprintId}/complete`)
                .set('Authorization', `Bearer ${ctx.scrumToken}`)
                .send({ moveIssuesToSprintId: ctx.carryOverSprintId });

            expect(response.status).toBe(500);
            expect(response.body.success).toBe(false);

            const rolledBackIssue = await Issue.findByPk(ctx.incompleteIssueId);
            const rolledBackSprint = await Sprint.findByPk(ctx.activeSprintId);

            expect(rolledBackIssue?.sprintId).toBe(ctx.activeSprintId);
            expect(rolledBackSprint?.status).toBe('ACTIVE');

            saveSpy.mockRestore();
        });
    });

    describe('DELETE /api/v1/sprints/:id', () => {
        it('deletes planned sprint and moves linked issues to backlog', async () => {
            const response = await request(app)
                .delete(`/api/v1/sprints/${ctx.plannedDeleteSprintId}`)
                .set('Authorization', `Bearer ${ctx.scrumToken}`);

            expect(response.status).toBe(200);
            expect(response.body.success).toBe(true);

            const deletedSprint = await Sprint.findByPk(ctx.plannedDeleteSprintId);
            const movedIssue = await Issue.findByPk(ctx.deleteSprintIssueId);

            expect(deletedSprint).toBeNull();
            expect(movedIssue?.sprintId).toBeNull();
        });

        it('rolls back delete lifecycle changes if sprint destroy fails', async () => {
            const destroySpy = jest
                .spyOn(Sprint.prototype, 'destroy')
                .mockRejectedValueOnce(new Error('forced delete failure'));

            const response = await request(app)
                .delete(`/api/v1/sprints/${ctx.plannedDeleteSprintId}`)
                .set('Authorization', `Bearer ${ctx.scrumToken}`);

            expect(response.status).toBe(500);
            expect(response.body.success).toBe(false);

            const sprintStillExists = await Sprint.findByPk(ctx.plannedDeleteSprintId);
            const issueStillLinked = await Issue.findByPk(ctx.deleteSprintIssueId);
            const memberStillLinked = await SprintMember.findByPk(ctx.deleteSprintMemberId);

            expect(sprintStillExists).not.toBeNull();
            expect(issueStillLinked?.sprintId).toBe(ctx.plannedDeleteSprintId);
            expect(memberStillLinked).not.toBeNull();

            destroySpy.mockRestore();
        });
    });
});
