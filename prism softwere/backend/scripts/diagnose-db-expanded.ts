import sequelize from '../src/config/database';

async function diagnose() {
    try {
        const queryInterface = sequelize.getQueryInterface();
        const tables: any = await queryInterface.showAllTables();

        const checkTable = async (name: string) => {
            if (tables.includes(name)) {
                const desc: any = await queryInterface.describeTable(name);
                console.log(`\n--- ${name} table columns ---`);
                Object.keys(desc).forEach(col => {
                    const info = desc[col];
                    console.log(`- ${col}: ${info.type} (${info.allowNull ? 'NULL' : 'NOT NULL'})`);
                });
            }
        };

        await checkTable('EmployeeDetails');
        await checkTable('Attendance');
        await checkTable('LeaveRequests');

    } catch (error: any) {
        console.error('❌ Diagnosis failed:', error.message);
    } finally {
        await sequelize.close();
    }
}

diagnose();
