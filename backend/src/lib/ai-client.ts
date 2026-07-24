import { env } from '../config/env';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('AIClient');

const BASE_URL = env.PYTHON_AI_URL;

interface AIClientOptions {
  timeoutMs?: number;
  retries?: number;
}

class AIClientError extends Error {
  constructor(
    message: string,
    public statusCode?: number,
    public endpoint?: string,
  ) {
    super(message);
    this.name = 'AIClientError';
  }
}

const DEFAULT_OPTIONS: AIClientOptions = {
  timeoutMs: 15000,
  retries: 1,
};

async function request<T>(
  endpoint: string,
  body: unknown,
  userToken: string,
  userAgent: string,
  options: AIClientOptions = {},
): Promise<T> {
  const { timeoutMs, retries } = { ...DEFAULT_OPTIONS, ...options };
  const url = `${BASE_URL}${endpoint}`;

  let lastError: Error | null = null;

  for (let attempt = 0; attempt <= (retries ?? 1); attempt++) {
    if (attempt > 0) {
      const delay = Math.min(1000 * Math.pow(2, attempt - 1), 5000);
      await new Promise((r) => setTimeout(r, delay));
    }

    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${userToken}`,
          'X-Api-Key': env.AI_SERVICE_KEY,
          'X-User-Id': userAgent,
        },
        body: JSON.stringify(body),
        signal: controller.signal,
      });

      if (!response.ok) {
        let detail = `HTTP ${response.status}`;
        try {
          const errBody = (await response.json()) as Record<string, unknown>;
          detail = (errBody.detail as string) || detail;
        } catch {}
        throw new AIClientError(detail, response.status, endpoint);
      }

      const json = await response.json();
      return json as T;
    } catch (error: any) {
      lastError = error;
      if (error.name === 'AbortError') {
        log.warn(`Request to ${endpoint} timed out after ${timeoutMs}ms (attempt ${attempt + 1})`);
      } else if (error instanceof AIClientError) {
        log.warn(`AI service error on ${endpoint}: ${error.message}`);
        throw error;
      } else {
        log.warn(`AI service request failed on ${endpoint}: ${error.message} (attempt ${attempt + 1})`);
      }
    } finally {
      clearTimeout(timer);
    }
  }

  throw lastError || new Error(`AI service request to ${endpoint} failed after ${(retries ?? 1) + 1} attempts`);
}

export const aiClient = {
  askCoach: (question: string, context: Record<string, unknown>, userToken: string, userId: string) =>
    request<{ answer: string; suggestions: string[] }>(
      '/coach/ask',
      { question, context },
      userToken,
      userId,
      { timeoutMs: 20000 },
    ),

  checkFraud: (
    data: { amount: number; merchant?: string; category?: string; location?: string; device_id?: string; receiver?: string },
    userToken: string,
    userId: string,
  ) =>
    request<{ risk_score: number; risk_level: string; signals: string[]; decision: string; message: string }>(
      '/fraud/check',
      data,
      userToken,
      userId,
      { timeoutMs: 5000 },
    ),

  analyzePatterns: (force: boolean, userToken: string, userId: string) =>
    request<{ patterns_detected: number; patterns: Record<string, unknown>[] }>(
      '/patterns/analyze',
      { force },
      userToken,
      userId,
      { timeoutMs: 15000 },
    ),

  getBusinessAdvice: (
    question: string,
    businessData: Record<string, unknown> | null,
    userToken: string,
    userId: string,
  ) =>
    request<{ answer: string; metrics: Record<string, unknown> }>(
      '/business/advise',
      { question, business_data: businessData },
      userToken,
      userId,
      { timeoutMs: 20000 },
    ),
};
