'use strict';

module.exports = {
    up: async (queryInterface, Sequelize) => {
        // Check if table exists before creating
        const tableExists = await queryInterface.tableExists('AuditLogs');

        if (!tableExists) {
            console.log('⚠️ AuditLogs table missing. Creating it now...');
            await queryInterface.createTable('AuditLogs', {
                id: {
                    type: Sequelize.UUID,
                    defaultValue: Sequelize.UUIDV4,
                    primaryKey: true,
                },
                userId: {
                    type: Sequelize.UUID,
                    allowNull: false,
                    references: {
                        model: 'Users',
                        key: 'id',
                    },
                    onUpdate: 'CASCADE',
                    onDelete: 'CASCADE',
                },
                action: {
                    type: Sequelize.STRING,
                    allowNull: false,
                },
                resource: {
                    type: Sequelize.STRING,
                    allowNull: false,
                },
                resourceId: {
                    type: Sequelize.UUID,
                },
                details: {
                    type: Sequelize.JSONB,
                    defaultValue: {},
                },
                ipAddress: {
                    type: Sequelize.STRING,
                },
                userAgent: {
                    type: Sequelize.STRING,
                },
                createdAt: {
                    type: Sequelize.DATE,
                    allowNull: false,
                },
                updatedAt: {
                    type: Sequelize.DATE,
                    allowNull: false,
                },
            });

            // Add indexes
            await queryInterface.addIndex('AuditLogs', ['userId']);
            await queryInterface.addIndex('AuditLogs', ['resource', 'resourceId']);
            await queryInterface.addIndex('AuditLogs', ['createdAt']);
            console.log('✅ AuditLogs table created successfully.');
        } else {
            console.log('ℹ️ AuditLogs table already exists.');
        }
    },

    down: async (queryInterface, Sequelize) => {
        // Don't drop in down migration as it might be a repair for an existing valid state in other envs
        // But for consistency, we can leave it empty or checking.
    }
};
