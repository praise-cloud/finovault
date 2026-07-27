import { Request, Response } from 'express';
import { sendSuccess } from '../utils/helpers';
import * as notificationService from '../services/notification.service';

export async function listNotifications(req: Request, res: Response): Promise<void> {
  const limit = Math.min(100, parseInt(req.query.limit as string, 10) || 50);
  const data = await notificationService.listNotifications(req.user!.id, limit);
  sendSuccess(res, data);
}

export async function getUnreadCount(req: Request, res: Response): Promise<void> {
  const count = await notificationService.getUnreadCount(req.user!.id);
  sendSuccess(res, { count });
}

export async function markRead(req: Request, res: Response): Promise<void> {
  const data = await notificationService.markNotificationRead(req.user!.id, req.params.id as string);
  sendSuccess(res, data);
}

export async function markAllRead(req: Request, res: Response): Promise<void> {
  await notificationService.markAllNotificationsRead(req.user!.id);
  sendSuccess(res, { message: 'All notifications marked as read' });
}
