import { v4 as uuidv4 } from 'uuid';
import { Response } from 'express';
import { ApiResponse } from '../types';

export function generateId(): string {
  return uuidv4();
}

export function sendSuccess<T>(res: Response, data: T, statusCode = 200): void {
  const response: ApiResponse<T> = {
    success: true,
    data,
    meta: {
      timestamp: new Date().toISOString(),
      version: '1.0.0',
    },
  };
  res.status(statusCode).json(response);
}

export function sendError(res: Response, statusCode: number, code: string, message: string): void {
  const response: ApiResponse<null> = {
    success: false,
    error: { code, message },
    meta: {
      timestamp: new Date().toISOString(),
      version: '1.0.0',
    },
  };
  res.status(statusCode).json(response);
}

export function parsePagination(query: { page?: string; limit?: string }): { page: number; limit: number; offset: number } {
  const page = Math.max(1, parseInt(query.page || '1', 10) || 1);
  const limit = Math.min(100, Math.max(1, parseInt(query.limit || '20', 10) || 20));
  const offset = (page - 1) * limit;
  return { page, limit, offset };
}

export function calculatePercentageChange(current: number, previous: number): number {
  if (previous === 0) return current > 0 ? 100 : 0;
  return ((current - previous) / previous) * 100;
}

export function sanitizePhone(phone: string): string {
  return phone.replace(/[^\d+]/g, '');
}

export function maskString(value: string, visibleChars = 4): string {
  if (value.length <= visibleChars) return value;
  return '•••• ' + value.slice(-visibleChars);
}
