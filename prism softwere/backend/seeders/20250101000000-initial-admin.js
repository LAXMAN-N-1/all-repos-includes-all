'use strict';
const bcrypt = require('bcryptjs');

module.exports = {
    async up(queryInterface, Sequelize) {
        // 1. Remove ALL existing admins
        console.log('🗑️  Removing all existing ADMIN users...');
        await queryInterface.bulkDelete('Users', { role: 'ADMIN' }, {});

        // 2. Set up new specific admin
        const adminEmail = 'laxmanlaxman1629@gmail.com';
        const adminPassword = '9640568933';

        console.log('🌱 Seeding specific Admin User...');

        // Hash password
        const passwordHash = await bcrypt.hash(adminPassword, 10);

        // Get or Create Organization
        let orgId;
        const [organizations] = await queryInterface.sequelize.query(
            `SELECT id FROM "Organizations" LIMIT 1;`
        );

        if (organizations.length > 0) {
            orgId = organizations[0].id;
        } else {
            const [newOrg] = await queryInterface.sequelize.query(
                `INSERT INTO "Organizations" (id, name, "subscriptionPlan", "maxUsers", "ssoEnabled", settings, "createdAt", "updatedAt")
                 VALUES (gen_random_uuid(), 'Primary Organization', 'ENTERPRISE', 100, false, '{}', NOW(), NOW())
                 RETURNING id;`
            );
            orgId = newOrg[0].id;
        }

        // Create Admin
        await queryInterface.bulkInsert('Users', [{
            id: Sequelize.literal('gen_random_uuid()'),
            email: adminEmail,
            username: 'admin', // Adding default username just in case
            passwordHash: passwordHash,
            firstName: 'Laxman',
            lastName: 'Admin',
            role: 'ADMIN',
            orgId: orgId,
            isActive: true, // Ensure active
            mfaEnabled: false,
            profileData: JSON.stringify({}),
            createdAt: new Date(),
            updatedAt: new Date(),
            phone: null,
            force_password_change: false,
            created_by: null
        }]);

        console.log(`✅ Admin user reset: ${adminEmail} / ${adminPassword}`);
    },

    async down(queryInterface, Sequelize) {
        // No down action
    }
};
