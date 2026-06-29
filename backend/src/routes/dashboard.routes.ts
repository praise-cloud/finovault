import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import * as dashboardController from '../controllers/dashboard.controller';
import { asyncWrap } from '../middleware/async-wrap';

const router = Router();

router.use(authenticate);

router.get('/summary', asyncWrap(dashboardController.getSummary));
router.get('/wealth-growth', asyncWrap(dashboardController.getWealthGrowth));
router.get('/smart-savings', asyncWrap(dashboardController.getSmartSavings));
router.get('/fraud-protection', asyncWrap(dashboardController.getFraudProtection));
router.get('/sme', asyncWrap(dashboardController.getSmeDashboard));
router.get('/sme-analytics', asyncWrap(dashboardController.getSmeAnalytics));
router.get('/freelancer', asyncWrap(dashboardController.getFreelancer));
router.get('/entrepreneur', asyncWrap(dashboardController.getEntrepreneur));
router.get('/profile-data', asyncWrap(dashboardController.getProfileData));

export default router;
