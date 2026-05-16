'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        const transaction = await queryInterface.sequelize.transaction();
        try {
            const projectTableInfo = await queryInterface.describeTable('Projects');

            if (!projectTableInfo.project_manager_id) {
                console.log('Adding project_manager_id to Projects');
                await queryInterface.addColumn('Projects', 'project_manager_id', {
                    type: Sequelize.UUID,
                    allowNull: true,
                    references: {
                        model: 'Users',
                        key: 'id',
                    },
                    onUpdate: 'CASCADE',
                    onDelete: 'SET NULL',
                }, { transaction });
            }

            if (!projectTableInfo.scrum_master_id) {
                console.log('Adding scrum_master_id to Projects');
                await queryInterface.addColumn('Projects', 'scrum_master_id', {
                    type: Sequelize.UUID,
                    allowNull: true,
                    references: {
                        model: 'Users',
                        key: 'id',
                    },
                    onUpdate: 'CASCADE',
                    onDelete: 'SET NULL',
                }, { transaction });
            }

            // Also checking for uses_epics and uses_sprints just in case
            if (!projectTableInfo.uses_epics) {
                console.log('Adding uses_epics to Projects');
                await queryInterface.addColumn('Projects', 'uses_epics', {
                    type: Sequelize.BOOLEAN,
                    defaultValue: true,
                    allowNull: false,
                }, { transaction });
            }

            if (!projectTableInfo.uses_sprints) {
                console.log('Adding uses_sprints to Projects');
                await queryInterface.addColumn('Projects', 'uses_sprints', {
                    type: Sequelize.BOOLEAN,
                    defaultValue: true,
                    allowNull: false,
                }, { transaction });
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
            const projectTableInfo = await queryInterface.describeTable('Projects');

            if (projectTableInfo.project_manager_id) {
                await queryInterface.removeColumn('Projects', 'project_manager_id', { transaction });
            }
            if (projectTableInfo.scrum_master_id) {
                await queryInterface.removeColumn('Projects', 'scrum_master_id', { transaction });
            }
            if (projectTableInfo.uses_epics) {
                await queryInterface.removeColumn('Projects', 'uses_epics', { transaction });
            }
            if (projectTableInfo.uses_sprints) {
                await queryInterface.removeColumn('Projects', 'uses_sprints', { transaction });
            }
            await transaction.commit();
        } catch (error) {
            await transaction.rollback();
            throw error;
        }
    }
};
