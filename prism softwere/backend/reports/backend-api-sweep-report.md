# Backend API Sweep Report

- Date: 2026-03-04T13:53:16.360Z
- Routes discovered: 126
- Happy-path 2xx count: 126
- Authz denial checks (401/403) passed: 121/121
- Validation probes returning client errors (4xx): 91/126
- Cross-org denial checks (403/404) passed: 73/73
- Routes with any 5xx probe: 0

## Matrix

| Method | Path | Protected | Happy | Authz | Validation | Cross-Org | Source |
|---|---|---:|---:|---:|---:|---:|---|
| GET | `/api/v1/analytics/burndown/:sprintId` | Yes | 200 | 401 | 400 | 403 | src/routes/analytics.ts:103 |
| GET | `/api/v1/analytics/client-stats` | Yes | 200 | 401 | 200 | - | src/routes/analytics.ts:55 |
| GET | `/api/v1/analytics/dashboard` | Yes | 200 | 401 | 200 | - | src/routes/analytics.ts:27 |
| GET | `/api/v1/analytics/db` | Yes | 200 | 401 | 200 | - | src/routes/analytics.ts:187 |
| GET | `/api/v1/analytics/export` | Yes | 200 | 401 | 400 | - | src/routes/analytics.ts:240 |
| GET | `/api/v1/analytics/growth` | Yes | 200 | 401 | 200 | - | src/routes/analytics.ts:205 |
| GET | `/api/v1/analytics/personal-stats` | Yes | 200 | 401 | 200 | - | src/routes/analytics.ts:41 |
| GET | `/api/v1/analytics/project-health/:projectId` | Yes | 200 | 401 | 400 | 403 | src/routes/analytics.ts:151 |
| GET | `/api/v1/analytics/resolution` | Yes | 200 | 401 | 200 | - | src/routes/analytics.ts:219 |
| GET | `/api/v1/analytics/system` | Yes | 200 | 401 | 200 | - | src/routes/analytics.ts:169 |
| GET | `/api/v1/analytics/team-performance` | Yes | 200 | 401 | 400 | 403 | src/routes/analytics.ts:127 |
| GET | `/api/v1/analytics/velocity` | Yes | 200 | 401 | 400 | 403 | src/routes/analytics.ts:79 |
| PATCH | `/api/v1/attendance/:id/status` | Yes | 200 | 403 | 400 | - | src/routes/attendanceRoutes.ts:30 |
| POST | `/api/v1/attendance/check-in` | Yes | 201 | 401 | 400 | - | src/routes/attendanceRoutes.ts:16 |
| POST | `/api/v1/attendance/check-out` | Yes | 200 | 401 | 400 | - | src/routes/attendanceRoutes.ts:17 |
| GET | `/api/v1/attendance/employee/:userId` | Yes | 200 | 403 | 400 | 403 | src/routes/attendanceRoutes.ts:21 |
| GET | `/api/v1/attendance/my-attendance` | Yes | 200 | 401 | 200 | - | src/routes/attendanceRoutes.ts:18 |
| GET | `/api/v1/attendance` | Yes | 200 | 403 | 200 | - | src/routes/attendanceRoutes.ts:41 |
| GET | `/api/v1/audit-logs/stats` | Yes | 200 | 403 | 200 | - | src/routes/auditLogs.ts:26 |
| GET | `/api/v1/audit-logs` | Yes | 200 | 403 | 200 | - | src/routes/auditLogs.ts:14 |
| POST | `/api/v1/auth/change-password` | Yes | 200 | 401 | 400 | - | src/routes/auth.ts:56 |
| POST | `/api/v1/auth/forgot-password` | No | 200 | 0 | 400 | - | src/routes/auth.ts:34 |
| POST | `/api/v1/auth/login` | No | 200 | 0 | 400 | - | src/routes/auth.ts:19 |
| POST | `/api/v1/auth/logout` | Yes | 200 | 401 | 200 | - | src/routes/auth.ts:54 |
| GET | `/api/v1/auth/me` | Yes | 200 | 401 | 200 | - | src/routes/auth.ts:55 |
| POST | `/api/v1/auth/refresh-token` | No | 200 | 0 | 400 | - | src/routes/auth.ts:26 |
| POST | `/api/v1/auth/reset-password` | No | 200 | 0 | 400 | - | src/routes/auth.ts:43 |
| GET | `/api/v1/client/pending-actions` | Yes | 200 | 403 | 200 | - | src/routes/client.ts:64 |
| GET | `/api/v1/client/projects/:id/activity` | Yes | 200 | 403 | 400 | 403 | src/routes/client.ts:50 |
| GET | `/api/v1/client/projects/:id/milestones` | Yes | 200 | 403 | 400 | 403 | src/routes/client.ts:43 |
| GET | `/api/v1/client/projects/:id/tasks` | Yes | 200 | 403 | 400 | 403 | src/routes/client.ts:36 |
| GET | `/api/v1/client/projects/:id/timeline` | Yes | 200 | 403 | 400 | 403 | src/routes/client.ts:57 |
| GET | `/api/v1/client/projects/:id` | Yes | 200 | 403 | 400 | 403 | src/routes/client.ts:29 |
| GET | `/api/v1/client/projects` | Yes | 200 | 403 | 200 | - | src/routes/client.ts:22 |
| GET | `/api/v1/client/search` | Yes | 200 | 403 | 200 | - | src/routes/client.ts:16 |
| POST | `/api/v1/epics/:id/close` | Yes | 200 | 401 | 400 | 403 | src/routes/epics.ts:48 |
| GET | `/api/v1/epics/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/epics.ts:24 |
| PUT | `/api/v1/epics/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/epics.ts:30 |
| DELETE | `/api/v1/epics/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/epics.ts:40 |
| GET | `/api/v1/epics` | Yes | 200 | 401 | 200 | - | src/routes/epics.ts:22 |
| POST | `/api/v1/epics` | Yes | 201 | 401 | 400 | 403 | src/routes/epics.ts:12 |
| GET | `/api/v1/features/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/features.ts:24 |
| PUT | `/api/v1/features/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/features.ts:30 |
| DELETE | `/api/v1/features/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/features.ts:40 |
| GET | `/api/v1/features` | Yes | 200 | 401 | 200 | - | src/routes/features.ts:22 |
| POST | `/api/v1/features` | Yes | 201 | 401 | 400 | 403 | src/routes/features.ts:12 |
| GET | `/api/v1/issues/:id/children` | Yes | 200 | 401 | 400 | 403 | src/routes/issues.ts:32 |
| PATCH | `/api/v1/issues/:id/client-approval` | Yes | 200 | 401 | 400 | 403 | src/routes/issues.ts:129 |
| GET | `/api/v1/issues/:id/history` | Yes | 200 | 401 | 400 | 403 | src/routes/issues.ts:194 |
| DELETE | `/api/v1/issues/:id/links/:linkId` | Yes | 200 | 401 | 400 | 403 | src/routes/issues.ts:184 |
| POST | `/api/v1/issues/:id/links` | Yes | 201 | 401 | 400 | 403 | src/routes/issues.ts:175 |
| PUT | `/api/v1/issues/:id/move-to-sprint` | Yes | 200 | 401 | 400 | 403 | src/routes/issues.ts:66 |
| PUT | `/api/v1/issues/:id/status` | Yes | 200 | 401 | 400 | 403 | src/routes/issues.ts:117 |
| GET | `/api/v1/issues/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/issues.ts:90 |
| PUT | `/api/v1/issues/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/issues.ts:140 |
| DELETE | `/api/v1/issues/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/issues.ts:147 |
| POST | `/api/v1/issues/:issueId/attachments` | Yes | 201 | 401 | 400 | 403 | src/routes/issues.ts:201 |
| GET | `/api/v1/issues/:issueId/comments` | Yes | 200 | 401 | 400 | 403 | src/routes/issues.ts:154 |
| POST | `/api/v1/issues/:issueId/comments` | Yes | 201 | 401 | 400 | 403 | src/routes/issues.ts:161 |
| POST | `/api/v1/issues/:issueId/worklog` | Yes | 201 | 401 | 400 | 403 | src/routes/issues.ts:168 |
| POST | `/api/v1/issues/assign-sprint` | Yes | 200 | 401 | 400 | 403 | src/routes/issues.ts:106 |
| DELETE | `/api/v1/issues/attachments/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/issues.ts:208 |
| POST | `/api/v1/issues/create-story` | Yes | 201 | 401 | 400 | 403 | src/routes/issues.ts:39 |
| POST | `/api/v1/issues/create-subtask` | Yes | 201 | 401 | 400 | 403 | src/routes/issues.ts:54 |
| GET | `/api/v1/issues/hierarchy/:projectId` | Yes | 200 | 401 | 400 | 403 | src/routes/issues.ts:25 |
| GET | `/api/v1/issues/my-issues` | Yes | 200 | 401 | 200 | - | src/routes/issues.ts:18 |
| GET | `/api/v1/issues/project/:projectId/backlog` | Yes | 200 | 401 | 400 | 403 | src/routes/issues.ts:83 |
| GET | `/api/v1/issues` | Yes | 200 | 401 | 200 | - | src/routes/issues.ts:76 |
| POST | `/api/v1/issues` | Yes | 201 | 401 | 400 | 403 | src/routes/issues.ts:97 |
| PATCH | `/api/v1/leaves/:id/status` | Yes | 200 | 403 | 400 | 403 | src/routes/leaveRoutes.ts:27 |
| POST | `/api/v1/leaves/apply` | Yes | 201 | 401 | 400 | - | src/routes/leaveRoutes.ts:16 |
| GET | `/api/v1/leaves/my-balances` | Yes | 200 | 401 | 200 | - | src/routes/leaveRoutes.ts:18 |
| GET | `/api/v1/leaves/my-leaves` | Yes | 200 | 401 | 200 | - | src/routes/leaveRoutes.ts:17 |
| GET | `/api/v1/leaves` | Yes | 200 | 403 | 200 | - | src/routes/leaveRoutes.ts:21 |
| PATCH | `/api/v1/milestones/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/milestones.ts:36 |
| DELETE | `/api/v1/milestones/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/milestones.ts:52 |
| GET | `/api/v1/milestones/projects/:projectId/milestones` | Yes | 200 | 401 | 400 | 403 | src/routes/milestones.ts:15 |
| POST | `/api/v1/milestones/projects/:projectId/milestones` | Yes | 201 | 401 | 400 | 403 | src/routes/milestones.ts:22 |
| PUT | `/api/v1/notifications/:id/read` | Yes | 200 | 401 | 400 | 404 | src/routes/notifications.ts:24 |
| PUT | `/api/v1/notifications/read-all` | Yes | 200 | 401 | 200 | - | src/routes/notifications.ts:19 |
| GET | `/api/v1/notifications` | Yes | 200 | 401 | 200 | - | src/routes/notifications.ts:12 |
| GET | `/api/v1/portal-settings` | Yes | 200 | 403 | 200 | - | src/routes/portalSettings.ts:17 |
| PUT | `/api/v1/portal-settings` | Yes | 200 | 403 | 200 | - | src/routes/portalSettings.ts:20 |
| GET | `/api/v1/projects/:id/issues` | Yes | 200 | 401 | 400 | 403 | src/routes/projects.ts:92 |
| DELETE | `/api/v1/projects/:id/members/:userId` | Yes | 200 | 401 | 400 | 403 | src/routes/projects.ts:81 |
| GET | `/api/v1/projects/:id/members` | Yes | 200 | 401 | 400 | 403 | src/routes/projects.ts:62 |
| POST | `/api/v1/projects/:id/members` | Yes | 201 | 401 | 400 | 403 | src/routes/projects.ts:69 |
| GET | `/api/v1/projects/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/projects.ts:31 |
| PUT | `/api/v1/projects/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/projects.ts:46 |
| DELETE | `/api/v1/projects/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/projects.ts:54 |
| GET | `/api/v1/projects/:projectId/files/:fileId/download` | Yes | 200 | 401 | 400 | 403 | src/routes/projects.ts:120 |
| DELETE | `/api/v1/projects/:projectId/files/:fileId` | Yes | 200 | 401 | 400 | 403 | src/routes/projects.ts:130 |
| GET | `/api/v1/projects/:projectId/files` | Yes | 200 | 401 | 400 | 403 | src/routes/projects.ts:100 |
| POST | `/api/v1/projects/:projectId/files` | Yes | 201 | 401 | 400 | 403 | src/routes/projects.ts:110 |
| GET | `/api/v1/projects/client` | Yes | 200 | 401 | 200 | - | src/routes/projects.ts:24 |
| GET | `/api/v1/projects` | Yes | 200 | 401 | 200 | - | src/routes/projects.ts:17 |
| POST | `/api/v1/projects` | Yes | 201 | 401 | 400 | - | src/routes/projects.ts:38 |
| GET | `/api/v1/settings/:key` | Yes | 200 | 403 | 404 | - | src/routes/settings.ts:16 |
| PUT | `/api/v1/settings/:key` | Yes | 200 | 403 | 400 | - | src/routes/settings.ts:19 |
| POST | `/api/v1/settings/test-email` | Yes | 200 | 403 | 400 | - | src/routes/settings.ts:30 |
| GET | `/api/v1/settings` | Yes | 200 | 403 | 200 | - | src/routes/settings.ts:13 |
| POST | `/api/v1/sprints/:id/complete` | Yes | 200 | 401 | 400 | 403 | src/routes/sprints.ts:68 |
| POST | `/api/v1/sprints/:id/start` | Yes | 200 | 401 | 400 | 403 | src/routes/sprints.ts:60 |
| GET | `/api/v1/sprints/:id/statistics` | Yes | 200 | 401 | 400 | 403 | src/routes/sprints.ts:46 |
| PUT | `/api/v1/sprints/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/sprints.ts:76 |
| DELETE | `/api/v1/sprints/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/sprints.ts:84 |
| GET | `/api/v1/sprints/project/:projectId` | Yes | 200 | 401 | 400 | 403 | src/routes/sprints.ts:53 |
| GET | `/api/v1/sprints` | Yes | 200 | 401 | 200 | - | src/routes/sprints.ts:40 |
| POST | `/api/v1/sprints` | Yes | 201 | 401 | 400 | 403 | src/routes/sprints.ts:32 |
| GET | `/api/v1/time/time-entries/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/timeTracking.ts:25 |
| PUT | `/api/v1/time/time-entries/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/timeTracking.ts:30 |
| DELETE | `/api/v1/time/time-entries/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/timeTracking.ts:40 |
| GET | `/api/v1/time/time-entries/summary/:period` | Yes | 200 | 401 | 400 | - | src/routes/timeTracking.ts:47 |
| GET | `/api/v1/time/time-entries` | Yes | 200 | 401 | 200 | - | src/routes/timeTracking.ts:24 |
| POST | `/api/v1/time/time-entries` | Yes | 201 | 401 | 400 | 403 | src/routes/timeTracking.ts:14 |
| GET | `/api/v1/users/:id/activity` | Yes | 200 | 401 | 400 | 403 | src/routes/users.ts:91 |
| POST | `/api/v1/users/:id/change-password` | Yes | 200 | 401 | 400 | 403 | src/routes/users.ts:98 |
| GET | `/api/v1/users/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/users.ts:30 |
| PUT | `/api/v1/users/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/users.ts:76 |
| DELETE | `/api/v1/users/:id` | Yes | 200 | 401 | 400 | 403 | src/routes/users.ts:83 |
| POST | `/api/v1/users/bulk` | Yes | 200 | 401 | 400 | - | src/routes/users.ts:37 |
| POST | `/api/v1/users/bulk-action` | Yes | 200 | 401 | 400 | - | src/routes/users.ts:50 |
| GET | `/api/v1/users/export` | Yes | 200 | 401 | 200 | - | src/routes/users.ts:16 |
| GET | `/api/v1/users` | Yes | 200 | 401 | 200 | - | src/routes/users.ts:23 |
| POST | `/api/v1/users` | Yes | 201 | 401 | 400 | - | src/routes/users.ts:61 |
| GET | `/api/v1` | No | 200 | 0 | 200 | - | src/routes/index.ts:43 |

## Notes

- Happy probe uses role-aware seed tokens and fixture IDs where possible.
- Authz probe checks denial behavior (missing or wrong-role token).
- Validation probe uses malformed params/body and should not produce 5xx responses.
- Cross-org probe reuses authenticated org-A tokens against org-B resource IDs; expected denial is 403/404.