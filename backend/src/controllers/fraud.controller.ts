import { Request, Response } from 'express';
import { sendSuccess } from '../utils/helpers';
import * as fraudService from '../services/fraud.service';

export async function checkTransaction(req: Request, res: Response): Promise<void> {
  const result = await fraudService.checkTransaction(req.user!.id, req.body);
  sendSuccess(res, result);
}

export async function listEvents(req: Request, res: Response): Promise<void> {
  const result = await fraudService.listEvents(req.user!.id);
  sendSuccess(res, result);
}

export async function reportEvent(req: Request, res: Response): Promise<void> {
  const result = await fraudService.reportEvent(req.user!.id, req.body);
  sendSuccess(res, result, 201);
}

export async function resolveEvent(req: Request, res: Response): Promise<void> {
  const result = await fraudService.resolveEvent(req.user!.id, req.params.id as string);
  sendSuccess(res, result);
}
