import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { businessAdviceSchema, createVendorSchema, updateVendorSchema } from '../models/business.schema';
import { idParamSchema } from '../models/common.schema';
import * as businessController from '../controllers/business.controller';
import { asyncWrap } from '../middleware/async-wrap';

const router = Router();

router.use(authenticate);

router.get('/health', asyncWrap(businessController.getHealth));
router.get('/forecast', asyncWrap(businessController.getForecast));
router.get('/vendors', asyncWrap(businessController.listVendors));
router.post('/vendors', validate({ body: createVendorSchema }), asyncWrap(businessController.addVendor));
router.put('/vendors/:id', validate({ params: idParamSchema, body: updateVendorSchema }), asyncWrap(businessController.updateVendor));
router.delete('/vendors/:id', validate({ params: idParamSchema }), asyncWrap(businessController.deleteVendor));
router.get('/ai-advice', asyncWrap(businessController.getExistingAiAdvice));
router.post('/ai-advice', validate({ body: businessAdviceSchema }), asyncWrap(businessController.getAiAdvice));

export default router;
