'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        const transaction = await queryInterface.sequelize.transaction();
        try {
            const sprintTableInfo = await queryInterface.describeTable('Sprints');

            if (!sprintTableInfo.totalPoints) {
                try {
                    console.log('Adding totalPoints to Sprints');
                    await queryInterface.addColumn('Sprints', 'totalPoints', {
                        type: Sequelize.INTEGER,
                        allowNull: true,
                        defaultValue: 0,
                    }, { transaction });
                } catch (e) { console.log('Skipping totalPoints:', e.message); }
            }

            if (!sprintTableInfo.completedPoints) {
                try {
                    console.log('Adding completedPoints to Sprints');
                    await queryInterface.addColumn('Sprints', 'completedPoints', {
                        type: Sequelize.INTEGER,
                        allowNull: true,
                        defaultValue: 0,
                    }, { transaction });
                } catch (e) { console.log('Skipping completedPoints:', e.message); }
            }

            if (!sprintTableInfo.velocity) {
                try {
                    console.log('Adding velocity to Sprints');
                    await queryInterface.addColumn('Sprints', 'velocity', {
                        type: Sequelize.INTEGER,
                        allowNull: true,
                    }, { transaction });
                } catch (e) { console.log('Skipping velocity:', e.message); }
            }

            // Re-ensure columns from 20251208 exist if that migration failed or was skipped
            if (!sprintTableInfo.key) {
                try {
                    console.log('Adding key to Sprints');
                    await queryInterface.addColumn('Sprints', 'key', {
                        type: Sequelize.STRING,
                        allowNull: true
                    }, { transaction });
                } catch (e) { console.log('Skipping key:', e.message); }
            }
            if (!sprintTableInfo.notes) {
                try {
                    console.log('Adding notes to Sprints');
                    await queryInterface.addColumn('Sprints', 'notes', {
                        type: Sequelize.TEXT,
                        allowNull: true
                    }, { transaction });
                } catch (e) { console.log('Skipping notes:', e.message); }
            }
            if (!sprintTableInfo.plannedPoints) {
                try {
                    console.log('Adding plannedPoints to Sprints');
                    await queryInterface.addColumn('Sprints', 'plannedPoints', {
                        type: Sequelize.INTEGER,
                        allowNull: true
                    }, { transaction });
                } catch (e) { console.log('Skipping plannedPoints:', e.message); }
            }
            if (!sprintTableInfo.burnDownConfig) {
                try {
                    console.log('Adding burnDownConfig to Sprints');
                    await queryInterface.addColumn('Sprints', 'burnDownConfig', {
                        type: Sequelize.JSON,
                        allowNull: true
                    }, { transaction });
                } catch (e) { console.log('Skipping burnDownConfig:', e.message); }
            }


            await transaction.commit();
        } catch (error) {
            await transaction.rollback();
            throw error;
        }
    },

    async down(queryInterface, Sequelize) {
        const transaction = await queryInterface.sequelize.transaction();
        try {
            const sprintTableInfo = await queryInterface.describeTable('Sprints');

            if (sprintTableInfo.totalPoints) await queryInterface.removeColumn('Sprints', 'totalPoints', { transaction });
            if (sprintTableInfo.completedPoints) await queryInterface.removeColumn('Sprints', 'completedPoints', { transaction });
            // Don't remove others as they might be from critical migrations

            await transaction.commit();
        } catch (error) {
            await transaction.rollback();
            throw error;
        }
    }
};
