import sequelize from '../config/database';

// Import all models
import Organization from './Organization';
import User from './User';
import Project from './Project';
import ProjectMember from './ProjectMember';
import Issue from './Issue';
import Sprint from './Sprint';
import SprintMember from './SprintMember';
import Comment from './Comment';
import Attachment from './Attachment';
import WorkLog from './WorkLog';
import Notification from './Notification';
import AuditLog from './AuditLog';
import CustomField from './CustomField';
import Workflow from './Workflow';
import Permission from './Permission';
import Settings from './Settings';
import Milestone from './Milestone';
import { Epic } from './Epic';
import { Feature } from './Feature';
import IssueLink from './IssueLink';
import EmployeeDetails from './EmployeeDetails';
import Attendance from './Attendance';
import LeaveRequest from './LeaveRequest';
import DailyReport from './DailyReport';
import DailyReportEntry from './DailyReportEntry';
import DailyReportComment from './DailyReportComment';

// Define relationships

// Organization relationships
Organization.hasMany(User, { foreignKey: 'orgId', as: 'users' });
Organization.hasMany(Project, { foreignKey: 'orgId', as: 'projects' });
Organization.hasMany(CustomField, { foreignKey: 'orgId', as: 'customFields' });
Organization.hasMany(Workflow, { foreignKey: 'orgId', as: 'workflows' });

// User relationships
User.belongsTo(Organization, { foreignKey: 'orgId', as: 'organization' });
User.hasMany(Issue, { foreignKey: 'assigneeId', as: 'assignedIssues' });
User.hasMany(Issue, { foreignKey: 'reporterId', as: 'reportedIssues' });
User.hasMany(Comment, { foreignKey: 'userId', as: 'comments' });
User.hasMany(Attachment, { foreignKey: 'userId', as: 'attachments' });
User.hasMany(WorkLog, { foreignKey: 'userId', as: 'workLogs' });
User.hasMany(Notification, { foreignKey: 'userId', as: 'notifications' });
User.hasMany(AuditLog, { foreignKey: 'userId', as: 'auditLogs' });
User.belongsToMany(Project, { through: ProjectMember, foreignKey: 'userId', as: 'projects' });
User.hasMany(SprintMember, { foreignKey: 'userId', as: 'sprintMembers' });

User.belongsToMany(Sprint, { through: SprintMember, foreignKey: 'userId', as: 'sprints' });
User.hasOne(EmployeeDetails, { foreignKey: 'userId', as: 'employeeDetails' });
User.hasMany(Attendance, { foreignKey: 'userId', as: 'attendanceRecords' });
User.hasMany(LeaveRequest, { foreignKey: 'userId', as: 'leaveRequests' });

// EmployeeDetails relationships
EmployeeDetails.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// Attendance relationships
Attendance.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// LeaveRequest relationships
LeaveRequest.belongsTo(User, { foreignKey: 'userId', as: 'user' });
LeaveRequest.belongsTo(User, { foreignKey: 'approvedBy', as: 'approver' });

// Project relationships
Project.belongsTo(Organization, { foreignKey: 'orgId', as: 'organization' });
Project.belongsTo(User, { foreignKey: 'leadId', as: 'lead' });
Project.hasMany(Issue, { foreignKey: 'projectId', as: 'issues' });
Project.hasMany(Sprint, { foreignKey: 'projectId', as: 'sprints' });
Project.hasMany(Milestone, { foreignKey: 'projectId', as: 'milestones' });
Project.hasMany(Epic, { foreignKey: 'projectId', as: 'epics' });
Project.hasMany(Feature, { foreignKey: 'projectId', as: 'features' });
Project.hasMany(Attachment, { foreignKey: 'projectId', as: 'attachments' });
Project.belongsToMany(User, { through: ProjectMember, foreignKey: 'projectId', as: 'members' });
Project.hasMany(ProjectMember, { foreignKey: 'projectId', as: 'projectMembers' });

// ProjectMember relationships
ProjectMember.belongsTo(Project, { foreignKey: 'projectId', as: 'project' });
ProjectMember.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// Sprint relationships
Sprint.belongsTo(Project, { foreignKey: 'projectId', as: 'project' });
Sprint.hasMany(Issue, { foreignKey: 'sprintId', as: 'issues' });
Sprint.hasMany(SprintMember, { foreignKey: 'sprintId', as: 'sprintMembers' });
Sprint.belongsToMany(User, { through: SprintMember, foreignKey: 'sprintId', as: 'members' });

// SprintMember relationships
SprintMember.belongsTo(Sprint, { foreignKey: 'sprintId', as: 'sprint' });
SprintMember.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// Issue relationships
Issue.belongsTo(Project, { foreignKey: 'projectId', as: 'project' });
Issue.belongsTo(User, { foreignKey: 'assigneeId', as: 'assignee' });
Issue.belongsTo(User, { foreignKey: 'reporterId', as: 'reporter' });
Issue.belongsTo(Sprint, { foreignKey: 'sprintId', as: 'sprint' });
Issue.belongsTo(Issue, { foreignKey: 'parentId', as: 'parent' });
Issue.hasMany(Issue, { foreignKey: 'parentId', as: 'subtasks' });
Issue.hasMany(Comment, { foreignKey: 'issueId', as: 'comments' });
Issue.hasMany(Attachment, { foreignKey: 'issueId', as: 'attachments' });
Issue.hasMany(WorkLog, { foreignKey: 'issueId', as: 'workLogs' });
Issue.belongsTo(Epic, { foreignKey: 'epicId', as: 'epic' });
Issue.belongsTo(Feature, { foreignKey: 'featureId', as: 'feature' });

