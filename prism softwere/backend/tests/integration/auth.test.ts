import request from 'supertest';
import app from '../../src/server';
import { User, Organization } from '../../src/models';
import { AuthService } from '../../src/services/authService';
import { resetDatabase } from '../utils/db';

describe('Authentication API', () => {
    let orgId: string;
    let adminUserId: string;
    let mfaUserId: string;

    beforeAll(async () => {
        await resetDatabase();

        const org = await Organization.create({
            name: 'Auth Test Organization',
            subscriptionPlan: 'FREE',
            maxUsers: 10,
            ssoEnabled: false,
            settings: {},
        });
        orgId = org.id;

        const adminUser = await User.create({
            email: 'admin@test.com',
            username: 'admin',
            passwordHash: 'placeholder',
            firstName: 'Admin',
            lastName: 'User',
            role: 'ADMIN',
            orgId,
            profileData: {},
            mfaEnabled: false,
            isActive: true,
        });
        await adminUser.setPassword('password123');
        await adminUser.save();
        adminUserId = adminUser.id;

        const mfaUser = await User.create({
            email: 'mfa@test.com',
            username: 'mfauser',
            passwordHash: 'placeholder',
            firstName: 'MFA',
            lastName: 'User',
            role: 'EMPLOYEE',
            orgId,
            profileData: {},
            mfaEnabled: true,
            isActive: true,
        });
        await mfaUser.setPassword('password123');
        await mfaUser.save();
        mfaUserId = mfaUser.id;
    });

    describe('POST /api/v1/auth/login', () => {
        it('logs in successfully with email/password', async () => {
            const response = await request(app)
                .post('/api/v1/auth/login')
                .send({
                    email: 'admin@test.com',
                    password: 'password123',
                });

            expect(response.status).toBe(200);
            expect(response.body.success).toBe(true);
            expect(response.body.data).toHaveProperty('accessToken');
            expect(response.body.data).toHaveProperty('refreshToken');
            expect(response.body.data.user.email).toBe('admin@test.com');
        });

        it('logs in successfully with username/password', async () => {
            const response = await request(app)
                .post('/api/v1/auth/login')
                .send({
                    username: 'admin',
                    password: 'password123',
                });

            expect(response.status).toBe(200);
            expect(response.body.success).toBe(true);
            expect(response.body.data.user.username).toBe('admin');
        });

        it('fails with invalid password', async () => {
            const response = await request(app)
                .post('/api/v1/auth/login')
                .send({
                    email: 'admin@test.com',
                    password: 'wrong-password',
                });

            expect(response.status).toBe(401);
            expect(response.body.success).toBe(false);
        });
    });

    describe('MFA flow hardening', () => {
        it('requires MFA token for MFA-enabled user', async () => {
            const response = await request(app)
                .post('/api/v1/auth/login')
                .send({
                    email: 'mfa@test.com',
                    password: 'password123',
                });

            expect(response.status).toBe(200);
            expect(response.body.success).toBe(true);
            expect(response.body.data.mfaRequired).toBe(true);
        });

        it('rejects MFA token issued for a different user', async () => {
            const invalidToken = AuthService.generateMFAToken(adminUserId);

            const response = await request(app)
                .post('/api/v1/auth/login')
                .send({
                    email: 'mfa@test.com',
                    password: 'password123',
                    mfaToken: invalidToken,
                });

            expect(response.status).toBe(401);
            expect(response.body.success).toBe(false);
        });

        it('accepts valid MFA token bound to the same user', async () => {
            const validToken = AuthService.generateMFAToken(mfaUserId);

            const response = await request(app)
                .post('/api/v1/auth/login')
                .send({
                    email: 'mfa@test.com',
                    password: 'password123',
                    mfaToken: validToken,
                });

            expect(response.status).toBe(200);
            expect(response.body.success).toBe(true);
            expect(response.body.data.user.email).toBe('mfa@test.com');
            expect(response.body.data).toHaveProperty('accessToken');
        });
    });

    describe('GET /api/v1/auth/me', () => {
        let accessToken: string;

        beforeAll(async () => {
            const response = await request(app)
                .post('/api/v1/auth/login')
                .send({
                    email: 'admin@test.com',
                    password: 'password123',
                });

            accessToken = response.body.data.accessToken;
        });

        it('returns current user with valid token', async () => {
            const response = await request(app)
                .get('/api/v1/auth/me')
                .set('Authorization', `Bearer ${accessToken}`);

            expect(response.status).toBe(200);
            expect(response.body.success).toBe(true);
            expect(response.body.data.user.email).toBe('admin@test.com');
        });

        it('fails without token', async () => {
            const response = await request(app)
                .get('/api/v1/auth/me');

            expect(response.status).toBe(401);
            expect(response.body.success).toBe(false);
        });

        it('fails with invalid token', async () => {
            const response = await request(app)
                .get('/api/v1/auth/me')
                .set('Authorization', 'Bearer invalid-token');

            expect(response.status).toBe(401);
            expect(response.body.success).toBe(false);
        });
    });

    describe('Refresh and logout flow', () => {
        it('rotates refresh token and rejects after logout', async () => {
            const loginResponse = await request(app)
                .post('/api/v1/auth/login')
                .send({
                    email: 'admin@test.com',
                    password: 'password123',
                });

            const accessToken = loginResponse.body.data.accessToken;
            const refreshToken = loginResponse.body.data.refreshToken;

            const refreshResponse = await request(app)
                .post('/api/v1/auth/refresh-token')
                .send({ refreshToken });

            expect(refreshResponse.status).toBe(200);
            expect(refreshResponse.body.success).toBe(true);
            expect(refreshResponse.body.data.refreshToken).toBeDefined();

            const logoutResponse = await request(app)
                .post('/api/v1/auth/logout')
                .set('Authorization', `Bearer ${accessToken}`);

            expect(logoutResponse.status).toBe(200);
            expect(logoutResponse.body.success).toBe(true);

            const refreshAfterLogout = await request(app)
                .post('/api/v1/auth/refresh-token')
                .send({ refreshToken: refreshResponse.body.data.refreshToken });

            expect(refreshAfterLogout.status).toBe(401);
            expect(refreshAfterLogout.body.success).toBe(false);
        });
    });

    describe('Forgot/reset password flow', () => {
        it('does not leak account existence in forgot-password', async () => {
            const existingUserResponse = await request(app)
                .post('/api/v1/auth/forgot-password')
                .send({ email: 'admin@test.com' });

            const unknownUserResponse = await request(app)
                .post('/api/v1/auth/forgot-password')
                .send({ email: 'missing-user@test.com' });

            expect(existingUserResponse.status).toBe(200);
            expect(unknownUserResponse.status).toBe(200);
            expect(existingUserResponse.body.message).toBe(unknownUserResponse.body.message);
        });

        it('rejects invalid reset token', async () => {
            const response = await request(app)
                .post('/api/v1/auth/reset-password')
                .send({
                    token: 'invalid-token',
                    newPassword: 'newPassword123',
                });

            expect(response.status).toBe(400);
            expect(response.body.success).toBe(false);
        });

        it('resets password with hashed token storage and allows login with new password', async () => {
            const user = await User.findByPk(adminUserId);
            expect(user).toBeTruthy();

            const resetToken = AuthService.generatePasswordResetToken(adminUserId);
            user!.resetPasswordToken = AuthService.hashToken(resetToken);
            user!.resetPasswordExpires = new Date(Date.now() + 60_000);
            await user!.save();

            const resetResponse = await request(app)
                .post('/api/v1/auth/reset-password')
                .send({
                    token: resetToken,
                    newPassword: 'newPassword123',
                });

            expect(resetResponse.status).toBe(200);
            expect(resetResponse.body.success).toBe(true);

            const loginWithNewPassword = await request(app)
                .post('/api/v1/auth/login')
                .send({
                    email: 'admin@test.com',
                    password: 'newPassword123',
                });

            expect(loginWithNewPassword.status).toBe(200);
            expect(loginWithNewPassword.body.success).toBe(true);
        });
    });
});
