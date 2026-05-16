import { DataTypes, Model, Optional } from 'sequelize';
import sequelize from '../config/database';

interface DailyReportCommentAttributes {
    id: string;
    reportId: string;
    userId: string;
    content: string;
    mentions: string[];
    messageType: 'comment' | 'question' | 'announcement' | 'action_item';
    parentId?: string | null;
    isPinned: boolean;
    isEdited: boolean;
    reactions: Record<string, string[]>; // { "👍": ["userId1", "userId2"], "🔥": ["userId3"] }
    createdAt?: Date;
    updatedAt?: Date;
}

interface DailyReportCommentCreationAttributes extends Optional<DailyReportCommentAttributes, 'id' | 'createdAt' | 'updatedAt' | 'messageType' | 'parentId' | 'isPinned' | 'isEdited' | 'reactions'> { }

class DailyReportComment extends Model<DailyReportCommentAttributes, DailyReportCommentCreationAttributes> implements DailyReportCommentAttributes {
    public id!: string;
    public reportId!: string;
    public userId!: string;
    public content!: string;
    public mentions!: string[];
    public messageType!: 'comment' | 'question' | 'announcement' | 'action_item';
    public parentId!: string | null;
    public isPinned!: boolean;
    public isEdited!: boolean;
    public reactions!: Record<string, string[]>;
    public readonly createdAt!: Date;
    public readonly updatedAt!: Date;
}

DailyReportComment.init(
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
        userId: {
            type: DataTypes.UUID,
            allowNull: false,
            references: { model: 'Users', key: 'id' },
            onDelete: 'CASCADE',
        },
        content: {
            type: DataTypes.TEXT,
            allowNull: false,
        },
        mentions: {
            type: DataTypes.ARRAY(DataTypes.UUID),
            defaultValue: [],
        },
        messageType: {
            type: DataTypes.ENUM('comment', 'question', 'announcement', 'action_item'),
            defaultValue: 'comment',
        },
        parentId: {
            type: DataTypes.UUID,
            allowNull: true,
            references: { model: 'DailyReportComments', key: 'id' },
            onDelete: 'CASCADE',
        },
        isPinned: {
            type: DataTypes.BOOLEAN,
            defaultValue: false,
        },
        isEdited: {
            type: DataTypes.BOOLEAN,
            defaultValue: false,
        },
        reactions: {
            type: DataTypes.JSONB,
            defaultValue: {},
        },
    },
    {
        sequelize,
        tableName: 'DailyReportComments',
        timestamps: true,
        indexes: [
            { fields: ['reportId'] },
            { fields: ['userId'] },
            { fields: ['parentId'] },
            { fields: ['isPinned'] },
        ],
    }
);

export default DailyReportComment;

