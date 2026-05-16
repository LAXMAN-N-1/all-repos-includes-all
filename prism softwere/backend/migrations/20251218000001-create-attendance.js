'use strict';

module.exports = {
    up: async (queryInterface, Sequelize) => {
        await queryInterface.createTable('Attendance', {
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
            date: {
                type: Sequelize.DATEONLY,
                allowNull: false
            },
            check_in_time: {
                type: Sequelize.DATE,
                allowNull: true
            },
            check_out_time: {
                type: Sequelize.DATE,
                allowNull: true
            },
            status: {
                type: Sequelize.ENUM('Present', 'Absent', 'Half Day', 'On Leave'),
                defaultValue: 'Present',
                allowNull: false
            },
            total_hours: {
                type: Sequelize.FLOAT,
                allowNull: true
            },
            notes: {
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

        await queryInterface.addIndex('Attendance', ['user_id', 'date'], { unique: true });
    },

    down: async (queryInterface, Sequelize) => {
        await queryInterface.dropTable('Attendance');
    }
};
