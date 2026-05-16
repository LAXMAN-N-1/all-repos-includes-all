'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        // We will use separate transactions or logic branches to ensure safety.
        const transaction = await queryInterface.sequelize.transaction();

        try {
            const tables = await queryInterface.showAllTables();
            const existingTables = new Set(tables); // tables might be ['Epics', 'Features'] or lowercase

            // Helper to check table existence case-insensitively
            const findTable = (name) => {
                // Check exact match first
                if (existingTables.has(name)) return name;
                // Check lowercase match
                for (const t of existingTables) {
                    if (t.toLowerCase() === name.toLowerCase()) return t;
                }
                return null;
            };

            const EpicsTable = findTable('Epics');
            const FeaturesTable = findTable('Features');

            // --- 1. EPICS ---
            if (!EpicsTable) {
                console.log('Creating Epics table with ALL columns');
                await queryInterface.createTable('Epics', {
                    id: { type: Sequelize.UUID, defaultValue: Sequelize.UUIDV4, primaryKey: true },
                    project_id: { type: Sequelize.UUID, allowNull: false, references: { model: 'Projects', key: 'id' }, onDelete: 'CASCADE' },
                    name: { type: Sequelize.STRING, allowNull: false },
                    description: { type: Sequelize.TEXT, allowNull: true },
                    key: { type: Sequelize.STRING, allowNull: true },
                    status: { type: Sequelize.STRING, defaultValue: 'OPEN' },
                    priority: { type: Sequelize.STRING, defaultValue: 'MEDIUM' },
                    owner_id: { type: Sequelize.UUID, allowNull: true, references: { model: 'Users', key: 'id' } },
                    start_date: { type: Sequelize.DATE, allowNull: true },
                    end_date: { type: Sequelize.DATE, allowNull: true },
                    color: { type: Sequelize.STRING, allowNull: true },
                    goals: { type: Sequelize.TEXT, allowNull: true },
                    tags: { type: Sequelize.ARRAY(Sequelize.STRING), defaultValue: [] },
                    business_value: { type: Sequelize.STRING, allowNull: true },
                    is_visible_to_client: { type: Sequelize.BOOLEAN, defaultValue: false },
                    completed_at: { type: Sequelize.DATE, allowNull: true },
                    created_at: { type: Sequelize.DATE, allowNull: false },
                    updated_at: { type: Sequelize.DATE, allowNull: false }
                }, { transaction });
            } else {
                console.log(`Epics table exists as ${EpicsTable}. Checking columns...`);
                const epicTableInfo = await queryInterface.describeTable(EpicsTable);

                const epicColumns = [
                    { name: 'description', type: Sequelize.TEXT, allowNull: true },
                    { name: 'key', type: Sequelize.STRING, allowNull: true },
                    { name: 'status', type: Sequelize.STRING, defaultValue: 'OPEN' },
                    { name: 'priority', type: Sequelize.STRING, defaultValue: 'MEDIUM' },
                    { name: 'owner_id', type: Sequelize.UUID, allowNull: true, references: { model: 'Users', key: 'id' } },
                    { name: 'start_date', type: Sequelize.DATE, allowNull: true },
                    { name: 'end_date', type: Sequelize.DATE, allowNull: true },
                    { name: 'color', type: Sequelize.STRING, allowNull: true },
                    { name: 'goals', type: Sequelize.TEXT, allowNull: true },
                    // Note: describeTable returns keys in lowercase typically
                    { name: 'tags', type: Sequelize.ARRAY(Sequelize.STRING), defaultValue: [], checkName: 'tags' },
                    { name: 'business_value', type: Sequelize.STRING, allowNull: true, checkName: 'business_value' },
                    { name: 'is_visible_to_client', type: Sequelize.BOOLEAN, defaultValue: false, checkName: 'is_visible_to_client' },
                    { name: 'completed_at', type: Sequelize.DATE, allowNull: true, checkName: 'completed_at' }
                ];

                for (const col of epicColumns) {
                    const colName = col.checkName || col.name;
                    if (!epicTableInfo[colName] && !epicTableInfo[colName.toLowerCase()]) {
                        console.log(`Adding ${col.name} to ${EpicsTable}`);
                        await queryInterface.addColumn(EpicsTable, col.name, {
                            type: col.type,
                            allowNull: col.allowNull,
                            defaultValue: col.defaultValue,
                            references: col.references
                        }, { transaction });
                    }
                }
            }

            // --- 2. FEATURES ---
            if (!FeaturesTable) {
                console.log('Creating Features table with ALL columns');
                await queryInterface.createTable('Features', {
                    id: { type: Sequelize.UUID, defaultValue: Sequelize.UUIDV4, primaryKey: true },
                    project_id: { type: Sequelize.UUID, allowNull: false, references: { model: 'Projects', key: 'id' }, onDelete: 'CASCADE' },
                    name: { type: Sequelize.STRING, allowNull: false },
                    description: { type: Sequelize.TEXT, allowNull: true },
                    key: { type: Sequelize.STRING, allowNull: true },
                    // Sequelize model defines 'acceptanceCriteria' (underscore: true) -> 'acceptance_criteria'
                    acceptance_criteria: { type: Sequelize.TEXT, allowNull: true },
                    status: { type: Sequelize.STRING, defaultValue: 'TO_DO' },
                    priority: { type: Sequelize.STRING, defaultValue: 'MEDIUM' },
                    owner_id: { type: Sequelize.UUID, allowNull: true, references: { model: 'Users', key: 'id' } },
                    start_date: { type: Sequelize.DATE, allowNull: true },
                    end_date: { type: Sequelize.DATE, allowNull: true },
                    story_points: { type: Sequelize.INTEGER, allowNull: true },
                    color: { type: Sequelize.STRING, allowNull: true },
                    tags: { type: Sequelize.ARRAY(Sequelize.STRING), defaultValue: [] },
                    epic_id: { type: Sequelize.UUID, allowNull: true, references: { model: 'Epics', key: 'id' } },
                    created_at: { type: Sequelize.DATE, allowNull: false },
                    updated_at: { type: Sequelize.DATE, allowNull: false }
                }, { transaction });
            } else {
                console.log(`Features table exists as ${FeaturesTable}. Checking columns...`);
                const featureTableInfo = await queryInterface.describeTable(FeaturesTable);

                const featureColumns = [
                    { name: 'description', type: Sequelize.TEXT, allowNull: true },
                    { name: 'key', type: Sequelize.STRING, allowNull: true },
                    { name: 'acceptance_criteria', type: Sequelize.TEXT, allowNull: true, checkName: 'acceptance_criteria' },
                    { name: 'status', type: Sequelize.STRING, defaultValue: 'TO_DO' },
                    { name: 'priority', type: Sequelize.STRING, defaultValue: 'MEDIUM' },
                    { name: 'owner_id', type: Sequelize.UUID, allowNull: true, references: { model: 'Users', key: 'id' } },
                    { name: 'start_date', type: Sequelize.DATE, allowNull: true },
                    { name: 'end_date', type: Sequelize.DATE, allowNull: true },
                    { name: 'story_points', type: Sequelize.INTEGER, allowNull: true, checkName: 'story_points' },
                    { name: 'color', type: Sequelize.STRING, allowNull: true },
                    { name: 'tags', type: Sequelize.ARRAY(Sequelize.STRING), defaultValue: [] },
                    { name: 'epic_id', type: Sequelize.UUID, allowNull: true, references: { model: 'Epics', key: 'id' }, checkName: 'epic_id' }
                ];

                for (const col of featureColumns) {
                    const colName = col.checkName || col.name;
                    if (!featureTableInfo[colName] && !featureTableInfo[colName.toLowerCase()]) {
                        console.log(`Adding ${col.name} to ${FeaturesTable}`);
                        await queryInterface.addColumn(FeaturesTable, col.name, {
                            type: col.type,
                            allowNull: col.allowNull,
                            defaultValue: col.defaultValue,
                            references: col.references
                        }, { transaction });
                    }
                }
            }

            await transaction.commit();
        } catch (error) {
            await transaction.rollback();
            throw error;
        }
    },

    async down(queryInterface, Sequelize) {
        // Optional reversal
    }
};
