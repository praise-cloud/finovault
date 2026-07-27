import AsyncStorage from '@react-native-async-storage/async-storage';
import { ENDPOINTS } from './endpoints';

const TOKEN_KEY = 'finovault_auth_token';
const DEFAULT_TIMEOUT = 15000;
const MAX_RETRIES = 2;

const ENDPOINT_TIMEOUTS: Record<string, number> = {
  '/ai/coach': 20000,
  '/ai/business-advice': 20000,
  '/ai/patterns/analyze': 15000,
  '/ai/fraud/check': 5000,
};

let _token: string | null = null;
let _refreshToken: string | null = null;
let _baseUrl: string = process.env.EXPO_PUBLIC_API_URL || (process.env.NODE_ENV === 'development' ? 'http://localhost:4000/api/v1' : 'https://finovault.onrender.com/api/v1');
let _refreshPromise: Promise<boolean> | null = null;

export async function setApiToken(token: string | null) {
  _token = token;
  if (token) {
    await AsyncStorage.setItem(TOKEN_KEY, token).catch(() => {});
  } else {
    await AsyncStorage.removeItem(TOKEN_KEY).catch(() => {});
  }
}

export function getApiToken(): string | null {
  return _token;
}

export async function setRefreshToken(token: string | null) {
  _refreshToken = token;
}

export async function loadStoredToken(): Promise<string | null> {
  try {
    const stored = await AsyncStorage.getItem(TOKEN_KEY);
    if (stored) {
      _token = stored;
      return stored;
    }
  } catch {}
  return null;
}

function isTokenExpired(errorBody: any): boolean {
  const msg = errorBody?.error?.message?.toLowerCase() || '';
  return msg.includes('token') && (msg.includes('expired') || msg.includes('invalid'));
}

async function refreshAccessToken(): Promise<boolean> {
  if (!_refreshToken) return false;
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 10000);
  try {
    const response = await fetch(`${_baseUrl}${ENDPOINTS.auth.refresh}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refresh_token: _refreshToken! }),
      signal: controller.signal,
    });
    clearTimeout(timeoutId);
    if (!response.ok) return false;
    const json = await response.json();
    const session = json.session || json.data?.session;
    if (session?.access_token) {
      _token = session.access_token;
      _refreshToken = session.refresh_token || _refreshToken;
      await AsyncStorage.setItem(TOKEN_KEY, _token!).catch(() => {});
      return true;
    }
    return false;
  } catch {
    clearTimeout(timeoutId);
    return false;
  }
}

async function refreshTokenIfNeeded(): Promise<boolean> {
  if (_refreshPromise) return _refreshPromise;
  _refreshPromise = refreshAccessToken().finally(() => {
    _refreshPromise = null;
  });
  return _refreshPromise;
}

interface FetchOptions extends RequestInit {
  params?: Record<string, string>;
  timeout?: number;
}

class ApiClient {
  private baseUrl: string;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  private async request<T>(endpoint: string, options: FetchOptions = {}, retryCount = 0): Promise<T> {
    const endpointTimeout = Object.entries(ENDPOINT_TIMEOUTS).find(([key]) => endpoint.includes(key))?.[1];
    const { params, timeout = endpointTimeout ?? DEFAULT_TIMEOUT, ...fetchOptions } = options;

    let url = `${this.baseUrl}${endpoint}`;

    if (params) {
      const searchParams = new URLSearchParams(params);
      url += `?${searchParams.toString()}`;
    }

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      ...(options.headers as Record<string, string>),
    };

    const token = _token;
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    try {
      const response = await fetch(url, {
        ...fetchOptions,
        headers,
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        let message = `API Error ${response.status}`;
        let errorBody: any = null;
        try {
          errorBody = await response.json();
          message = errorBody?.error?.message || message;
        } catch {}

        // Try to refresh token on 401 if token is expired
        if (response.status === 401 && isTokenExpired(errorBody) && retryCount === 0) {
          const refreshed = await refreshTokenIfNeeded();
          if (refreshed) {
            return this.request<T>(endpoint, options, retryCount + 1);
          }
        }

        throw new Error(message);
      }

      const text = await response.text();
      if (!text) return undefined as T;

      const json = JSON.parse(text);
      const paginationKeys = ['total', 'page', 'limit', 'has_more', 'next_cursor', 'previous_cursor'];
      const hasPagination = paginationKeys.some((key) => key in json);
      if (json.data !== undefined && !hasPagination) {
        return json.data;
      }
      return json;
    } catch (err: any) {
      clearTimeout(timeoutId);

      if (err.name === 'AbortError') {
        throw new Error(`Request timeout after ${timeout}ms: ${endpoint}`);
      }

      // Retry on network errors and server errors (5xx), but not client errors (4xx)
      if (retryCount < MAX_RETRIES && (!err.message?.startsWith('API Error') || /^API Error 5\d{2}/.test(err.message))) {
        return this.request<T>(endpoint, options, retryCount + 1);
      }

      throw err;
    }
  }

  get<T>(endpoint: string, options?: FetchOptions) {
    return this.request<T>(endpoint, { ...options, method: 'GET' });
  }

  post<T>(endpoint: string, body?: unknown, options?: FetchOptions) {
    return this.request<T>(endpoint, {
      ...options,
      method: 'POST',
      body: body ? JSON.stringify(body) : undefined,
    });
  }

  put<T>(endpoint: string, body?: unknown, options?: FetchOptions) {
    return this.request<T>(endpoint, {
      ...options,
      method: 'PUT',
      body: body ? JSON.stringify(body) : undefined,
    });
  }

  delete<T>(endpoint: string, options?: FetchOptions) {
    return this.request<T>(endpoint, { ...options, method: 'DELETE' });
  }
}

export const apiClient = new ApiClient(_baseUrl);
