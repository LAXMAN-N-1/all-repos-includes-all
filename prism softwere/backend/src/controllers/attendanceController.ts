import { Response } from 'express';
import { AuthRequest } from '../types/interfaces';
import { Attendance, User } from '../models';
import { AppError, asyncHandler } from '../middleware/errorHandler';
import { Op } from 'sequelize';
import { format } from 'date-fns';

export class AttendanceController {
    // Check In
    static checkIn = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const userId = req.user!.id;
        const today = new Date();
        const dateStr = format(today, 'yyyy-MM-dd');
        const { workLocation } = req.body;

        // Check if already checked in
        const existingAttendance = await Attendance.findOne({
            where: {
                userId,
                date: dateStr
            }
        });

        if (existingAttendance) {
            throw new AppError('Already checked in for today', 400);
        }

        const attendance = await Attendance.create({
            userId,
            date: dateStr,
            checkInTime: today,
            status: 'Present',
            workLocation: workLocation || 'Office',
            approvalStatus: 'Pending',
            notes: req.body.notes
        });

        res.status(201).json({
            success: true,
            message: 'Checked in successfully',
            data: { attendance }
        });
    });

    // Check Out
    static checkOut = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const userId = req.user!.id;
        const today = new Date();
        const dateStr = format(today, 'yyyy-MM-dd');

        const attendance = await Attendance.findOne({
            where: {
                userId,
                date: dateStr
            }
        });

        if (!attendance) {
            throw new AppError('No check-in record found for today', 404);
        }

        if (attendance.checkOutTime) {
            throw new AppError('Already checked out for today', 400);
        }

        attendance.checkOutTime = today;

        // Calculate total hours
        if (attendance.checkInTime) {
            const diffMs = today.getTime() - new Date(attendance.checkInTime).getTime();
            const totalHours = diffMs / (1000 * 60 * 60);
            attendance.totalHours = parseFloat(totalHours.toFixed(2));
        }

        await attendance.save();

        res.json({
            success: true,
            message: 'Checked out successfully',
            data: { attendance }
        });
    });

    // Update Status (Admin)
    static updateStatus = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { id } = req.params;
        const { status, rejectionReason } = req.body;

        const attendance = await Attendance.findByPk(id, {
            include: [
                {
                    model: User,
                    as: 'user',
                    attributes: ['id', 'orgId'],
                },
            ],
        });

        if (!attendance) {
            throw new AppError('Attendance record not found', 404);
        }
        const attendanceUser = attendance.get('user') as User | undefined;
        if (!attendanceUser || attendanceUser.orgId !== req.user!.orgId) {
            throw new AppError('Access denied', 403);
        }

        attendance.approvalStatus = status;
        if (status === 'Rejected' && rejectionReason) {
            attendance.rejectionReason = rejectionReason;
            // Also mark as Absent if rejected? Or just keep rejected status?
            // Requirement says "❌ Rejected (Red) - Admin rejected". 
            // We can keep status as Present but approvalStatus as Rejected, or sync them. 
            // For now, let's keep status as is, approvalStatus governs the validity.
        }

        await attendance.save();

        res.json({
            success: true,
            message: `Attendance ${status.toLowerCase()} successfully`,
            data: { attendance }
        });
    });

    // Get My Attendance
    static getMyAttendance = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const userId = req.user!.id;
        const { startDate, endDate } = req.query;

        const where: any = { userId };

        if (startDate && endDate) {
            where.date = {
                [Op.between]: [startDate, endDate]
            };
        }

        const attendance = await Attendance.findAll({
            where,
            order: [['date', 'DESC']]
        });

        res.json({
            success: true,
            data: { attendance }
        });
    });

    // Get Employee Attendance (Admin)
    static getEmployeeAttendance = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { userId } = req.params;
        const { startDate, endDate } = req.query;

        const targetUser = await User.findByPk(userId);
        if (!targetUser || targetUser.orgId !== req.user!.orgId) {
            throw new AppError('Access denied', 403);
        }

        const where: any = { userId };

        if (startDate && endDate) {
            where.date = {
                [Op.between]: [startDate, endDate]
            };
        }

        const attendance = await Attendance.findAll({
            where,
            order: [['date', 'DESC']],
            include: [
                {
                    model: User,
                    as: 'user',
                    attributes: ['id', 'firstName', 'lastName', 'email']
                }
            ]
        });

        res.json({
            success: true,
            data: { attendance }
        });
    });

    // Get All Attendance (Admin Dashboard)
    static getAllAttendance = asyncHandler(async (req: AuthRequest, res: Response): Promise<void> => {
        const { orgId } = req.user!;
        const { date, approvalStatus } = req.query;
        const where: any = {};

        if (date) {
            where.date = String(date);
        }

        if (approvalStatus) {
            where.approvalStatus = String(approvalStatus);
        }

        const attendance = await Attendance.findAll({
            where,
            order: [['date', 'DESC'], ['checkInTime', 'DESC']],
            include: [
                {
                    model: User,
                    as: 'user',
                    where: { orgId },
                    required: true,
                    attributes: ['id', 'firstName', 'lastName', 'email', 'profileData'],
                },
                // We would ideally join with EmployeeDetails here to get Department, but EmployeeDetails is associated with User
                // Nested include: User -> EmployeeDetails
                /*
                {
                    model: User,
                    as: 'user',
                    include: [{ model: EmployeeDetails, as: 'employeeDetails' }]
                }
                */
            ]
        });

        res.json({
            success: true,
            data: { attendance }
        });
    });
}
