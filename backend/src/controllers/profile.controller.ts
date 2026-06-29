import { Request, Response } from 'express';
import { sendSuccess } from '../utils/helpers';
import * as profileService from '../services/profile.service';

export async function getProfile(req: Request, res: Response): Promise<void> {
  const result = await profileService.getProfile(req.user!.id);
  sendSuccess(res, result);
}

export async function updateProfile(req: Request, res: Response): Promise<void> {
  const result = await profileService.updateProfile(req.user!.id, req.body);
  sendSuccess(res, result);
}

export async function getPreferences(req: Request, res: Response): Promise<void> {
  const result = await profileService.getPreferences(req.user!.id);
  sendSuccess(res, result);
}

export async function updatePreferences(req: Request, res: Response): Promise<void> {
  const result = await profileService.updatePreferences(req.user!.id, req.body);
  sendSuccess(res, result);
}

export async function linkAccount(req: Request, res: Response): Promise<void> {
  const result = await profileService.linkAccount(req.user!.id, req.body);
  sendSuccess(res, result, 201);
}

export async function getLinkedAccounts(req: Request, res: Response): Promise<void> {
  const result = await profileService.getLinkedAccounts(req.user!.id);
  sendSuccess(res, result);
}
