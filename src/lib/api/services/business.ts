import { apiClient } from '../client';
import { ENDPOINTS } from '../endpoints';
import type { Vendor } from '@/src/lib/supabase-types';

export interface BusinessHealth {
  overall_health_score: number;
  revenue: number;
  expenses: number;
  profit: number;
  profit_margin: number;
  revenue_trend: number;
  expense_trend: number;
  vendor_count: number;
  vendor_health_average: number;
}

export interface BusinessForecast {
  monthly_avg_revenue: number;
  monthly_avg_expenses: number;
  net_monthly: number;
  cash_reserves: number;
  runway_months: number;
  forecast: number[];
  recommendation: string;
}

export interface BusinessAiAdvice {
  advice: string;
  recommendations: string[];
}

export async function getBusinessHealth(): Promise<BusinessHealth> {
  return apiClient.get<BusinessHealth>(ENDPOINTS.business.health);
}

export async function getBusinessForecast(): Promise<BusinessForecast> {
  return apiClient.get<BusinessForecast>(ENDPOINTS.business.forecast);
}

export async function getBusinessVendors(): Promise<{ vendors: Vendor[] }> {
  return apiClient.get<{ vendors: Vendor[] }>(ENDPOINTS.business.vendors);
}

export async function getBusinessAiAdvice(): Promise<BusinessAiAdvice> {
  return apiClient.get<BusinessAiAdvice>(ENDPOINTS.business.aiAdvice);
}

export async function addVendor(data: Partial<Vendor>): Promise<Vendor> {
  return apiClient.post<Vendor>(ENDPOINTS.business.vendors, data);
}

export async function updateVendor(id: string, data: Partial<Vendor>): Promise<Vendor> {
  return apiClient.put<Vendor>(`${ENDPOINTS.business.vendors}/${id}`, data);
}

export async function deleteVendor(id: string): Promise<void> {
  return apiClient.delete<void>(`${ENDPOINTS.business.vendors}/${id}`);
}
