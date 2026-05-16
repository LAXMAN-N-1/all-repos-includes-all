import { Response } from 'express';
import { AuthRequest } from '../types/interfaces';
import { Attachment, AuditLog } from '../models';
import { AppError, asyncHandler } from '../middleware/errorHandler';
import { AuditAction } from '../types/enums';
import { FileService } from '../services/fileService';
import { getAccessibleIssue, getAccessibleProject } from '../utils/accessControl';

export class AttachmentController {
    // Upload attachment to issue or project
    static uploadAttachment = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        // ID could be in params (/:issueId/attachments) or body
        const issueId = req.params.issueId || req.body.issueId;
        const projectId = req.params.projectId || req.params.id || req.body.projectId;

        const file = req.file;

        if (!file) {
            throw new AppError('No file uploaded', 400);
        }

        if (!issueId && !projectId) {
            throw new AppError('Target Issue or Project ID is required', 400);
        }
        if (issueId && projectId) {
            throw new AppError('Provide either issueId or projectId, not both', 400);
        }

        if (issueId) {
            await getAccessibleIssue(req, issueId, { requireClientVisible: true });
        } else if (projectId) {
            await getAccessibleProject(req, projectId);
        }

        // Upload file (MVP: Local storage via FileService)
        // In a real app, this would upload to S3/GCS
        const fileUrl = `/uploads/${file.filename}`; // Assuming local storage for now

        let attachment;
        try {
            attachment = await Attachment.create({
                issueId: issueId || null,
                projectId: projectId || null,
                userId: req.user!.id,
                filename: file.filename,
                originalName: file.originalname,
                mimetype: file.mimetype,
                size: file.size,
                path: file.path,
                fileUrl,
            });
        } catch (error: any) {
            const message = String(error?.message || '');
            if (!issueId && projectId && /issueId|issue_id/i.test(message)) {
                throw new AppError(
                    'Project-level attachments require latest database migrations',
                    400
                );
            }
            throw error;
        }

        // Audit log
        await AuditLog.create({
            userId: req.user!.id,
            action: AuditAction.CREATE,
            resource: 'attachment',
            resourceId: attachment.id,
            details: { filename: file.originalname, size: file.size },
            ipAddress: req.ip,
            userAgent: req.get('user-agent'),
        });

        res.status(201).json({
            success: true,
            data: { attachment },
        });
    });

    // Delete attachment
    static deleteAttachment = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;

        const attachment = await Attachment.findByPk(id);
        if (!attachment) {
            throw new AppError('Attachment not found', 404);
        }

        if (attachment.issueId) {
            await getAccessibleIssue(req, attachment.issueId, { requireClientVisible: true });
        } else if (attachment.projectId) {
            await getAccessibleProject(req, attachment.projectId);
        }

        // Check ownership (or admin/scrum master)
        if (attachment.userId !== req.user!.id && req.user!.role !== 'ADMIN' && req.user!.role !== 'SCRUM_MASTER') {
            throw new AppError('Access denied', 403);
        }

        // Delete file from storage (Implementation depends on storage strategy)
        await FileService.deleteFile(attachment.filename);

        await attachment.destroy();

        // Audit log
        await AuditLog.create({
            userId: req.user!.id,
            action: AuditAction.DELETE,
            resource: 'attachment',
            resourceId: attachment.id,
            details: { filename: attachment.originalName },
            ipAddress: req.ip,
            userAgent: req.get('user-agent'),
        });

        res.json({
            success: true,
            message: 'Attachment deleted successfully',
        });
    });
}
