import { Router } from 'express';
import healthRoutes from './health.routes';
import authRoutes from './auth.routes';
import profileRoutes from './profile.routes';
import transactionsRoutes from './transactions.routes';
import dashboardRoutes from './dashboard.routes';
import savingsRoutes from './savings.routes';
import fraudRoutes from './fraud.routes';
import aiRoutes from './ai.routes';
import businessRoutes from './business.routes';
import onboardingRoutes from './onboarding.routes';

const router = Router();

router.use('/health', healthRoutes);
router.use('/auth', authRoutes);
router.use('/profile', profileRoutes);
router.use('/transactions', transactionsRoutes);
router.use('/dashboard', dashboardRoutes);
router.use('/savings', savingsRoutes);
router.use('/fraud', fraudRoutes);
router.use('/ai', aiRoutes);
router.use('/business', businessRoutes);
router.use('/onboarding', onboardingRoutes);

export default router;
