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

export async function getExistingAiAdvice(req: Request, res: Response): Promise<void> {
  const result = await businessService.getExistingAdvice(req.user!.id);
  sendSuccess(res, result);
}

export async function addVendor(req: Request, res: Response): Promise<void> {
  const result = await businessService.addVendor(req.user!.id, req.body);
  sendSuccess(res, result, 201);
}

export async function updateVendor(req: Request, res: Response): Promise<void> {
  const result = await businessService.updateVendor(req.user!.id, req.params.id as string, req.body);
  sendSuccess(res, result);
}

export async function deleteVendor(req: Request, res: Response): Promise<void> {
  await businessService.deleteVendor(req.user!.id, req.params.id as string);
  sendSuccess(res, { message: 'Vendor deleted' });
}
