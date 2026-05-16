import { Sequelize } from 'sequelize';
import dotenv from 'dotenv';

dotenv.config();

const isProduction = process.env.NODE_ENV === 'production';
const dbSslEnv = process.env.DB_SSL ?? process.env.DATABASE_SSL;
const shouldUseSsl = dbSslEnv !== undefined ? dbSslEnv.toLowerCase() === 'true' : isProduction;
const sslDialectOptions = shouldUseSsl
    ? {
        ssl: {
            require: true,
            rejectUnauthorized: false,
        },
    }
    : undefined;

const sequelize = process.env.DATABASE_URL
    ? new Sequelize(process.env.DATABASE_URL as string, {
        dialect: 'postgres',
        logging: isProduction ? false : console.log,
        ...(sslDialectOptions ? { dialectOptions: sslDialectOptions } : {}),
        pool: {
            max: 5,
            min: 0,
            acquire: 30000,
            idle: 10000,
        },
        define: {
            timestamps: true,
            underscored: false,
            freezeTableName: true,
        },
    })
    : new Sequelize({
        database: process.env.DB_NAME || process.env.PGDATABASE || 'project_management',
        username: process.env.DB_USER || process.env.PGUSER || process.env.USER || 'postgres',
        password: process.env.DB_PASSWORD || process.env.PGPASSWORD || '',
        host: process.env.DB_HOST || process.env.PGHOST || 'localhost',
        port: parseInt(process.env.DB_PORT || process.env.PGPORT || '5432'),
        dialect: 'postgres',
        logging: process.env.NODE_ENV === 'development' ? console.log : false,
        ...(sslDialectOptions ? { dialectOptions: sslDialectOptions } : {}),
        pool: {
            max: 5,
            min: 0,
            acquire: 30000,
            idle: 10000,
        },
        define: {
            timestamps: true,
            underscored: false,
            freezeTableName: true,
        },
    });

export default sequelize;

// Test database connection
export const testConnection = async (): Promise<void> => {
    try {
        await sequelize.authenticate();
        console.log('✅ Database connection established successfully.');
    } catch (error) {
        console.error('❌ Unable to connect to the database:', error);
        process.exit(1);
    }
};
