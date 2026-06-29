import { apiClient } from '../client';
import { ENDPOINTS } from '../endpoints';
import type {
  DashboardSummary,
  WealthGrowthData,
  SmartSavingsData,
  FraudProtectionData,
  SmeDashboardData,
  SmeAnalyticsData,
  FreelancerData,
  EntrepreneurData,
  ProfileData,
} from '@/lib/supabase-types';

export async function getDashboardSummary(_userId: string): Promise<DashboardSummary> {
  return apiClient.get<DashboardSummary>(ENDPOINTS.dashboard.summary);
}

export async function getWealthGrowthData(_userId: string): Promise<WealthGrowthData> {
  return apiClient.get<WealthGrowthData>(ENDPOINTS.dashboard.wealthGrowth);
}

export async function getSmartSavingsData(_userId: string): Promise<SmartSavingsData> {
  return apiClient.get<SmartSavingsData>(ENDPOINTS.dashboard.smartSavings);
}

export async function getFraudProtectionData(_userId: string): Promise<FraudProtectionData> {
  return apiClient.get<FraudProtectionData>(ENDPOINTS.dashboard.fraudProtection);
}

export async function getSmeDashboardData(_userId: string): Promise<SmeDashboardData> {
  return apiClient.get<SmeDashboardData>(ENDPOINTS.dashboard.sme);
}

export async function getSmeAnalyticsData(_userId: string): Promise<SmeAnalyticsData> {
  return apiClient.get<SmeAnalyticsData>(ENDPOINTS.dashboard.smeAnalytics);
}

export async function getFreelancerData(_userId: string): Promise<FreelancerData> {
  return apiClient.get<FreelancerData>(ENDPOINTS.dashboard.freelancer);
}

export async function getEntrepreneurData(_userId: string): Promise<EntrepreneurData> {
  return apiClient.get<EntrepreneurData>(ENDPOINTS.dashboard.entrepreneur);
}

export async function getProfileData(_userId: string): Promise<ProfileData> {
  return apiClient.get<ProfileData>(ENDPOINTS.dashboard.profile);
}
