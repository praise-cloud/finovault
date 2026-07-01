import { apiClient } from '../client';
import { ENDPOINTS } from '../endpoints';

export interface FraudEvent {
  id: string;
  user_id: string;
  event_type: string;
  description: string;
  severity: 'info' | 'warning' | 'critical';
  metadata?: any;
  timestamp: string;
  created_at: string;
}

interface FraudCheckInput {
  amount: number;
  merchant?: string;
  category?: string;
  location?: string;
  device_id?: string;
  receiver?: string;
}

interface FraudCheckResponse {
  risk_score: number;
  risk_level: 'low' | 'medium' | 'high' | 'critical';
  signals: string[];
  decision: 'allow' | 'freeze' | 'block';
  message: string;
}

interface ReportFraudInput {
  event_type: string;
  description: string;
  severity?: 'info' | 'warning' | 'critical';
  metadata?: Record<string, unknown>;
}

export async function checkTransaction(input: FraudCheckInput): Promise<FraudCheckResponse> {
  return apiClient.post<FraudCheckResponse>(ENDPOINTS.fraud.check, input);
}

export async function listEvents(): Promise<FraudEvent[]> {
  return apiClient.get<FraudEvent[]>(ENDPOINTS.fraud.events);
}

export async function reportEvent(input: ReportFraudInput): Promise<FraudEvent> {
  return apiClient.post<FraudEvent>(ENDPOINTS.fraud.events, input);
}

export async function resolveEvent(id: string): Promise<FraudEvent> {
  return apiClient.put<FraudEvent>(ENDPOINTS.fraud.resolveEvent(id), {});
}
