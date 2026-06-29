import { Request, Response } from 'express';
import { sendSuccess } from '../utils/helpers';
import * as aiService from '../services/ai.service';

export async function getInsights(req: Request, res: Response): Promise<void> {
  const result = await aiService.getInsights(req.user!.id);
  sendSuccess(res, result);
}

export async function askCoach(req: Request, res: Response): Promise<void> {
  const result = await aiService.askCoach(req.user!.id, req.body.question, req.body.context);
  sendSuccess(res, result);
}

export async function getMorningBriefing(req: Request, res: Response): Promise<void> {
  const result = await aiService.getMorningBriefing(req.user!.id);
  sendSuccess(res, result);
}

export async function getSuggestions(req: Request, res: Response): Promise<void> {
  const result = await aiService.getSuggestions(req.user!.id);
  sendSuccess(res, result);
}

export async function updateSuggestion(req: Request, res: Response): Promise<void> {
  const result = await aiService.updateSuggestion(req.user!.id, req.params.id as string, req.body);
  sendSuccess(res, result);
}
