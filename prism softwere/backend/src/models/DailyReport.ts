import { DataTypes, Model, Optional } from 'sequelize';
import sequelize from '../config/database';

interface DailyReportAttributes {
    id: string;
    projectId: string;
    userId: string;
    date: string; // DATEONLY
    standupSubmitted: boolean;
    standupTime?: string;
    standupTasks: string[]; // array of task IDs
    concerns: string;
    lessonsLearned: string;
    summarySubmitted: boolean;
    summaryTime?: string;
    status: 'excellent' | 'good' | 'at-risk' | 'missing';
    createdAt?: Date;
    updatedAt?: Date;
}

interface DailyReportCreationAttributes extends Optional<DailyReportAttributes, 'id' | 'createdAt' | 'updatedAt'> { }

class DailyReport extends Model<DailyReportAttributes, DailyReportCreationAttributes> implements DailyReportAttributes {
    public id!: string;
    public projectId!: string;
    public userId!: string;
    public date!: string;
    public standupSubmitted!: boolean;
    public standupTime?: string;
    public standupTasks!: string[];
    public concerns!: string;
    public lessonsLearned!: string;
    public summarySubmitted!: boolean;
    public summaryTime?: string;
    public status!: 'excellent' | 'good' | 'at-risk' | 'missing';
    public readonly createdAt!: Date;
    public readonly updatedAt!: Date;
}

DailyReport.init(
    {
        id: {
            type: DataTypes.UUID,
            defaultValue: DataTypes.UUIDV4,
            primaryKey: true,
        },
        projectId: {
            type: DataTypes.UUID,
            allowNull: false,
            references: { model: 'Projects', key: 'id' },
            onDelete: 'CASCADE',
        },
        userId: {
            type: DataTypes.UUID,
            allowNull: false,
            references: { model: 'Users', key: 'id' },
            onDelete: 'CASCADE',
        },
        date: {
            type: DataTypes.DATEONLY,
            allowNull: false,
        },
        standupSubmitted: {
            type: DataTypes.BOOLEAN,
            defaultValue: false,
        },
        standupTime: {
            type: DataTypes.STRING(20),
            allowNull: true,
        },
        standupTasks: {
            type: DataTypes.ARRAY(DataTypes.UUID),
            defaultValue: [],
        },
        concerns: {
            type: DataTypes.TEXT,
            defaultValue: '',
        },
        lessonsLearned: {
            type: DataTypes.TEXT,
            defaultValue: '',
        },
        summarySubmitted: {
            type: DataTypes.BOOLEAN,
            defaultValue: false,
        },
        summaryTime: {
            type: DataTypes.STRING(20),
            allowNull: true,
        },
        status: {
            type: DataTypes.ENUM('excellent', 'good', 'at-risk', 'missing'),
            defaultValue: 'missing',
        },
    },
    {
        sequelize,
        tableName: 'DailyReports',
        timestamps: true,
        indexes: [
            { unique: true, fields: ['projectId', 'userId', 'date'] },
            { fields: ['projectId'] },
            { fields: ['userId'] },
            { fields: ['date'] },
        ],
    }
);

export default DailyReport;