Issue.hasMany(IssueLink, { foreignKey: 'sourceIssueId', as: 'links' });
Issue.hasMany(IssueLink, { foreignKey: 'targetIssueId', as: 'linkedBy' });

IssueLink.belongsTo(Issue, { foreignKey: 'sourceIssueId', as: 'sourceIssue' });
IssueLink.belongsTo(Issue, { foreignKey: 'targetIssueId', as: 'relatedIssue' }); // Renamed alias to 'relatedIssue' to match frontend expectation.

// Comment relationships
Comment.belongsTo(Issue, { foreignKey: 'issueId', as: 'issue' });
Comment.belongsTo(User, { foreignKey: 'userId', as: 'user' });
Comment.hasMany(Attachment, { foreignKey: 'commentId', as: 'attachments' });

// Attachment relationships
Attachment.belongsTo(Issue, { foreignKey: 'issueId', as: 'issue' });
Attachment.belongsTo(Project, { foreignKey: 'projectId', as: 'project' });
Attachment.belongsTo(Comment, { foreignKey: 'commentId', as: 'comment' });
Attachment.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// WorkLog relationships
WorkLog.belongsTo(Issue, { foreignKey: 'issueId', as: 'issue' });
WorkLog.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// Notification relationships
Notification.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// AuditLog relationships
AuditLog.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// CustomField relationships
CustomField.belongsTo(Organization, { foreignKey: 'orgId', as: 'organization' });

// Settings relationships
Settings.belongsTo(User, { foreignKey: 'updatedBy', as: 'updater' });

// Workflow relationships
Workflow.belongsTo(Organization, { foreignKey: 'orgId', as: 'organization' });

// Milestone relationships
Milestone.belongsTo(Project, { foreignKey: 'projectId', as: 'project' });

// Epic relationships
Epic.belongsTo(Project, { foreignKey: 'projectId', as: 'project' });
Epic.belongsTo(User, { foreignKey: 'ownerId', as: 'owner' });
Epic.hasMany(Feature, { foreignKey: 'epicId', as: 'features' });
Epic.hasMany(Issue, { foreignKey: 'epicId', as: 'issues' });

// Feature relationships
Feature.belongsTo(Epic, { foreignKey: 'epicId', as: 'epic' });
Feature.belongsTo(Project, { foreignKey: 'projectId', as: 'project' });
Feature.belongsTo(User, { foreignKey: 'ownerId', as: 'owner' });
Feature.hasMany(Issue, { foreignKey: 'featureId', as: 'issues' });

// DailyReport relationships
DailyReport.belongsTo(Project, { foreignKey: 'projectId', as: 'project' });
DailyReport.belongsTo(User, { foreignKey: 'userId', as: 'user' });
DailyReport.hasMany(DailyReportEntry, { foreignKey: 'reportId', as: 'entries' });
DailyReport.hasMany(DailyReportComment, { foreignKey: 'reportId', as: 'comments' });

DailyReportEntry.belongsTo(DailyReport, { foreignKey: 'reportId', as: 'report' });

DailyReportComment.belongsTo(DailyReport, { foreignKey: 'reportId', as: 'report' });
DailyReportComment.belongsTo(User, { foreignKey: 'userId', as: 'user' });
DailyReportComment.belongsTo(DailyReportComment, { foreignKey: 'parentId', as: 'parent' });
DailyReportComment.hasMany(DailyReportComment, { foreignKey: 'parentId', as: 'replies' });

User.hasMany(DailyReport, { foreignKey: 'userId', as: 'dailyReports' });
Project.hasMany(DailyReport, { foreignKey: 'projectId', as: 'dailyReports' });

// Export all models and sequelize instance
export {
    sequelize,
    Organization,
    User,
    Project,
    ProjectMember,
    Issue,
    Sprint,
    SprintMember,
    Comment,
    Attachment,
    WorkLog,
    Notification,
    AuditLog,
    CustomField,
    Workflow,
    Permission,
    Settings,
    Milestone,
    Epic,
    Feature,
    EmployeeDetails,
    Attendance,
    LeaveRequest,
    DailyReport,
    DailyReportEntry,
    DailyReportComment,
};

export default {
    sequelize,
    Organization,
    User,
    Project,
    ProjectMember,
    Issue,
    Sprint,
    SprintMember,
    Comment,
    Attachment,
    WorkLog,
    Notification,
    AuditLog,
    CustomField,
    Workflow,
    Permission,
    Settings,
    Milestone,
    Epic,
    Feature,
    EmployeeDetails,
    Attendance,
    LeaveRequest,
    DailyReport,
    DailyReportEntry,
    DailyReportComment,
};
