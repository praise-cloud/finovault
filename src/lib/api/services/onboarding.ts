import { apiClient } from '../client';
import { ENDPOINTS } from '../endpoints';

export interface FinancialProfile {
  id: string;
  user_id: string;
  role: string;
  goals: string[];
  monthly_income: number;
  monthly_expenses: number;
  risk_tolerance: string;
  completed: boolean;
}

export async function submitFinancialInterview(data: Record<string, unknown>): Promise<{ message: string }> {
  return await apiClient.post<{ message: string }>(ENDPOINTS.onboarding.financialInterview, data);
}

export async function getFinancialProfile(): Promise<FinancialProfile | null> {
  return apiClient.get<FinancialProfile | null>(ENDPOINTS.onboarding.financialProfile);
}

export async function updateFinancialProfile(data: Partial<FinancialProfile>): Promise<FinancialProfile> {
  return apiClient.put<FinancialProfile>(ENDPOINTS.onboarding.financialProfile, data);
}
