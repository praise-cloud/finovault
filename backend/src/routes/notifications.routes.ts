import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { idParamSchema } from '../models/common.schema';
import * as notificationsController from '../controllers/notifications.controller';
import { asyncWrap } from '../middleware/async-wrap';

const router = Router();
router.use(authenticate);

router.get('/', asyncWrap(notificationsController.listNotifications));
router.get('/unread-count', asyncWrap(notificationsController.getUnreadCount));
router.put('/read-all', asyncWrap(notificationsController.markAllRead));
router.put('/:id/read', validate({ params: idParamSchema }), asyncWrap(notificationsController.markRead));

export default router;
