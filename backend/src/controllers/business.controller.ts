import { Request, Response } from 'express';
import { sendSuccess } from '../utils/helpers';
import * as businessService from '../services/business.service';

export async function getHealth(req: Request, res: Response): Promise<void> {
  const result = await businessService.getHealth(req.user!.id);
  sendSuccess(res, result);
}

export async function getForecast(req: Request, res: Response): Promise<void> {
  const result = await businessService.getForecast(req.user!.id);
  sendSuccess(res, result);
}

export async function listVendors(req: Request, res: Response): Promise<void> {
  const result = await businessService.listVendors(req.user!.id);
  sendSuccess(res, result);
}

export async function getAiAdvice(req: Request, res: Response): Promise<void> {
  const result = await businessService.getAiAdvice(req.user!.id, req.body.question, req.body.business_data);
  sendSuccess(res, result);
}
