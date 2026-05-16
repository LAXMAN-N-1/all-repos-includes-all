'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        const transaction = await queryInterface.sequelize.transaction();
        try {
            const tables = await queryInterface.showAllTables();
            const existingTables = new Set(tables);

            const findTable = (name) => {
                if (existingTables.has(name)) return name;
                for (const t of existingTables) {
                    if (t.toLowerCase() === name.toLowerCase()) return t;
                }
                return null;
            };

            const featuresTable = findTable('Features');

            if (featuresTable) {
                console.log(`Fixing Features table: ${featuresTable}`);

                // 1. Clean up orphaned Features (invalid project_id)
                await queryInterface.sequelize.query(
                    `DELETE FROM "${featuresTable}" WHERE "project_id" NOT IN (SELECT "id" FROM "Projects")`,
                    { transaction }
                );

                // 2. Clean up orphaned Features (invalid epic_id) - assuming epic_id is nullable, we set to null instead of delete?
                // Actually safer to set to NULL if orphan
                await queryInterface.sequelize.query(
                    `UPDATE "${featuresTable}" SET "epic_id" = NULL WHERE "epic_id" IS NOT NULL AND "epic_id" NOT IN (SELECT "id" FROM "Epics")`,
                    { transaction }
                );

                // 3. Clean up orphaned Features (invalid owner_id)
                await queryInterface.sequelize.query(
                    `UPDATE "${featuresTable}" SET "owner_id" = NULL WHERE "owner_id" IS NOT NULL AND "owner_id" NOT IN (SELECT "id" FROM "Users")`,
                    { transaction }
                );

                // 4. Drop old constraints (IF EXISTS)
                const constraints = ['features_project_id_fkey', 'features_epic_id_fkey', 'features_owner_id_fkey'];
                for (const constraint of constraints) {
                    await queryInterface.sequelize.query(
                        `ALTER TABLE "${featuresTable}" DROP CONSTRAINT IF EXISTS "${constraint}"`,
                        { transaction }
                    );
                    // Also try v2/v3 variants just in case
                    await queryInterface.sequelize.query(
                        `ALTER TABLE "${featuresTable}" DROP CONSTRAINT IF EXISTS "${constraint}_v2"`,
                        { transaction }
                    );
                }

                // 5. Add valid constraints

                // Project FK
                console.log('Adding FK Features.projectId -> Projects.id');
                await queryInterface.addConstraint(featuresTable, {
                    fields: ['project_id'],
                    type: 'foreign key',
                    name: 'features_project_id_fkey_v2',
                    references: { table: 'Projects', field: 'id' },
                    onDelete: 'CASCADE',
                    onUpdate: 'CASCADE',
                    transaction
                });

                // Epic FK
                console.log('Adding FK Features.epicId -> Epics.id');
                await queryInterface.addConstraint(featuresTable, {
                    fields: ['epic_id'],
                    type: 'foreign key',
                    name: 'features_epic_id_fkey_v2',
                    references: { table: 'Epics', field: 'id' },
                    onDelete: 'SET NULL',
                    onUpdate: 'CASCADE',
                    transaction
                });

                // Owner FK
                console.log('Adding FK Features.ownerId -> Users.id');
                await queryInterface.addConstraint(featuresTable, {
                    fields: ['owner_id'],
                    type: 'foreign key',
                    name: 'features_owner_id_fkey_v2',
                    references: { table: 'Users', field: 'id' },
                    onDelete: 'SET NULL',
                    onUpdate: 'CASCADE',
                    transaction
                });

            } else {
                console.log('Features table not found! Skipping FK fix.');
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
