import { Request, Response, NextFunction } from 'express';
import { getSupabase } from '../config/supabase';
import { UnauthorizedError } from '../utils/errors';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('AuthMiddleware');

export async function authenticate(req: Request, _res: Response, next: NextFunction): Promise<void> {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedError('Missing or invalid authorization header');
    }

    const token = authHeader.split(' ')[1];
    if (!token) {
      throw new UnauthorizedError('Missing token');
    }

    const supabase = getSupabase();
    const { data: { user }, error } = await supabase.auth.getUser(token);

    if (error || !user) {
      log.warn('Token verification failed', { error: error?.message });
      throw new UnauthorizedError('Invalid or expired token');
    }

    req.user = {
      id: user.id,
      email: user.email || '',
      role: user.user_metadata?.role || 'individual',
    };

    next();
  } catch (error) {
    next(error);
  }
}

export function optionalAuth(req: Request, _res: Response, next: NextFunction): void {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    next();
    return;
  }

  authenticate(req, _res, next);
}
