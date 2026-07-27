import { AppError, NotFoundError, UnauthorizedError, ForbiddenError, ValidationError, ConflictError, RateLimitError, InternalError } from '../../src/utils/errors';

describe('AppError', () => {
  it('creates a basic error with status code and code', () => {
    const err = new AppError('test message', 400, 'TEST_CODE');
    expect(err.message).toBe('test message');
    expect(err.statusCode).toBe(400);
    expect(err.code).toBe('TEST_CODE');
    expect(err.isOperational).toBe(true);
  });

  it('is instance of Error and AppError', () => {
    const err = new AppError('test', 500, 'ERR');
    expect(err).toBeInstanceOf(Error);
    expect(err).toBeInstanceOf(AppError);
  });
});

describe('NotFoundError', () => {
  it('creates with correct status and message', () => {
    const err = new NotFoundError('User');
    expect(err.message).toBe('User not found');
    expect(err.statusCode).toBe(404);
    expect(err.code).toBe('NOT_FOUND');
  });
});

describe('UnauthorizedError', () => {
  it('creates with default message', () => {
    const err = new UnauthorizedError();
    expect(err.message).toBe('Unauthorized');
    expect(err.statusCode).toBe(401);
    expect(err.code).toBe('UNAUTHORIZED');
  });

  it('creates with custom message', () => {
    const err = new UnauthorizedError('Invalid token');
    expect(err.message).toBe('Invalid token');
  });
});

describe('ForbiddenError', () => {
  it('creates with correct status and code', () => {
    const err = new ForbiddenError();
    expect(err.statusCode).toBe(403);
    expect(err.code).toBe('FORBIDDEN');
  });
});

describe('ValidationError', () => {
  it('creates with correct status and code', () => {
    const err = new ValidationError('Invalid email');
    expect(err.message).toBe('Invalid email');
    expect(err.statusCode).toBe(400);
    expect(err.code).toBe('VALIDATION_ERROR');
  });
});

describe('ConflictError', () => {
  it('creates with correct status and code', () => {
    const err = new ConflictError('Email already exists');
    expect(err.statusCode).toBe(409);
    expect(err.code).toBe('CONFLICT');
  });
});

describe('RateLimitError', () => {
  it('creates with default message and 429', () => {
    const err = new RateLimitError();
    expect(err.statusCode).toBe(429);
    expect(err.code).toBe('RATE_LIMIT');
    expect(err.message).toContain('Too many requests');
  });
});

describe('InternalError', () => {
  it('creates with default message and 500', () => {
    const err = new InternalError();
    expect(err.message).toBe('Internal server error');
    expect(err.statusCode).toBe(500);
    expect(err.code).toBe('INTERNAL_ERROR');
  });
});
