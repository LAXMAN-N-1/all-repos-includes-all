import jwt, { SignOptions } from 'jsonwebtoken';
import crypto from 'crypto';
import { User } from '../models';
import { jwtConfig } from '../config/jwt';
import { JwtPayload } from '../types/interfaces';

export class AuthService {
    // Generate access token
    static generateAccessToken(userId: string, email: string, role: string, orgId: string): string {
        const payload = { userId, email, role, orgId };
        // @ts-ignore - JWT library type mismatch with expiresIn
        const options: SignOptions = { expiresIn: jwtConfig.accessExpiry };
        return jwt.sign(payload, jwtConfig.accessSecret, options);
    }

    // Generate refresh token
    static generateRefreshToken(userId: string): string {
        const payload = { userId };
        // @ts-ignore - JWT library type mismatch with expiresIn
        const options: SignOptions = { expiresIn: jwtConfig.refreshExpiry };
        return jwt.sign(payload, jwtConfig.refreshSecret, options);
    }

    // Verify refresh token
    static verifyRefreshToken(token: string): JwtPayload {
        return jwt.verify(token, jwtConfig.refreshSecret) as JwtPayload;
    }

    // Store refresh token
    static async storeRefreshToken(user: User, token: string): Promise<void> {
        user.refreshToken = token;
        await user.save();
    }

    // Revoke refresh token
    static async revokeRefreshToken(user: User): Promise<void> {
        user.refreshToken = null;
        await user.save();
    }

    static hashToken(token: string): string {
        return crypto.createHash('sha256').update(token).digest('hex');
    }

    // Generate password reset token
    static generatePasswordResetToken(userId: string): string {
        const payload = { userId, purpose: 'password-reset' };
        const options: SignOptions = { expiresIn: '1h' };
        return jwt.sign(payload, jwtConfig.accessSecret, options);
    }

    // Verify password reset token
    static verifyPasswordResetToken(token: string, expectedUserId?: string): JwtPayload {
        const decoded = jwt.verify(token, jwtConfig.accessSecret) as JwtPayload & { purpose?: string };

        if (decoded.purpose !== 'password-reset') {
            throw new Error('Invalid password reset token');
        }

        if (expectedUserId && decoded.userId !== expectedUserId) {
            throw new Error('Token does not match user');
        }

        return decoded;
    }

    // Generate MFA token
    static generateMFAToken(userId: string): string {
        const payload = { userId, mfa: true, purpose: 'mfa-auth' };
        const options: SignOptions = { expiresIn: '5m' };
        return jwt.sign(payload, jwtConfig.accessSecret, options);
    }

    // Verify MFA token
    static verifyMFAToken(token: string, expectedUserId: string): JwtPayload {
        const decoded = jwt.verify(token, jwtConfig.accessSecret) as JwtPayload & { mfa?: boolean; purpose?: string };

        if (!decoded.mfa || decoded.purpose !== 'mfa-auth' || decoded.userId !== expectedUserId) {
            throw new Error('Invalid MFA token');
        }

        return decoded;
    }
}
