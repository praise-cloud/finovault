import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { askCoachSchema } from '../models/ai.schema';
import { aiRateLimit } from '../middleware/rate-limit';
import { idParamSchema } from '../models/common.schema';
import * as aiController from '../controllers/ai.controller';
import { asyncWrap } from '../middleware/async-wrap';

const router = Router();

router.use(authenticate);

router.get('/insights', asyncWrap(aiController.getInsights));
router.post('/coach/ask', aiRateLimit, validate({ body: askCoachSchema }), asyncWrap(aiController.askCoach));
router.get('/coach/morning-briefing', asyncWrap(aiController.getMorningBriefing));
router.get('/suggestions', asyncWrap(aiController.getSuggestions));
router.put('/suggestions/:id', validate({ params: idParamSchema }), asyncWrap(aiController.updateSuggestion));

export default router;
