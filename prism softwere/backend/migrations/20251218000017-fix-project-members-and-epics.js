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

            // 1. PROJECT MEMBERS
            let projectMembersTable = findTable('ProjectMembers');

            if (!projectMembersTable) {
                console.log('Creating ProjectMembers table');
                await queryInterface.createTable('ProjectMembers', {
                    id: {
                        type: Sequelize.UUID,
                        defaultValue: Sequelize.UUIDV4,
                        primaryKey: true,
                    },
                    projectId: {
                        type: Sequelize.UUID,
                        allowNull: false,
                        references: {
                            model: 'Projects',
                            key: 'id',
                        },
                        onDelete: 'CASCADE',
                        field: 'project_id'
                    },
                    userId: {
                        type: Sequelize.UUID,
                        allowNull: false,
                        references: {
                            model: 'Users',
                            key: 'id',
                        },
                        onDelete: 'CASCADE',
                        field: 'user_id'
                    },
                    role: {
                        type: Sequelize.STRING(50),
                        allowNull: false,
                        defaultValue: 'MEMBER',
                    },
                    accessLevel: {
                        type: Sequelize.STRING(20),
                        defaultValue: 'VIEW_ONLY',
                        field: 'access_level'
                    },
                    createdAt: { type: Sequelize.DATE, allowNull: false, field: 'created_at' },
                    updatedAt: { type: Sequelize.DATE, allowNull: false, field: 'updated_at' }
                }, { transaction });

                // Raw SQL to add unique constraint safely
                await queryInterface.sequelize.query(
                    `ALTER TABLE "ProjectMembers" ADD CONSTRAINT "unique_project_member_v2" UNIQUE ("project_id", "user_id")`,
                    { transaction }
                );

            } else {
                if (projectMembersTable !== 'ProjectMembers') {
                    console.log(`Renaming ${projectMembersTable} -> ProjectMembers`);
                    await queryInterface.renameTable(projectMembersTable, 'ProjectMembers', { transaction });
                    projectMembersTable = 'ProjectMembers';
                }
            }

            // 2. FIX EPICS FK
            const epicsTable = findTable('Epics');
            if (epicsTable) {
                console.log(`Fixing Epics table: ${epicsTable}`);

                // A. Clean up orphaned Epics
                await queryInterface.sequelize.query(
                    `DELETE FROM "${epicsTable}" WHERE "project_id" NOT IN (SELECT "id" FROM "Projects")`,
                    { transaction }
                );

                // B. Drop old constraints (IF EXISTS)
                await queryInterface.sequelize.query(
                    `ALTER TABLE "${epicsTable}" DROP CONSTRAINT IF EXISTS "epics_project_id_fkey"`,
                    { transaction }
                );
                await queryInterface.sequelize.query(
                    `ALTER TABLE "${epicsTable}" DROP CONSTRAINT IF EXISTS "epics_project_id_fkey_v2"`,
                    { transaction }
                );

                // C. Add valid constraint
                await queryInterface.sequelize.query(
                    `ALTER TABLE "${epicsTable}" ADD CONSTRAINT "epics_project_id_fkey_v2" FOREIGN KEY ("project_id") REFERENCES "Projects" ("id") ON DELETE CASCADE ON UPDATE CASCADE`,
                    { transaction }
                );
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
