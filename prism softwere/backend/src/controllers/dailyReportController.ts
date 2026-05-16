import { Response } from 'express';
import { AuthRequest } from '../types/interfaces';
import { DailyReport, DailyReportEntry, DailyReportComment, User, Notification, ProjectMember } from '../models';
import { asyncHandler } from '../middleware/errorHandler';

function todayDate(): string {
    return new Date().toISOString().split('T')[0] || new Date().toISOString().substring(0, 10);
}

async function getOrCreateReport(projectId: string, userId: string, date?: string) {
    const d = date || todayDate();
    const [report] = await DailyReport.findOrCreate({
        where: { projectId, userId, date: d },
        defaults: { projectId, userId, date: d, standupSubmitted: false, standupTasks: [], concerns: '', lessonsLearned: '', summarySubmitted: false, status: 'missing' as const },
    });
    return report;
}

export class DailyReportController {

    // GET /daily-reports/:projectId — get all reports for a project on a date
    static getProjectReports = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { projectId } = req.params;
        const date = (req.query.date as string) || todayDate();
        const userId = req.query.userId as string | undefined;

        console.log(`[DailyTracker] getProjectReports called — projectId: ${projectId}, date: ${date}`);

        // Roles to EXCLUDE from the daily tracker (only show employees)
        const excludedRoles = ['admin', 'project_manager', 'scrum_master', 'client'];

        // 1. Always get project members first (this is reliable)
        const members = await ProjectMember.findAll({
            where: { projectId },
            include: [{ model: User, as: 'user', attributes: ['id', 'firstName', 'lastName', 'email', 'role'] }],
        });

        console.log(`[DailyTracker] Found ${members.length} project members for project ${projectId}`);

        // Map all members to a flat structure, filtering to employees only
        const allMembers = members.map((m: any) => {
            if (!m.user) {
                console.log(`[DailyTracker] WARNING: ProjectMember has no associated user. memberId: ${m.id}, userId: ${m.userId}`);
                return null;
            }
            const u = m.user.toJSON ? m.user.toJSON() : m.user;
            const memberRole = (m.role || '').toLowerCase();
            const userRole = (u.role || '').toLowerCase();

            // Skip non-employee roles (admin, PM, SM, client)
            if (excludedRoles.includes(memberRole) || excludedRoles.includes(userRole)) {
                console.log(`[DailyTracker] Skipping non-employee: ${u.firstName} ${u.lastName} (memberRole: ${m.role}, userRole: ${u.role})`);
                return null;
            }

            return {
                ...u,
                memberRole: m.role || 'Member'
            };
        }).filter(Boolean);

        console.log(`[DailyTracker] Employees (after filtering): ${allMembers.length}`);

        // 2. Try to get daily reports (may fail if tables have issues)
        let reports: any[] = [];
        try {
            const where: any = { projectId, date };
            if (userId) where.userId = userId;

            reports = await DailyReport.findAll({
                where,
                include: [
                    { model: User, as: 'user', attributes: ['id', 'firstName', 'lastName', 'email', 'role'] },
                    { model: DailyReportEntry, as: 'entries', separate: true, order: [['createdAt', 'ASC']] as any },
                    { model: DailyReportComment, as: 'comments', separate: true, where: { parentId: null }, required: false, include: [{ model: User, as: 'user', attributes: ['id', 'firstName', 'lastName'] }, { model: DailyReportComment, as: 'replies', include: [{ model: User, as: 'user', attributes: ['id', 'firstName', 'lastName'] }] }], order: [['createdAt', 'ASC']] as any },
                ],
                order: [['createdAt', 'ASC']],
            });
            console.log(`[DailyTracker] Found ${reports.length} reports for date ${date}`);
        } catch (err: any) {
            console.error(`[DailyTracker] Error fetching reports (returning members without reports):`, err?.message || err);
            // Continue — we still return members even if reports fail
        }

        const reportUserIds = reports.map((r: any) => r.userId);

        // Find members who haven't submitted
        const missingMembers = allMembers.filter((u: any) => !reportUserIds.includes(u.id));

