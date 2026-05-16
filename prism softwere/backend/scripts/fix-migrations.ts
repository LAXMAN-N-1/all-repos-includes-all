import sequelize from '../src/config/database';

const migrations = [
    '20231201000001-create-organizations-users.js',
    '20231201000002-create-projects.js',
    '20231201000003-create-sprints-issues.js',
    '20231201000004-create-comments-attachments-worklogs.js',
    '20231201000005-create-notifications-audit-custom.js',
    '20251210212442-create-issue-links.js',
    '20251210215125-add-fix-version-to-issues.js',
    '20251212999999-cleanup-demo-data.js'
];

async function fix() {
    try {
        for (const name of migrations) {
            await sequelize.query(`INSERT INTO "SequelizeMeta" (name) VALUES ('${name}') ON CONFLICT DO NOTHING`);
            console.log(`Inserted ${name}`);
        }
    } catch (error) {
        console.error('Error fixing migrations:', error);
    } finally {
        await sequelize.close();
    }
}

fix();
