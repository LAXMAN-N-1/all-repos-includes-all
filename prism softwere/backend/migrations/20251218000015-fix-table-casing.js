'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        const transaction = await queryInterface.sequelize.transaction();
        try {
            const tables = await queryInterface.showAllTables();
            const existingTables = new Set(tables);

            // Rename epics -> Epics
            if (existingTables.has('epics') && !existingTables.has('Epics')) {
                console.log('Renaming epics -> Epics');
                await queryInterface.renameTable('epics', 'Epics', { transaction });
            }

            // Rename features -> Features
            if (existingTables.has('features') && !existingTables.has('Features')) {
                console.log('Renaming features -> Features');
                await queryInterface.renameTable('features', 'Features', { transaction });
            }

            await transaction.commit();
        } catch (error) {
            await transaction.rollback();
            throw error;
        }
    },

    async down(queryInterface, Sequelize) {
        // Reversal not needed for forward fix
    }
};
