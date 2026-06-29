import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { updateProfileSchema, updatePreferencesSchema } from '../models/user.schema';
import * as profileController from '../controllers/profile.controller';
import { asyncWrap } from '../middleware/async-wrap';

const router = Router();

router.use(authenticate);

router.get('/me', asyncWrap(profileController.getProfile));
router.put('/me', validate({ body: updateProfileSchema }), asyncWrap(profileController.updateProfile));
router.get('/preferences', asyncWrap(profileController.getPreferences));
router.put('/preferences', validate({ body: updatePreferencesSchema }), asyncWrap(profileController.updatePreferences));
router.post('/link-account', asyncWrap(profileController.linkAccount));
router.get('/linked-accounts', asyncWrap(profileController.getLinkedAccounts));

export default router;
