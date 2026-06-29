import { Request, Response } from 'express';
import { sendSuccess } from '../utils/helpers';
import * as onboardingService from '../services/onboarding.service';

export async function submitInterview(req: Request, res: Response): Promise<void> {
  const result = await onboardingService.submitInterview(req.user!.id, req.body);
  sendSuccess(res, result, 201);
}

export async function getFinancialProfile(req: Request, res: Response): Promise<void> {
  const result = await onboardingService.getFinancialProfile(req.user!.id);
  sendSuccess(res, result);
}

export async function updateFinancialProfile(req: Request, res: Response): Promise<void> {
  const result = await onboardingService.updateFinancialProfile(req.user!.id, req.body);
  sendSuccess(res, result);
}
