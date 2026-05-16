const sequelize = require('./src/config/database').default || require('./src/config/database');
const { DailyReport, DailyReportEntry, DailyReportComment } = require('./src/models');

async function recreateDb() {
    try {
        await sequelize.authenticate();
        console.log("Connected to DB.");

        // Force drop & recreate ONLY these three specific tables
        await DailyReportComment.sync({ force: true });
        await DailyReportEntry.sync({ force: true });
        await DailyReport.sync({ force: true });

        console.log("DailyReport models recreated successfully.");
    } catch (e) {
        console.error("Sync failed:", e);
    }
    process.exit(0);
}
recreateDb();