        // Compute stats
        const totalMembers = allMembers.length;
        const submitted = reports.filter((r: any) => r.standupSubmitted).length;
        const totalHours = reports.reduce((sum: number, r: any) => {
            const entries = r.entries || [];
            return sum + entries.filter((e: any) => e.type === 'work').reduce((s: number, e: any) => s + parseFloat(e.hours || 0), 0);
        }, 0);
        const openBlockers = reports.reduce((sum: number, r: any) => {
            const entries = r.entries || [];
            return sum + entries.filter((e: any) => e.type === 'blocker' && e.blockerStatus === 'OPEN').length;
        }, 0);

        res.json({
            success: true,
            data: {
                reports,
                missingMembers,
                stats: { totalMembers, submitted, totalHours: Math.round(totalHours * 100) / 100, openBlockers },
            },
        });
    });

    // GET /daily-reports/:projectId/my — get my report for a date
    static getMyReport = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { projectId } = req.params;
        const date = (req.query.date as string) || todayDate();
        const userId = req.user!.id as string;

        const report = await DailyReport.findOne({
            where: { projectId, userId, date },
            include: [
                { model: DailyReportEntry, as: 'entries', separate: true, order: [['createdAt', 'ASC']] as any },
                { model: DailyReportComment, as: 'comments', separate: true, include: [{ model: User, as: 'user', attributes: ['id', 'firstName', 'lastName'] }], order: [['createdAt', 'ASC']] as any },
            ],
        });

        res.json({ success: true, data: { report } });
    });

    // POST /daily-reports/:projectId/standup — submit morning standup
    static submitStandup = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const projectId = req.params.projectId as string;
        const userId = req.user!.id as string;
        const { selectedTasks, concerns } = req.body;
        const date = todayDate();

        const report = await getOrCreateReport(projectId, userId, date);
        const now = new Date();
        const timeStr = now.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true });

        await report.update({
            standupSubmitted: true,
            standupTime: timeStr,
            standupTasks: selectedTasks || [],
            concerns: concerns || '',
            status: 'good',
        });

        res.json({ success: true, data: { report }, message: 'Standup submitted successfully' });
    });

    // POST /daily-reports/:projectId/entry — add hourly tracking entry
    static addEntry = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const projectId = req.params.projectId as string;
        const userId = req.user!.id as string;
        const { taskId, taskTitle, hours, progress, notes } = req.body;
        const date = todayDate();

        const report = await getOrCreateReport(projectId, userId, date);
        const now = new Date();
        const timeStr = now.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true });

        const entry = await DailyReportEntry.create({
            reportId: report.id,
            taskId: taskId || null,
            taskTitle: taskTitle || 'Unknown task',
            type: 'work',
            hours: hours || 1,
            progress: progress || 0,
            notes: notes || '',
            time: timeStr,
        });

        // Update report status based on hours
        const allEntries = await DailyReportEntry.findAll({ where: { reportId: report.id, type: 'work' } });
        const totalHours = allEntries.reduce((s, e) => s + parseFloat(String(e.hours)), 0);
        const newStatus = totalHours >= 6 ? 'excellent' : totalHours >= 3 ? 'good' : 'at-risk';
        await report.update({ status: newStatus });

        res.json({ success: true, data: { entry }, message: 'Entry logged' });
    });

    // POST /daily-reports/:projectId/blocker — report a blocker
    static addBlocker = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const projectId = req.params.projectId as string;
        const userId = req.user!.id as string;
        const { description, severity, taggedPeople } = req.body;
        const date = todayDate();

        const report = await getOrCreateReport(projectId, userId, date);
        const now = new Date();
        const timeStr = now.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true });

        const entry = await DailyReportEntry.create({
            reportId: report.id,
            taskTitle: description || 'Blocker',
            type: 'blocker',
            hours: 0,
            progress: 0,
            notes: description || '',
            time: timeStr,
            severity: severity || 'medium',
            blockerStatus: 'OPEN',
            taggedPeople: taggedPeople || [],
        });

        // Create notifications for tagged people
        if (taggedPeople && taggedPeople.length > 0) {
            const user = await User.findByPk(userId);
            const notifications = taggedPeople.map((pid: string) => ({
                userId: pid,
                type: 'BLOCKER_REPORTED' as any,
                title: 'Blocker Reported',
                message: `${user?.firstName || 'Someone'} reported a blocker: "${description}"`,
                data: { reportId: report.id, entryId: entry.id, projectId },
                isRead: false,
            }));
            await Notification.bulkCreate(notifications);
        }

        res.json({ success: true, data: { entry }, message: 'Blocker reported' });
    });

    // POST /daily-reports/:projectId/summary — submit evening summary
    static submitSummary = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const projectId = req.params.projectId as string;
        const userId = req.user!.id as string;
        const { lessonsLearned } = req.body;
        const date = todayDate();

        const report = await getOrCreateReport(projectId, userId, date);
        const now = new Date();
        const timeStr = now.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true });

        // Compute final status
        const entries = await DailyReportEntry.findAll({ where: { reportId: report.id, type: 'work' } });
        const totalHours = entries.reduce((s, e) => s + parseFloat(String(e.hours)), 0);
        const finalStatus = totalHours >= 6 ? 'excellent' : totalHours >= 3 ? 'good' : 'at-risk';

        await report.update({
            summarySubmitted: true,
            summaryTime: timeStr,
            lessonsLearned: lessonsLearned || '',
            status: finalStatus,
        });

        res.json({ success: true, data: { report }, message: 'Evening summary submitted' });
    });

    // POST /daily-reports/:reportId/comment — add comment to a report
    static addComment = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const reportId = req.params.reportId as string;
        const userId = req.user!.id as string;
        const { content, mentions, messageType, parentId } = req.body;

        const report = await DailyReport.findByPk(reportId);
        if (!report) { res.status(404).json({ success: false, message: 'Report not found' }); return; }

        // If parentId is provided, verify it exists and belongs to the same report
        if (parentId) {
            const parentComment = await DailyReportComment.findOne({ where: { id: parentId, reportId } });
            if (!parentComment) { res.status(404).json({ success: false, message: 'Parent comment not found' }); return; }
        }

        const comment = await DailyReportComment.create({
            reportId: reportId,
            userId: userId,
            content: content || '',
            mentions: mentions || [],
            messageType: messageType || 'comment',
            parentId: parentId || null,
        });

        // Create notification for report owner
        if (report.userId !== userId) {
            const commenter = await User.findByPk(userId);
            await Notification.create({
                userId: report.userId,
                type: 'DAILY_REPORT_COMMENT' as any,
                title: parentId ? 'New Reply on Your Daily Report' : 'New Comment on Your Daily Report',
                message: `${commenter?.firstName || 'Someone'} ${parentId ? 'replied to a comment' : 'commented'} on your daily report: "${(content || '').substring(0, 100)}"`,
                data: { reportId, commentId: comment.id },
                isRead: false,
            });
        }

        // Create notifications for mentioned users
        if (mentions && mentions.length > 0) {
            const commenter = await User.findByPk(userId);
            const notifs = mentions.filter((m: string) => m !== report.userId).map((mid: string) => ({
                userId: mid,
                type: 'DAILY_REPORT_MENTION' as any,
                title: 'You were mentioned in a daily report comment',
                message: `${commenter?.firstName || 'Someone'} mentioned you: "${(content || '').substring(0, 100)}"`,
                data: { reportId, commentId: comment.id },
                isRead: false,
            }));
            if (notifs.length > 0) await Notification.bulkCreate(notifs);
        }

        // Refetch with user data and replies
        const fullComment = await DailyReportComment.findByPk(comment.id, {
            include: [
                { model: User, as: 'user', attributes: ['id', 'firstName', 'lastName'] },
                { model: DailyReportComment, as: 'replies', include: [{ model: User, as: 'user', attributes: ['id', 'firstName', 'lastName'] }] },
            ],
        });

        res.json({ success: true, data: { comment: fullComment }, message: 'Comment added' });
    });

    // PATCH /daily-reports/comments/:commentId/react — toggle emoji reaction
    static reactToComment = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { commentId } = req.params;
        const userId = req.user!.id as string;
        const { emoji } = req.body;

        if (!emoji) { res.status(400).json({ success: false, message: 'Emoji is required' }); return; }

        const comment = await DailyReportComment.findByPk(commentId);
        if (!comment) { res.status(404).json({ success: false, message: 'Comment not found' }); return; }

        const reactions = { ...(comment.reactions || {}) };
        if (!reactions[emoji]) {
            reactions[emoji] = [userId];
        } else if (reactions[emoji].includes(userId)) {
            reactions[emoji] = reactions[emoji].filter((id: string) => id !== userId);
            if (reactions[emoji].length === 0) delete reactions[emoji];
        } else {
            reactions[emoji].push(userId);
        }

        await comment.update({ reactions });

        res.json({ success: true, data: { reactions }, message: 'Reaction toggled' });
    });

    // PATCH /daily-reports/comments/:commentId/pin — toggle pin status
    static pinComment = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { commentId } = req.params;

        const comment = await DailyReportComment.findByPk(commentId);
        if (!comment) { res.status(404).json({ success: false, message: 'Comment not found' }); return; }

        await comment.update({ isPinned: !comment.isPinned });

        res.json({ success: true, data: { isPinned: comment.isPinned }, message: comment.isPinned ? 'Message pinned' : 'Message unpinned' });
    });

    // PUT /daily-reports/comments/:commentId — edit comment
    static editComment = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { commentId } = req.params;
        const userId = req.user!.id as string;
        const { content } = req.body;

        const comment = await DailyReportComment.findByPk(commentId);
        if (!comment) { res.status(404).json({ success: false, message: 'Comment not found' }); return; }
        if (comment.userId !== userId) { res.status(403).json({ success: false, message: 'You can only edit your own comments' }); return; }

        // Check 5-minute edit window
        const fiveMinAgo = new Date(Date.now() - 5 * 60 * 1000);
        if (comment.createdAt < fiveMinAgo) {
            res.status(403).json({ success: false, message: 'Edit window (5 minutes) has expired' });
            return;
        }

        await comment.update({ content, isEdited: true });

        const fullComment = await DailyReportComment.findByPk(commentId, {
            include: [{ model: User, as: 'user', attributes: ['id', 'firstName', 'lastName'] }],
        });

        res.json({ success: true, data: { comment: fullComment }, message: 'Comment updated' });
    });

    // DELETE /daily-reports/comments/:commentId — delete comment
    static deleteComment = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { commentId } = req.params;
        const userId = req.user!.id as string;

        const comment = await DailyReportComment.findByPk(commentId);
        if (!comment) { res.status(404).json({ success: false, message: 'Comment not found' }); return; }

        // Allow deletion by comment owner or project admin
        if (comment.userId !== userId) {
            // Check if user is admin/PM of the project
            const report = await DailyReport.findByPk(comment.reportId);
            if (report) {
                const membership = await ProjectMember.findOne({ where: { projectId: report.projectId, userId } });
                if (!membership || !['admin', 'project_manager', 'scrum_master'].includes((membership as any).role || '')) {
                    res.status(403).json({ success: false, message: 'You can only delete your own comments' });
                    return;
                }
            }
        }

        await comment.destroy();

        res.json({ success: true, message: 'Comment deleted' });
    });

    // POST /daily-reports/:reportId/remind — send reminder notification
    static sendReminder = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { reportId } = req.params;
        const senderId = req.user!.id;
        const { targetUserId, message } = req.body;

        // If reportId is 'project', use targetUserId directly
        let tuid = targetUserId;
        if (reportId !== 'project') {
            const report = await DailyReport.findByPk(reportId);
            if (report) tuid = report.userId;
        }

        if (!tuid) { res.status(400).json({ success: false, message: 'Target user required' }); return; }

        const sender = await User.findByPk(senderId);
        await Notification.create({
            userId: tuid,
            type: 'DAILY_REPORT_REMINDER' as any,
            title: 'Daily Report Reminder',
            message: message || `${sender?.firstName || 'Your manager'} is reminding you to submit your daily report.`,
            data: { senderId },
            isRead: false,
        });

        res.json({ success: true, message: 'Reminder sent successfully' });
    });

    // PATCH /daily-reports/entries/:entryId/resolve — resolve a blocker
    static resolveBlocker = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { entryId } = req.params;
        const now = new Date();
        const timeStr = now.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true });

        const [updated] = await DailyReportEntry.update(
            { blockerStatus: 'RESOLVED', resolvedAt: timeStr },
            { where: { id: entryId, type: 'blocker' } }
        );

        if (updated === 0) { res.status(404).json({ success: false, message: 'Blocker not found' }); return; }

        res.json({ success: true, message: 'Blocker resolved' });
    });
}
