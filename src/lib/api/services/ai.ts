import { apiClient } from '../client';
import { ENDPOINTS } from '../endpoints';
import type { AISuggestion } from '@/src/lib/supabase-types';

interface CoachResponse {
  answer: string;
  suggestions?: string[];
  context: {
    recent_transactions: any[];
    total_savings_goals: number;
  };
}

interface MorningBriefing {
  id: string;
  user_id: string;
  briefing_date: string;
  content: any;
  created_at: string;
}

export async function getInsights(): Promise<AISuggestion[]> {
  return apiClient.get<AISuggestion[]>(ENDPOINTS.ai.insights);
}

export async function askCoach(question: string, context?: Record<string, unknown>): Promise<CoachResponse> {
  return apiClient.post<CoachResponse>(ENDPOINTS.ai.askCoach, { question, context });
}

export async function getMorningBriefing(): Promise<MorningBriefing | null> {
  return apiClient.get<MorningBriefing | null>(ENDPOINTS.ai.morningBriefing);
}

export async function getSuggestions(): Promise<AISuggestion[]> {
  return apiClient.get<AISuggestion[]>(ENDPOINTS.ai.suggestions);
}

export async function updateSuggestion(id: string, status: string): Promise<AISuggestion> {
  return apiClient.put<AISuggestion>(ENDPOINTS.ai.updateSuggestion(id), { status });
}
