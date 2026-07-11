import { apiClient } from '../client';
import { ENDPOINTS } from '../endpoints';

export async function getBusinessHealth() {
  return apiClient.get(ENDPOINTS.business.health);
}

export async function getBusinessForecast() {
  return apiClient.get(ENDPOINTS.business.forecast);
}

export async function getBusinessVendors() {
  return apiClient.get(ENDPOINTS.business.vendors);
}

export async function getBusinessAiAdvice() {
  return apiClient.get(ENDPOINTS.business.aiAdvice);
}

export async function addVendor(data: Record<string, any>) {
  return apiClient.post(ENDPOINTS.business.vendors, data);
}

export async function updateVendor(id: string, data: Record<string, any>) {
  return apiClient.put(`${ENDPOINTS.business.vendors}/${id}`, data);
}

export async function deleteVendor(id: string) {
  return apiClient.delete(`${ENDPOINTS.business.vendors}/${id}`);
}
