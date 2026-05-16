'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        const transaction = await queryInterface.sequelize.transaction();
        try {
            // 1. Fix Table Casing (issues -> Issues)
            try {
                const tables = await queryInterface.sequelize.showAllSchemas();
                const [results] = await queryInterface.sequelize.query(
                    "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';"
                );

                const tableNames = results.map(r => r.table_name);

                if (tableNames.includes('issues') && !tableNames.includes('Issues')) {
                    console.log('Renaming issues -> Issues');
                    await queryInterface.renameTable('issues', 'Issues', { transaction });
                }
            } catch (e) {
                console.log('Skipping renameTable (likely already done):', e.message);
            }

            // 2. Fix Projects table columns (client_id)
            try {
                const projectTableInfo = await queryInterface.describeTable('Projects');
                if (!projectTableInfo.client_id) {
                    console.log('Adding client_id to Projects');
                    await queryInterface.addColumn('Projects', 'client_id', {
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
            } catch (e) {
                console.log('Skipping addColumn client_id (likely already exists):', e.message);
            }

            // 3. Ensure 'Issues' exists now
            try {
                const [results] = await queryInterface.sequelize.query(
                    "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';"
                );
                const tableNames = results.map(r => r.table_name);

                if (!tableNames.includes('issues') && !tableNames.includes('Issues')) {
                    console.log('Create Issues table (it was totally missing)');
                    await queryInterface.createTable('Issues', {
                        id: { type: Sequelize.UUID, defaultValue: Sequelize.UUIDV4, primaryKey: true },
                        projectId: { type: Sequelize.UUID, allowNull: false, references: { model: 'Projects', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
                        issueNumber: { type: Sequelize.INTEGER, allowNull: false },
                        key: { type: Sequelize.STRING, allowNull: false, unique: true },
                        type: { type: Sequelize.STRING, allowNull: false },
                        status: { type: Sequelize.STRING, allowNull: false },
                        priority: { type: Sequelize.STRING, allowNull: false },
                        title: { type: Sequelize.STRING, allowNull: false },
                        description: { type: Sequelize.TEXT },
                        assigneeId: { type: Sequelize.UUID, references: { model: 'Users', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'SET NULL' },
                        reporterId: { type: Sequelize.UUID, allowNull: false, references: { model: 'Users', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'RESTRICT' },
                        sprintId: { type: Sequelize.UUID, references: { model: 'Sprints', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'SET NULL' },
                        parentId: { type: Sequelize.UUID, references: { model: 'Issues', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
                        storyPoints: { type: Sequelize.INTEGER },
                        estimatedHours: { type: Sequelize.DECIMAL(8, 2) },
                        actualHours: { type: Sequelize.DECIMAL(8, 2), defaultValue: 0 },
                        dueDate: { type: Sequelize.DATE },
                        labels: { type: Sequelize.ARRAY(Sequelize.STRING), defaultValue: [] },
                        customFields: { type: Sequelize.JSONB, defaultValue: {} },
                        createdAt: { type: Sequelize.DATE, allowNull: false },
                        updatedAt: { type: Sequelize.DATE, allowNull: false },
                    }, { transaction });
                }
            } catch (e) {
                console.log('Skipping createTable Issues (likely already exists):', e.message);
            }

            await transaction.commit();
        } catch (error) {
            await transaction.rollback();
            throw error;
        }
    },

    async down(queryInterface, Sequelize) {
        // Reverting case sensitivity fixes is unpredictable, usually ignored or manual.
        const projectTableInfo = await queryInterface.describeTable('Projects');
        if (projectTableInfo.client_id) {
            await queryInterface.removeColumn('Projects', 'client_id');
        }
    }
};
