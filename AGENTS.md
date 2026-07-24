# Expo HAS CHANGED

Read the exact versioned docs at https://docs.expo.dev/versions/v56.0.0/ before writing any code.

# Frontend Design System

Before building any UI component or screen, read `frontend-design.md` and ground the work in:
- **Design Tokens** (Section 6) — colors, radii, fonts, shadows
- **Vault Metaphor** (Section 1) — every container should feel secured/stored in a vault, not a generic rectangle
- **Component Specs** (Section 5.3) — cards, buttons, inputs, charts, iconography
- **Screen Specs** (Section 5.2) — per-screen layout and behavior

# Backend Architecture

## Service Topology
```
Client → Node.js API (Express, port 4000)
           ├── Sync queries → Supabase (service_role key, direct PostgreSQL)
           ├── AI requests → Python AI (FastAPI, port 8000) via HTTP POST
           │                  └── Python → OpenRouter (LLM for coach/advisor)
           │                  └── Python → Supabase (conversations, model state)
           └── Bull Queue (Redis) → Async jobs
                  ├── Daily briefing → generates morning_briefings row
                  ├── Pattern learning → calls Python /patterns/analyze
                  └── Transaction analysis → Z-score anomaly detection
```

## Inter-service Authentication
- **Service → Service**: `X-Api-Key` header (shared secret from `AI_SERVICE_KEY` env var) + `X-User-Id` header
- **Client → Service**: `Authorization: Bearer <JWT>` (validated via Supabase Auth)
- Python auth.py checks `X-Api-Key` first; falls back to JWT validation

## AI Client (Node.js)
File: `backend/src/lib/ai-client.ts`
- Wraps all calls to Python AI endpoints with:
  - Automatic retry (exponential backoff, configurable)
  - Timeout handling (AbortController)
  - Service key injection
  - Per-endpoint timeout presets:
    - Coach: 20s (LLM response)
    - Business advice: 20s (LLM response)
    - Pattern analysis: 15s
    - Fraud check: 5s (real-time requirement)

## Fallback Strategy
Every Node.js service that calls Python AI has a local fallback:
- Coach falls back to rule-based keyword matching (`generateCoachResponse`)
- Fraud falls back to threshold-based rules ($10k, $50k, receiver)
- Business advice falls back to template-based responses
- Pattern recognition falls back to heuristic detection (day-of-week, merchant frequency, category trends)

## Environment Variables
### Node.js (`backend/.env`)
- `AI_SERVICE_KEY` — shared secret for Node.js → Python auth
- `PYTHON_AI_URL` — base URL of Python AI service (default: https://finovault-ai.onrender.com)

### Python (`backend-ai/.env`)
- `AI_SERVICE_KEY` — shared secret to verify incoming Node.js requests
- `OPENROUTER_API_KEY` — OpenRouter API key for LLM calls (to be used in Phase 2)
- `CORS_ORIGINS` — comma-separated allowed origins

## Rate Limiting
### Node.js
- Standard rate limit on all routes: `express-rate-limit`
- AI coach endpoint: 30 requests/minute per IP (`aiRateLimit`)
- Auth endpoints: 10 requests/15 minutes (`authRateLimit`)

### Python
- slowapi with per-endpoint limits:
  - Coach: 30/minute
  - Fraud check: 60/minute
  - Business advice: 30/minute
  - Pattern analysis: 20/minute
