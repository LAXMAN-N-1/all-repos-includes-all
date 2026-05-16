import sequelize from '../src/config/database';
import { User } from '../src/models';

async function diagnose() {
    try {
        console.log('--- Database Diagnosis ---');
        await sequelize.authenticate();
        console.log('✅ Connection successful');

        const queryInterface = sequelize.getQueryInterface();
        const tables: any = await queryInterface.showAllTables();
        console.log('Tables:', tables);

        const checkTable = async (name: string) => {
            if (tables.includes(name)) {
                const desc: any = await queryInterface.describeTable(name);
                console.log(`\n--- ${name} table columns ---`);
                Object.keys(desc).forEach(col => {
                    const info = desc[col];
                    console.log(`- ${col}: ${info.type} (${info.allowNull ? 'NULL' : 'NOT NULL'})`);
                });
            } else {
                console.log(`❌ Table ${name} MISSING`);
            }
        };

        await checkTable('Users');
        await checkTable('Projects');
        await checkTable('Organizations');
        await checkTable('AuditLogs');

        console.log('\n--- Model Checks ---');
        try {
            const userCount = await User.count();
            console.log('User count:', userCount);
        } catch (e: any) {
            console.error('❌ User model query failed:', e.message);
        }

    } catch (error: any) {
        console.error('❌ Diagnosis failed:', error.message);
    } finally {
        await sequelize.close();
    }
}

diagnose();
