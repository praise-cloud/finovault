import { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/errors';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('ErrorHandler');

export function errorHandler(err: Error, _req: Request, res: Response, _next: NextFunction): void {
  if (err instanceof AppError) {
    res.status(err.statusCode).json({
      success: false,
      error: { code: err.code, message: err.message },
      meta: { timestamp: new Date().toISOString(), version: '1.0.0' },
    });
    return;
  }
  log.error(`Unhandled error: ${err.message}`, { stack: err.stack });
  res.status(500).json({
    success: false,
    error: { code: 'INTERNAL_ERROR', message: 'An unexpected error occurred' },
    meta: { timestamp: new Date().toISOString(), version: '1.0.0' },
  });
}
