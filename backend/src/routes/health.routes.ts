import { Router, Request, Response } from 'express';
import { asyncWrap } from '../middleware/async-wrap';
import { sendSuccess } from '../utils/helpers';
import { getSupabase } from '../config/supabase';

const router = Router();

router.get('/', asyncWrap(async (_req: Request, res: Response) => {
  const start = Date.now();
  let dbStatus = 'ok';

  try {
    const supabase = getSupabase();
    const { error } = await supabase.from('profiles').select('id').limit(1);
    if (error) dbStatus = 'error';
  } catch {
    dbStatus = 'error';
  }

  sendSuccess(res, {
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    database: dbStatus,
    response_time_ms: Date.now() - start,
  });
}));

export default router;
