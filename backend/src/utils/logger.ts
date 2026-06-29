import winston from 'winston';
import { env } from '../config/env';

const logFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  winston.format.errors({ stack: true }),
  env.isProduction
    ? winston.format.json()
    : winston.format.printf(({ timestamp, level, message, stack, ...meta }) => {
        const metaStr = Object.keys(meta).length ? ` ${JSON.stringify(meta)}` : '';
        return `${timestamp} [${level.toUpperCase()}]: ${message}${metaStr}${stack ? '\n' + stack : ''}`;
      }),
);

export const logger = winston.createLogger({
  level: env.LOG_LEVEL,
  format: logFormat,
  transports: [
    new winston.transports.Console({
      stderrLevels: ['error'],
    }),
  ],
});

export function createContextLogger(context: string) {
  return {
    info: (message: string, meta?: Record<string, unknown>) => logger.info(`[${context}] ${message}`, meta),
    warn: (message: string, meta?: Record<string, unknown>) => logger.warn(`[${context}] ${message}`, meta),
    error: (message: string, meta?: Record<string, unknown>) => logger.error(`[${context}] ${message}`, meta),
    debug: (message: string, meta?: Record<string, unknown>) => logger.debug(`[${context}] ${message}`, meta),
  };
}
