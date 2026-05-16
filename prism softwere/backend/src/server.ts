import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import cookieParser from 'cookie-parser';
import dotenv from 'dotenv';
import { Server } from 'socket.io';
import http from 'http';
import path from 'path';
import os from 'os';

// Import configuration
import sequelize, { testConnection } from './config/database';
import { appConfig } from './config/app';
import { setupSwagger } from './config/swagger';

// Import middleware
import { AppError, errorHandler, notFoundHandler } from './middleware/errorHandler';
import { apiLimiter } from './middleware/rateLimiter';

// Import routes
import routes from './routes';

// Import models to initialize relationships
import './models';

// Import logger
import logger from './utils/logger';

// Load environment variables
dotenv.config();

// Create Express app
const app: Application = express();
const server = http.createServer(app);

const getLocalDevOrigins = (): string[] => {
    const localOrigins = ['http://localhost:3000', 'http://127.0.0.1:3000'];
    const networkInterfaces = os.networkInterfaces();

    for (const iface of Object.values(networkInterfaces)) {
        for (const address of iface || []) {
            if (address.family === 'IPv4' && !address.internal) {
                localOrigins.push(`http://${address.address}:3000`);
            }
        }
    }

    return localOrigins;
};

const configuredCorsOrigins = (Array.isArray(appConfig.corsOrigin) ? appConfig.corsOrigin : [appConfig.corsOrigin])
    .map(origin => origin.trim())
    .filter(Boolean);
const allowedCorsOrigins = new Set(configuredCorsOrigins);
if (appConfig.env === 'development') {
    for (const origin of getLocalDevOrigins()) {
        allowedCorsOrigins.add(origin);
    }
}
const isAllowedCorsOrigin = (origin: string): boolean => (
    allowedCorsOrigins.has(origin) ||
    origin.endsWith('.vercel.app') ||
    origin.endsWith('.up.railway.app')
);
// Initialize Socket.io
const io = new Server(server, {
    cors: {
        origin: (origin, callback) => {
            if (!origin || isAllowedCorsOrigin(origin)) {
                callback(null, true);
                return;
            }
            callback(new Error('Not allowed by CORS'));
        },
        methods: ['GET', 'POST'],
        credentials: true
    },
});

// Manual CORS handler removed in favor of cors middleware


// CORS Test Endpoint
app.get('/cors-test', (req, res) => {
    res.json({
        message: 'CORS Test Endpoint',
        origin: req.headers.origin,
        allowed: appConfig.corsOrigin,
        method: req.method
    });
});

// Middleware
app.set('trust proxy', 1); // Trust first proxy (Render/Nginx)
app.use(helmet()); // Security headers

// Detailed CORS logging
app.use((req, _res, next) => {
    const origin = req.headers.origin;
    console.log(`[CORS Request] Method: ${req.method}, Path: ${req.path}, Origin: ${origin}`);
    next();
});

