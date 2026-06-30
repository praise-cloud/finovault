import { Router } from 'express';
import { validate } from '../middleware/validate';
import { authRateLimit } from '../middleware/rate-limit';
import { signupSchema, loginSchema } from '../models/user.schema';
import * as authController from '../controllers/auth.controller';
import { asyncWrap } from '../middleware/async-wrap';

const router = Router();

router.post('/signup', authRateLimit, validate({ body: signupSchema }), asyncWrap(authController.signup));
router.post('/login', authRateLimit, validate({ body: loginSchema }), asyncWrap(authController.login));
router.post('/google', authRateLimit, asyncWrap(authController.googleAuth));
router.post('/verify', authRateLimit, asyncWrap(authController.verifySession));
router.post('/refresh', authRateLimit, asyncWrap(authController.refreshSession));
router.post('/logout', asyncWrap(authController.logout));

export default router;
