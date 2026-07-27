import { aiClient } from '../../src/lib/ai-client';

const mockFetch = jest.fn();
global.fetch = mockFetch as any;

describe('aiClient', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('healthCheck', () => {
    it('returns null on network error', async () => {
      mockFetch.mockRejectedValueOnce(new Error('Network error'));
      const result = await aiClient.healthCheck();
      expect(result).toBeNull();
    });

    it('returns null on non-ok response', async () => {
      mockFetch.mockResolvedValueOnce({ ok: false, status: 503 });
      const result = await aiClient.healthCheck();
      expect(result).toBeNull();
    });

    it('returns parsed body on success', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ service: 'finovault-ai', status: 'healthy' }),
      });
      const result = await aiClient.healthCheck();
      expect(result).toEqual({ service: 'finovault-ai', status: 'healthy' });
    });
  });

  describe('isReachable', () => {
    it('returns true when health returns running', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ service: 'finovault-ai', status: 'running' }),
      });
      const result = await aiClient.isReachable();
      expect(result).toBe(true);
    });

    it('returns false when health returns non-running', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ service: 'finovault-ai', status: 'error' }),
      });
      const result = await aiClient.isReachable();
      expect(result).toBe(false);
    });

    it('returns false when health returns null', async () => {
      mockFetch.mockRejectedValueOnce(new Error('fail'));
      const result = await aiClient.isReachable();
      expect(result).toBe(false);
    });
  });

  describe('askCoach', () => {
    it('sends POST with correct headers and body', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ answer: 'Great question!', suggestions: ['Save more'] }),
      });

      const result = await aiClient.askCoach(
        'How can I save more?',
        { total_income: 5000 },
        'user-token',
        'user-123',
      );

      expect(mockFetch).toHaveBeenCalledWith(
        expect.stringContaining('/coach/ask'),
        expect.objectContaining({
          method: 'POST',
          headers: expect.objectContaining({
            'Authorization': 'Bearer user-token',
            'X-User-Id': 'user-123',
          }),
          body: JSON.stringify({ question: 'How can I save more?', context: { total_income: 5000 } }),
        }),
      );
      expect(result).toEqual({ answer: 'Great question!', suggestions: ['Save more'] });
    });

    it('retries on 5xx error', async () => {
      mockFetch
        .mockResolvedValueOnce({
          ok: false,
          status: 502,
          json: async () => ({ detail: 'Bad gateway' }),
        })
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({ answer: 'Retry worked!', suggestions: [] }),
        });

      const result = await aiClient.askCoach('hi', {}, 'tok', 'uid');
      expect(result).toEqual({ answer: 'Retry worked!', suggestions: [] });
      expect(mockFetch).toHaveBeenCalledTimes(2);
    });

    it('throws on 4xx error without retry', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 400,
        json: async () => ({ detail: 'Bad request' }),
      });

      await expect(aiClient.askCoach('hi', {}, 'tok', 'uid')).rejects.toThrow();
      expect(mockFetch).toHaveBeenCalledTimes(1);
    });
  });
});
