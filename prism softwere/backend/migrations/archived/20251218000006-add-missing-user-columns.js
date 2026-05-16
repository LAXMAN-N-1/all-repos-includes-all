'use strict';

module.exports = {
    up: async (queryInterface, Sequelize) => {
        await queryInterface.addColumn('Users', 'phone', {
            type: Sequelize.STRING(20),
            allowNull: true
        });

        await queryInterface.addColumn('Users', 'force_password_change', {
            type: Sequelize.BOOLEAN,
            defaultValue: false
        });

        await queryInterface.addColumn('Users', 'created_by', {
            type: Sequelize.UUID,
            allowNull: true,
            references: {
                model: 'Users',
                key: 'id',
            }
        });
    },

    down: async (queryInterface, Sequelize) => {
        await queryInterface.removeColumn('Users', 'phone');
        await queryInterface.removeColumn('Users', 'force_password_change');
        await queryInterface.removeColumn('Users', 'created_by');
    }
};
