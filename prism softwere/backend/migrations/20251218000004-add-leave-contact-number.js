'use strict';

module.exports = {
    up: async (queryInterface, Sequelize) => {
        await queryInterface.addColumn('LeaveRequests', 'contactNumber', {
            type: Sequelize.STRING,
            allowNull: true,
            field: 'contact_number'
        });
    },

    down: async (queryInterface, Sequelize) => {
        await queryInterface.removeColumn('LeaveRequests', 'contactNumber');
    }
};
