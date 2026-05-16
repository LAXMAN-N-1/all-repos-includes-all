const { DailyReport, User, DailyReportEntry, DailyReportComment, ProjectMember } = require('./src/models');

async function testController() {
    try {
        const projectId = '80c9fcd3-9dec-48e7-a8e7-f9d4d5a9814b';
        const date = '2026-03-05';

        const reports = await DailyReport.findAll({
            where: { projectId, date },
            include: [
                { model: User, as: 'user', attributes: ['id', 'firstName', 'lastName', 'email', 'role', 'avatar'] },
                { model: DailyReportEntry, as: 'entries', order: [['createdAt', 'ASC']] },
                { model: DailyReportComment, as: 'comments', include: [{ model: User, as: 'user', attributes: ['id', 'firstName', 'lastName', 'avatar'] }], order: [['createdAt', 'ASC']] },
            ],
            order: [['createdAt', 'ASC']],
        });

        // Also get all project members
        const members = await ProjectMember.findAll({
            where: { projectId },
            include: [{ model: User, as: 'user', attributes: ['id', 'firstName', 'lastName', 'email', 'role', 'avatar'] }],
        });

        const reportUserIds = reports.map(r => r.userId);

        // Map all members to a flat structure
        const allMembers = members.map((m) => {
            if (!m.user) return null;
            const u = m.user.toJSON ? m.user.toJSON() : m.user;
            return {
                ...u,
                memberRole: m.role || 'Member'
            };
        }).filter(Boolean);

        // Find those who haven't submitted
        const missingMembers = allMembers.filter((u) => !reportUserIds.includes(u.id));

        console.log("Stats calculated correctly.");
        console.log("Reports:", reports.length);
        console.log("Missing members:", missingMembers.length);

    } catch (err) {
        console.error("FATAL ERROR:");
        console.error(err);
    } finally {
        process.exit(0);
    }
}

testController();
