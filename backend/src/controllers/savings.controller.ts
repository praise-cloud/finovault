import { Request, Response } from 'express';
import { sendSuccess } from '../utils/helpers';
import * as savingsService from '../services/savings.service';

export async function listGoals(req: Request, res: Response): Promise<void> {
  const result = await savingsService.listGoals(req.user!.id);
  sendSuccess(res, result);
}

export async function createGoal(req: Request, res: Response): Promise<void> {
  const result = await savingsService.createGoal(req.user!.id, req.body);
  sendSuccess(res, result, 201);
}

export async function updateGoal(req: Request, res: Response): Promise<void> {
  const result = await savingsService.updateGoal(req.user!.id, req.params.id as string, req.body);
  sendSuccess(res, result);
}

export async function deleteGoal(req: Request, res: Response): Promise<void> {
  await savingsService.deleteGoal(req.user!.id, req.params.id as string);
  sendSuccess(res, { message: 'Goal deleted' });
}

export async function listRoundUps(req: Request, res: Response): Promise<void> {
  const result = await savingsService.listRoundUps(req.user!.id);
  sendSuccess(res, result);
}
