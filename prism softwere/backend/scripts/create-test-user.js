#!/usr/bin/env node

require('ts-node/register/transpile-only');

process.env.NODE_ENV = process.env.NODE_ENV || 'development';
process.env.DB_HOST = process.env.DB_HOST || '127.0.0.1';
process.env.DB_PORT = process.env.DB_PORT || '5432';
process.env.DB_NAME = process.env.DB_NAME || 'project_management';
process.env.DB_SSL = process.env.DB_SSL || 'false';

const sequelize = require('../src/config/database').default;
const { Organization, User } = require('../src/models');

const TEST_USER = {
    username: 'testuser',
    email: 'testuser@local.dev',
    password: 'test1234',
    firstName: 'Test',
    lastName: 'User',
    role: 'ADMIN',
};

const main = async () => {
    await sequelize.authenticate();

    let organization = await Organization.findOne({ where: { name: 'Local Dev Org' } });
    if (!organization) {
        organization = await Organization.create({
            name: 'Local Dev Org',
            subscriptionPlan: 'FREE',
            maxUsers: 50,
            ssoEnabled: false,
            settings: {},
        });
    }

    let user = await User.findOne({
        where: {
            email: TEST_USER.email,
        },
    });

    if (!user) {
        user = await User.findOne({
            where: {
                username: TEST_USER.username,
            },
        });
    }

    if (!user) {
        user = await User.create({
            email: TEST_USER.email,
            username: TEST_USER.username,
            passwordHash: 'placeholder',
            firstName: TEST_USER.firstName,
            lastName: TEST_USER.lastName,
            role: TEST_USER.role,
            orgId: organization.id,
            profileData: {},
            mfaEnabled: false,
            isActive: true,
        });
    } else {
        await user.update({
            email: TEST_USER.email,
            username: TEST_USER.username,
            firstName: TEST_USER.firstName,
            lastName: TEST_USER.lastName,
            role: TEST_USER.role,
            orgId: organization.id,
            isActive: true,
            mfaEnabled: false,
        });
    }

    await user.setPassword(TEST_USER.password);
    await user.save();

    console.log('Test user ready:');
    console.log(`username: ${TEST_USER.username}`);
    console.log(`email: ${TEST_USER.email}`);
    console.log(`password: ${TEST_USER.password}`);
    console.log(`role: ${TEST_USER.role}`);

    await sequelize.close();
};

main().catch(async (error) => {
    console.error('Failed to create test user:', error);
    try {
        await sequelize.close();
    } catch (_error) {
        // ignore close errors
    }
    process.exit(1);
});
