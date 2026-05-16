import { Response } from 'express';
import { AuthRequest } from '../types/interfaces';
import { LeaveRequest, User, EmployeeDetails } from '../models';
import { AppError, asyncHandler } from '../middleware/errorHandler';
import sequelize from '../config/database';

export class LeaveController {
    // Apply for Leave
    // DEDUCTS BALANCE IMMEDIATELY (Temporarily, until rejected/cancelled)
    static applyLeave = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const userId = req.user!.id;
        const { leaveType, startDate, endDate, daysCount, reason, contactNumber } = req.body;

        if (daysCount <= 0) {
            throw new AppError('Invalid days count', 400);
        }

        const leaveRequest = await sequelize.transaction(async (transaction) => {
            // Check if user has sufficient balance
            const employeeDetails = await EmployeeDetails.findOne({
                where: { userId },
                transaction,
                lock: transaction.LOCK.UPDATE,
            });
            if (!employeeDetails) {
                throw new AppError('Employee details not found', 404);
            }

            let balance = 0;
            switch (leaveType) {
                case 'Annual': balance = employeeDetails.annualLeaveBalance; break;
                case 'Sick': balance = employeeDetails.sickLeaveBalance; break;
                case 'Casual': balance = employeeDetails.casualLeaveBalance; break;
                case 'Other': balance = employeeDetails.otherLeaveBalance; break;
                default: throw new AppError('Invalid leave type', 400);
            }

            if (balance < daysCount) {
                throw new AppError(`Insufficient ${leaveType} leave balance. Available: ${balance}, Requested: ${daysCount}`, 400);
            }

            // Deduct balance immediately
            switch (leaveType) {
                case 'Annual': employeeDetails.annualLeaveBalance -= daysCount; break;
                case 'Sick': employeeDetails.sickLeaveBalance -= daysCount; break;
                case 'Casual': employeeDetails.casualLeaveBalance -= daysCount; break;
                case 'Other': employeeDetails.otherLeaveBalance -= daysCount; break;
            }
            await employeeDetails.save({ transaction });

            return LeaveRequest.create({
                userId,
                leaveType,
                startDate,
                endDate,
                daysCount,
                reason,
                contactNumber,
                status: 'Pending'
            }, { transaction });
        });

        res.status(201).json({
            success: true,
            message: 'Leave application submitted successfully',
            data: { leaveRequest }
        });
    });

    // Get My Leaves
    static getMyLeaves = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const userId = req.user!.id;
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 10;
        const status = req.query.status as string; // Filter by status

        const offset = (page - 1) * limit;

        const where: any = { userId };
        if (status && status !== 'All') {
            where.status = status;
        }

        const { rows, count } = await LeaveRequest.findAndCountAll({
            where,
            order: [['createdAt', 'DESC']],
            limit,
            offset
        });

        res.json({
            success: true,
            data: {
                leaves: rows,
                pagination: {
                    total: count,
                    page,
                    limit,
                    pages: Math.ceil(count / limit)
                }
            }
        });
    });

    // Get Leave Balances
    static getMyBalances = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const userId = req.user!.id;
        const employeeDetails = await EmployeeDetails.findOne({ where: { userId } });

        if (!employeeDetails) {
            throw new AppError('Employee details not found', 404);
        }

        res.json({
            success: true,
            data: {
                annual: employeeDetails.annualLeaveBalance,
                sick: employeeDetails.sickLeaveBalance,
                casual: employeeDetails.casualLeaveBalance,
                other: employeeDetails.otherLeaveBalance
            }
        });
    });

    // Admin: Get All Leave Requests
    static getAllLeaveRequests = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { orgId } = req.user!;
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 10;
        const status = req.query.status as string;

        const where: any = {};
        if (status && status !== 'All') {
            where.status = status;
        }

        const offset = (page - 1) * limit;

        const { rows, count } = await LeaveRequest.findAndCountAll({
            where,
            include: [
                {
                    model: User,
                    as: 'user',
                    where: { orgId },
                    required: true,
                    attributes: ['id', 'firstName', 'lastName', 'email'],
                    include: [
                        {
                            model: EmployeeDetails,
                            as: 'employeeDetails',
                            attributes: ['department']
                        }
                    ]
                }
            ],
            order: [['createdAt', 'DESC']],
            limit,
            offset
        });

        res.json({
            success: true,
            data: {
                leaves: rows,
                pagination: {
                    total: count,
                    page,
                    limit,
                    pages: Math.ceil(count / limit)
                }
            }
        });
    });

    // Admin: Approve/Reject Leave
    static updateLeaveStatus = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;
        const { status, rejectionReason } = req.body;

        if (!['Approved', 'Rejected'].includes(status)) {
            throw new AppError('Invalid status', 400);
        }

        const leaveRequest = await sequelize.transaction(async (transaction) => {
            const requestRecord = await LeaveRequest.findByPk(id, {
                transaction,
                lock: transaction.LOCK.UPDATE,
            });
            if (!requestRecord) {
                throw new AppError('Leave request not found', 404);
            }

            if (requestRecord.status !== 'Pending') {
                throw new AppError('Leave request already processed', 400);
            }

            const targetUser = await User.findByPk(requestRecord.userId, {
                transaction,
                attributes: ['id', 'orgId'],
            });
            if (!targetUser || targetUser.orgId !== req.user!.orgId) {
                throw new AppError('Access denied', 403);
            }

            requestRecord.status = status;
            requestRecord.approvedBy = req.user!.id;
            if (status === 'Rejected') {
                requestRecord.rejectionReason = rejectionReason;

                // Refund balance on Rejection
                const employeeDetails = await EmployeeDetails.findOne({
                    where: { userId: requestRecord.userId },
                    transaction,
                    lock: transaction.LOCK.UPDATE,
                });
                if (employeeDetails) {
                    switch (requestRecord.leaveType) {
                        case 'Annual': employeeDetails.annualLeaveBalance += requestRecord.daysCount; break;
                        case 'Sick': employeeDetails.sickLeaveBalance += requestRecord.daysCount; break;
                        case 'Casual': employeeDetails.casualLeaveBalance += requestRecord.daysCount; break;
                        case 'Other': employeeDetails.otherLeaveBalance += requestRecord.daysCount; break;
                    }
                    await employeeDetails.save({ transaction });
                }
            }

            await requestRecord.save({ transaction });
            return requestRecord;
        });

        res.json({
            success: true,
            message: `Leave request ${status.toLowerCase()} successfully`,
            data: { leaveRequest }
        });
    });
}
