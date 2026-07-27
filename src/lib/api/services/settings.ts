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

export interface LinkedAccount {
  id: string;
  institution: string;
  account_type: string;
  last_synced: string;
  status: string;
}

export interface LoginEvent {
  id: string;
  timestamp: string;
  ip_address: string;
  device: string;
  location: string;
  success: boolean;
}

export interface AuditEntry {
  id: string;
  action: string;
  category: string;
  timestamp: string;
  details: string;
}

export async function getLinkedAccounts(): Promise<LinkedAccount[]> {
  return apiClient.get<LinkedAccount[]>(ENDPOINTS.settings.linkedAccounts);
}

export async function getLoginActivity(): Promise<LoginEvent[]> {
  return apiClient.get<LoginEvent[]>(ENDPOINTS.settings.loginActivity);
}

export async function getAuditLog(): Promise<AuditEntry[]> {
  return apiClient.get<AuditEntry[]>(ENDPOINTS.settings.auditLog);
}
