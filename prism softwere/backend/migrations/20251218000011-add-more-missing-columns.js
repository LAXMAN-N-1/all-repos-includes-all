'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        const transaction = await queryInterface.sequelize.transaction();
        try {
            const projectTableInfo = await queryInterface.describeTable('Projects');
            const issueTableInfo = await queryInterface.describeTable('Issues');

            // 1. Fix Projects table
            if (!projectTableInfo.clientConfig) {
                try {
                    console.log('Adding clientConfig to Projects');
                    await queryInterface.addColumn('Projects', 'clientConfig', {
                        type: Sequelize.JSONB,
                        defaultValue: { showBudget: false, allowTaskCreation: false },
                    }, { transaction });
                } catch (e) { console.log('Skipping clientConfig:', e.message); }
            }

            // 2. Fix Issues table
            if (!issueTableInfo.epic_id) {
                try {
                    console.log('Adding epic_id to Issues');
                    await queryInterface.addColumn('Issues', 'epic_id', {
                        type: Sequelize.UUID,
                        allowNull: true,
                        references: {
                            model: 'Issues', // Self-reference
                            key: 'id',
                        },
                        onDelete: 'SET NULL',
                    }, { transaction });
                } catch (e) { console.log('Skipping epic_id:', e.message); }
            }

            if (!issueTableInfo.feature_id) {
                try {
                    console.log('Adding feature_id to Issues');
                    // Note: Features table might not exist yet, so we reference it carefully or just add the column for now.
                    // If Features model exists, we can reference it. If not, maybe just UUID.
                    // Assuming Features table exists or will exist. If not, this might fail if we add FK.
                    // Let's check generally if we can just add the column.
                    await queryInterface.addColumn('Issues', 'feature_id', {
                        type: Sequelize.UUID,
                        allowNull: true,
                        // referencing Features if it exists, otherwise just a column
                    }, { transaction });
                } catch (e) { console.log('Skipping feature_id:', e.message); }
            }

            if (!issueTableInfo.storyPoints) {
                try {
                    console.log('Adding storyPoints to Issues');
                    await queryInterface.addColumn('Issues', 'storyPoints', {
                        type: Sequelize.INTEGER,
                        allowNull: true,
                    }, { transaction });
                } catch (e) { console.log('Skipping storyPoints:', e.message); }
            }

            if (!issueTableInfo.fixVersion) {
                try {
                    console.log('Adding fixVersion to Issues');
                    await queryInterface.addColumn('Issues', 'fixVersion', {
                        type: Sequelize.STRING,
                        allowNull: true,
                    }, { transaction });
                } catch (e) { console.log('Skipping fixVersion:', e.message); }
            }

            if (!issueTableInfo.order_index) {
                try {
                    console.log('Adding order_index to Issues');
                    await queryInterface.addColumn('Issues', 'order_index', {
                        type: Sequelize.INTEGER,
                        allowNull: false,
                        defaultValue: 0,
                    }, { transaction });
                } catch (e) { console.log('Skipping order_index:', e.message); }
            }

            if (!issueTableInfo.is_client_visible) {
                try {
                    console.log('Adding is_client_visible to Issues');
                    await queryInterface.addColumn('Issues', 'is_client_visible', {
                        type: Sequelize.BOOLEAN,
                        defaultValue: false,
                        allowNull: false,
                    }, { transaction });
                } catch (e) { console.log('Skipping is_client_visible:', e.message); }
            }

            if (!issueTableInfo.client_approval_status) {
                try {
                    console.log('Adding client_approval_status to Issues');
                    // Provide enum values explicitly if needed, or rely on string/enum type
                    await queryInterface.addColumn('Issues', 'client_approval_status', {
                        type: Sequelize.STRING, // Using STRING to be safe or define ENUM
                        allowNull: true,
                    }, { transaction });
                } catch (e) { console.log('Skipping client_approval_status:', e.message); }
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
            const issueTableInfo = await queryInterface.describeTable('Issues');

            if (projectTableInfo.clientConfig) {
                await queryInterface.removeColumn('Projects', 'clientConfig', { transaction });
            }
            if (issueTableInfo.epic_id) {
                await queryInterface.removeColumn('Issues', 'epic_id', { transaction });
            }
            if (issueTableInfo.feature_id) {
                await queryInterface.removeColumn('Issues', 'feature_id', { transaction });
            }
            if (issueTableInfo.storyPoints) {
                await queryInterface.removeColumn('Issues', 'storyPoints', { transaction });
            }
            if (issueTableInfo.fixVersion) {
                await queryInterface.removeColumn('Issues', 'fixVersion', { transaction });
            }
            if (issueTableInfo.order_index) {
                await queryInterface.removeColumn('Issues', 'order_index', { transaction });
            }
            if (issueTableInfo.is_client_visible) {
                await queryInterface.removeColumn('Issues', 'is_client_visible', { transaction });
            }
            if (issueTableInfo.client_approval_status) {
                await queryInterface.removeColumn('Issues', 'client_approval_status', { transaction });
            }

            await transaction.commit();
        } catch (error) {
            await transaction.rollback();
            throw error;
        }
    }
};
