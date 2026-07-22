import { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/errors';
import { logger } from '../utils/logger';
import { sendError } from '../utils/helpers';

export function errorHandler(err: Error, _req: Request, res: Response, _next: NextFunction): void {
  if (err instanceof AppError && err.isOperational) {
    logger.warn('Operational error', {
      code: err.code,
      message: err.message,
      statusCode: err.statusCode,
    });
    sendError(res, err.statusCode, err.code, err.message);
    return;
  }

  logger.error('Unexpected error — restart recommended', {
    message: err.message,
    stack: err.stack,
    name: err.name,
  });

  sendError(res, 500, 'INTERNAL_ERROR', 'An unexpected error occurred');
}
