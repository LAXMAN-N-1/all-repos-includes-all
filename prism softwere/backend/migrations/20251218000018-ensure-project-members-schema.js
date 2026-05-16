'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        const transaction = await queryInterface.sequelize.transaction();
        try {
            const pmTableInfo = await queryInterface.describeTable('ProjectMembers');

            if (!pmTableInfo.accessLevel && !pmTableInfo.access_level) {
                console.log('Adding access_level to ProjectMembers');
                await queryInterface.addColumn('ProjectMembers', 'access_level', {
                    type: Sequelize.STRING(20),
                    defaultValue: 'VIEW_ONLY',
                }, { transaction });
            }

            await transaction.commit();
        } catch (error) {
            await transaction.rollback();
            throw error;
        }
    },

    async down(queryInterface, Sequelize) {
        // Reversal
    }
};
