import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { createSavingsGoalSchema, updateSavingsGoalSchema } from '../models/savings.schema';
import { idParamSchema } from '../models/common.schema';
import * as savingsController from '../controllers/savings.controller';
import { asyncWrap } from '../middleware/async-wrap';

const router = Router();

router.use(authenticate);

router.get('/goals', asyncWrap(savingsController.listGoals));
router.get('/goals/:id', validate({ params: idParamSchema }), asyncWrap(savingsController.getGoal));
router.post('/goals', validate({ body: createSavingsGoalSchema }), asyncWrap(savingsController.createGoal));
router.put('/goals/:id', validate({ params: idParamSchema, body: updateSavingsGoalSchema }), asyncWrap(savingsController.updateGoal));
router.delete('/goals/:id', validate({ params: idParamSchema }), asyncWrap(savingsController.deleteGoal));
router.get('/round-ups', asyncWrap(savingsController.listRoundUps));

export default router;
