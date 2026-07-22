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

export async function getDashboardSummary(): Promise<DashboardSummary> {
  return apiClient.get<DashboardSummary>(ENDPOINTS.dashboard.summary);
}

export async function getWealthGrowthData(): Promise<WealthGrowthData> {
  return apiClient.get<WealthGrowthData>(ENDPOINTS.dashboard.wealthGrowth);
}

export async function getSmartSavingsData(): Promise<SmartSavingsData> {
  return apiClient.get<SmartSavingsData>(ENDPOINTS.dashboard.smartSavings);
}

export async function getFraudProtectionData(): Promise<FraudProtectionData> {
  return apiClient.get<FraudProtectionData>(ENDPOINTS.dashboard.fraudProtection);
}

export async function getSmeDashboardData(): Promise<SmeDashboardData> {
  return apiClient.get<SmeDashboardData>(ENDPOINTS.dashboard.sme);
}

export async function getSmeAnalyticsData(): Promise<SmeAnalyticsData> {
  return apiClient.get<SmeAnalyticsData>(ENDPOINTS.dashboard.smeAnalytics);
}

export async function getFreelancerData(): Promise<FreelancerData> {
  return apiClient.get<FreelancerData>(ENDPOINTS.dashboard.freelancer);
}

export async function getEntrepreneurData(): Promise<EntrepreneurData> {
  return apiClient.get<EntrepreneurData>(ENDPOINTS.dashboard.entrepreneur);
}

export async function getProfileData(): Promise<ProfileData> {
  return apiClient.get<ProfileData>(ENDPOINTS.dashboard.profile);
}
