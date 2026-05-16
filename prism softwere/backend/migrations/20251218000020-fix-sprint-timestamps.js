'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        const transaction = await queryInterface.sequelize.transaction();
        try {
            const table = 'SprintMembers';
            const tableInfo = await queryInterface.describeTable(table);

            // Rename created_at -> createdAt
            if (tableInfo.created_at) {
                console.log('Renaming created_at -> createdAt');
                await queryInterface.renameColumn(table, 'created_at', 'createdAt', { transaction });
            }

            // Rename updated_at -> updatedAt
            if (tableInfo.updated_at) {
                console.log('Renaming updated_at -> updatedAt');
                await queryInterface.renameColumn(table, 'updated_at', 'updatedAt', { transaction });
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
