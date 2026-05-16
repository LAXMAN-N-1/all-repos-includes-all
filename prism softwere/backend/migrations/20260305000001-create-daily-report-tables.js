'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        // 1. Create DailyReports table
        const tableExists = async (name) => {
            try {
                await queryInterface.describeTable(name);
                return true;
            } catch { return false; }
        };

        if (!(await tableExists('DailyReports'))) {
            // Create enum for status
            await queryInterface.sequelize.query(`
        DO $$ BEGIN
          IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_DailyReports_status') THEN
            CREATE TYPE "enum_DailyReports_status" AS ENUM ('excellent', 'good', 'at-risk', 'missing');
          END IF;
        END $$;
      `);

            await queryInterface.createTable('DailyReports', {
                id: {
                    type: Sequelize.UUID,
                    defaultValue: Sequelize.UUIDV4,
                    primaryKey: true,
                    allowNull: false,
                },
                projectId: {
                    type: Sequelize.UUID,
                    allowNull: false,
                    references: { model: 'Projects', key: 'id' },
                    onDelete: 'CASCADE',
                },
                userId: {
                    type: Sequelize.UUID,
                    allowNull: false,
                    references: { model: 'Users', key: 'id' },
                    onDelete: 'CASCADE',
                },
                date: {
                    type: Sequelize.DATEONLY,
                    allowNull: false,
                },
                standupSubmitted: {
                    type: Sequelize.BOOLEAN,
                    defaultValue: false,
                },
                standupTime: {
                    type: Sequelize.STRING(20),
                    allowNull: true,
                },
                standupTasks: {
                    type: Sequelize.ARRAY(Sequelize.UUID),
                    defaultValue: [],
                },
                concerns: {
                    type: Sequelize.TEXT,
                    defaultValue: '',
                },
                lessonsLearned: {
                    type: Sequelize.TEXT,
                    defaultValue: '',
                },
                summarySubmitted: {
                    type: Sequelize.BOOLEAN,
                    defaultValue: false,
                },
                summaryTime: {
                    type: Sequelize.STRING(20),
                    allowNull: true,
                },
                status: {
                    type: '"enum_DailyReports_status"',
                    defaultValue: 'missing',
                },
                createdAt: {
                    type: Sequelize.DATE,
                    allowNull: false,
                    defaultValue: Sequelize.fn('NOW'),
                },
                updatedAt: {
                    type: Sequelize.DATE,
                    allowNull: false,
                    defaultValue: Sequelize.fn('NOW'),
                },
            });

            // Add indexes
            await queryInterface.addIndex('DailyReports', ['projectId', 'userId', 'date'], { unique: true, name: 'daily_reports_project_user_date_unique' });
            await queryInterface.addIndex('DailyReports', ['projectId'], { name: 'daily_reports_project_id' });
            await queryInterface.addIndex('DailyReports', ['userId'], { name: 'daily_reports_user_id' });
            await queryInterface.addIndex('DailyReports', ['date'], { name: 'daily_reports_date' });

            console.log('✅ Created DailyReports table');
        } else {
            console.log('⏭️  DailyReports table already exists');
        }

        // 2. Create DailyReportEntries table
        if (!(await tableExists('DailyReportEntries'))) {
            // Create enums
            await queryInterface.sequelize.query(`
        DO $$ BEGIN
          IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_DailyReportEntries_type') THEN
            CREATE TYPE "enum_DailyReportEntries_type" AS ENUM ('work', 'blocker');
          END IF;
          IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_DailyReportEntries_severity') THEN
            CREATE TYPE "enum_DailyReportEntries_severity" AS ENUM ('low', 'medium', 'high');
          END IF;
          IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_DailyReportEntries_blockerStatus') THEN
            CREATE TYPE "enum_DailyReportEntries_blockerStatus" AS ENUM ('OPEN', 'RESOLVED');
          END IF;
        END $$;
      `);

            await queryInterface.createTable('DailyReportEntries', {
                id: {
                    type: Sequelize.UUID,
                    defaultValue: Sequelize.UUIDV4,
                    primaryKey: true,
                    allowNull: false,
                },
                reportId: {
                    type: Sequelize.UUID,
                    allowNull: false,
                    references: { model: 'DailyReports', key: 'id' },
                    onDelete: 'CASCADE',
                },
                taskId: {
                    type: Sequelize.UUID,
                    allowNull: true,
                },
                taskTitle: {
                    type: Sequelize.STRING(500),
                    allowNull: false,
                },
                type: {
                    type: '"enum_DailyReportEntries_type"',
                    defaultValue: 'work',
                },
                hours: {
                    type: Sequelize.DECIMAL(10, 2),
                    defaultValue: 0,
                },
                progress: {
                    type: Sequelize.INTEGER,
                    defaultValue: 0,
                },
                notes: {
                    type: Sequelize.TEXT,
                    defaultValue: '',
                },
                time: {
                    type: Sequelize.STRING(20),
                    allowNull: false,
                },
                severity: {
                    type: '"enum_DailyReportEntries_severity"',
                    allowNull: true,
                },
                blockerStatus: {
                    type: '"enum_DailyReportEntries_blockerStatus"',
                    allowNull: true,
                },
                taggedPeople: {
                    type: Sequelize.ARRAY(Sequelize.UUID),
                    defaultValue: [],
                },
                resolvedAt: {
                    type: Sequelize.STRING(20),
                    allowNull: true,
                },
                createdAt: {
                    type: Sequelize.DATE,
                    allowNull: false,
                    defaultValue: Sequelize.fn('NOW'),
                },
                updatedAt: {
                    type: Sequelize.DATE,
                    allowNull: false,
                    defaultValue: Sequelize.fn('NOW'),
                },
            });

            await queryInterface.addIndex('DailyReportEntries', ['reportId'], { name: 'daily_report_entries_report_id' });
            await queryInterface.addIndex('DailyReportEntries', ['type'], { name: 'daily_report_entries_type' });

            console.log('✅ Created DailyReportEntries table');
        } else {
            console.log('⏭️  DailyReportEntries table already exists');
        }

        // 3. Create DailyReportComments table
        if (!(await tableExists('DailyReportComments'))) {
            await queryInterface.sequelize.query(`
        DO $$ BEGIN
          IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_DailyReportComments_messageType') THEN
            CREATE TYPE "enum_DailyReportComments_messageType" AS ENUM ('comment', 'question', 'announcement', 'action_item');
          END IF;
        END $$;
      `);

            await queryInterface.createTable('DailyReportComments', {
                id: {
                    type: Sequelize.UUID,
                    defaultValue: Sequelize.UUIDV4,
                    primaryKey: true,
                    allowNull: false,
                },
                reportId: {
                    type: Sequelize.UUID,
                    allowNull: false,
                    references: { model: 'DailyReports', key: 'id' },
                    onDelete: 'CASCADE',
                },
                userId: {
                    type: Sequelize.UUID,
                    allowNull: false,
                    references: { model: 'Users', key: 'id' },
                    onDelete: 'CASCADE',
                },
                content: {
                    type: Sequelize.TEXT,
                    allowNull: false,
                },
                mentions: {
                    type: Sequelize.ARRAY(Sequelize.UUID),
                    defaultValue: [],
                },
                messageType: {
                    type: '"enum_DailyReportComments_messageType"',
                    defaultValue: 'comment',
                },
                parentId: {
                    type: Sequelize.UUID,
                    allowNull: true,
                    references: { model: 'DailyReportComments', key: 'id' },
                    onDelete: 'CASCADE',
                },
                isPinned: {
                    type: Sequelize.BOOLEAN,
                    defaultValue: false,
                },
                isEdited: {
                    type: Sequelize.BOOLEAN,
                    defaultValue: false,
                },
                reactions: {
                    type: Sequelize.JSONB,
                    defaultValue: {},
                },
                createdAt: {
                    type: Sequelize.DATE,
                    allowNull: false,
                    defaultValue: Sequelize.fn('NOW'),
                },
                updatedAt: {
                    type: Sequelize.DATE,
                    allowNull: false,
                    defaultValue: Sequelize.fn('NOW'),
                },
            });

            await queryInterface.addIndex('DailyReportComments', ['reportId'], { name: 'daily_report_comments_report_id' });
            await queryInterface.addIndex('DailyReportComments', ['userId'], { name: 'daily_report_comments_user_id' });
            await queryInterface.addIndex('DailyReportComments', ['parentId'], { name: 'daily_report_comments_parent_id' });
            await queryInterface.addIndex('DailyReportComments', ['isPinned'], { name: 'daily_report_comments_is_pinned' });

            console.log('✅ Created DailyReportComments table');
        } else {
            console.log('⏭️  DailyReportComments table already exists');
        }
    },

    async down(queryInterface) {
        await queryInterface.dropTable('DailyReportComments');
        await queryInterface.dropTable('DailyReportEntries');
        await queryInterface.dropTable('DailyReports');

        await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_DailyReports_status";');
        await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_DailyReportEntries_type";');
        await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_DailyReportEntries_severity";');
        await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_DailyReportEntries_blockerStatus";');
        await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_DailyReportComments_messageType";');
    },
};
