import dotenv from 'dotenv';
import { Secret } from 'jsonwebtoken';

dotenv.config();

if (process.env.NODE_ENV === 'production') {
    if (!process.env.JWT_ACCESS_SECRET) {
        throw new Error('FATAL: JWT_ACCESS_SECRET is not defined in production environment.');
    }
    if (!process.env.JWT_REFRESH_SECRET) {
        throw new Error('FATAL: JWT_REFRESH_SECRET is not defined in production environment.');
    }
}

export const jwtConfig = {
    accessSecret: (process.env.JWT_ACCESS_SECRET || 'default_access_secret_change_me') as Secret,
    refreshSecret: (process.env.JWT_REFRESH_SECRET || 'default_refresh_secret_change_me') as Secret,
    accessExpiry: process.env.JWT_ACCESS_EXPIRY || '7d',
    refreshExpiry: process.env.JWT_REFRESH_EXPIRY || '30d',
};

export const sessionConfig = {
    secret: process.env.SESSION_SECRET || 'default_session_secret',
    resave: false,
    saveUninitialized: false,
    cookie: {
        secure: process.env.NODE_ENV === 'production',
        httpOnly: true,
        maxAge: 24 * 60 * 60 * 1000, // 24 hours
    },
};
