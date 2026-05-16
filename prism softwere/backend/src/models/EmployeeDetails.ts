import { DataTypes, Model, Optional } from 'sequelize';
import sequelize from '../config/database';

export interface EmployeeDetailsAttributes {
    id: string;
    userId: string;
    department: string;
    designation: string;
    employeeId: string;
    dateOfJoining: Date;
    employmentType: 'Full-time' | 'Part-time' | 'Contract' | 'Intern';
    reportingManagerId?: string;
    workLocation: 'Office' | 'Remote' | 'Hybrid';
    officeLocation?: string;
    shiftTiming: string;
    annualLeaveBalance: number;
    sickLeaveBalance: number;
    casualLeaveBalance: number;
    otherLeaveBalance: number;
    createdAt?: Date;
    updatedAt?: Date;
}

interface EmployeeDetailsCreationAttributes extends Optional<EmployeeDetailsAttributes, 'id' | 'createdAt' | 'updatedAt'> { }

class EmployeeDetails extends Model<EmployeeDetailsAttributes, EmployeeDetailsCreationAttributes> implements EmployeeDetailsAttributes {
    public id!: string;
    public userId!: string;
    public department!: string;
    public designation!: string;
    public employeeId!: string;
    public dateOfJoining!: Date;
    public employmentType!: 'Full-time' | 'Part-time' | 'Contract' | 'Intern';
    public reportingManagerId?: string;
    public workLocation!: 'Office' | 'Remote' | 'Hybrid';
    public officeLocation?: string;
    public shiftTiming!: string;
    public annualLeaveBalance!: number;
    public sickLeaveBalance!: number;
    public casualLeaveBalance!: number;
    public otherLeaveBalance!: number;
    public readonly createdAt!: Date;
    public readonly updatedAt!: Date;
}

EmployeeDetails.init(
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
        department: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        designation: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        employeeId: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true,
            field: 'employee_id'
        },
        dateOfJoining: {
            type: DataTypes.DATEONLY,
            allowNull: false,
            field: 'date_of_joining'
        },
        employmentType: {
            type: DataTypes.ENUM('Full-time', 'Part-time', 'Contract', 'Intern'),
            allowNull: false,
            field: 'employment_type'
        },
        reportingManagerId: {
            type: DataTypes.UUID,
            allowNull: true,
            references: {
                model: 'Users',
                key: 'id',
            },
            field: 'reporting_manager_id'
        },
        workLocation: {
            type: DataTypes.ENUM('Office', 'Remote', 'Hybrid'),
            allowNull: false,
            field: 'work_location'
        },
        officeLocation: {
            type: DataTypes.STRING,
            allowNull: true,
            field: 'office_location'
        },
        shiftTiming: {
            type: DataTypes.STRING,
            allowNull: false,
            field: 'shift_timing'
        },
        annualLeaveBalance: {
            type: DataTypes.FLOAT,
            defaultValue: 20,
            field: 'annual_leave_balance'
        },
        sickLeaveBalance: {
            type: DataTypes.FLOAT,
            defaultValue: 10,
            field: 'sick_leave_balance'
        },
        casualLeaveBalance: {
            type: DataTypes.FLOAT,
            defaultValue: 5,
            field: 'casual_leave_balance'
        },
        otherLeaveBalance: {
            type: DataTypes.FLOAT,
            defaultValue: 5,
            field: 'other_leave_balance'
        }
    },
    {
        sequelize,
        tableName: 'EmployeeDetails',
        timestamps: true,
    }
);

export default EmployeeDetails;
