import { Request, Response, NextFunction } from 'express';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('ErrorHandler');

export interface ApiError {
  status: number;
  message: string;
  details?: unknown;
}

export class AppError extends Error {
  public status: number;
  public details?: unknown;

  constructor(status: number, message: string, details?: unknown) {
    super(message);
    this.status = status;
    this.details = details;
    this.name = 'AppError';
  }
}

export function errorHandler(err: Error, _req: Request, res: Response, _next: NextFunction): void {
  if (err instanceof AppError) {
    res.status(err.status).json({ error: { status: err.status, message: err.message, details: err.details } });
    return;
  }
  log.error(`Unhandled error: ${err.message}`, { stack: err.stack });
  res.status(500).json({ error: { status: 500, message: 'Internal Server Error' } });
}
