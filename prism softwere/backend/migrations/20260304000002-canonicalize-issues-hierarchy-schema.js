'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        const transaction = await queryInterface.sequelize.transaction();

        try {
            const tableName = 'Issues';
            const tableInfo = await queryInterface.describeTable(tableName);
            const hasColumn = (column) => Object.prototype.hasOwnProperty.call(tableInfo, column);

            if (!hasColumn('is_client_visible')) {
                await queryInterface.addColumn(tableName, 'is_client_visible', {
                    type: Sequelize.BOOLEAN,
                    allowNull: false,
                    defaultValue: false,
                }, { transaction });
            }

            if (!hasColumn('client_approval_status')) {
                await queryInterface.addColumn(tableName, 'client_approval_status', {
                    type: Sequelize.STRING,
                    allowNull: true,
                }, { transaction });
            }

            if (!hasColumn('order_index')) {
                await queryInterface.addColumn(tableName, 'order_index', {
                    type: Sequelize.INTEGER,
                    allowNull: false,
                    defaultValue: 0,
                }, { transaction });
            }

            if (!hasColumn('epic_id')) {
                await queryInterface.addColumn(tableName, 'epic_id', {
                    type: Sequelize.UUID,
                    allowNull: true,
                }, { transaction });
            }

            if (!hasColumn('feature_id')) {
                await queryInterface.addColumn(tableName, 'feature_id', {
                    type: Sequelize.UUID,
                    allowNull: true,
                }, { transaction });
            }

            if (hasColumn('isClientVisible')) {
                await queryInterface.sequelize.query(
                    `UPDATE "Issues"
                     SET "is_client_visible" = COALESCE("is_client_visible", "isClientVisible", false)`,
                    { transaction }
                );
            }

            if (hasColumn('clientApprovalStatus')) {
                await queryInterface.sequelize.query(
                    `UPDATE "Issues"
                     SET "client_approval_status" = COALESCE("client_approval_status", "clientApprovalStatus"::text)`,
                    { transaction }
                );
            }

            if (hasColumn('isClientVisible')) {
                await queryInterface.removeColumn(tableName, 'isClientVisible', { transaction });
            }

            if (hasColumn('clientApprovalStatus')) {
                await queryInterface.removeColumn(tableName, 'clientApprovalStatus', { transaction });
            }

            await queryInterface.sequelize.query(
                `UPDATE "Issues" i
                 SET "epic_id" = NULL
                 WHERE "epic_id" IS NOT NULL
                   AND NOT EXISTS (
                       SELECT 1 FROM "Epics" e WHERE e.id = i."epic_id"
                   )`,
                { transaction }
            );

            await queryInterface.sequelize.query(
                `UPDATE "Issues" i
                 SET "feature_id" = NULL
                 WHERE "feature_id" IS NOT NULL
                   AND NOT EXISTS (
                       SELECT 1 FROM "Features" f WHERE f.id = i."feature_id"
                   )`,
                { transaction }
            );

            await queryInterface.sequelize.query(
                `DO $$
                 DECLARE fk_name TEXT;
                 BEGIN
                   FOR fk_name IN
                       SELECT DISTINCT c.conname
                       FROM pg_constraint c
                       JOIN pg_class t ON t.oid = c.conrelid
                       JOIN pg_namespace n ON n.oid = t.relnamespace
                       JOIN unnest(c.conkey) AS cols(attnum) ON TRUE
                       JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = cols.attnum
                       WHERE c.contype = 'f'
                         AND n.nspname = 'public'
                         AND t.relname = 'Issues'
                         AND a.attname IN ('epic_id', 'feature_id')
                   LOOP
                       EXECUTE format('ALTER TABLE "Issues" DROP CONSTRAINT IF EXISTS %I', fk_name);
                   END LOOP;
                 END $$;`,
                { transaction }
            );

            await queryInterface.addConstraint(tableName, {
                fields: ['epic_id'],
                type: 'foreign key',
                name: 'issues_epic_id_fkey_epics_canonical',
                references: {
                    table: 'Epics',
                    field: 'id',
                },
                onUpdate: 'CASCADE',
                onDelete: 'SET NULL',
                transaction,
            });

            await queryInterface.addConstraint(tableName, {
                fields: ['feature_id'],
                type: 'foreign key',
                name: 'issues_feature_id_fkey_features_canonical',
                references: {
                    table: 'Features',
                    field: 'id',
                },
                onUpdate: 'CASCADE',
                onDelete: 'SET NULL',
                transaction,
            });

            await queryInterface.sequelize.query(
                `CREATE INDEX IF NOT EXISTS "issues_epic_id_idx" ON "Issues" ("epic_id")`,
                { transaction }
            );

            await queryInterface.sequelize.query(
                `CREATE INDEX IF NOT EXISTS "issues_feature_id_idx" ON "Issues" ("feature_id")`,
                { transaction }
            );

            await queryInterface.sequelize.query(
                `CREATE INDEX IF NOT EXISTS "issues_order_index_idx" ON "Issues" ("order_index")`,
                { transaction }
            );

            await transaction.commit();
        } catch (error) {
            await transaction.rollback();
            throw error;
        }
    },

    async down(queryInterface, Sequelize) {
        const transaction = await queryInterface.sequelize.transaction();

        try {
            const tableName = 'Issues';
            const tableInfo = await queryInterface.describeTable(tableName);

            if (!tableInfo.isClientVisible) {
                await queryInterface.addColumn(tableName, 'isClientVisible', {
                    type: Sequelize.BOOLEAN,
                    allowNull: false,
                    defaultValue: false,
                }, { transaction });
            }

            if (!tableInfo.clientApprovalStatus) {
                await queryInterface.addColumn(tableName, 'clientApprovalStatus', {
                    type: Sequelize.STRING,
                    allowNull: true,
                }, { transaction });
            }

            await queryInterface.sequelize.query(
                `UPDATE "Issues"
                 SET "isClientVisible" = COALESCE("isClientVisible", "is_client_visible", false),
                     "clientApprovalStatus" = COALESCE("clientApprovalStatus", "client_approval_status")`,
                { transaction }
            );

            await queryInterface.sequelize.query(
                `ALTER TABLE "Issues" DROP CONSTRAINT IF EXISTS "issues_epic_id_fkey_epics_canonical"`,
                { transaction }
            );
            await queryInterface.sequelize.query(
                `ALTER TABLE "Issues" DROP CONSTRAINT IF EXISTS "issues_feature_id_fkey_features_canonical"`,
                { transaction }
            );

            await transaction.commit();
        } catch (error) {
            await transaction.rollback();
            throw error;
        }
    },
};
