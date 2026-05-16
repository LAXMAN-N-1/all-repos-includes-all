import { DataTypes, Model, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface LeaveRequestAttributes {
    id: string;
    userId: string;
    leaveType: 'Annual' | 'Sick' | 'Casual' | 'Other';
    startDate: string; // YYYY-MM-DD
    endDate: string; // YYYY-MM-DD
    daysCount: number;
    reason: string;
    contactNumber?: string;
    status: 'Pending' | 'Approved' | 'Rejected' | 'Cancelled';
    approvedBy?: string;
    rejectionReason?: string;
    createdAt?: Date;
    updatedAt?: Date;
}

interface LeaveRequestCreationAttributes extends Optional<LeaveRequestAttributes, 'id' | 'createdAt' | 'updatedAt'> { }

class LeaveRequest extends Model<LeaveRequestAttributes, LeaveRequestCreationAttributes> implements LeaveRequestAttributes {
    public id!: string;
    public userId!: string;
    public leaveType!: 'Annual' | 'Sick' | 'Casual' | 'Other';
    public startDate!: string;
    public endDate!: string;
    public daysCount!: number;
    public reason!: string;
    public contactNumber?: string;
    public status!: 'Pending' | 'Approved' | 'Rejected' | 'Cancelled';
    public approvedBy?: string;
    public rejectionReason?: string;
    public readonly createdAt!: Date;
    public readonly updatedAt!: Date;
}

LeaveRequest.init(
    {
        id: {
            type: DataTypes.UUID,
            defaultValue: DataTypes.UUIDV4,
            primaryKey: true,
        },
        userId: {
            type: DataTypes.UUID,
            allowNull: false,
            references: {
                model: 'Users',
                key: 'id',
            },
            onDelete: 'CASCADE',
            field: 'user_id'
        },
        leaveType: {
            type: DataTypes.ENUM('Annual', 'Sick', 'Casual', 'Other'),
            allowNull: false,
            field: 'leave_type'
        },
        startDate: {
            type: DataTypes.DATEONLY,
            allowNull: false,
            field: 'start_date'
        },
        endDate: {
            type: DataTypes.DATEONLY,
            allowNull: false,
            field: 'end_date'
        },
        daysCount: {
            type: DataTypes.FLOAT,
            allowNull: false,
            field: 'days_count'
        },
        reason: {
            type: DataTypes.TEXT,
            allowNull: false,
        },
        contactNumber: {
            type: DataTypes.STRING,
            allowNull: true,
        },
        status: {
            type: DataTypes.ENUM('Pending', 'Approved', 'Rejected', 'Cancelled'),
            defaultValue: 'Pending',
            allowNull: false,
        },
        approvedBy: {
            type: DataTypes.UUID,
            allowNull: true,
            references: {
                model: 'Users',
                key: 'id',
            },
            field: 'approved_by'
        },
        rejectionReason: {
            type: DataTypes.TEXT,
            allowNull: true,
            field: 'rejection_reason'
        },
    },
    {
        sequelize,
        tableName: 'LeaveRequests',
        timestamps: true,
    }
);

export default LeaveRequest;
