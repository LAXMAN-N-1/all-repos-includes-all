import { DataTypes, Model, Optional } from 'sequelize';
import sequelize from '../config/database';

interface DailyReportEntryAttributes {
    id: string;
    reportId: string;
    taskId?: string;
    taskTitle: string;
    type: 'work' | 'blocker';
    hours: number;
    progress: number;
    notes: string;
    time: string;
    // Blocker-specific fields
    severity?: 'low' | 'medium' | 'high';
    blockerStatus?: 'OPEN' | 'RESOLVED';
    taggedPeople?: string[];
    resolvedAt?: string;
    createdAt?: Date;
    updatedAt?: Date;
}

interface DailyReportEntryCreationAttributes extends Optional<DailyReportEntryAttributes, 'id' | 'createdAt' | 'updatedAt'> { }

class DailyReportEntry extends Model<DailyReportEntryAttributes, DailyReportEntryCreationAttributes> implements DailyReportEntryAttributes {
    public id!: string;
    public reportId!: string;
    public taskId?: string;
    public taskTitle!: string;
    public type!: 'work' | 'blocker';
    public hours!: number;
    public progress!: number;
    public notes!: string;
    public time!: string;
    public severity?: 'low' | 'medium' | 'high';
    public blockerStatus?: 'OPEN' | 'RESOLVED';
    public taggedPeople?: string[];
    public resolvedAt?: string;
    public readonly createdAt!: Date;
    public readonly updatedAt!: Date;
}

DailyReportEntry.init(
    {
        id: {
            type: DataTypes.UUID,
            defaultValue: DataTypes.UUIDV4,
            primaryKey: true,
        },
        reportId: {
            type: DataTypes.UUID,
            allowNull: false,
            references: { model: 'DailyReports', key: 'id' },
            onDelete: 'CASCADE',
        },
        taskId: {
            type: DataTypes.UUID,
            allowNull: true,
        },
        taskTitle: {
            type: DataTypes.STRING(500),
            allowNull: false,
        },
        type: {
            type: DataTypes.ENUM('work', 'blocker'),
            defaultValue: 'work',
        },
        hours: {
            type: DataTypes.DECIMAL(10, 2),
            defaultValue: 0,
        },
        progress: {
            type: DataTypes.INTEGER,
            defaultValue: 0,
        },
        notes: {
            type: DataTypes.TEXT,
            defaultValue: '',
        },
        time: {
            type: DataTypes.STRING(20),
            allowNull: false,
        },
        severity: {
            type: DataTypes.ENUM('low', 'medium', 'high'),
            allowNull: true,
        },
        blockerStatus: {
            type: DataTypes.ENUM('OPEN', 'RESOLVED'),
            allowNull: true,
        },
        taggedPeople: {
            type: DataTypes.ARRAY(DataTypes.UUID),
            defaultValue: [],
        },
        resolvedAt: {
            type: DataTypes.STRING(20),
            allowNull: true,
        },
    },
    {
        sequelize,
        tableName: 'DailyReportEntries',
        timestamps: true,
        indexes: [
            { fields: ['reportId'] },
            { fields: ['type'] },
        ],
    }
);

export default DailyReportEntry;
