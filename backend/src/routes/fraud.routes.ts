import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { fraudCheckSchema, reportFraudSchema } from '../models/fraud.schema';
import { idParamSchema } from '../models/common.schema';
import * as fraudController from '../controllers/fraud.controller';
import { asyncWrap } from '../middleware/async-wrap';

const router = Router();

router.use(authenticate);

router.post('/check', validate({ body: fraudCheckSchema }), asyncWrap(fraudController.checkTransaction));
router.get('/events', asyncWrap(fraudController.listEvents));
router.post('/events', validate({ body: reportFraudSchema }), asyncWrap(fraudController.reportEvent));
router.put('/events/:id/resolve', validate({ params: idParamSchema }), asyncWrap(fraudController.resolveEvent));

export default router;
