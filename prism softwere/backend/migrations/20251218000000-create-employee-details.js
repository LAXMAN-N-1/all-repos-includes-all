'use strict';

module.exports = {
    up: async (queryInterface, Sequelize) => {
        await queryInterface.createTable('EmployeeDetails', {
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
            department: {
                type: Sequelize.STRING,
                allowNull: false
            },
            designation: {
                type: Sequelize.STRING,
                allowNull: false
            },
            employee_id: {
                type: Sequelize.STRING,
                allowNull: false,
                unique: true
            },
            date_of_joining: {
                type: Sequelize.DATEONLY,
                allowNull: false
            },
            employment_type: {
                type: Sequelize.ENUM('Full-time', 'Part-time', 'Contract', 'Intern'),
                allowNull: false
            },
            reporting_manager_id: {
                type: Sequelize.UUID,
                allowNull: true,
                references: {
                    model: 'Users',
                    key: 'id'
                }
            },
            work_location: {
                type: Sequelize.ENUM('Office', 'Remote', 'Hybrid'),
                allowNull: false
            },
            office_location: {
                type: Sequelize.STRING,
                allowNull: true
            },
            shift_timing: {
                type: Sequelize.STRING,
                allowNull: false
            },
            annual_leave_balance: {
                type: Sequelize.FLOAT,
                defaultValue: 20
            },
            sick_leave_balance: {
                type: Sequelize.FLOAT,
                defaultValue: 10
            },
            casual_leave_balance: {
                type: Sequelize.FLOAT,
                defaultValue: 5
            },
            other_leave_balance: {
                type: Sequelize.FLOAT,
                defaultValue: 5
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

        // Add indexes for common lookups
        await queryInterface.addIndex('EmployeeDetails', ['department']);
        await queryInterface.addIndex('EmployeeDetails', ['reporting_manager_id']);
    },

    down: async (queryInterface, Sequelize) => {
        await queryInterface.dropTable('EmployeeDetails');
    }
};
