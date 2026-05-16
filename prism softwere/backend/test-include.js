const { DailyReport, DailyReportComment } = require('./src/models');

async function test() {
    try {
        await DailyReport.findAll({
            include: [
                { model: DailyReportComment, as: 'comments' }
            ]
        });
        console.log("SUCCESS");
    } catch (e) {
        console.error("FAILED:", e.message);
    }
    process.exit(0);
}
test();
