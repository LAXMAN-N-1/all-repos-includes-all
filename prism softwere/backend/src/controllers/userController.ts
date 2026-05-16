import { Response } from 'express';
import { AuthRequest } from '../types/interfaces';
import { User, Organization, AuditLog, EmployeeDetails } from '../models';
import { AppError, asyncHandler } from '../middleware/errorHandler';
import { AuditAction, UserRole } from '../types/enums';
import { getOffset, getPaginationMeta } from '../utils/helpers';
import { Op } from 'sequelize';

export class UserController {
    // Get all users (with pagination and filters)
    static getAllUsers = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 10;
        const search = req.query.search as string;
        const role = req.query.role as UserRole;
        const isActive = req.query.isActive as string;

        const sortBy = req.query.sortBy as string || 'createdAt';
        const sortDir = (req.query.sortDir as string)?.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';

        const where: any = {};

        // Multi-tenant isolation: always scope to request user's organization
        where.orgId = req.user?.orgId;

        // Search filter
        if (search) {
            where[Op.or] = [
                { firstName: { [Op.iLike]: `%${search}%` } },
                { lastName: { [Op.iLike]: `%${search}%` } },
                { email: { [Op.iLike]: `%${search}%` } },
            ];
        }

        // Role filter
        if (role) {
            where.role = role;
        }

        // Active status filter
        if (isActive !== undefined) {
            where.isActive = isActive === 'true';
        }

        // Determine column for sorting
        let orderColumn = 'createdAt';
        if (sortBy === 'name') orderColumn = 'firstName';
        else if (sortBy === 'role') orderColumn = 'role';
        else if (sortBy === 'email') orderColumn = 'email';
        else if (sortBy === 'isActive') orderColumn = 'isActive';

        const { count, rows } = await User.findAndCountAll({
            where,
            limit,
            offset: getOffset(page, limit),
            order: [[orderColumn, sortDir]],
            include: [
                {
                    model: Organization,
                    as: 'organization',
                    attributes: ['id', 'name'],
                },
                {
                    model: EmployeeDetails,
                    as: 'employeeDetails',
                }
            ],
        });

