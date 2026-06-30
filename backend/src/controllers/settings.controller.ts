import { Request, Response } from 'express';
import { sendSuccess, sendError } from '../utils/helpers';
import * as settingsService from '../services/settings.service';

export async function getSecuritySettings(req: Request, res: Response): Promise<void> {
  const userId = req.user!.id;
  const result = await settingsService.getSecuritySettings(userId);
  sendSuccess(res, result);
}

export async function updateSecuritySettings(req: Request, res: Response): Promise<void> {
  const userId = req.user!.id;
  const result = await settingsService.updateSecuritySettings(userId, req.body);
  sendSuccess(res, result);
}

export async function updateTwoFactor(req: Request, res: Response): Promise<void> {
  const userId = req.user!.id;
  const result = await settingsService.updateTwoFactor(userId, req.body);
  sendSuccess(res, result);
}

export async function updateGuardrails(req: Request, res: Response): Promise<void> {
  const userId = req.user!.id;
  const result = await settingsService.updateGuardrails(userId, req.body.guardrails);
  sendSuccess(res, result);
}

export async function updatePrivacyToggles(req: Request, res: Response): Promise<void> {
  const userId = req.user!.id;
  const result = await settingsService.updatePrivacyToggles(userId, req.body.privacy_toggles);
  sendSuccess(res, result);
}

export async function getLinkedAccounts(req: Request, res: Response): Promise<void> {
  const userId = req.user!.id;
  const result = await settingsService.getLinkedAccounts(userId);
  sendSuccess(res, result);
}

export async function getLoginActivity(req: Request, res: Response): Promise<void> {
  const userId = req.user!.id;
  const result = await settingsService.getLoginActivity(userId);
  sendSuccess(res, result);
}

export async function getAuditLog(req: Request, res: Response): Promise<void> {
  const userId = req.user!.id;
  const result = await settingsService.getAuditLog(userId);
  sendSuccess(res, result);
}

export async function getDataPrivacy(req: Request, res: Response): Promise<void> {
  const userId = req.user!.id;
  const result = await settingsService.getDataPrivacy(userId);
  sendSuccess(res, result);
}
