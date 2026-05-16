'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        const transaction = await queryInterface.sequelize.transaction();
        try {
            const projectTableInfo = await queryInterface.describeTable('Projects');
            const issueTableInfo = await queryInterface.describeTable('Issues');

            // --- Projects Table Checks ---

            // 'type' column (ENUM: SCRUM, KANBAN, WATERFALL)
            if (!projectTableInfo.type) {
                console.log('Adding type to Projects');
                await queryInterface.addColumn('Projects', 'type', {
                    type: Sequelize.STRING, // Using STRING for flexibility/simplicity
                    defaultValue: 'SCRUM',
                    allowNull: false,
                }, { transaction });
            }

            // 'settings' (JSONB)
            if (!projectTableInfo.settings) {
                console.log('Adding settings to Projects');
                await queryInterface.addColumn('Projects', 'settings', {
                    type: Sequelize.JSONB,
                    defaultValue: {},
                }, { transaction });
            }

            // 'startDate' (DATE)
            if (!projectTableInfo.startDate) {
                console.log('Adding startDate to Projects');
                await queryInterface.addColumn('Projects', 'startDate', {
                    type: Sequelize.DATE,
                    allowNull: true,
                }, { transaction });
            }

            // 'endDate' (DATE)
            if (!projectTableInfo.endDate) {
                console.log('Adding endDate to Projects');
                await queryInterface.addColumn('Projects', 'endDate', {
                    type: Sequelize.DATE,
                    allowNull: true,
                }, { transaction });
            }

            // 'budget' (DECIMAL)
            if (!projectTableInfo.budget) {
                console.log('Adding budget to Projects');
                await queryInterface.addColumn('Projects', 'budget', {
                    type: Sequelize.DECIMAL(10, 2),
                    allowNull: true,
                }, { transaction });
            }


            // --- Issues Table Checks ---

            // 'parentId' (UUID)
            try {
                if (!issueTableInfo.parentId) {
                    console.log('Adding parentId to Issues');
                    await queryInterface.addColumn('Issues', 'parentId', {
                        type: Sequelize.UUID,
                        allowNull: true,
                        references: {
                            model: 'Issues',
                            key: 'id',
                        },
                        onDelete: 'CASCADE',
                    }, { transaction });
                }
            } catch (e) { console.log('Skipping default parentId:', e.message); }

            // 'estimatedHours'
            try {
                if (!issueTableInfo.estimatedHours) {
                    console.log('Adding estimatedHours to Issues');
                    await queryInterface.addColumn('Issues', 'estimatedHours', {
                        type: Sequelize.DECIMAL(10, 2),
                        allowNull: true,
                    }, { transaction });
                }
            } catch (e) { console.log('Skipping default estimatedHours:', e.message); }

            // 'actualHours'
            try {
                if (!issueTableInfo.actualHours) {
                    console.log('Adding actualHours to Issues');
                    await queryInterface.addColumn('Issues', 'actualHours', {
                        type: Sequelize.DECIMAL(10, 2),
                        allowNull: true,
                        defaultValue: 0,
                    }, { transaction });
                }
            } catch (e) { console.log('Skipping default actualHours:', e.message); }

            // 'dueDate'
            try {
                if (!issueTableInfo.dueDate) {
                    console.log('Adding dueDate to Issues');
                    await queryInterface.addColumn('Issues', 'dueDate', {
                        type: Sequelize.DATE,
                        allowNull: true,
                    }, { transaction });
                }
            } catch (e) { console.log('Skipping default dueDate:', e.message); }

            // 'labels' (ARRAY(STRING))
            try {
                if (!issueTableInfo.labels) {
                    console.log('Adding labels to Issues');
                    await queryInterface.addColumn('Issues', 'labels', {
                        type: Sequelize.ARRAY(Sequelize.STRING),
                        defaultValue: [],
                    }, { transaction });
                }
            } catch (e) { console.log('Skipping default labels:', e.message); }

            // 'customFields' (JSONB)
            try {
                if (!issueTableInfo.customFields) {
                    console.log('Adding customFields to Issues');
                    await queryInterface.addColumn('Issues', 'customFields', {
                        type: Sequelize.JSONB,
                        defaultValue: {},
                    }, { transaction });
                }
            } catch (e) { console.log('Skipping default customFields:', e.message); }

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
            const issueTableInfo = await queryInterface.describeTable('Issues');

            // Projects
            if (projectTableInfo.type) await queryInterface.removeColumn('Projects', 'type', { transaction });
            if (projectTableInfo.settings) await queryInterface.removeColumn('Projects', 'settings', { transaction });
            if (projectTableInfo.startDate) await queryInterface.removeColumn('Projects', 'startDate', { transaction });
            if (projectTableInfo.endDate) await queryInterface.removeColumn('Projects', 'endDate', { transaction });
            if (projectTableInfo.budget) await queryInterface.removeColumn('Projects', 'budget', { transaction });

            // Issues
            if (issueTableInfo.parentId) await queryInterface.removeColumn('Issues', 'parentId', { transaction });
            if (issueTableInfo.estimatedHours) await queryInterface.removeColumn('Issues', 'estimatedHours', { transaction });
            if (issueTableInfo.actualHours) await queryInterface.removeColumn('Issues', 'actualHours', { transaction });
            if (issueTableInfo.dueDate) await queryInterface.removeColumn('Issues', 'dueDate', { transaction });
            if (issueTableInfo.labels) await queryInterface.removeColumn('Issues', 'labels', { transaction });
            if (issueTableInfo.customFields) await queryInterface.removeColumn('Issues', 'customFields', { transaction });

            await transaction.commit();
        } catch (error) {
            await transaction.rollback();
            throw error;
        }
    }
};
