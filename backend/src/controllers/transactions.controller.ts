import { Request, Response } from 'express';
import { sendSuccess, parsePagination } from '../utils/helpers';
import * as transactionService from '../services/transaction.service';

export async function listTransactions(req: Request, res: Response): Promise<void> {
  const { page, limit, offset } = parsePagination(req.query as any);
  const result = await transactionService.listTransactions(req.user!.id, { page, limit, offset, ...req.query as any });
  sendSuccess(res, result);
}

export async function getTransaction(req: Request, res: Response): Promise<void> {
  const result = await transactionService.getTransaction(req.user!.id, req.params.id as string);
  sendSuccess(res, result);
}

export async function createTransaction(req: Request, res: Response): Promise<void> {
  const result = await transactionService.createTransaction(req.user!.id, req.body);
  sendSuccess(res, result, 201);
}

export async function updateTransaction(req: Request, res: Response): Promise<void> {
  const result = await transactionService.updateTransaction(req.user!.id, req.params.id as string, req.body);
  sendSuccess(res, result);
}

export async function deleteTransaction(req: Request, res: Response): Promise<void> {
  await transactionService.deleteTransaction(req.user!.id, req.params.id as string);
  sendSuccess(res, { message: 'Transaction deleted' });
}
