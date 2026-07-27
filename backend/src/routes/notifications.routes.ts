import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import * as notificationsController from '../controllers/notifications.controller';
import { asyncWrap } from '../middleware/async-wrap';

const router = Router();
router.use(authenticate);

router.get('/', asyncWrap(notificationsController.listNotifications));
router.get('/unread-count', asyncWrap(notificationsController.getUnreadCount));
router.put('/:id/read', asyncWrap(notificationsController.markRead));
router.put('/read-all', asyncWrap(notificationsController.markAllRead));

export default router;
