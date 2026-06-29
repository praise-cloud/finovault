import { Request, Response } from 'express';
import { sendSuccess } from '../utils/helpers';
import * as dashboardService from '../services/dashboard.service';

export async function getSummary(req: Request, res: Response): Promise<void> {
  const result = await dashboardService.getSummary(req.user!.id);
  sendSuccess(res, result);
}

export async function getWealthGrowth(req: Request, res: Response): Promise<void> {
  const result = await dashboardService.getWealthGrowth(req.user!.id);
  sendSuccess(res, result);
}

export async function getSmartSavings(req: Request, res: Response): Promise<void> {
  const result = await dashboardService.getSmartSavings(req.user!.id);
  sendSuccess(res, result);
}

export async function getFraudProtection(req: Request, res: Response): Promise<void> {
  const result = await dashboardService.getFraudProtection(req.user!.id);
  sendSuccess(res, result);
}

export async function getSmeDashboard(req: Request, res: Response): Promise<void> {
  const result = await dashboardService.getSmeDashboard(req.user!.id);
  sendSuccess(res, result);
}

export async function getSmeAnalytics(req: Request, res: Response): Promise<void> {
  const result = await dashboardService.getSmeAnalytics(req.user!.id);
  sendSuccess(res, result);
}

export async function getFreelancer(req: Request, res: Response): Promise<void> {
  const result = await dashboardService.getFreelancer(req.user!.id);
  sendSuccess(res, result);
}

export async function getEntrepreneur(req: Request, res: Response): Promise<void> {
  const result = await dashboardService.getEntrepreneur(req.user!.id);
  sendSuccess(res, result);
}

export async function getProfileData(req: Request, res: Response): Promise<void> {
  const result = await dashboardService.getProfileData(req.user!.id);
  sendSuccess(res, result);
}
