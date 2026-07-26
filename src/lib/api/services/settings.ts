import { apiClient } from '../client';
import { ENDPOINTS } from '../endpoints';

export interface SecuritySettings {
  two_factor_enabled: boolean;
  two_factor_method: string;
  guardrails: any[];
  privacy_toggles: any[];
  recovery_codes: string[];
  recent_events: any[];
}

export interface DataPrivacy {
  privacy_toggles: { key: string; label: string; enabled: boolean }[];
  last_updated: string;
}

export async function getSecuritySettings(): Promise<SecuritySettings> {
  return apiClient.get<SecuritySettings>(ENDPOINTS.settings.security);
}

export async function updateTwoFactor(enabled: boolean, method?: string): Promise<void> {
  await apiClient.put(ENDPOINTS.settings.securityTwoFactor, { enabled, method });
}

export async function updateGuardrails(guardrails: any[]): Promise<void> {
  await apiClient.put(ENDPOINTS.settings.securityGuardrails, { guardrails });
}

export async function getDataPrivacy(): Promise<DataPrivacy> {
  return apiClient.get<DataPrivacy>(ENDPOINTS.settings.dataPrivacy);
}

export async function updatePrivacyToggles(privacy_toggles: { key: string; label: string; enabled: boolean }[]): Promise<void> {
  await apiClient.put(ENDPOINTS.settings.dataPrivacy, { privacy_toggles });
}

export async function getLinkedAccounts(): Promise<any[]> {
  return apiClient.get<any[]>(ENDPOINTS.settings.linkedAccounts);
}

export async function getLoginActivity(): Promise<any[]> {
  return apiClient.get<any[]>(ENDPOINTS.settings.loginActivity);
}

export async function getAuditLog(): Promise<any[]> {
  return apiClient.get<any[]>(ENDPOINTS.settings.auditLog);
}
