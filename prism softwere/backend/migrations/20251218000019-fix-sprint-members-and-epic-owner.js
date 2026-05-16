'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        const transaction = await queryInterface.sequelize.transaction();
        try {
            // 1. Fix SprintMembers Columns (snake_case -> camelCase)
            // The error "column sprintMembers.sprintId does not exist" implies Sequelize is querying camelCase.

            const smTable = 'SprintMembers';
            const smTableInfo = await queryInterface.describeTable(smTable);

            // Rename sprint_id -> sprintId
            if (smTableInfo.sprint_id) {
                console.log('Renaming sprint_id -> sprintId in SprintMembers');
                await queryInterface.renameColumn(smTable, 'sprint_id', 'sprintId', { transaction });
            }

            // Rename user_id -> userId
            if (smTableInfo.user_id) {
                console.log('Renaming user_id -> userId in SprintMembers');
                await queryInterface.renameColumn(smTable, 'user_id', 'userId', { transaction });
            }

            // Rename capacity_hours -> capacityHours
            if (smTableInfo.capacity_hours) {
                console.log('Renaming capacity_hours -> capacityHours in SprintMembers');
                await queryInterface.renameColumn(smTable, 'capacity_hours', 'capacityHours', { transaction });
            }


            // 2. Fix Epics Owner FK
            // Re-add robustly
            console.log('Adding FK Epics.ownerId -> Users.id');
            await queryInterface.addConstraint('Epics', {
                fields: ['owner_id'], // This column exists as snake_case in Epics from ...14
                type: 'foreign key',
                name: 'epics_owner_id_fkey_v2', // New name
                references: {
                    table: 'Users',
                    field: 'id',
                },
                onDelete: 'SET NULL',
                onUpdate: 'CASCADE',
                transaction,
            });

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
