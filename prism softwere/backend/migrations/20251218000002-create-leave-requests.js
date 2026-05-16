'use strict';

module.exports = {
    up: async (queryInterface, Sequelize) => {
        await queryInterface.createTable('LeaveRequests', {
            id: {
                allowNull: false,
                primaryKey: true,
                type: Sequelize.UUID,
                defaultValue: Sequelize.UUIDV4
            },
            user_id: {
                type: Sequelize.UUID,
                allowNull: false,
                references: {
                    model: 'Users',
                    key: 'id'
                },
                onDelete: 'CASCADE'
            },
            leave_type: {
                type: Sequelize.ENUM('Annual', 'Sick', 'Casual', 'Other'),
                allowNull: false
            },
            start_date: {
                type: Sequelize.DATEONLY,
                allowNull: false
            },
            end_date: {
                type: Sequelize.DATEONLY,
                allowNull: false
            },
            days_count: {
                type: Sequelize.FLOAT,
                allowNull: false
            },
            reason: {
                type: Sequelize.TEXT,
                allowNull: false
            },
            status: {
                type: Sequelize.ENUM('Pending', 'Approved', 'Rejected', 'Cancelled'),
                defaultValue: 'Pending',
                allowNull: false
            },
            approved_by: {
                type: Sequelize.UUID,
                allowNull: true,
                references: {
                    model: 'Users',
                    key: 'id'
                }
            },
            rejection_reason: {
                type: Sequelize.TEXT,
                allowNull: true
            },
            createdAt: {
                allowNull: false,
                type: Sequelize.DATE
            },
            updatedAt: {
                allowNull: false,
                type: Sequelize.DATE
            }
        });

        await queryInterface.addIndex('LeaveRequests', ['user_id', 'status']);
    },

    down: async (queryInterface, Sequelize) => {
        await queryInterface.dropTable('LeaveRequests');
    }
};
