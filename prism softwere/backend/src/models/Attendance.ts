import { DataTypes, Model, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface AttendanceAttributes {
    id: string;
    userId: string;
    date: string; // YYYY-MM-DD
    checkInTime?: Date;
    checkOutTime?: Date;
    workLocation?: 'Office' | 'Home' | 'Remote';
    status: 'Present' | 'Absent' | 'Half Day' | 'On Leave';
    approvalStatus: 'Pending' | 'Approved' | 'Rejected';
    rejectionReason?: string;
    totalHours?: number;
    notes?: string;
    createdAt?: Date;
    updatedAt?: Date;
}

interface AttendanceCreationAttributes extends Optional<AttendanceAttributes, 'id' | 'createdAt' | 'updatedAt'> { }

class Attendance extends Model<AttendanceAttributes, AttendanceCreationAttributes> implements AttendanceAttributes {
    public id!: string;
    public userId!: string;
    public date!: string;
    public checkInTime?: Date;
    public checkOutTime?: Date;
    public workLocation?: 'Office' | 'Home' | 'Remote';
    public status!: 'Present' | 'Absent' | 'Half Day' | 'On Leave';
    public approvalStatus!: 'Pending' | 'Approved' | 'Rejected';
    public rejectionReason?: string;
    public totalHours?: number;
    public notes?: string;
    public readonly createdAt!: Date;
    public readonly updatedAt!: Date;
}

Attendance.init(
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
        date: {
            type: DataTypes.DATEONLY,
            allowNull: false,
        },
        checkInTime: {
            type: DataTypes.DATE,
            allowNull: true,
            field: 'check_in_time'
        },
        checkOutTime: {
            type: DataTypes.DATE,
            allowNull: true,
            field: 'check_out_time'
        },
        workLocation: {
            type: DataTypes.ENUM('Office', 'Home', 'Remote'),
            allowNull: true,
            defaultValue: 'Office'
        },
        status: {
            type: DataTypes.ENUM('Present', 'Absent', 'Half Day', 'On Leave'),
            defaultValue: 'Present',
            allowNull: false,
        },
        approvalStatus: {
            type: DataTypes.ENUM('Pending', 'Approved', 'Rejected'),
            defaultValue: 'Pending',
            allowNull: false,
        },
        rejectionReason: {
            type: DataTypes.TEXT,
            allowNull: true,
        },
        totalHours: {
            type: DataTypes.FLOAT,
            allowNull: true,
            field: 'total_hours'
        },
        notes: {
            type: DataTypes.TEXT,
            allowNull: true,
        },
    },
    {
        sequelize,
        tableName: 'Attendance',
        timestamps: true,
        indexes: [
            {
                unique: true,
                fields: ['userId', 'date']
            }
        ]
    }
);

export default Attendance;
