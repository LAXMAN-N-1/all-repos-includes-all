'use strict';

module.exports = {
    up: async (queryInterface, Sequelize) => {

        const tables = await queryInterface.sequelize.showAllSchemas();
        // Helper to check if table exists (case independent-ish)
        const tableExists = (tableName) => {
            // Check if exact match or lowercase match exists in the list of tables
            // This is a rough check but safer than queryInterface.tableExists which is specific
            return tables.some(t => t.tableName === tableName || t.tableName === tableName.toLowerCase() || t.tableName === `"${tableName}"`);
        };

        // 1. Projects
        try {
            if (!tableExists('Projects')) {
                console.log('⚠️ Projects table missing. Creating it now...');
                await queryInterface.createTable('Projects', {
                    id: { type: Sequelize.UUID, defaultValue: Sequelize.UUIDV4, primaryKey: true },
                    name: { type: Sequelize.STRING, allowNull: false },
                    key: { type: Sequelize.STRING, allowNull: false, unique: true },
                    description: { type: Sequelize.TEXT },
                    orgId: { type: Sequelize.UUID, allowNull: false, references: { model: 'Organizations', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
                    leadId: { type: Sequelize.UUID, allowNull: false, references: { model: 'Users', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'RESTRICT' },
                    settings: { type: Sequelize.JSONB, defaultValue: {} },
                    status: { type: Sequelize.STRING, allowNull: false, defaultValue: 'ACTIVE' },
                    visibility: { type: Sequelize.STRING, defaultValue: 'PRIVATE' },
                    startDate: { type: Sequelize.DATE },
                    endDate: { type: Sequelize.DATE },
                    budget: { type: Sequelize.DECIMAL(12, 2) },
                    createdAt: { type: Sequelize.DATE, allowNull: false },
                    updatedAt: { type: Sequelize.DATE, allowNull: false },
                });
                // Implicit index created by unique: true on key
                // await queryInterface.addIndex('Projects', ['key']);
                try { await queryInterface.addIndex('Projects', ['orgId']); } catch (e) { console.log('Skipping index Projects.orgId:', e.message); }
                try { await queryInterface.addIndex('Projects', ['status']); } catch (e) { console.log('Skipping index Projects.status:', e.message); }
            }
        } catch (e) { console.warn('Skipping Projects creation:', e.message); }

        // 2. ProjectMembers
        try {
            if (!tableExists('ProjectMembers')) {
                console.log('⚠️ ProjectMembers table missing. Creating it now...');
                await queryInterface.createTable('ProjectMembers', {
                    id: { type: Sequelize.UUID, defaultValue: Sequelize.UUIDV4, primaryKey: true },
                    projectId: { type: Sequelize.UUID, allowNull: false, references: { model: 'Projects', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
                    userId: { type: Sequelize.UUID, allowNull: false, references: { model: 'Users', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
                    role: { type: Sequelize.STRING, defaultValue: 'MEMBER' },
                    createdAt: { type: Sequelize.DATE, allowNull: false },
                    updatedAt: { type: Sequelize.DATE, allowNull: false },
                });
                try { await queryInterface.addIndex('ProjectMembers', ['projectId', 'userId'], { unique: true }); } catch (e) { console.log('Skipping index ProjectMembers unique:', e.message); }
            }
        } catch (e) { console.warn('Skipping ProjectMembers creation:', e.message); }

        // 3. Sprints
        try {
            if (!tableExists('Sprints')) {
                console.log('⚠️ Sprints table missing. Creating it now...');
                await queryInterface.createTable('Sprints', {
                    id: { type: Sequelize.UUID, defaultValue: Sequelize.UUIDV4, primaryKey: true },
                    projectId: { type: Sequelize.UUID, allowNull: false, references: { model: 'Projects', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
                    name: { type: Sequelize.STRING, allowNull: false },
                    goal: { type: Sequelize.TEXT },
                    startDate: { type: Sequelize.DATE, allowNull: false },
                    endDate: { type: Sequelize.DATE, allowNull: false },
                    status: { type: Sequelize.STRING, allowNull: false, defaultValue: 'PLANNED' },
                    capacity: { type: Sequelize.INTEGER },
                    velocity: { type: Sequelize.INTEGER },
                    createdAt: { type: Sequelize.DATE, allowNull: false },
                    updatedAt: { type: Sequelize.DATE, allowNull: false },
                });
                try { await queryInterface.addIndex('Sprints', ['projectId']); } catch (e) { console.log('Skipping index Sprints.projectId:', e.message); }
                try { await queryInterface.addIndex('Sprints', ['status']); } catch (e) { console.log('Skipping index Sprints.status:', e.message); }
            }
        } catch (e) { console.warn('Skipping Sprints creation:', e.message); }

        // 4. Issues
        try {
            if (!tableExists('Issues')) {
                console.log('⚠️ Issues table missing. Creating it now...');
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
                });
                // Implicit index created by unique: true on key
                // await queryInterface.addIndex('Issues', ['key']);
                try { await queryInterface.addIndex('Issues', ['projectId']); } catch (e) { console.log('Skipping index Issues.projectId:', e.message); }
                try { await queryInterface.addIndex('Issues', ['status']); } catch (e) { console.log('Skipping index Issues.status:', e.message); }
                try { await queryInterface.addIndex('Issues', ['assigneeId']); } catch (e) { console.log('Skipping index Issues.assigneeId:', e.message); }
                try { await queryInterface.addIndex('Issues', ['sprintId']); } catch (e) { console.log('Skipping index Issues.sprintId:', e.message); }
            }
        } catch (e) { console.warn('Skipping Issues creation:', e.message); }

        // 5. Comments
        try {
            if (!tableExists('Comments')) {
                console.log('⚠️ Comments table missing. Creating it now...');
                await queryInterface.createTable('Comments', {
                    id: { type: Sequelize.UUID, defaultValue: Sequelize.UUIDV4, primaryKey: true },
                    issueId: { type: Sequelize.UUID, allowNull: false, references: { model: 'Issues', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
                    userId: { type: Sequelize.UUID, allowNull: false, references: { model: 'Users', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
                    content: { type: Sequelize.TEXT, allowNull: false },
                    mentions: { type: Sequelize.ARRAY(Sequelize.UUID), defaultValue: [] },
                    createdAt: { type: Sequelize.DATE, allowNull: false },
                    updatedAt: { type: Sequelize.DATE, allowNull: false },
                });
                try { await queryInterface.addIndex('Comments', ['issueId']); } catch (e) { console.log('Skipping index Comments.issueId:', e.message); }
            }
        } catch (e) { console.warn('Skipping Comments creation:', e.message); }

        // 6. Attachments
        try {
            if (!tableExists('Attachments')) {
                console.log('⚠️ Attachments table missing. Creating it now...');
                await queryInterface.createTable('Attachments', {
                    id: { type: Sequelize.UUID, defaultValue: Sequelize.UUIDV4, primaryKey: true },
                    issueId: { type: Sequelize.UUID, allowNull: false, references: { model: 'Issues', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
                    userId: { type: Sequelize.UUID, allowNull: false, references: { model: 'Users', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
                    filename: { type: Sequelize.STRING, allowNull: false },
                    originalName: { type: Sequelize.STRING, allowNull: false },
                    mimeType: { type: Sequelize.STRING, allowNull: false },
                    size: { type: Sequelize.INTEGER, allowNull: false },
                    path: { type: Sequelize.STRING, allowNull: false },
                    url: { type: Sequelize.STRING },
                    createdAt: { type: Sequelize.DATE, allowNull: false },
                    updatedAt: { type: Sequelize.DATE, allowNull: false },
                });
                try { await queryInterface.addIndex('Attachments', ['issueId']); } catch (e) { console.log('Skipping index Attachments.issueId:', e.message); }
            }
        } catch (e) { console.warn('Skipping Attachments creation:', e.message); }

        // 7. WorkLogs
        try {
            if (!tableExists('WorkLogs')) {
                console.log('⚠️ WorkLogs table missing. Creating it now...');
                await queryInterface.createTable('WorkLogs', {
                    id: { type: Sequelize.UUID, defaultValue: Sequelize.UUIDV4, primaryKey: true },
                    issueId: { type: Sequelize.UUID, allowNull: false, references: { model: 'Issues', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
                    userId: { type: Sequelize.UUID, allowNull: false, references: { model: 'Users', key: 'id' }, onUpdate: 'CASCADE', onDelete: 'CASCADE' },
                    timeSpent: { type: Sequelize.DECIMAL(8, 2), allowNull: false },
                    date: { type: Sequelize.DATE, allowNull: false },
                    description: { type: Sequelize.TEXT },
                    createdAt: { type: Sequelize.DATE, allowNull: false },
                    updatedAt: { type: Sequelize.DATE, allowNull: false },
                });
                try { await queryInterface.addIndex('WorkLogs', ['issueId']); } catch (e) { console.log('Skipping index WorkLogs.issueId:', e.message); }
                try { await queryInterface.addIndex('WorkLogs', ['userId']); } catch (e) { console.log('Skipping index WorkLogs.userId:', e.message); }
            }
        } catch (e) { console.warn('Skipping WorkLogs creation:', e.message); }

        console.log('✅ Core tables check/repair completed.');
    },

    down: async (queryInterface, Sequelize) => {
        // Repair migration - no down action necessary as removing tables is destructive
    }
};
