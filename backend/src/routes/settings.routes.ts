import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import * as settingsController from '../controllers/settings.controller';
import { asyncWrap } from '../middleware/async-wrap';

const router = Router();

router.get('/security', authenticate, asyncWrap(settingsController.getSecuritySettings));
router.put('/security', authenticate, asyncWrap(settingsController.updateSecuritySettings));
router.put('/security/two-factor', authenticate, asyncWrap(settingsController.updateTwoFactor));
router.put('/security/guardrails', authenticate, asyncWrap(settingsController.updateGuardrails));
router.put('/data-privacy', authenticate, asyncWrap(settingsController.updatePrivacyToggles));
router.get('/data-privacy', authenticate, asyncWrap(settingsController.getDataPrivacy));
router.get('/linked-accounts', authenticate, asyncWrap(settingsController.getLinkedAccounts));
router.get('/login-activity', authenticate, asyncWrap(settingsController.getLoginActivity));
router.get('/audit-log', authenticate, asyncWrap(settingsController.getAuditLog));

export default router;
