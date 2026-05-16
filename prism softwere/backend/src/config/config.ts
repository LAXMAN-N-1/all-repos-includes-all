import dotenv from 'dotenv';
dotenv.config();

console.log('--- DATABASE CONFIGURATION DEBUG ---');
console.log('NODE_ENV:', process.env.NODE_ENV);
console.log('DATABASE_URL present:', !!process.env.DATABASE_URL);
if (process.env.DATABASE_URL) {
    console.log('DATABASE_URL starts with:', process.env.DATABASE_URL.substring(0, 10) + '...');
}
console.log('DB_HOST:', process.env.DB_HOST);
console.log('DB_USER:', process.env.DB_USER);
console.log('DB_NAME:', process.env.DB_NAME);
console.log('DB_PORT:', process.env.DB_PORT);
console.log('------------------------------------');

const dbConfig: any = {
    dialect: 'postgres',
    logging: false,
};
const dbSslEnv = process.env.DB_SSL ?? process.env.DATABASE_SSL;
const shouldUseSsl = dbSslEnv !== undefined ? dbSslEnv.toLowerCase() === 'true' : process.env.NODE_ENV === 'production';
if (shouldUseSsl) {
    dbConfig.dialectOptions = {
        ssl: {
            require: true,
            rejectUnauthorized: false,
        },
    };
}

// Check if DATABASE_URL exists
if (process.env.DATABASE_URL) {
    console.log('Using DATABASE_URL for connection.');
    dbConfig.use_env_variable = 'DATABASE_URL';
} else {
    console.log('DATABASE_URL not found. Attempting fallback to individual variables.');
    // Fallback to individual variables
    dbConfig.username = process.env.DB_USER || process.env.PGUSER;
    dbConfig.password = process.env.DB_PASSWORD || process.env.PGPASSWORD;
    dbConfig.database = process.env.DB_NAME || process.env.PGDATABASE;
    dbConfig.host = process.env.DB_HOST || process.env.PGHOST;
    dbConfig.port = parseInt(process.env.DB_PORT || process.env.PGPORT || '5432');

    if (!dbConfig.host) {
        console.error('CRITICAL ERROR: No DB_HOST found in environment variables!');
    } else {
        console.log(`Fallback configuration using host: ${dbConfig.host}`);
    }
}

const config = {
    development: {
        username: process.env.DB_USER || process.env.PGUSER || process.env.USER || 'postgres',
        password: process.env.DB_PASSWORD || process.env.PGPASSWORD || '',
        database: process.env.DB_NAME || process.env.PGDATABASE || 'project_management',
        host: process.env.DB_HOST || process.env.PGHOST || 'localhost',
        port: parseInt(process.env.DB_PORT || process.env.PGPORT || '5432'),
        dialect: 'postgres',
        logging: false,
    },
    test: {
        username: process.env.DB_USER || process.env.PGUSER || process.env.USER || 'postgres',
        password: process.env.DB_PASSWORD || process.env.PGPASSWORD || '',
        database: process.env.DB_NAME_TEST || 'project_management_test',
        host: process.env.DB_HOST || process.env.PGHOST || 'localhost',
        port: parseInt(process.env.DB_PORT || process.env.PGPORT || '5432'),
        dialect: 'postgres',
        logging: false,
    },
    production: dbConfig,
};

module.exports = config;