// CORS Configuration
app.use(cors({
    origin: (origin, callback) => {
        // Allow requests with no origin (like mobile apps or curl)
        if (!origin) {
            return callback(null, true);
        }

        // Check if origin is in allowed list or matches dynamic patterns
        const isAllowed = isAllowedCorsOrigin(origin);

        if (isAllowed) {
            callback(null, true);
        } else {
            const allowedOrigins = Array.from(allowedCorsOrigins.values());
            console.log(`[CORS Blocked] Origin: ${origin} not in allowed list:`, allowedOrigins);
            callback(new AppError('Not allowed by CORS', 403));
        }
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept', 'Origin']
}));

app.use(express.json({ limit: '50mb' })); // Parse JSON bodies
app.use(express.urlencoded({ extended: true, limit: '50mb' })); // Parse URL-encoded bodies
app.use(cookieParser()); // Parse cookies
app.use(morgan('combined')); // HTTP request logging

// Serve static files (uploads)
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Apply rate limiting to all routes
app.use(apiLimiter);

// Setup Swagger documentation
setupSwagger(app);

// Health check endpoint
app.get('/health', (_req, res) => {
    console.log(`[Health Check] Request received on port ${appConfig.port}`);
    res.json({
        success: true,
        message: 'Server is running',
        timestamp: new Date().toISOString(),
    });
});

// API routes
app.use(`/api/${appConfig.apiVersion}`, routes);

// Socket.io connection handling
io.on('connection', (socket) => {
    logger.info(`Socket connected: ${socket.id}`);

    // Join room for user-specific notifications
    socket.on('join', (userId: string) => {
        socket.join(`user:${userId}`);
        logger.info(`User ${userId} joined their room`);
    });

    // Join room for project-specific updates
    socket.on('joinProject', (projectId: string) => {
        socket.join(`project:${projectId}`);
        logger.info(`Socket ${socket.id} joined project ${projectId}`);
    });

    // Leave project room
    socket.on('leaveProject', (projectId: string) => {
        socket.leave(`project:${projectId}`);
        logger.info(`Socket ${socket.id} left project ${projectId}`);
    });

    socket.on('disconnect', () => {
        logger.info(`Socket disconnected: ${socket.id}`);
    });
});

// Make io accessible to routes
app.set('io', io);

// 404 handler
app.use(notFoundHandler);

// Error handler (must be last)
app.use(errorHandler);

// Database connection and server start
const startServer = async (): Promise<void> => {
    try {
        console.log('Starting server initialization...');
        // Test database connection
        await testConnection();
        console.log('Database connection test passed.');

        // Sync database schema (add new columns etc.)
        // Use targeted migration to avoid enum cast issues with sync({ alter: true })
        try {
            await sequelize.query(`
                DO $$
                BEGIN
                    -- Add messageType enum and column
                    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enum_DailyReportComments_messageType') THEN
                        CREATE TYPE "enum_DailyReportComments_messageType" AS ENUM ('comment', 'question', 'announcement', 'action_item');
                    END IF;
                    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'DailyReportComments' AND column_name = 'messageType') THEN
                        ALTER TABLE "DailyReportComments" ADD COLUMN "messageType" "enum_DailyReportComments_messageType" DEFAULT 'comment';
                    END IF;
                    -- Add parentId column
                    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'DailyReportComments' AND column_name = 'parentId') THEN
                        ALTER TABLE "DailyReportComments" ADD COLUMN "parentId" UUID REFERENCES "DailyReportComments"("id") ON DELETE CASCADE;
                    END IF;
                    -- Add isPinned column
                    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'DailyReportComments' AND column_name = 'isPinned') THEN
                        ALTER TABLE "DailyReportComments" ADD COLUMN "isPinned" BOOLEAN DEFAULT false;
                    END IF;
                    -- Add isEdited column
                    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'DailyReportComments' AND column_name = 'isEdited') THEN
                        ALTER TABLE "DailyReportComments" ADD COLUMN "isEdited" BOOLEAN DEFAULT false;
                    END IF;
                    -- Add reactions column
                    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'DailyReportComments' AND column_name = 'reactions') THEN
                        ALTER TABLE "DailyReportComments" ADD COLUMN "reactions" JSONB DEFAULT '{}';
                    END IF;
                END $$;
            `);
            console.log('Database schema migration applied.');
        } catch (migrationErr: any) {
            console.warn('Schema migration warning (may be already applied):', migrationErr.message);
        }

        // Server error handling
        server.on('error', (error: any) => {
            console.error('\n================ FATAL PORT ERROR ================');
            if (error.code === 'EADDRINUSE') {
                console.error(`Port ${appConfig.port} is already in use by another process.`);
                console.error('Please kill any process using this port (e.g. `killall node`).');
            } else {
                console.error('Server error:', error);
            }
            console.error('==================================================\n');
            process.exit(1);
        });

        // Start server
        console.log(`Attempting to bind server to port ${appConfig.port}...`);
        try {
            server.listen(appConfig.port, '0.0.0.0', () => {
                console.log('Server callback triggered.');
                logger.info(`🚀 Server running on port ${appConfig.port}`);
                logger.info(`📝 Environment: ${appConfig.env}`);
                logger.info(`🔗 API: http://0.0.0.0:${appConfig.port}/api/${appConfig.apiVersion}`);
            });
        } catch (e: any) {
            console.error('SERVER LISTEN INSTANT CRASH:', e);
            process.exit(1);
        }
        console.log('Server listen called successfully.');
    } catch (error: any) {
        console.error('CRITICAL: Failed to start server:', error.message);
        logger.error('Failed to start server:', {
            message: error.message,
            stack: error.stack,
            error
        });
        process.exit(1);
    }
};

const registerProcessHandlers = (): void => {
    // Handle unhandled promise rejections
    process.on('unhandledRejection', (reason: Error) => {
        logger.error('Unhandled Rejection:', reason);
        process.exit(1);
    });

    // Handle uncaught exceptions
    process.on('uncaughtException', (error: Error) => {
        logger.error('Uncaught Exception:', error);
        process.exit(1);
    });

    // Graceful shutdown
    process.on('SIGTERM', () => {
        logger.info('SIGTERM received, closing server gracefully');
        server.close(() => {
            logger.info('Server closed');
            sequelize.close();
            process.exit(0);
        });
    });
};

if (require.main === module) {
    registerProcessHandlers();
    void startServer();
}

export { io, server, startServer };
export default app;
