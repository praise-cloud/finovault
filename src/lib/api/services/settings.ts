import { apiClient } from '../client';
import { ENDPOINTS } from '../endpoints';

export async function getSecuritySettings(): Promise<any> {
  const result = await apiClient.get<any>(ENDPOINTS.settings.security);
  return result;
}

export async function updateTwoFactor(enabled: boolean, method?: string): Promise<void> {
  await apiClient.put(ENDPOINTS.settings.securityTwoFactor, { enabled, method });
}

export async function updateGuardrails(guardrails: any[]): Promise<void> {
  await apiClient.put(ENDPOINTS.settings.securityGuardrails, { guardrails });
}

export async function getDataPrivacy(): Promise<any> {
  const result = await apiClient.get<any>(ENDPOINTS.settings.dataPrivacy);
  return result;
}

export async function updatePrivacyToggles(privacy_toggles: any[]): Promise<void> {
  await apiClient.put(ENDPOINTS.settings.dataPrivacy, { privacy_toggles });
}

export async function getLinkedAccounts(): Promise<any[]> {
  const result = await apiClient.get<any[]>(ENDPOINTS.settings.linkedAccounts);
  return result;
}

export async function getLoginActivity(): Promise<any[]> {
  const result = await apiClient.get<any[]>(ENDPOINTS.settings.loginActivity);
  return result;
}

export async function getAuditLog(): Promise<any[]> {
  const result = await apiClient.get<any[]>(ENDPOINTS.settings.auditLog);
  return result;
}
