let _token: string | null = null;
let _baseUrl: string = process.env.EXPO_PUBLIC_API_URL || 'https://finovault.onrender.com/api/v1';

export function setApiToken(token: string | null) {
  _token = token;
}

export function getApiToken(): string | null {
  return _token;
}

interface FetchOptions extends RequestInit {
  params?: Record<string, string>;
}

class ApiClient {
  private baseUrl: string;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  private async request<T>(endpoint: string, options: FetchOptions = {}): Promise<T> {
    const { params, ...fetchOptions } = options;

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

    const response = await fetch(url, {
      ...fetchOptions,
      headers,
    });

    if (!response.ok) {
      let message = `API Error ${response.status}`;
      try {
        const errorBody = await response.json();
        message = errorBody?.error?.message || message;
      } catch {}
      throw new Error(message);
    }

    const json = await response.json();

    const paginationKeys = ['total', 'page', 'limit', 'has_more', 'next_cursor', 'previous_cursor'];
    const hasPagination = paginationKeys.some((key) => key in json);
    if (json.data !== undefined && !hasPagination) {
      return json.data;
    }
    return json;
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