        res.json({
            success: true,
            data: {
                users: rows.map(user => user.toJSON()),
                pagination: getPaginationMeta(page, limit, count),
            },
        });
    });

    // Get user by ID
    static getUserById = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;

        const user = await User.findByPk(id, {
            include: [
                {
                    model: Organization,
                    as: 'organization',
                    attributes: ['id', 'name'],
                },
                {
                    model: EmployeeDetails,
                    as: 'employeeDetails',
                }
            ],
        });

        if (!user) {
            throw new AppError('User not found', 404);
        }

        // Check access (always org-scoped)
        if (user.orgId !== req.user?.orgId) {
            throw new AppError('Access denied', 403);
        }

        res.json({
            success: true,
            data: { user: user.toJSON() },
        });
    });

    // Create user
    static createUser = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { email, password, firstName, lastName, role, orgId } = req.body;

        // Check if user already exists
        const existingUser = await User.findOne({ where: { email } });
        if (existingUser) {
            throw new AppError('User with this email already exists', 400);
        }

        // Validate organization access
        const targetOrgId = orgId || req.user?.orgId;
        if (targetOrgId !== req.user?.orgId) {
            throw new AppError('Cannot create user in different organization', 403);
        }

        // Create user
        const user = await User.create({
            email,
            passwordHash: '',
            firstName,
            lastName,
            role: role || UserRole.EMPLOYEE,
            orgId: targetOrgId,
            profileData: {},
            mfaEnabled: false,
            isActive: true,
        });

        await user.setPassword(password);
        await user.save();

        // If role is employee and details are provided, create employee details
        if (role === UserRole.EMPLOYEE && req.body.employeeDetails) {
            const details = { ...req.body.employeeDetails };
            // Sanitize empty strings to null for optional UUID/Date fields
            if (details.reportingManagerId === '') details.reportingManagerId = null;
            if (details.officeLocation === '') details.officeLocation = null;

            await EmployeeDetails.create({
                userId: user.id,
                ...details
            });
        }

        // Fetch user with details
        const createdUser = await User.findByPk(user.id, {
            include: [{ model: EmployeeDetails, as: 'employeeDetails' }]
        });

        // Audit log
        await AuditLog.create({
            userId: req.user!.id,
            action: AuditAction.CREATE,
            resource: 'user',
            resourceId: user.id,
            details: { email: user.email, role: user.role },
            ipAddress: req.ip,
            userAgent: req.get('user-agent'),
        });

        res.status(201).json({
            success: true,
            message: 'User created successfully',
            data: { user: createdUser ? createdUser.toJSON() : user.toJSON() },
        });
    });

    // Update user
    static updateUser = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;
        const { firstName, lastName, role, isActive, profileData, employeeDetails } = req.body;

        const user = await User.findByPk(id);
        if (!user) {
            throw new AppError('User not found', 404);
        }

        // Check access
        if (user.orgId !== req.user?.orgId) {
            throw new AppError('Access denied', 403);
        }

        // Only admins can change roles and active status
        if ((role || isActive !== undefined) && req.user?.role !== UserRole.ADMIN) {
            throw new AppError('Only admins can change user role or status', 403);
        }

        // Update fields
        if (firstName) user.firstName = firstName;
        if (lastName) user.lastName = lastName;
        if (role) user.role = role;
        if (isActive !== undefined) user.isActive = isActive;
        if (profileData) user.profileData = { ...user.profileData, ...profileData };

        // Handle email update with uniqueness check
        if (req.body.email && req.body.email !== user.email) {
            const existingUser = await User.findOne({ where: { email: req.body.email } });
            if (existingUser) {
                throw new AppError('User with this email already exists', 400);
            }
            user.email = req.body.email;
        }

        await user.save();

        // Update employee details if provided
        if (employeeDetails) {
            const existingDetails = await EmployeeDetails.findOne({ where: { userId: user.id } });
            if (existingDetails) {
                await existingDetails.update(employeeDetails);
            } else if (user.role === UserRole.EMPLOYEE) {
                await EmployeeDetails.create({
                    userId: user.id,
                    ...employeeDetails
                });
            }
        }

        // Audit log
        await AuditLog.create({
            userId: req.user!.id,
            action: AuditAction.UPDATE,
            resource: 'user',
            resourceId: user.id,
            details: { changes: req.body },
            ipAddress: req.ip,
            userAgent: req.get('user-agent'),
        });

        res.json({
            success: true,
            message: 'User updated successfully',
            data: { user: user.toJSON() },
        });
    });

    // Bulk create users
    static bulkCreate = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { users } = req.body; // Expects an array of user objects

        if (!Array.isArray(users) || users.length === 0) {
            throw new AppError('Invalid users data', 400);
        }

        const createdUsers = [];
        const errors = [];

        // We process sequentially to handle errors gracefully and ensure hooks run (hashing passwords)
        for (const userData of users) {
            try {
                // user orgId should default to admin's org if not provided, or be validated
                const orgId = req.user!.orgId;

                // Check existing
                const existing = await User.findOne({ where: { email: userData.email } });
                if (existing) {
                    errors.push({ email: userData.email, error: 'Email already exists' });
                    continue;
                }

                const email = String(userData.email || '').trim().toLowerCase();
                const firstName = String(userData.firstName || '').trim();
                const lastName = String(userData.lastName || '').trim();
                const password = String(userData.password || 'Temporary@123');

                if (!email || !firstName || !lastName) {
                    errors.push({ email: userData.email, error: 'Missing required fields' });
                    continue;
                }

                const user = await User.create({
                    email,
                    firstName,
                    lastName,
                    role: userData.role || UserRole.EMPLOYEE,
                    orgId,
                    profileData: userData.profileData || {},
                    mfaEnabled: false,
                    isActive: true,
                    passwordHash: '',
                    username: userData.username || null,
                    phone: userData.phone || null,
                    forcePasswordChange: Boolean(userData.forcePasswordChange ?? true),
                    createdBy: req.user!.id,
                });
                await user.setPassword(password);
                await user.save();
                createdUsers.push(user);
            } catch (error: any) {
                errors.push({ email: userData.email, error: error.message });
            }
        }

        res.json({
            success: true,
            data: {
                createdCount: createdUsers.length,
                errorCount: errors.length,
                errors,
            },
        });
    });

    // Bulk action (Deactivate/Delete)
    static bulkAction = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { userIds, action } = req.body;

        if (!Array.isArray(userIds) || userIds.length === 0) {
            throw new AppError('Invalid user IDs', 400);
        }

        let result;
        if (action === 'DEACTIVATE') {
            result = await User.update(
                { isActive: false },
                { where: { id: { [Op.in]: userIds }, orgId: req.user!.orgId } }
            );
        } else if (action === 'ACTIVATE') {
            result = await User.update(
                { isActive: true },
                { where: { id: { [Op.in]: userIds }, orgId: req.user!.orgId } }
            );
        } else if (action === 'DELETE') {
            result = await User.destroy({
                where: { id: { [Op.in]: userIds }, orgId: req.user!.orgId }
            });
        } else {
            throw new AppError('Invalid action', 400);
        }

        res.json({
            success: true,
            message: `Bulk ${action} completed successfully`,
            data: { count: typeof result === 'number' ? result : result[0] }, // update returns [count], destroy returns count
        });
    });

    // Export users to CSV
    static exportUsers = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const search = req.query.search as string;
        const role = req.query.role as UserRole;
        const isActive = req.query.isActive as string;

        const where: any = {};
        where.orgId = req.user?.orgId;
        if (search) {
            where[Op.or] = [
                { firstName: { [Op.iLike]: `%${search}%` } },
                { lastName: { [Op.iLike]: `%${search}%` } },
                { email: { [Op.iLike]: `%${search}%` } },
            ];
        }
        if (role) where.role = role;
        if (isActive !== undefined) where.isActive = isActive === 'true';

        const users = await User.findAll({
            where,
            order: [['createdAt', 'DESC']],
            include: [{ model: Organization, as: 'organization', attributes: ['name'] }]
        });

        // Convert to CSV
        const fields = ['id', 'email', 'firstName', 'lastName', 'role', 'isActive', 'createdAt', 'organization.name'];
        const csvRows = [];

        // Header
        csvRows.push(fields.join(','));

        // Rows
        for (const user of users) {
            const u: any = user.toJSON();
            const row = fields.map(field => {
                const keys = field.split('.');
                let value = u;
                for (const key of keys) {
                    value = value ? value[key] : '';
                }
                // Escape quotes and wrap in quotes
                const stringValue = String(value === null || value === undefined ? '' : value);
                return `"${stringValue.replace(/"/g, '""')}"`;
            });
            csvRows.push(row.join(','));
        }

        const csvString = csvRows.join('\n');

        res.header('Content-Type', 'text/csv');
        res.header('Content-Disposition', 'attachment; filename="users.csv"');
        res.send(csvString);
    });

    // Delete user
    static deleteUser = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;

        const user = await User.findByPk(id);
        if (!user) {
            throw new AppError('User not found', 404);
        }
        if (user.orgId !== req.user?.orgId) {
            throw new AppError('Access denied', 403);
        }

        // Check access (only admins can delete users)
        if (req.user?.role !== UserRole.ADMIN) {
            throw new AppError('Only admins can delete users', 403);
        }

        // Prevent self-deletion
        if (user.id === req.user?.id) {
            throw new AppError('Cannot delete your own account', 400);
        }

        // Audit log before deletion
        await AuditLog.create({
            userId: req.user!.id,
            action: AuditAction.DELETE,
            resource: 'user',
            resourceId: user.id,
            details: { email: user.email },
            ipAddress: req.ip,
            userAgent: req.get('user-agent'),
        });

        try {
            await user.destroy();
        } catch (error: any) {
            if (error.name === 'SequelizeForeignKeyConstraintError') {
                throw new AppError(
                    'Cannot delete user because they are assigned to projects or issues. Please reassign their work first.',
                    409
                );
            }
            throw error;
        }

        res.json({
            success: true,
            message: 'User deleted successfully',
        });
    });

    // Get user activity logs
    static getUserActivity = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 20;

        const user = await User.findByPk(id);
        if (!user) {
            throw new AppError('User not found', 404);
        }
        if (user.orgId !== req.user?.orgId) {
            throw new AppError('Access denied', 403);
        }

        // Check access
        if (req.user?.role !== UserRole.ADMIN && user.id !== req.user?.id) {
            throw new AppError('Access denied', 403);
        }

        const { count, rows } = await AuditLog.findAndCountAll({
            where: { userId: id },
            limit,
            offset: getOffset(page, limit),
            order: [['createdAt', 'DESC']],
        });

        res.json({
            success: true,
            data: {
                activities: rows,
                pagination: getPaginationMeta(page, limit, count),
            },
        });
    });

    // Change password
    static changePassword = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;
        const { currentPassword, newPassword } = req.body;

        const user = await User.findByPk(id);
        if (!user) {
            throw new AppError('User not found', 404);
        }
        if (user.orgId !== req.user?.orgId) {
            throw new AppError('Access denied', 403);
        }

        // Users can only change their own password, unless admin
        if (req.user?.role !== UserRole.ADMIN && user.id !== req.user?.id) {
            throw new AppError('Access denied', 403);
        }

        // Verify current password (not required for admins)
        if (req.user?.role !== UserRole.ADMIN) {
            const isValid = await user.comparePassword(currentPassword);
            if (!isValid) {
                throw new AppError('Current password is incorrect', 400);
            }
        }

        // Set new password
        await user.setPassword(newPassword);
        user.refreshToken = undefined; // Invalidate all sessions
        await user.save();

        // Audit log
        await AuditLog.create({
            userId: req.user!.id,
            action: AuditAction.UPDATE,
            resource: 'user',
            resourceId: user.id,
            details: { action: 'password_change' },
            ipAddress: req.ip,
            userAgent: req.get('user-agent'),
        });

        res.json({
            success: true,
            message: 'Password changed successfully',
        });
    });
}
