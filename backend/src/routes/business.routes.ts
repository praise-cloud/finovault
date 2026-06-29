import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { businessAdviceSchema } from '../models/business.schema';
import * as businessController from '../controllers/business.controller';
import { asyncWrap } from '../middleware/async-wrap';

const router = Router();

router.use(authenticate);

router.get('/health', asyncWrap(businessController.getHealth));
router.get('/forecast', asyncWrap(businessController.getForecast));
router.get('/vendors', asyncWrap(businessController.listVendors));
router.post('/ai-advice', validate({ body: businessAdviceSchema }), asyncWrap(businessController.getAiAdvice));

export default router;
