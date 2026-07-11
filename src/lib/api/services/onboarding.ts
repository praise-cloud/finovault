import { apiClient } from '../client';
import { ENDPOINTS } from '../endpoints';

export async function submitFinancialInterview(data: Record<string, any>) {
  return apiClient.post(ENDPOINTS.onboarding.financialInterview, data);
}

export async function getFinancialProfile() {
  return apiClient.get(ENDPOINTS.onboarding.financialProfile);
}

export async function updateFinancialProfile(data: Record<string, any>) {
  return apiClient.put(ENDPOINTS.onboarding.financialProfile, data);
}
