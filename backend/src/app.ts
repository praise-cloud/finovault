import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { env } from './config/env';
import { errorHandler } from './middleware/error-handler';
import { standardRateLimit } from './middleware/rate-limit';
import routes from './routes';
import { logger } from './utils/logger';
import { API_PREFIX } from './utils/constants';

const app = express();

app.use(helmet());
app.use(cors({
  origin: env.isProduction ? env.corsOrigins : true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  optionsSuccessStatus: 204,
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

app.use(standardRateLimit);

app.use(API_PREFIX, routes);

app.use(errorHandler);

process.on('unhandledRejection', (reason: Error) => {
  logger.error('Unhandled Rejection', { message: reason.message, stack: reason.stack });
});

process.on('uncaughtException', (error: Error) => {
  logger.error('Uncaught Exception', { message: error.message, stack: error.stack });
  process.exit(1);
});

export default app;
