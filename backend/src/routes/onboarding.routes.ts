import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { financialInterviewSchema } from '../models/ai.schema';
import * as onboardingController from '../controllers/onboarding.controller';
import { asyncWrap } from '../middleware/async-wrap';

const router = Router();

router.use(authenticate);

router.post('/financial-interview', validate({ body: financialInterviewSchema }), asyncWrap(onboardingController.submitInterview));
router.get('/financial-profile', asyncWrap(onboardingController.getFinancialProfile));
router.put('/financial-profile', validate({ body: financialInterviewSchema }), asyncWrap(onboardingController.updateFinancialProfile));

export default router;
