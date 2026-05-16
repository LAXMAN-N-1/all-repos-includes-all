'use strict';

module.exports = {
    up: async (queryInterface, Sequelize) => {
        await queryInterface.addColumn('Users', 'username', {
            type: Sequelize.STRING(50),
            allowNull: true,
            unique: true
        });
    },

    down: async (queryInterface, Sequelize) => {
        await queryInterface.removeColumn('Users', 'username');
    }
};
