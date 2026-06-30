# Finovault AI — Complete Application Documentation

> **Version:** 1.0.0  
> **Last Updated:** June 30, 2026  
> **Stack:** React Native (Expo) + Express.js (Node) + FastAPI (Python) + Supabase (PostgreSQL)

---

## Table of Contents

1. [Application Overview](#1-application-overview)
2. [System Architecture](#2-system-architecture)
3. [Frontend (Mobile + Web)](#3-frontend)
4. [Backend API (Node.js/Express)](#4-backend-api)
5. [AI Engine (Python/FastAPI)](#5-ai-engine)
6. [Database Schema](#6-database-schema)
7. [Authentication & Authorization](#7-authentication)
8. [Features — Deep Dive](#8-features-deep-dive)
9. [AI Models & Algorithms](#9-ai-models-and-algorithms)
10. [Background Jobs & Schedulers](#10-background-jobs)
11. [Deployment Infrastructure](#11-deployment)
12. [Current State & Working Features](#12-current-state)
13. [Known Issues & Solutions](#13-issues-and-solutions)
14. [Design Assets & Prototypes](#14-design-assets)

---

## 1. Application Overview

Finovault AI is an **adaptive financial intelligence platform** that provides AI-powered personal finance management, SME business intelligence, fraud detection, and wealth growth tools. It targets four user personas: **Individuals**, **SME Owners**, **Entrepreneurs** (with a focus on female founders), and **Freelancers**.

### Core Value Propositions
- **Predict** — AI forecasting of market trends and asset performance
- **Protect** — Real-time fraud detection with neural monitoring, AES-256 encryption
- **Empower** — Personalized AI coaching and actionable financial insights
- **SME Intelligence** — Cashflow forensics, vendor health tracking, payroll automation

### Technology Stack

| Layer          | Technology                                     | Purpose                          |
|----------------|------------------------------------------------|----------------------------------|
| Frontend       | React Native + Expo SDK 56 + Expo Router       | Cross-platform (iOS, Android, Web) |
| Styling        | NativeWind v4 (Tailwind CSS for RN) + gluestack-ui | Utility-first styling + component library |
| State          | Zustand v5                                    | Client-side state management      |
| Backend API    | Node.js + Express.js + TypeScript              | RESTful API server                |
| Python AI      | FastAPI + scikit-learn + OpenAI                | ML inference & agent logic       |
| Database       | Supabase (PostgreSQL)                          | Data persistence + Auth           |
| Cache/Queue    | Redis + Bull                                   | Background jobs, task queuing     |
| Auth           | Supabase Auth (JWT)                            | Email/password, OTP, Google OAuth |
| Forms          | react-hook-form + Zod                          | Validation                        |
| Animations     | react-native-reanimated                        | Smooth UI transitions             |

---

## 2. System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      CLIENT (Expo App)                          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐  │
│  │  Welcome │ │  Auth    │ │ Onboard  │ │ Role Dashboards  │  │
│  │  Tour    │ │  Screens │ │ (Prefs)  │ │ (5 personas)     │  │
│  └──────────┘ └──────────┘ └──────────┘ └──────────────────┘  │
│         │              │           │               │           │
│         └──────────────┴───────────┴───────────────┘           │
│                            │ HTTP/JSON                          │
│                    Authorization: Bearer JWT                    │
└─────────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   BACKEND API (Express.js)                      │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐  │
│  │  Auth    │ │ Transaction│ Savings  │ │  Dashboard       │  │
│  │  Routes  │ │ Routes    │ Routes    │ │  Routes          │  │
│  ├──────────┤ ├──────────┤ ├──────────┤ ├──────────────────┤  │
│  │  Fraud   │ │ Business │ AI/Coach  │ │  Onboarding      │  │
│  │  Routes  │ │ Routes   │ Routes    │ │  Routes          │  │
│  └──────────┘ └──────────┘ └──────────┘ └──────────────────┘  │
│         │              │           │               │           │
│         └──────────────┴───────────┴───────────────┘           │
│                            │                                    │
│              ┌─────────────┴─────────────┐                      │
│              ▼                            ▼                     │
│       ┌──────────┐               ┌──────────────┐              │
│       │ Supabase │               │ Python AI    │              │
│       │ (Auth +  │◄──HTTP───────│ Service      │              │
│       │  DB)     │               │ (FastAPI)    │              │
│       └──────────┘               └──────┬───────┘              │
│                                         │                       │
│              ┌──────────────────────────┘                       │
│              ▼                                                  │
│       ┌──────────┐                                              │
│       │ OpenAI   │                                              │
│       │ (LLM)    │                                              │
│       └──────────┘                                              │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **Client Request** — Mobile/web app makes an HTTP request with a Bearer JWT token
2. **Middleware** — `rate-limit` → `helmet` (security headers) → `auth` (JWT verification via Supabase) → `validate` (Zod schema validation)
3. **Controller** — Handles request/response, calls service layer
4. **Service Layer** — Contains business logic, queries Supabase or calls Python AI service
5. **Python AI Service** — Handles ML inference (fraud detection, pattern recognition, business advice)
6. **Background Jobs** — Bull queues with Redis handle async tasks (daily briefings, pattern learning, transaction analysis)

---

## 3. Frontend (Mobile + Web)

### 3.1 Project Structure

```
src/
├── app/                        # Expo Router (file-based routing)
│   ├── _layout.tsx             # Root layout (providers, fonts, auth init)
│   ├── index.tsx               # Welcome Tour (onboarding carousel)
│   ├── login.tsx               # Login screen
│   ├── signup.tsx              # Signup screen (OTP flow)
│   ├── verification.tsx        # OTP verification screen
│   ├── preferences.tsx         # Role & goal selection
│   ├── explore.tsx             # Dev explore page (from Expo template)
│   └── (tabs)/                 # Authenticated tab screens
│       ├── _layout.tsx         # Tab layout (auth guard, bottom nav)
│       ├── index.tsx           # Individual Dashboard
│       ├── wealth-growth.tsx   # Wealth Growth portfolio
│       ├── smart-savings.tsx   # Smart Savings & round-ups
│       ├── fraud-protection.tsx # Fraud protection dashboard
│       ├── sme-dashboard.tsx   # SME main dashboard
│       ├── sme-analytics.tsx   # SME analytics/benchmarking
│       ├── entrepreneur.tsx    # Entrepreneur dashboard
│       ├── freelancer.tsx      # Freelancer dashboard
│       └── profile.tsx         # User profile & settings
├── components/                 # Shared UI components
│   ├── bottom-tab-bar.tsx      # Custom bottom navigation
│   ├── bento-card.tsx          # Card with press animation
│   ├── glass-card.tsx          # Glassmorphism card
│   ├── primary-button.tsx      # Gradient button
│   ├── progress-bar.tsx        # Animated progress bar
│   ├── stat-card.tsx           # Stat display card
│   ├── hint-row.tsx            # Hint/helper row
│   ├── external-link.tsx       # In-app browser link
│   ├── web-badge.tsx           # Web version badge
│   ├── themed-text.tsx         # Theme-aware text
│   ├── themed-view.tsx         # Theme-aware view
│   ├── top-app-bar.tsx         # Header bar
│   ├── animated-icon.tsx       # Splash animation (native)
│   ├── animated-icon.web.tsx   # Splash animation (web)
│   └── ui/collapsible.tsx      # Expandable section
├── stores/                     # Zustand state management
│   ├── auth-store.ts           # Auth state (user, session, OTP)
│   ├── dashboard-store.ts      # Dashboard data for all personas
│   └── preferences-store.ts    # User preferences & goals
├── lib/                        # Utilities & API layer
│   ├── api/
│   │   ├── client.ts           # HTTP client (fetch wrapper + token)
│   │   ├── endpoints.ts        # API endpoint constants
│   │   └── services/           # Service modules
│   │       ├── auth.ts         # Auth API calls
│   │       ├── dashboard.ts    # Dashboard API calls
│   │       └── profile.ts      # Profile API calls
│   ├── supabase.ts             # Supabase client (null - unused client-side)
│   ├── supabase-types.ts       # TypeScript interfaces for DB tables
│   ├── gluestack-provider.tsx  # gluestack-ui theme provider
│   └── nativewind-interop.ts   # NativeWind CSS setup
├── hooks/                      # Custom hooks
│   ├── use-color-scheme.ts     # Color scheme hook
│   ├── use-color-scheme.web.ts # Web-specific color scheme
│   ├── use-fonts.ts            # Font loading
│   └── use-theme.ts            # Theme hook
├── constants/theme.ts          # Colors, spacing, font config
├── types/                      # Type declarations
│   ├── css.d.ts                # CSS modules type
│   └── gluestack.d.ts          # gluestack-ui types
└── global.css                  # Global Tailwind styles
```

### 3.2 Route Flow

```
/ → index.tsx (Welcome Tour)
    ├── Not authenticated → /preferences → /signup → /verification → /(tabs)
    ├── Authenticated → /(tabs)
    └── Login link → /login → /(tabs)

/(tabs) → Tab Navigation
    ├── index         → Individual Dashboard (default)
    ├── wealth-growth → Wealth Growth Portfolio
    ├── smart-savings → Smart Savings & Round-ups
    ├── fraud-protection → Fraud Protection
    ├── sme-dashboard → SME Business Dashboard
    ├── sme-analytics → SME Analytics & Benchmarking
    ├── entrepreneur  → Entrepreneur Dashboard
    ├── freelancer    → Freelancer Dashboard
    └── profile       → User Profile & Settings
```

### 3.3 State Management

**auth-store.ts** (Zustand):
- Manages `user`, `session`, `isAuthenticated`, `isLoading`
- Handles OTP flow: `signUp` → stores `pendingPassword`/`pendingUserData` → `verifyOtp` completes registration
- Methods: `initialize`, `signUp`, `signIn`, `signInWithGoogle`, `signOut`, `verifyOtp`, `resendOtp`

**dashboard-store.ts** (Zustand):
- Lazy-loads dashboard data per persona via separate methods
- Each method calls the backend API and stores in its respective field
- `loadSummary()`, `loadWealthGrowth()`, `loadSmartSavings()`, `loadFraudProtection()`, etc.

**preferences-store.ts** (Zustand):
- Manages role selection, financial goals, notification toggles
- `savePreferences()` persists via API

### 3.4 API Client

The `apiClient` is a custom fetch wrapper that:
- Automatically attaches the Bearer JWT token from `_token` (set via `setApiToken`)
- Handles JSON serialization/deserialization
- Parses the standard API response `{ success, data, error, meta }`
- Throws on non-OK responses

The token is stored in-memory only (not persisted to AsyncStorage). On app start, `auth-store.initialize()` calls `getCurrentSession()` which uses the in-memory token to verify the session.

### 3.5 Screen Details

**Welcome Tour** (`index.tsx`):
- 4-slide animated carousel (Predict / Protect / Empower / SME Intelligence)
- Auto-advances every 5 seconds with pan gesture support
- Animated floating icons with `react-native-reanimated`
- Routes to preferences if unauthenticated, or tabs if authenticated

**Preferences** (`preferences.tsx`):
- Step 2 of 4 onboarding (after welcome tour)
- Role selection grid (Individual, SME, Woman Entrepreneur, Freelancer)
- Financial goals (Wealth Growth, Smart Savings, Fraud Protection, SME Analytics)
- Notification toggle switches
- Saves via `preferences-store.savePreferences()` → API → routes to signup

**Signup** (`signup.tsx`):
- Full name, email, phone (optional), password + confirm
- Password strength meter (4 levels: Weak/Fair/Good/Strong)
- Rate-limit cooldown timer (60s on 429)
- Calls `authStore.signUp()` → backend sends OTP → routes to verification
- Google/Apple OAuth buttons

**Verification** (`verification.tsx`):
- 6-digit OTP input with auto-advance on digit entry
- Animated floating elements (lock, security icons)
- 60s resend cooldown
- Calls `authStore.verifyOtp()` → backend completes registration + creates session

**Individual Dashboard** (`tabs/index.tsx`):
- Total Net Worth hero card with animated change indicator
- "Next Best Move" AI suggestion card (if available)
- Monthly spending breakdown with trend
- Asset allocation visualization
- Recent transactions feed
- Falls back to mock data if API returns null

**Wealth Growth** (`wealth-growth.tsx`):
- Performance forecast bar chart (12-month AI projection)
- Donut chart for asset allocation (Equities/Fixed Income/Digital Assets/Cash)
- Market Intelligence feed
- Risk Shield card (AI-detected portfolio drag, optimization suggestion)

**Smart Savings** (`smart-savings.tsx`):
- Rainy Day Fund progress with animated spring fill
- AI Savings Suggestion card
- Round-up savings list
- Total savings impact stat
- Micro-budget optimization tip

**Fraud Protection** (`fraud-protection.tsx`):
- Security Score doughnut gauge (circular SVG)
- Identity verification & encryption status
- Real-time monitoring event feed
- Encryption/AI Monitoring/Key Custody cards
- "Finovault Shield" marketing section

**SME Dashboard** (`sme-dashboard.tsx`):
- Cash Flow Analysis (incoming/outgoing/net with forecast bars)
- Payroll Tasks with health score gauge
- B2B Vendor Ecosystem grid
- Growth Pulse AI metrics
- Fraud Protection section

**SME Analytics** (`sme-analytics.tsx`):
- Cashflow Forensics (chart + net inflow/burn rate/runway)
- Industry Benchmarking (efficiency, retention, digital adoption)
- Vendor Health Analytics table
- AI Smart Recommendation banner

**Freelancer Dashboard** (`freelancer.tsx`):
- Tax Liability tracker with withholding progress
- Income Tracking (project-based vs retainers)
- Unpaid Invoices card
- Projects table with status
- Tax Shield optimization section

**Entrepreneur Dashboard** (`entrepreneur.tsx`):
- MRR (Monthly Recurring Revenue) with growth
- Burn Rate / CAC / Runway metrics
- Grant Insight card
- Smart Savings (operational reserve)
- Circle Network contacts
- Upcoming Roundtable event
- SME Analytics Portfolio (SaaS/Marketing/Human Capital breakdown)

**Profile** (`profile.tsx`):
- Profile hero with avatar, name, plan badge
- Settings sidebar (Personal Info, Security, Linked Accounts, Data Privacy, Notifications)
- Personal Info form display
- Plan Details with subscription management
- Security & Protection status
- Linked Accounts list
- Sign Out button

---

## 4. Backend API (Node.js/Express)

### 4.1 Project Structure

```
backend/
├── src/
│   ├── index.ts                 # Entry point (server startup, graceful shutdown)
│   ├── app.ts                   # Express app setup (middleware, routes)
│   ├── config/
│   │   ├── env.ts               # Environment variable validation & export
│   │   └── supabase.ts          # Supabase client singleton factory
│   ├── middleware/
│   │   ├── auth.ts              # JWT authentication (bearer token)
│   │   ├── async-wrap.ts        # Async error wrapper for Express
│   │   ├── error-handler.ts     # Global error handler
│   │   ├── rate-limit.ts        # Rate limiting (standard, auth, AI)
│   │   └── validate.ts          # Zod schema validation middleware
│   ├── routes/
│   │   ├── index.ts             # Route aggregator (/api/v1/...)
│   │   ├── health.routes.ts     # Health check endpoint
│   │   ├── auth.routes.ts       # Authentication endpoints
│   │   ├── profile.routes.ts    # Profile management
│   │   ├── transactions.routes.ts # Transaction CRUD
│   │   ├── dashboard.routes.ts  # Dashboard aggregated data
│   │   ├── savings.routes.ts    # Savings goals & round-ups
│   │   ├── fraud.routes.ts      # Fraud checking & events
│   │   ├── ai.routes.ts         # AI coach, insights, suggestions
│   │   ├── business.routes.ts   # Business health, forecast, vendors
│   │   └── onboarding.routes.ts # Financial profile/interview
│   ├── controllers/
│   │   ├── auth.controller.ts
│   │   ├── profile.controller.ts
│   │   ├── transactions.controller.ts
│   │   ├── dashboard.controller.ts
│   │   ├── savings.controller.ts
│   │   ├── fraud.controller.ts
│   │   ├── ai.controller.ts
│   │   ├── business.controller.ts
│   │   └── onboarding.controller.ts
│   ├── services/
│   │   ├── auth.service.ts           # Auth logic (OTP, signup, login, Google, session)
│   │   ├── transaction.service.ts    # Transaction CRUD
│   │   ├── fraud.service.ts          # Rule-based fraud checks
│   │   ├── savings.service.ts        # Savings goals & round-ups
│   │   ├── business.service.ts       # Business health, forecast, AI advice
│   │   ├── dashboard.service.ts      # Aggregated dashboard data (all personas)
│   │   ├── ai.service.ts            # AI coach, insights, suggestions
│   │   ├── onboarding.service.ts    # Financial profile CRUD
│   │   ├── profile.service.ts       # User profile & preferences
│   │   ├── pattern-recognition.service.ts # ML pattern detection on transactions
│   │   ├── notification.service.ts  # In-app notification dispatch
│   │   └── scheduler.service.ts     # Daily briefing generation
│   ├── models/                  # Zod schemas for request validation
│   │   ├── common.schema.ts
│   │   ├── user.schema.ts
│   │   ├── transaction.schema.ts
│   │   ├── fraud.schema.ts
│   │   ├── savings.schema.ts
│   │   ├── business.schema.ts
│   │   ├── dashboard.schema.ts
│   │   └── ai.schema.ts
│   ├── types/
│   │   ├── index.ts             # Shared TypeScript types
│   │   └── express.d.ts         # Express Request augmentation (req.user)
│   └── utils/
│       ├── logger.ts            # Winston logger with context support
│       ├── errors.ts            # Custom error classes (AppError, NotFound, etc.)
│       ├── helpers.ts           # Response helpers, pagination, utilities
│       └── constants.ts         # App-wide constants & enums
├── jobs/
│   ├── queue.ts                 # Bull queue definitions
│   ├── scheduler.ts             # Job scheduling logic
│   └── processors/
│       ├── daily-briefing.ts    # Generate daily financial briefing
│       ├── pattern-learning.ts  # Learn user spending patterns
│       └── transaction-analysis.ts # Analyze transaction anomalies
├── supabase/migrations/
│   └── 003_add_ai_features.sql  # AI features schema (profiles, patterns, conversations, etc.)
├── tests/
├── docker-compose.yml           # API + Redis
├── Dockerfile                   # Multi-stage build
├── jest.config.ts
└── tsconfig.json
```

### 4.2 Middleware Pipeline

```
Request → helmet (security headers)
        → cors (cross-origin, configurable origins)
        → express.json (body parsing, 10mb limit)
        → standardRateLimit (100 req / 15 min)
        → Router (auth check per route where needed)
            → optional: validate (Zod)
            → controller → service → response
        → errorHandler (catches thrown errors)
```

### 4.3 Auth Middleware

```typescript
// Extracts Bearer token from Authorization header
// Calls supabase.auth.getUser(token) to verify JWT
// Sets req.user = { id, email, role }
// Throws UnauthorizedError on invalid/missing token
// optionalAuth variant: continues if no token present
```

### 4.4 Validation Middleware

Uses Zod schemas defined in `/models` to validate `body`, `query`, and `params`. On validation failure, throws `ValidationError` with concatenated error messages.

### 4.5 Error Handling

Custom `AppError` hierarchy:
- `AppError` (base) — has `statusCode`, `code`, `isOperational`
- `NotFoundError` (404)
- `UnauthorizedError` (401)
- `ForbiddenError` (403)
- `ValidationError` (400)
- `ConflictError` (409)
- `InternalError` (500, non-operational)

The `errorHandler` middleware:
- Operational errors → warn log + structured error response
- Non-operational / unexpected → error log + generic 500

### 4.6 API Endpoints

All routes are prefixed with `/api/v1`.

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/health` | No | Health check (incl. DB ping) |
| POST | `/auth/send-otp` | No | Send OTP to email (rate-limited) |
| POST | `/auth/signup` | No | Create account (rate-limited) |
| POST | `/auth/login` | No | Login (rate-limited) |
| POST | `/auth/verify-otp` | No | Verify OTP + create session |
| POST | `/auth/google` | No | Google OAuth |
| POST | `/auth/verify` | No | Verify session token |
| POST | `/auth/refresh` | No | Refresh session |
| POST | `/auth/logout` | Yes | Sign out |
| GET | `/profile/me` | Yes | Get full profile |
| PUT | `/profile/me` | Yes | Update profile |
| GET | `/profile/preferences` | Yes | Get preferences |
| PUT | `/profile/preferences` | Yes | Update preferences |
| POST | `/profile/link-account` | Yes | Link bank account |
| GET | `/profile/linked-accounts` | Yes | List linked accounts |
| GET | `/transactions` | Yes | List transactions (paginated, filterable) |
| GET | `/transactions/:id` | Yes | Get single transaction |
| POST | `/transactions` | Yes | Create transaction |
| PUT | `/transactions/:id` | Yes | Update transaction |
| DELETE | `/transactions/:id` | Yes | Delete transaction |
| GET | `/dashboard/summary` | Yes | Individual dashboard summary |
| GET | `/dashboard/wealth-growth` | Yes | Wealth growth data |
| GET | `/dashboard/smart-savings` | Yes | Smart savings data |
| GET | `/dashboard/fraud-protection` | Yes | Fraud protection data |
| GET | `/dashboard/sme` | Yes | SME dashboard data |
| GET | `/dashboard/sme-analytics` | Yes | SME analytics data |
| GET | `/dashboard/freelancer` | Yes | Freelancer data |
| GET | `/dashboard/entrepreneur` | Yes | Entrepreneur data |
| GET | `/dashboard/profile-data` | Yes | Profile page data |
| GET | `/savings/goals` | Yes | List savings goals |
| POST | `/savings/goals` | Yes | Create savings goal |
| PUT | `/savings/goals/:id` | Yes | Update savings goal |
| DELETE | `/savings/goals/:id` | Yes | Delete savings goal |
| GET | `/savings/round-ups` | Yes | List round-up savings |
| POST | `/fraud/check` | Yes | Check transaction for fraud |
| GET | `/fraud/events` | Yes | List fraud events |
| POST | `/fraud/events` | Yes | Report fraud event |
| PUT | `/fraud/events/:id/resolve` | Yes | Resolve fraud event |
| GET | `/ai/insights` | Yes | Get AI insights |
| POST | `/ai/coach/ask` | Yes | Ask AI financial coach |
| GET | `/ai/coach/morning-briefing` | Yes | Get daily briefing |
| GET | `/ai/suggestions` | Yes | List AI suggestions |
| PUT | `/ai/suggestions/:id` | Yes | Update suggestion status |
| GET | `/business/health` | Yes | Business health metrics |
| GET | `/business/forecast` | Yes | Business forecast |
| GET | `/business/vendors` | Yes | List vendors |
| POST | `/business/ai-advice` | Yes | Get AI business advice |
| POST | `/onboarding/financial-interview` | Yes | Submit financial interview |
| GET | `/onboarding/financial-profile` | Yes | Get financial profile |
| PUT | `/onboarding/financial-profile` | Yes | Update financial profile |

### 4.7 Standard API Response Format

```typescript
// Success
{
  success: true,
  data: { ... },            // Response payload
  meta: {
    timestamp: "2026-06-30T...",
    version: "1.0.0"
  }
}

// Error
{
  success: false,
  error: {
    code: "VALIDATION_ERROR",
    message: "email: Invalid email address"
  },
  meta: {
    timestamp: "2026-06-30T...",
    version: "1.0.0"
  }
}
```

### 4.8 Key Service Implementations

**auth.service.ts**:
- `sendOtp()` — Calls `supabase.auth.signInWithOtp()` with `shouldCreateUser: true`; stores user metadata (name, phone)
- `signup()` — Uses `supabase.auth.admin.createUser()` (service role) to create user with confirmed email, then signs them in
- `login()` — Calls `supabase.auth.signInWithPassword()`
- `verifyOtp()` — Calls `supabase.auth.verifyOtp()`, then optionally updates password and metadata via `admin.updateUserById()`
- `googleAuth()` — Supports both `signInWithIdToken` (access token) and `signInWithOAuth` (URL redirect)

**dashboard.service.ts**:
- Each method queries multiple Supabase tables in parallel via `Promise.all`
- Falls back to **hardcoded mock data** when queries return empty. This is a key design decision — the app works with demo data out of the box
- All persona-specific dashboards (SME, Freelancer, Entrepreneur) are served from this single service

**fraud.service.ts**:
- Rule-based risk scoring (not ML-based in the Node service):
  - Amount > $10,000 → +25 risk score
  - Amount > $50,000 → +25 risk score
  - Receiver present → +5 risk score
- Thresholds: >50 = "high"/freeze, >25 = "medium", else "low"/allow
- Logs all checks to `fraud_events` table

**pattern-recognition.service.ts**:
- Three detection algorithms:
  1. **Day-of-week patterns** — Identifies days where spending exceeds 1.5x expected (total_transactions/7)
  2. **Merchant frequency** — Flags merchants visited 5+ times
  3. **Category trends** — Detects category spending changes >30% over 3+ months
- Upserts results into `behavior_patterns` table

---

## 5. AI Engine (Python/FastAPI)

### 5.1 Project Structure

```
backend-ai/
├── app/
│   ├── main.py                  # FastAPI app (CORS, route registration)
│   ├── core/
│   │   ├── config.py            # Settings (Supabase, OpenRouter, Redis)
│   │   ├── supabase.py          # Supabase client singleton
│   │   └── logger.py            # Python logging setup
│   ├── models/
│   │   └── schemas.py           # Pydantic request/response models
│   ├── routes/
│   │   ├── health.py            # Health check endpoint
│   │   ├── fraud.py             # POST /fraud/check
│   │   ├── coach.py             # POST /coach/ask
│   │   ├── patterns.py          # POST /patterns/analyze
│   │   └── business.py          # POST /business/advise
│   └── services/
│       ├── fraud_detector.py    # Isolation Forest + rule-based fraud detection
│       ├── financial_coach.py   # AI coach with context-aware responses
│       ├── pattern_recognizer.py # Transaction pattern detection
│       └── business_advisor.py  # Business advice with data context
├── tests/                       # (currently empty)
├── requirements.txt
├── Dockerfile
└── .env
```

### 5.2 Python Service Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check with DB ping |
| POST | `/fraud/check` | ML-based fraud detection |
| POST | `/coach/ask` | AI financial coaching |
| POST | `/patterns/analyze` | Transaction pattern analysis |
| POST | `/business/advise` | Business financial advice |

### 5.3 Fraud Detection Algorithm (`fraud_detector.py`)

Uses a **two-stage approach**:

**Stage 1 — Isolation Forest (ML)**:
- Model: `sklearn.ensemble.IsolationForest`
- Contamination: 0.1 (expects 10% anomalies)
- Training: Fits on the user's last 100 transaction amounts + current transaction
- Inference: If `predictions[-1] == -1` (anomaly), adds +35 to risk score
- Required: Minimum 10 historical transactions

**Stage 2 — Rule-based**:
- Amount > $10,000 → +20 (high value)
- Amount > $50,000 → +20 additional (very high)
- New receiver present → +10
- Device check (queries `security_metrics` table)

**Final Decision**:
- Risk > 70 → "critical" / **block**
- Risk > 50 → "high" / **freeze**
- Risk > 25 → "medium" / **freeze**
- Otherwise → "low" / **allow**

### 5.4 Financial Coach Algorithm (`financial_coach.py`)

A **rule-based NLP coach** (not using LLM despite having OpenRouter API key configured):
- Fetches user profile, last 30 transactions, and savings goals
- Keyword matching on the question:
  - "save"/"saving" → savings advice + total saved amount
  - "spend"/"spending" → spending analysis + income percentage
  - "invest"/"investment" → portfolio allocation advice (60/25/15)
  - "budget"/"budgeting" → 50/30/20 rule recommendation
  - "debt"/"loan" → avalanche vs snowball method advice
  - Default → general financial health tip
- Saves the conversation to `ai_conversations` table
- Returns both `answer` and `suggestions` array

### 5.5 Pattern Recognizer Algorithm (`pattern_recognizer.py`)

Three detection methods identical in logic to the Node.js `pattern-recognition.service.ts`:
1. **Day-of-week patterns**: Compares daily transaction count to expected (total/7), flags days >1.5x expected
2. **Merchant frequency**: Flags merchants visited 5+ times
3. **Category trends**: Detects spending changes >30% over 3+ months (monthly aggregation)
- Upserts results to `behavior_patterns` table
- Requires minimum 10 transactions to analyze

### 5.6 Business Advisor (`business_advisor.py`)

- Fetches user's last 100 transactions and all vendors
- Calculates revenue, expenses, profit margin
- Keyword-based routing:
  - "profit"/"revenue"/"growth" → margin analysis with recommendation
  - "vendor"/"supplier" → vendor count, top vendor details
  - "cash"/"runway" → runway calculation from expense history
  - Default → comprehensive summary

---

## 6. Database Schema

### 6.1 Tables (Supabase/PostgreSQL)

**Migration 001_init.sql** creates 15 core tables:

| # | Table | Purpose | Key Columns |
|---|-------|---------|-------------|
| 1 | `profiles` | User profile (extends auth.users) | `id` (PK, FK to auth.users), `full_name`, `email`, `phone`, `account_id`, `plan_type` |
| 2 | `user_preferences` | Onboarding preferences | `user_id` (FK), `role`, `goals[]`, `ai_insights_enabled`, `security_alerts_enabled` |
| 3 | `transactions` | Financial transactions | `user_id` (FK), `type` (income/expense/transfer), `amount`, `category`, `merchant`, `status` |
| 4 | `asset_allocations` | Portfolio allocation | `user_id` (FK), `category`, `percentage`, `value`, `color`, `icon` |
| 5 | `savings_goals` | Savings targets | `user_id` (FK), `name`, `target_amount`, `current_amount`, `goal_type`, `status` |
| 6 | `round_up_savings` | Round-up micro-savings | `user_id` (FK), `transaction_id` (FK), `original_amount`, `saved_amount`, `merchant` |
| 7 | `market_insights` | Market news/intelligence | `badge`, `title`, `description`, `category`, `published_at` |
| 8 | `vendors` | SME vendor management | `user_id` (FK), `name`, `health_score`, `monthly_spend`, `status` |
| 9 | `payroll_tasks` | SME payroll actions | `user_id` (FK), `title`, `status` (overdue/completed/pending) |
| 10 | `projects` | Freelancer projects | `user_id` (FK), `name`, `client`, `amount`, `status` |
| 11 | `network_contacts` | Entrepreneur network | `user_id` (FK), `name`, `role` |
| 12 | `fraud_events` | Security/fraud events | `user_id` (FK), `event_type`, `severity` (info/warning/critical) |
| 13 | `linked_accounts` | Linked bank accounts | `user_id` (FK), `bank_name`, `account_type`, `balance` |
| 14 | `ai_suggestions` | AI-generated suggestions | `user_id` (FK), `title`, `type`, `potential_savings`, `status` |
| 15 | `security_metrics` | User security status | `user_id` (FK, UNIQUE), `score`, `encryption_level`, `active_devices` |

**Migration 003_add_ai_features.sql** adds 7 more tables:

| # | Table | Purpose |
|---|-------|---------|
| 16 | `financial_profiles` | Onboarding interview answers (employment, income, goals, fears, risk tolerance) |
| 17 | `behavior_patterns` | Detected user spending patterns (type, name, confidence score, metadata as JSONB) |
| 18 | `ai_conversations` | Chat history with AI coach (role, content, context as JSONB) |
| 19 | `scam_database` | Known fraud pattern signatures (text fields + severity) |
| 20 | `business_health_snapshots` | Daily business health records (revenue, expenses, health score, AI insight) |
| 21 | `morning_briefings` | Daily financial briefings per user (content, action items as JSONB) |
| 22 | `notifications` | In-app notifications (type, title, body, data as JSONB) |

### 6.2 Trigger: Auto-create Profile on Signup

```sql
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

The trigger function:
1. Inserts into `profiles` with name, email, phone, and auto-generated account_id (`'FV-' + 6 random hex chars`)
2. Creates a `security_metrics` record with default score of 98
3. Uses `ON CONFLICT DO NOTHING` (safe for re-runs, fixed in migration 002)

### 6.3 Row-Level Security (RLS)

All tables have RLS enabled. Policies ensure users can only access their own data:
- `SELECT` — `auth.uid() = user_id` (or `auth.uid() = id` for profiles)
- `INSERT` / `UPDATE` / `DELETE` — Same user_id check where applicable
- Service role (backend API) bypasses RLS entirely

---

## 7. Authentication & Authorization

### 7.1 Auth Flow

```
Signup:
  1. User fills form → POST /auth/send-otp (creates unconfirmed user)
  2. User receives 6-digit OTP via email
  3. User enters OTP → POST /auth/verify-otp
  4. Backend verifies OTP, optionally sets password + metadata
  5. Session tokens returned → client stores in memory

Login:
  1. User enters email + password → POST /auth/login
  2. Backend calls supabase.auth.signInWithPassword()
  3. Session tokens returned → client stores in memory

Session Verification:
  1. Client sends Bearer token → POST /auth/verify
  2. Backend calls supabase.auth.getUser(token)
  3. Returns user data or 401
```

### 7.2 Token Management

- **Access Token**: JWT, short-lived (default 1 hour by Supabase)
- **Refresh Token**: Long-lived, used for silent refresh via `POST /auth/refresh`
- **Storage**: In-memory only (not AsyncStorage). Token is lost on app restart, requiring re-login
- **Service Role Key**: Used server-side for admin operations (create user, update user by ID)

---

## 8. Features — Deep Dive

### 8.1 Onboarding Flow

```
Welcome Tour → Preferences (Role + Goals) → Signup → OTP Verification → Dashboard
```

1. **Welcome Tour** (index.tsx): 4-slide carousel explaining "Predict, Protect, Empower, SME Intelligence"
2. **Preferences** (preferences.tsx): Select role + financial goals + notification settings
3. **Signup** (signup.tsx): Email/password registration with OTP
4. **Verification** (verification.tsx): 6-digit code entry
5. **Financial Interview** (planned via `/onboarding/financial-interview`): Questions about employment, income, goals, risk tolerance

### 8.2 Individual Dashboard

- **Net Worth Card**: Displays total with animated change indicator. Supports drill-down via "Detailed Report"
- **Next Best Move**: AI suggestion card with action button (Execute Transfer / More)
- **Monthly Spending**: Shows current vs limit with category breakdown bars
- **Asset Allocation**: Color-coded categories with percentage and value
- **Recent Flux**: Recent transactions with type indicators (+/-)

### 8.3 Wealth Growth Portfolio

- **Performance Forecast**: 12-month projection bar chart (AI-generated). Toggle 1Y/5Y/MAX
- **Asset Allocation**: Interactive donut chart (Equities 55%, Fixed Income 25%, Digital Assets 12%, Cash 8%)
- **Market Intelligence**: Curated financial news with badges (Bullish/Neutral)
- **Risk Shield**: AI-detected portfolio drag, potential savings calculation, optimization execution

### 8.4 Smart Savings

- **Rainy Day Fund**: Animated progress bar with spring physics. Shows percentage reached and time-to-goal
- **AI Suggestion**: "Hidden saving potential" card with enable auto-budgeting action
- **Round-up Savings**: List of micro-savings from transaction rounding (e.g., $42.34 → $43.00, saves $0.66)
- **Total Savings Impact**: Aggregate of all round-ups with trend
- **Micro-budget Suggestion**: Personalized optimization tip

### 8.5 Fraud Protection

- **Security Score**: Circular gauge (currently 98/100)
- **Identity Verification**: Checked status with AES-256 encryption
- **Real-time Monitoring**: Event feed with severity indicators, left-border color coding
- **The Finovault Shield**: Marketing section describing the AI protection architecture
- **Additional Info Cards**: End-to-End Tunnel encryption, Neural Engine v4.2, Hardware Isolated Key Custody

### 8.6 SME Dashboard

- **Cash Flow Analysis**: Incoming/Outgoing/Net Position with live badge and forecast bars
- **Payroll Tasks**: Task list with health score gauge (SVG Circle)
- **B2B Vendor Ecosystem**: Health score cards with sort/filter
- **Growth Pulse AI**: Market share, CLV, burn rate efficiency
- **Fraud Protection**: Invoice validation, identity sync, transaction flagging

### 8.7 SME Analytics

- **Cashflow Forensics**: Net inflow, burn rate, runway with bar chart
- **Industry Benchmarking**: Top 5% performance badge with efficiency/retention/digital adoption scores
- **Vendor Health Analytics**: Table with vendor names, monthly spend, payment reliability bars, Finovault score
- **AI Smart Recommendation**: Actionable business insight from AI analysis

### 8.8 Freelancer Dashboard

- **Tax Liability**: Estimated tax with withholding progress bar
- **Income Tracking**: Project-based vs retainer income breakdown
- **Unpaid Invoices**: Amount with overdue count badge
- **Recent Projects**: Table with project name, client, amount, status (Invoiced/In Progress/Overdue)
- **Tax Shield**: Optimization suggestion with projected savings chart

### 8.9 Entrepreneur Dashboard

- **Business Growth Velocity**: MRR with YoY growth, burn rate, CAC, runway
- **Grant Insight**: Curated grant opportunity (e.g., "Female Innovators Seed Fund 2024")
- **Smart Savings**: Operational reserve with APY display
- **Circle Network**: Professional contacts list with chat action
- **Upcoming Roundtable**: Event card (e.g., "Series B Fundraising Tactics")
- **SME Analytics Portfolio**: Portfolio distribution (SaaS/Marketing/Human Capital) with circular visualization

---

## 9. AI Models and Algorithms

### 9.1 Fraud Detection (Python - scikit-learn)

**Algorithm: Isolation Forest**
- **Purpose**: Detect anomalous transaction amounts
- **How it works**: Constructs isolation trees by randomly selecting features and split values. Anomalies are isolated closer to the root (shorter path length), normal points require more splits
- **Parameters**: `contamination=0.1`, `n_estimators=100`, `random_state=42`
- **Training**: Online — retrains on each request using the user's last 100 transactions + the current one
- **Output**: Binary prediction (-1 = anomaly, 1 = normal)
- **Integration**: Combined with rule-based checks (amount thresholds, new receiver, device match) for final risk score

**Risk Score Calculation**:
```
risk_score = 0
if IsolationForest predicts anomaly: risk_score += 35
if amount > 10000: risk_score += 20
if amount > 50000: risk_score += 20
if new receiver: risk_score += 10
risk_score = min(100, risk_score)
```

### 9.2 Pattern Recognition (Python + Node.js)

**Three independent algorithms**:

1. **Day-of-Week Detection**:
   - For each day, count transactions and compute `expected = total / 7`
   - Flag if `count > expected * 1.5` AND `count >= 3`
   - Confidence = `min(95, (count / expected) * 50)`

2. **Merchant Frequency Detection**:
   - Count visits per merchant
   - Flag if `visits >= 5`
   - Confidence = `min(90, (visits / 50) * 80)`

3. **Category Trend Detection**:
   - Aggregate spending by category per month
   - Compare first vs last month's amount over 3+ months
   - Flag if change > 30%
   - Confidence = `min(85, |change_percent|)`

### 9.3 Financial Coach (Python - Rule-based NLP)

Not using LLM (despite having OpenRouter API key configured). A deterministic keyword-matching system:
- Tokenizes the user's question
- Matches against known keywords
- Responds with pre-formatted financial advice
- Context is enriched with actual user data (transactions, goals, profile)

### 9.4 Business Advisor (Python + Node.js)

**Health Score Algorithm** (`business.service.ts`):
```
marginScore = min(50, max(0, (profitMargin / 20) * 50))
vendorScore = min(50, vendorHealthAverage / 2)
healthScore = round(marginScore + vendorScore)
```

**Forecast Algorithm** (`business.service.ts`):
- Generates 6-month cash projection
- Starts at $100,000 baseline
- Each month: `current += netMonthly; current += current * random(-5%, +5%)`

### 9.5 Transaction Anomaly Detection (Node.js - Bull job processor)

**Z-Score Method**:
```
mean = average of last 50 transaction amounts
stdDev = standard deviation of last 50
zScore = |current_amount - mean| / stdDev

if zScore > 3: flag as anomaly
anomalyScore = min(100, (zScore / 5) * 100)
```

If anomaly score > 70:
- Creates a `fraud_event` with severity "warning"
- Updates transaction status to "flagged"

---

## 10. Background Jobs & Schedulers

### 10.1 Queue Infrastructure (Bull + Redis)

Three queues defined in `backend/jobs/queue.ts`:

| Queue | Redis Key | Retries | Purpose |
|-------|-----------|---------|---------|
| `transaction-analysis` | bull:transaction-analysis | 3 (exponential backoff) | Analyze new transactions |
| `daily-briefing` | bull:daily-briefing | 2 (fixed backoff) | Generate morning briefings |
| `pattern-learning` | bull:pattern-learning | 2 (fixed backoff) | Learn user patterns |

### 10.2 Daily Briefing Generator

Triggered via `scheduleDailyBriefings()`:
1. Fetches all profile IDs from Supabase
2. Skips users who already have a briefing for today
3. Enqueues one job per user with random delay (0–1 hour spread)
4. Processor (`generateDailyBriefing`) queries last 30 days of transactions, active savings goals, and recent fraud events
5. Generates personalized content text and action items
6. Inserts into `morning_briefings` table

### 10.3 Pattern Learning

Triggered via `schedulePatternLearning()`:
- Fetches all profile IDs
- Enqueues pattern learning jobs with random delay
- Processor calls `analyzeUserPatterns()` which runs the 3 detection algorithms

### 10.4 Transaction Analysis

Triggered per-transaction (in real-time flow):
- Receives `{ userId, transactionId, amount, merchant, category }`
- Loads last 50 transactions (excluding current)
- Calculates Z-score for amount anomaly
- If anomaly detected: checks if merchant is new, calculates category average
- Creates fraud event if score > 70, flags transaction

---

## 11. Deployment Infrastructure

### 11.1 Docker Containers

**Backend API** (`backend/Dockerfile`):
- Multi-stage build (builder + runner)
- Node 20 Alpine base image
- Non-root `express` user
- Exposes port 4000

**Python AI** (`backend-ai/Dockerfile`):
- Python 3.12 slim image
- Installs pip dependencies
- Exposes port 8000

**Docker Compose** (`backend/docker-compose.yml`):
```yaml
services:
  finovault-api:   # Node.js API (port 4000)
  redis:           # Redis 7 Alpine (port 6379, with volume)
```

### 11.2 Render Deployment (`render.yaml`)

Two web services:
1. **finovault-api** (Node):
   - Build: `npm install && npm run build`
   - Start: `npm start`
   - Health: `/api/v1/health`

2. **finovault-ai** (Python):
   - Build: `pip install -r requirements.txt`
   - Start: `uvicorn app.main:app --host 0.0.0.0 --port 8000`
   - Health: `/health`

### 11.3 Environment Variables

**Backend (.env)**:
- `PORT` — Server port (4000)
- `NODE_ENV` — Environment mode
- `SUPABASE_URL` — Supabase project URL
- `SUPABASE_SERVICE_KEY` — Service role key (bypasses RLS)
- `SUPABASE_JWT_SECRET` — JWT signing secret
- `PYTHON_AI_URL` — Python service URL (http://localhost:8000)
- `REDIS_URL` — Redis connection string
- `CORS_ORIGIN` — Allowed origins
- `LOG_LEVEL` — Winston log level

**Python AI (.env)**:
- `SUPABASE_URL` — Direct PostgreSQL connection string
- `SUPABASE_SERVICE_KEY` — Service role key
- `OPENROUTER_API_KEY` — LLM API key (configured but not yet used)
- `REDIS_URL` — Redis connection string
- `LOG_LEVEL` — Logging level

**Frontend (.env.example)**:
- `EXPO_PUBLIC_API_URL` — Backend API URL for Expo client

---

## 12. Current State & Working Features

### 12.1 Git Commit History

```
7b32cb8 Fix Metro resolver for @/ path alias
f71b660 Add backend API (Express+TS) + Python AI service + frontend migration
566bdb6 fix: apply user metadata after OTP verification + add email alert
8ce6b9c fix: add rate-limit cooldown timer for OTP and signup buttons
bf69c2a fix: dashboard null crash + switch signup to OTP email flow
e1e7ddd Initial commit
```

### 12.2 🟢 Working Features

| Feature | Status | Notes |
|---------|--------|-------|
| Welcome Tour Carousel | ✅ Working | Animated with auto-advance, swipe support |
| Preferences (Role + Goals) | ✅ Working | Role selection, goal toggles, notification switches |
| Email/Password Signup | ✅ Working | OTP-based flow with email verification |
| OTP Verification Screen | ✅ Working | 6-digit input with auto-focus, 60s resend cooldown |
| User Login | ✅ Working | Email/password with JWT session |
| Rate Limiting Cooldown | ✅ Working | 60s timer on 429 error for OTP and signup |
| Session Management | ✅ Working | JWT verification, silent refresh |
| Individual Dashboard | ✅ Working | Net worth, spending, allocations, transactions |
| Wealth Growth Portfolio | ✅ Working | Forecast chart, allocation donut, market insights, Risk Shield |
| Smart Savings | ✅ Working | Rainy Day Fund, round-ups, AI suggestion |
| Fraud Protection | ✅ Working | Security score, event feed, encryption info |
| SME Dashboard | ✅ Working | Cash flow, payroll, vendors, growth pulse |
| SME Analytics | ✅ Working | Forensics, benchmarking, vendor table |
| Freelancer Dashboard | ✅ Working | Tax tracking, income, invoices, projects |
| Entrepreneur Dashboard | ✅ Working | MRR, funding, network, portfolio |
| Profile Page | ✅ Working | Personal info, plan, security, linked accounts |
| Logout | ✅ Working | Clears session and redirects |
| Auth Guard on Tabs | ✅ Working | Redirects to welcome tour if not authenticated |
| Backend Health Check | ✅ Working | DB ping + uptime + response time |
| Backend Auth (all endpoints) | ✅ Working | JWT verification for protected routes |
| Request Validation (Zod) | ✅ Working | Body/query/params validation |
| Error Handling | ✅ Working | Structured error responses, global handler |
| Rate Limiting | ✅ Working | Standard (100/15min), Auth (10/15min), AI (30/min) |
| Lazy Data Loading | ✅ Working | Zustand stores fetch on mount |
| Mock Data Fallback | ✅ Working | Every dashboard falls back to realistic demo data |
| Background Job Queues (Bull) | ✅ Working | Defined with Redis, processors implemented |
| Pattern Recognition Algorithms | ✅ Working | Both Node.js (service) and Python (service) implementations |
| Fraud Detection (rule-based) | ✅ Working | Node.js service with risk scoring |
| Fraud Detection (ML) | ✅ Working | Python service with Isolation Forest |
| Database Migrations | ✅ Working | 3 SQL migrations (init + fix + AI features) |
| Docker Setup | ✅ Working | Compose for API + Redis |
| Render Deployment Config | ✅ Working | YAML for both services |
| Multi-platform (iOS/Android/Web) | ✅ Working | Expo with platform-specific components |
| Light/Dark Mode | ✅ Working | Theme-aware components |
| Custom Tab Bar | ✅ Working | Bottom navigation with active states |
| Animated Splash Screen | ✅ Working | Elastic animation with keyframes |

### 12.3 🟡 Partially Working / In Progress

| Feature | Status | Details |
|---------|--------|---------|
| Google OAuth | 🟡 Partial | Backend endpoint exists; frontend has button but token flow untested |
| Apple OAuth | 🟡 Partial | Button exists but not wired to backend |
| Financial Profile / Interview | 🟡 Partial | Backend CRUD exists; frontend form not yet built |
| AI Coach Conversation | 🟡 Partial | Backend + Python service answer; frontend chat UI not yet built |
| Morning Briefing | 🟡 Partial | Backend generates; frontend display not yet built |
| Real-time Notifications | 🟡 Partial | Backend `notifications` table + service exist; push not configured |
| Link Bank Account | 🟡 Partial | Backend API exists; frontend UI button exists but UX incomplete |
| Transaction CRUD in Frontend | 🟡 Partial | Backend full CRUD; frontend doesn't have create/edit forms yet |
| Dynamic Nav for Role-based Dashes | 🟡 Partial | Roles are stored but tabs don't dynamically switch per role |

### 12.4 🔴 Not Yet Built

| Feature | Status | Notes |
|---------|--------|-------|
| Scam Database Integration | 🔴 Not built | Table exists, no service implementation |
| Business Health Snapshots (daily) | 🔴 Not built | Table exists, generation not implemented |
| LLM Integration (OpenRouter) | 🔴 Not built | API key configured but not used — coach is rule-based |
| Push Notifications (FCM/APNs) | 🔴 Not built | Table exists, no push integration |
| Supabase Client-side Usage | 🔴 Bypassed | Client `supabase.ts` returns null; all DB via backend API |
| Tests (Python) | 🔴 Empty | `tests/` directory is empty |
| Full Test Suite (Backend) | 🔴 Not built | Jest configured, tests minimal |

---

## 13. Known Issues & Solutions

### 13.1 Issues Encountered During Development

**Issue 1: Dashboard Null Crash**
- **Commit**: `bf69c2a`
- **Symptom**: Screens crashed when API returned null for dashboard data
- **Root Cause**: Components tried to access properties on null objects
- **Solution**: 
  - Backend: Each dashboard service method now returns mock/fallback data when queries return empty
  - Frontend: Added `|| {}` / `|| []` fallbacks and conditional rendering
  - Example (Individual Dashboard): `const data = summary || { total_net_worth: 1284500.42, ... }`

**Issue 2: OTP Rate Limiting Without User Feedback**
- **Commit**: `8ce6b9c`
- **Symptom**: Users were rate-limited during signup/OTP but received no visual feedback
- **Root Cause**: Backend returned 429 but frontend didn't handle it gracefully
- **Solution**: Added 60-second cooldown timer on both signup and OTP resend buttons:
  - When 429/rate-limit error is detected, `setCooldown(60)` 
  - Button shows "Wait 60s" with countdown
  - Disabled state until timer expires

**Issue 3: User Metadata Not Applied After OTP**
- **Commit**: `566bdb6`
- **Symptom**: User's full name and phone weren't saved when using OTP flow
- **Root Cause**: `verifyOtp` in the backend didn't update user metadata after verification
- **Solution**: Added `supabase.auth.admin.updateUserById()` call after OTP verification to set `user_metadata` with full_name and phone

**Issue 4: Metro Resolver Failed for `@/` Path Alias**
- **Commit**: `7b32cb8`
- **Symptom**: Metro bundler couldn't resolve `@/` imports during development
- **Root Cause**: Metro config didn't have the `@/` path alias mapped
- **Solution**: Fixed `metro.config.js` to properly resolve `@/ → ./src/`

**Issue 5: RLS Policy Conflicts**
- **Migration**: `002_fix_rls.sql`
- **Symptom**: After initial migration, profile creation on signup failed due to RLS
- **Root Cause**: The `handle_new_user()` trigger inserted into `profiles` which was RLS-protected, and the trigger ran as the user (not SECURITY DEFINER context)
- **Solution**: 
  - Changed trigger function to `SECURITY DEFINER`
  - Added `ON CONFLICT DO NOTHING` to prevent duplicate errors
  - Added `GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated` for client access

**Issue 6: Python AI Service Not Connected to Backend**
- **Symptom**: Backend has `PYTHON_AI_URL` env var but doesn't forward requests to it
- **Root Cause**: The Node.js backend and Python AI service were developed independently
- **Current State**: Both services implement their own versions of:
  - Pattern recognition (duplicated logic in Node + Python)
  - Fraud detection (Node is rule-based, Python adds Isolation Forest)
  - Business advice (both implement keyword-based responses)
- **Impact**: The duplicate code means maintenance burden; Python's ML capabilities are underutilized

---

## 14. Design Assets & Prototypes

The `stitch_finovault_ai_onboarding_flow/` and `design_ui/` directories contain HTML/CSS prototypes for every screen:

| Screen | Design File | Status |
|--------|-------------|--------|
| Welcome Tour | `welcome_tour_finovault_ai/code.html` | Implemented |
| Signup | `signup_finovault_ai/code.html` | Implemented |
| Verification | `verification_finovault_ai/code.html` | Implemented |
| Preferences | `preferences_finovault_ai/code.html` | Implemented |
| Individual Dashboard | `individual_dashboard_finovault_ai/code.html` | Implemented |
| Wealth Growth | `wealth_growth_finovault_ai/code.html` | Implemented |
| Smart Savings | `smart_savings_finovault_ai/code.html` | Implemented |
| Fraud Protection | `fraud_protection_finovault_ai/code.html` | Implemented |
| SME Dashboard | `sme_dashboard_finovault_ai/code.html` | Implemented |
| SME Analytics | `sme_analytics_finovault_ai/code.html` | Implemented |
| Freelancer Dashboard | `freelancer_dashboard_finovault_ai/code.html` | Implemented |
| Entrepreneur Dashboard | `entrepreneur_dashboard_finovault_ai/code.html` | Implemented |
| Profile | `profile_finovault_ai/code.html` | Implemented |

A comprehensive `DESIGN.md` is at `stitch_finovault_ai_onboarding_flow/finovault_ai/DESIGN.md`.

---

## Appendix A: Key Dependencies

### Frontend (package.json)
- `expo@~56.0.12` — Core Expo SDK
- `expo-router@~56.2.9` — File-based routing
- `nativewind@^4.2.5` — Tailwind CSS for React Native
- `@gluestack-ui/themed@^1.1.73` — UI component library
- `zustand@^5.0.14` — State management
- `react-native-reanimated@4.3.1` — Animations
- `react-hook-form@^7.80.0` — Form handling
- `zod@^4.4.3` — Schema validation
- `@supabase/supabase-js@^2.108.2` — Supabase client

### Backend (backend/package.json)
- `express@^4.21.1` — Web framework
- `@supabase/supabase-js@^2.108.2` — Supabase admin client
- `bull@^4.12.9` — Queue management
- `ioredis@^5.4.1` — Redis client
- `winston@^3.17.0` — Logging
- `zod@^3.24.1` — Validation
- `jsonwebtoken@^9.0.2` — JWT handling
- `helmet@^8.0.0` — Security headers
- `express-rate-limit@^7.4.1` — Rate limiting

### Python AI (backend-ai/requirements.txt)
- `fastapi==0.115.6` — Web framework
- `scikit-learn==1.6.0` — ML (Isolation Forest)
- `pandas==2.2.3` — Data manipulation
- `numpy==2.2.0` — Numerical computing
- `openai==1.58.1` — LLM client (configured, not active)
- `supabase==2.6.0` — Supabase client

---

## Appendix B: Environment Setup

```bash
# 1. Clone and install frontend
cd Finovault
npm install

# 2. Clone and install backend
cd backend
npm install

# 3. Clone and install Python AI
cd backend-ai
pip install -r requirements.txt

# 4. Start Redis (required for queues)
docker run -d -p 6379:6379 redis:7-alpine

# 5. Start backend API
cd backend
npm run dev  # runs on port 4000

# 6. Start Python AI
cd backend-ai
uvicorn app.main:app --reload --port 8000

# 7. Start frontend
cd Finovault
npx expo start  # opens dev server
```

---

*Document generated from full codebase analysis — covers all 3 services (Node.js backend, Python AI engine, React Native frontend), 22 database tables, 55+ API endpoints, ML algorithms, background job system, and deployment configuration.*
