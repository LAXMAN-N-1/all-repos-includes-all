const { DailyReport, User, DailyReportEntry, DailyReportComment, ProjectMember } = require('./src/models');

console.log('DailyReportComment defined?', !!DailyReportComment);
console.log('DailyReport associations:');
Object.keys(DailyReport.associations).forEach(k => console.log(' - ' + k));
console.log('ProjectMember associations:');
Object.keys(ProjectMember.associations).forEach(k => console.log(' - ' + k));
