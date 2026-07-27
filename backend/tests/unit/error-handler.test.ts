import { Request, Response, NextFunction } from 'express';
import { errorHandler } from '../../src/middleware/error-handler';
import { AppError, NotFoundError, InternalError } from '../../src/utils/errors';

function mockRes(): Response {
  const res: Partial<Response> = {};
  res.status = jest.fn().mockReturnValue(res);
  res.json = jest.fn().mockReturnValue(res);
  return res as Response;
}

describe('errorHandler', () => {
  it('handles AppError with correct status and JSON shape', () => {
    const req = {} as Request;
    const res = mockRes();
    const next = {} as NextFunction;
    const err = new NotFoundError('User');

    errorHandler(err, req, res, next);

    expect(res.status).toHaveBeenCalledWith(404);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: false,
        error: { code: 'NOT_FOUND', message: 'User not found' },
        meta: expect.objectContaining({ version: '1.0.0' }),
      }),
    );
  });

  it('handles non-AppError as 500', () => {
    const req = {} as Request;
    const res = mockRes();
    const next = {} as NextFunction;
    const err = new Error('unexpected crash');

    errorHandler(err, req, res, next);

    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: false,
        error: { code: 'INTERNAL_ERROR', message: 'An unexpected error occurred' },
      }),
    );
  });

  it('handles InternalError correctly', () => {
    const req = {} as Request;
    const res = mockRes();
    const next = {} as NextFunction;
    const err = new InternalError('custom internal message');

    errorHandler(err, req, res, next);

    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        error: { code: 'INTERNAL_ERROR', message: 'custom internal message' },
      }),
    );
  });
});
