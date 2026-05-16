'use strict';

module.exports = {
    up: async (queryInterface, Sequelize) => {
        await queryInterface.addColumn('Attendance', 'workLocation', {
            type: Sequelize.ENUM('Office', 'Home', 'Remote'),
            allowNull: true,
            defaultValue: 'Office'
        });

        await queryInterface.addColumn('Attendance', 'approvalStatus', {
            type: Sequelize.ENUM('Pending', 'Approved', 'Rejected'),
            allowNull: false,
            defaultValue: 'Pending'
        });

        await queryInterface.addColumn('Attendance', 'rejectionReason', {
            type: Sequelize.TEXT,
            allowNull: true
        });
    },

    down: async (queryInterface, Sequelize) => {
        await queryInterface.removeColumn('Attendance', 'workLocation');
        await queryInterface.removeColumn('Attendance', 'approvalStatus');
        await queryInterface.removeColumn('Attendance', 'rejectionReason');
    }
};
