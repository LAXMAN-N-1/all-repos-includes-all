import dotenv from 'dotenv';

dotenv.config();

export const appConfig = {
    env: process.env.NODE_ENV || 'development',
    port: parseInt(process.env.PORT || '5000'),
    apiVersion: process.env.API_VERSION || 'v1',
    corsOrigin: process.env.CORS_ORIGIN
        ? (process.env.CORS_ORIGIN.includes(',')
            ? process.env.CORS_ORIGIN.split(',').map(origin => origin.trim())
            : process.env.CORS_ORIGIN.trim())
        : 'http://localhost:3000',
};

// Debug log for CORS configuration
console.log('--- CORS CONFIGURATION DEBUG ---');
console.log('Raw CORS_ORIGIN:', process.env.CORS_ORIGIN);
console.log('Parsed corsOrigin:', appConfig.corsOrigin);
console.log('Is Array?', Array.isArray(appConfig.corsOrigin));
if (Array.isArray(appConfig.corsOrigin)) {
    console.log('Origins count:', appConfig.corsOrigin.length);
    appConfig.corsOrigin.forEach((origin, index) => {
        console.log(`Origin [${index}]: "${origin}"`);
    });
}
console.log('--------------------------------');

export const securityConfig = {
    bcryptRounds: parseInt(process.env.BCRYPT_ROUNDS || '10'),
    rateLimitWindowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'),
    rateLimitMaxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
};

export const uploadConfig = {
    maxFileSize: parseInt(process.env.MAX_FILE_SIZE || '10485760'), // 10MB
    uploadDir: process.env.UPLOAD_DIR || './uploads',
    allowedFileTypes: (process.env.ALLOWED_FILE_TYPES || 'image/jpeg,image/png,image/gif,application/pdf').split(','),
};

export const mfaConfig = {
    appName: process.env.MFA_APP_NAME || 'ProjectManagement',
    issuer: process.env.MFA_ISSUER || 'ProjectManagement',
};
