import { Request, Response } from 'express';
import { sendSuccess } from '../utils/helpers';
import * as authService from '../services/auth.service';

export async function signup(req: Request, res: Response): Promise<void> {
  const result = await authService.signup(req.body);
  sendSuccess(res, result, 201);
}

export async function login(req: Request, res: Response): Promise<void> {
  const result = await authService.login(req.body);
  sendSuccess(res, result);
}

export async function googleAuth(req: Request, res: Response): Promise<void> {
  const result = await authService.googleAuth(req.body);
  sendSuccess(res, result);
}

export async function verifySession(req: Request, res: Response): Promise<void> {
  const authHeader = req.headers.authorization;
  const token = authHeader?.startsWith('Bearer ') ? authHeader.split(' ')[1] : req.body.token;
  const result = await authService.verifySession(token);
  sendSuccess(res, result);
}

export async function refreshSession(req: Request, res: Response): Promise<void> {
  const { refresh_token } = req.body;
  const result = await authService.refreshSession(refresh_token);
  sendSuccess(res, result);
}

export async function logout(req: Request, res: Response): Promise<void> {
  const authHeader = req.headers.authorization;
  const token = authHeader?.startsWith('Bearer ') ? authHeader.split(' ')[1] : null;

  if (token) {
    const { user } = await authService.verifySession(token);
    if (user) {
      await authService.logout(user.id);
    }
  }

  sendSuccess(res, { message: 'Logged out successfully' });
}
