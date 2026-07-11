import { apiClient } from '../client';
import { ENDPOINTS } from '../endpoints';

interface ProfileResponse {
  profile: any;
  preferences: any | null;
  linked_accounts: any[];
  security: any | null;
}

export async function getProfile(_userId?: string): Promise<ProfileResponse> {
  return apiClient.get<ProfileResponse>(ENDPOINTS.profile.me);
}

export async function updateProfile(_userId: string, updates: Record<string, any>) {
  return apiClient.put(ENDPOINTS.profile.update, updates);
}

export async function savePreferences(_userId: string, prefs: Record<string, any>) {
  return apiClient.put(ENDPOINTS.profile.preferences, prefs);
}

export async function getPreferences(_userId?: string): Promise<Record<string, any>> {
  return apiClient.get(ENDPOINTS.profile.preferences);
}

export async function getProfileLinkedAccounts(_userId?: string) {
  return apiClient.get(ENDPOINTS.profile.linkedAccounts);
}

export async function getSecurityMetrics(_userId: string) {
  const profile = await getProfile(_userId);
  return profile.security;
}
