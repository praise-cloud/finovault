import { apiClient } from '../client';
import { ENDPOINTS } from '../endpoints';

export interface SavingsGoal {
  id: string;
  user_id: string;
  name: string;
  target_amount: number;
  current_amount: number;
  goal_type: string;
  status: 'active' | 'completed' | 'paused';
  created_at: string;
  updated_at: string;
}

export interface RoundUpSaving {
  id: string;
  user_id: string;
  amount: number;
  date: string;
  transaction_id?: string;
  created_at: string;
}

interface CreateGoalInput {
  name: string;
  target_amount: number;
  current_amount?: number;
  goal_type?: 'rainy_day' | 'general';
}

interface UpdateGoalInput {
  name?: string;
  target_amount?: number;
  current_amount?: number;
  status?: 'active' | 'completed' | 'paused';
}

export async function listGoals(): Promise<SavingsGoal[]> {
  return apiClient.get<SavingsGoal[]>(ENDPOINTS.savings.goals);
}

export async function createGoal(input: CreateGoalInput): Promise<SavingsGoal> {
  return apiClient.post<SavingsGoal>(ENDPOINTS.savings.goals, input);
}

export async function updateGoal(id: string, input: UpdateGoalInput): Promise<SavingsGoal> {
  return apiClient.put<SavingsGoal>(ENDPOINTS.savings.goalDetail(id), input);
}

export async function deleteGoal(id: string): Promise<void> {
  return apiClient.delete(ENDPOINTS.savings.goalDetail(id));
}

export async function listRoundUps(): Promise<RoundUpSaving[]> {
  return apiClient.get<RoundUpSaving[]>(ENDPOINTS.savings.roundUps);
}
