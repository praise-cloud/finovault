# Finovault AI — Complete System Thesis Documentation

> **Authoritative Technical Reference**  
> **Version 1.0.0 — June 2026**  
> **Audience:** Senior Engineers, Architects, Technical Leads  
> **Scope:** Full-system architecture, implementation details, algorithmic foundations, data flow analysis, deployment topology, and operational considerations.

---

## Table of Contents

1. [Executive System Overview](#1-executive-system-overview)
2. [Architectural Philosophy & Design Decisions](#2-architectural-philosophy)
3. [Frontend Architecture in Depth](#3-frontend-architecture)
4. [Backend API Architecture in Depth](#4-backend-api-architecture)
5. [Python AI Engine Architecture](#5-python-ai-engine)
6. [Database Design & Data Flow](#6-database-design)
7. [Authentication & Authorization System](#7-authentication-system)
8. [Feature Implementation Analysis](#8-feature-implementation)
9. [AI/ML Algorithmic Foundations](#9-algorithmic-foundations)
10. [Background Job System](#10-background-job-system)
11. [Infrastructure & Deployment Topology](#11-infrastructure-deployment)
12. [Security Architecture](#12-security-architecture)
13. [Performance Considerations](#13-performance-considerations)
14. [Known Issues, Resolutions & Architectural Debt](#14-issues-and-debt)
15. [Future Architecture Roadmap](#15-future-roadmap)

---

## 1. Executive System Overview

Finovault AI is a multi-tenant, cross-platform financial intelligence platform that delivers personalized wealth management, business analytics, fraud detection, and financial coaching through a unified AI-powered interface. The system serves four distinct user personas—**individual investors**, **SME owners**, **entrepreneurs** (with specific accommodations for female founders), and **freelancers**—each receiving a tailored dashboard experience that adapts to their financial profile and goals.

The application follows a **three-tier microservices architecture** with a React Native (Expo) frontend serving iOS, Android, and Web platforms from a single codebase; a Node.js/Express backend API acting as the primary orchestration layer and data gateway; and a Python FastAPI service dedicated to machine learning inference and AI agent logic. Data persistence is handled by **Supabase**, a Firebase-like platform built atop PostgreSQL that provides managed authentication, Row-Level Security (RLS), real-time subscriptions, and a RESTful API interface. Background job processing is managed through **Bull** (a Redis-backed queue library) for asynchronous tasks such as daily briefing generation and pattern learning.

A distinguishing architectural characteristic of Finovault is its **defensive fallback strategy**: every dashboard endpoint is designed to return realistic mock data when database queries return empty results. This allows the application to function as a fully interactive demo without requiring seeded data, while simultaneously providing a production-ready path when real data becomes available. This dual-mode operation is not a temporary scaffolding measure but a deliberate architectural pattern that enables rapid onboarding, testing, and presentation scenarios without compromising the production data model.

The system is deployed via **Render** using Docker containers, with Redis as a critical infrastructure dependency for both queue management and potential caching operations. The Python AI service is containerized separately and communicates with the Node.js API over HTTP, though as of this writing the integration between the two services is incomplete, with both services independently implementing overlapping functionality.

---

## 2. Architectural Philosophy & Design Decisions

### 2.1 Separation of Concerns: Three-Tier Architecture

The decision to split the system into three distinct services—frontend, API, and AI engine—was driven by several engineering considerations:

First, the Node.js/Express layer serves as an **API gateway and orchestration layer**. It handles authentication, request validation, rate limiting, data aggregation, and business logic that does not require machine learning. This creates a clear boundary where the Express API owns the data domain (transactions, users, savings goals) while the Python service owns the inference domain (fraud scoring, pattern detection, natural language coaching).

Second, Python was chosen for the AI service because the scikit-learn library provides production-tested implementations of Isolation Forest and other ML algorithms that lack mature equivalents in the Node.js ecosystem. While Node.js has ML libraries (TensorFlow.js, brain.js), the scikit-learn Isolation Forest implementation is battle-tested in production environments and benefits from extensive optimization in C-based underlying implementations (NumPy, Cython).

Third, the frontend is deliberately **thin**—it performs no business logic beyond form validation and local state management. All data processing, aggregation, and security enforcement occurs server-side. This decision was made to ensure that the system's security model (RLS, JWT verification, rate limiting) remains intact regardless of the client platform and to enable future client implementations (e.g., a web-only PWA or third-party API consumers) without duplicating business logic.

### 2.2 Supabase as the Backend Platform

Supabase was selected over alternatives (Firebase, custom PostgreSQL, Prisma + direct DB) for several strategic reasons:

The **managed authentication** system eliminates the need to build and maintain a custom auth service. Supabase Auth provides email/password, OTP, OAuth (Google, Apple), and JWT session management out of the box, with PostgreSQL-backed user storage that integrates directly with the application's data model. The `auth.users` table is automatically linked to the application's `profiles` table through a database trigger (`handle_new_user`), ensuring referential integrity without application-level orchestration.

The **Row-Level Security** model allows the backend API (using the service role key) to bypass RLS for administrative operations while still maintaining the security model for any potential direct client-to-database access. This is a significant advantage over Firebase's security rules model, as RLS is enforced at the database engine level and cannot be bypassed by client modifications.

The **PostgreSQL foundation** means the system benefits from a mature, battle-tested relational database with support for JSONB (used for `metadata`, `context`, `action_items` columns), array types (used for `financial_goals[]`, `money_fears[]`), full-text search, and advanced indexing. The `UNIQUE(user_id, pattern_type, pattern_name)` constraint on `behavior_patterns` is an example of leveraging PostgreSQL's multi-column unique constraints to implement an upsert-based pattern storage strategy.

### 2.3 Mock Data Fallback Strategy

One of the most distinctive architectural decisions in Finovault is the deliberate implementation of **hardcoded fallback data** in every dashboard service method. When `dashboard.service.ts` queries Supabase and receives an empty result set (which is the default state for new users), it returns realistic demo data such as:

```
total_net_worth: 1284500.42,
net_worth_change: 42000,
monthly_spending: 8420,
```

This approach was chosen over seeding the database for several reasons:

First, it eliminates the need for a complex seed data pipeline that must be maintained across schema migrations. Every time the data model changes, seed scripts must be updated—a maintenance burden that grows with schema complexity.

Second, it enables **zero-configuration onboarding**. A new user can create an account, complete onboarding, and immediately see a fully populated dashboard without waiting for data aggregation or pattern learning to complete.

Third, the fallback data serves as a **contract for frontend development**. The TypeScript types defined in `supabase-types.ts` are guaranteed to match the shape of the fallback data, so frontend components can be developed and tested against realistic data shapes without a running backend.

The trade-off is that **test coverage must account for both code paths**: the real-data path and the fallback path. Integration tests that verify data aggregation logic must seed the database first, while frontend tests can rely on the fallback data being returned.

### 2.4 In-Memory Token Storage

The decision to store JWT tokens **exclusively in memory** (rather than in AsyncStorage or SecureStore) was a deliberate trade-off between security and UX persistence:

Security argument: In-memory tokens cannot be extracted via file-system access attacks, SQL injection on local storage, or clipboard scraping. On mobile devices, AsyncStorage is backed by SQLite on Android and NSUserDefaults on iOS—both of which are accessible through backup mechanisms and debug tools.

UX argument: The user must re-authenticate after app restart. For a financial application, this is considered an acceptable trade-off (similar to banking apps that require re-login on cold start). The session refresh endpoint (`POST /auth/refresh`) enables extending the session without full re-authentication if the refresh token is available.

The implementation in `auth-store.ts` stores tokens in a Zustand state variable, which is ephemeral. On app initialization, `initialize()` attempts to verify any existing token by calling the backend's session verification endpoint—but since no token persists across restarts, this always fails and the user sees the welcome tour.

### 2.5 HTTP Client Architecture

The custom `ApiClient` class in `client.ts` wraps the Fetch API with automatic token injection, JSON serialization, and error handling. The architecture is intentionally simple:

```typescript
class ApiClient {
  private async request<T>(endpoint: string, options: FetchOptions): Promise<T> {
    // 1. Construct URL with query parameters
    // 2. Add Authorization header if token exists
    // 3. Execute fetch
    // 4. Parse JSON response
    // 5. Throw on non-OK responses
    // 6. Return json.data
  }
}
```

The token is managed through module-level variables (`_token`, `_baseUrl`) rather than through React context or Zustand to avoid coupling the API layer to any particular state management solution. The `setApiToken()` and `getApiToken()` functions are imported by the auth store and API client independently, creating a **token authority pattern** where the auth store is the single source of truth for token state but the API client reads it directly without going through React's render cycle.

---

## 3. Frontend Architecture in Depth

### 3.1 Expo Router & File-Based Routing

The frontend uses **Expo Router v4** (powered by React Navigation under the hood) with a file-based routing convention. Every `.tsx` file in `src/app/` automatically becomes a route. The `(tabs)/` directory group creates a tab navigator, while files at the root level (`login.tsx`, `signup.tsx`, etc.) are stack screens.

The `_layout.tsx` at each level defines the navigation container. The root layout (`src/app/_layout.tsx`) sets up a `<Stack>` with all screens registered, loads custom fonts, initializes the auth store, and renders the animated splash overlay. The entire app is wrapped in `FinovaultProvider` (the gluestack-ui theme provider), ensuring consistent theming across all components.

The tabs layout (`src/app/(tabs)/_layout.tsx`) implements an **auth guard**: if `isAuthenticated` is false, it redirects to the welcome tour. It also renders the custom `BottomTabBar` for mobile navigation with three tabs: Dashboard, Protection, and Profile.

### 3.2 Component Architecture & Theming

The component layer is built on three foundational abstractions:

**Themed Components** (`themed-text.tsx`, `themed-view.tsx`): These accept a `themeColor` prop (typed as `ThemeColor`, a union of keys from the `Colors` object) and look up the corresponding color value from the current theme (light or dark). The theme is determined by the `useTheme()` hook, which reads from `useColorScheme()` and returns the appropriate `Colors` palette. This creates a **type-safe theming system** where invalid color keys are caught at compile time.

**Styled Components with NativeWind**: The majority of components use NativeWind utility classes (e.g., `bg-surface-container-lowest`, `text-primary`, `rounded-xl`). These classes map to the gluestack-ui design token system, which defines semantic color roles rather than literal colors. Changing the theme in `gluestack-provider.tsx` propagates to every component that uses NativeWind tokens.

**Animated Components**: The `BentoCard` component uses `react-native-reanimated` shared values and animated styles with spring physics (`withSpring`) to create press-feedback animations. The `ProgressBar` uses `withTiming` for smooth fill animations. The `AnimatedIcon` component implements a **keyframe-based splash animation** that scales the logo from screen-center to its final position with elastic easing.

### 3.3 State Management: Zustand Stores

The application uses three Zustand stores, each with a distinct responsibility:

**auth-store.ts** manages authentication state and the OTP flow. During signup, when the user submits the registration form, the store stores `pendingPassword` and `pendingUserData` in memory. When the user later verifies their OTP, the store combines the OTP token with the pending data to complete registration. This is necessary because the OTP flow requires two API calls (send OTP + verify OTP) with data from the first call needing to be available during the second.

**dashboard-store.ts** provides lazy-loading for all dashboard data types. Each persona dashboard screen calls its respective `load*` method in a `useEffect`, which triggers an API call and stores the result. Data is fetched on-demand rather than eagerly loaded at app startup, reducing initial load time and bandwidth.

**preferences-store.ts** manages onboarding preferences and synchronizes them with the backend via `savePreferences()`. The role selection and financial goals are stored here and persisted when the user completes onboarding.

### 3.4 Screen Implementation Patterns

Each dashboard screen follows a consistent implementation pattern:

1. **Data Injection**: The component imports `useDashboardStore` and selects the relevant data slice
2. **Side Effect**: A `useEffect` calls the store's `load*` method
3. **Loading State**: If data is null and loading is true, an `ActivityIndicator` is shown
4. **Fallback Data**: The store's data is used if available; otherwise, inline mock data serves as fallback
5. **Rendering**: The component renders using a hierarchy of NativeWind-classed Views, Texts, and interactive elements

The Wealth Growth screen (`wealth-growth.tsx`) is representative of the more complex implementations. The **Performance Forecast Chart** is a series of colored bars rendered as percentage-height `<View>` elements within a flex container. The bars are capped at 100% height and colored differently based on index (past vs projected periods). The **Asset Allocation Donut** is implemented using `react-native-svg` with multiple `<Circle>` elements with calculated `strokeDasharray` and `strokeDashoffset` values to create segments. The **Market Insights** section maps over `market_insights` data with badge colors and typography. The **Risk Shield** card is a dark-themed card with an overlay color scheme, showing AI-detected portfolio optimization suggestions with an action button.

The SVG-based circular progress indicators (used in Fraud Protection, SME Dashboard, and Wealth Growth) calculate their arc lengths using the formula: circumference = 2 * pi * radius, with the visible arc length being circumference * (progress / 100), and the strokeDashoffset calculated as circumference minus the visible arc length.

### 3.5 Platform-Specific Code

The application uses Expo's platform-specific file resolution to provide different implementations for native and web:

- `animated-icon.tsx` (native) vs `animated-icon.web.tsx` (web) — The native version uses `scheduleOnRN` from `react-native-worklets` for callback scheduling, while the web version uses CSS modules for background styling.
- `app-tabs.tsx` (native) vs `app-tabs.web.tsx` (web) — Different implementations for native and web tab styling.
- `use-color-scheme.ts` (native) vs `use-color-scheme.web.ts` (web) — Different implementations for detecting color scheme preference.

---

## 4. Backend API Architecture in Depth

### 4.1 Application Bootstrap & Server Lifecycle

The backend entry point (`index.ts`) creates an Express app and starts listening on the configured port. The server lifecycle includes graceful shutdown on `SIGTERM`/`SIGINT` (calls `server.close()`, waits 10 seconds max, then exits). Unhandled rejections are logged (non-fatal), while uncaught exceptions trigger process exit with code 1 since the process may be in an inconsistent state.

### 4.2 Middleware Stack (Order Matters)

The middleware stack in `app.ts` is ordered deliberately:

1. **helmet()** — Sets security-related HTTP headers (CSP, X-Frame-Options, HSTS). Must be first to ensure all responses have security headers.
2. **cors()** — Configures CORS. In production, restricts to specific origins; in development, allows all origins.
3. **express.json({ limit: '10mb' })** — Parses JSON bodies with a 10MB limit.
4. **express.urlencoded({ extended: true })** — Parses URL-encoded bodies.
5. **standardRateLimit** — 100 requests per 15-minute window globally.
6. **Router** — Delegates to route-specific handlers.
7. **errorHandler** — Catches all errors thrown from routes/middleware above.

### 4.3 Route Registration & Module Organization

Routes are organized by domain in separate files and aggregated in `routes/index.ts`. Each route file follows a consistent pattern: create a Router, optionally apply authentication middleware, optionally apply validation middleware, and wire up controller methods with async error wrapping.

### 4.4 Controller Layer (Thin Delegation)

Controllers are intentionally thin—they extract request parameters, call the appropriate service method, and format the response via `sendSuccess()`. This separation ensures that controllers can be tested with mocked services, services can be tested without HTTP context, and if the API framework changes, only controllers need modification.

### 4.5 Service Layer (Business Logic)

Services contain all business logic and database interactions. A key pattern is **parallel data fetching** using `Promise.all` to minimize latency. Dashboard endpoints that aggregate data from 3-5 tables would suffer 300-800ms of latency per query without parallel fetching, making dashboards unacceptably slow.

The **fallback data pattern** is implemented as conditional logic after each query:

```typescript
const transactions = txRes.data || [];
return {
  total_net_worth: totalNetWorth || 1284500.42,  // Fallback when DB has no data
};
```

### 4.6 Supabase Client Architecture

The Supabase client is managed through a **singleton factory pattern** in `config/supabase.ts`:

```typescript
let _supabase: SupabaseClient | null = null;

export function getSupabase(): SupabaseClient {
  if (!_supabase) {
    _supabase = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_KEY, {
      auth: { autoRefreshToken: false, persistSession: false },
    });
  }
  return _supabase;
}
```

The service role key bypasses all RLS policies—this is intentional since the backend API is the sole authorized database consumer, implementing its own authorization through JWT middleware. The `autoRefreshToken: false` and `persistSession: false` options are critical for a server-side client that doesn't represent any user session.

### 4.7 Error Handling Architecture

The custom error hierarchy (`AppError` base class with `isOperational` flag) implements the **operational vs programmer error** distinction:

- **Operational errors** (expected runtime failures like invalid input, missing resources): Return structured error responses with appropriate HTTP status codes, logged at `warn` level.
- **Programmer errors** (unexpected failures like null pointer exceptions): Logged at `error` level with full stack traces. Generic message returned to client to avoid leaking implementation details.

### 4.8 Request Validation Pipeline

Zod schemas are defined in the `models/` directory and applied through the `validate()` middleware. The middleware supports validating three parts of the request: `body`, `query`, and `params`. When validation fails, a `ZodError` is caught and transformed into a `ValidationError` (HTTP 400). The middleware also supports transformation—Zod's `.parse()` method both validates and transforms data, and the transformed values are written back to `req.body`/`req.query`/`req.params` for downstream use.

---

## 5. Python AI Engine Architecture

### 5.1 Service Design & Lifecycle

The Python AI service (`backend-ai/app/main.py`) is a FastAPI application running independently on port 8000. FastAPI was chosen over Flask for its **automatic OpenAPI documentation**, **Pydantic-based request/response validation** (mirroring Zod in the Node.js service), and **asyncio-native request handling** for concurrent request processing.

The service routes are organized by domain with explicit prefixes: `/fraud/check`, `/coach/ask`, `/patterns/analyze`, `/business/advise`, and a health endpoint at `/health`.

### 5.2 Supabase Integration

The Python service connects to the same Supabase project using the service role key via a singleton factory pattern identical to the Node.js implementation. The Python client uses `supabase-py`, which provides a Pythonic API for querying Supabase tables, executing stored procedures, and managing auth.

### 5.3 OpenAI/LLM Integration (Configured, Not Active)

The `.env` file contains `OPENROUTER_API_KEY=your_openrouter_api_key`, indicating that LLM integration was planned but not yet implemented. OpenRouter was chosen as the provider because it provides a unified API for multiple models (GPT-4, Claude, Gemini, Llama) with a single API key, allowing the application to switch models without code changes. The current financial coach and business advisor are rule-based, not LLM-powered.

### 5.4 Asynchronous Request Handling

All service methods in the Python AI engine are implemented as `async def` and use `await` for Supabase queries. However, scikit-learn operations (`IsolationForest.fit()`, `predict()`) are CPU-bound and will block the asyncio event loop regardless of the async wrapper. For production, these operations should be offloaded to a thread pool via `asyncio.to_thread()` or executed in a separate worker process via Celery (already in `requirements.txt`).

---

## 6. Database Design & Data Flow

### 6.1 Schema Architecture & Table Relationships

The database is **PostgreSQL 15** managed through Supabase, with **22 tables** organized into functional domains:

**User Domain:**
- `profiles` — Central user record, linked to `auth.users` via a trigger
- `user_preferences` — Onboarding preferences (role, goals, fears, risk tolerance)

**Financial Domain:**
- `transactions` — All financial transactions with categorization
- `accounts` — Bank/investment accounts linked to users
- `budgets` — Monthly/periodic budget allocations
- `savings_goals` — Target-based savings with progress tracking
- `investments` — Portfolio holdings
- `bills` — Recurring bill obligations
- `loans` — Active loan records

**Analytics Domain:**
- `business_analytics` — SME-specific KPIs (revenue, CAC, runway, team, operational costs)
- `cashflow_forecasts` — Time-series cashflow predictions
- `spending_patterns` — Monthly spending analysis by category
- `fraud_alerts` — Detected fraud/security incidents
- `behavior_patterns` — Learned behavioral traits from transaction analysis

**AI/ML Domain:**
- `ai_coach_messages` — Coaching conversation history
- `pattern_learning_jobs` — Background job tracking for pattern analysis

**Content Domain:**
- `daily_briefings` — Generated daily summaries for users
- `business_insights` — Actionable business recommendations
- `market_insights` — External market data and trend analysis
- `content_recommendations` — Personalized article/video suggestions
- `onboarding_content` — Content served during user onboarding
- `learning_paths` — Educational progress tracking

### 6.2 Key Schema Patterns

**JSONB for Flexible Metadata:** Several tables use PostgreSQL's JSONB column type for extensible data:
- `transactions.metadata` — Merchant data, location, receipt URLs
- `ai_coach_messages.context` — Arbitrary context for coaching sessions
- `ai_coach_messages.action_items` — Extracted action items from conversations
- `user_preferences.financial_goals[]` — Array of goal strings
- `user_preferences.money_fears[]` — Array of fear/concern strings

**Array Types for Preferences:** The `user_preferences` table uses PostgreSQL array columns (`TEXT[]`) for multi-value preferences, avoiding a separate junction table. This is appropriate because the array is always loaded atomically—there's no query pattern that needs to index individual goals or fears.

**Explicit Constraint Naming:** All foreign key constraints are explicitly named (e.g., `fk_transactions_user`, `fk_budgets_user`) following a `fk_{child}_{parent}` convention, improving error readability and migration management.

### 6.3 Data Flow: Onboarding to Dashboard

1. User signs up → `auth.users` created → `handle_new_user()` trigger inserts row into `profiles`
2. User completes onboarding → `profiles` updated with name, `user_preferences` inserted with role/goals
3. Dashboard loads → if `transactions` table empty for user, fallback mock data returned
4. URL scheme detection → if user signed up via a deep link with `scheme=female_founder`, `profile.scheme` set accordingly

### 6.4 Data Flow: Transaction Processing Pipeline

1. Transactions ingested (via CSV import or Plaid integration, depending on implementation) → stored in `transactions` table
2. Background job triggers fraud detection → Python AI service runs `IsolationForest` on transaction features
3. Results stored in `fraud_alerts` table linked to original transactions
4. Background job triggers pattern learning → behavior patterns computed and stored in `behavior_patterns` table
5. User requests dashboard → dashboard queries aggregate data from all financial tables, joins behavior patterns, formats response

### 6.5 The behavior_patterns Table

The `behavior_patterns` table is the key output of the ML pipeline. It stores per-user learned patterns:
- `user_id` — FK to profiles
- `pattern_type` — Category: `momentum_pricing`, `emotional`, `personality`, `spending_behavior`
- `pattern_name` — Specific pattern: `loss_aversion`, `mental_accounting`
- `score` — Numeric score 0-100
- `metadata` — JSONB with detailed diagnostics
- `detected_at` — Timestamp of detection
- Unique constraint on `(user_id, pattern_type, pattern_name)` enables upsert behavior

### 6.6 Migration Strategy

The schema is managed through typed SQL migration files in `backend/supabase/migrations/`. Each migration is a standalone SQL file with a timestamp prefix for ordering. The `supabase-types.ts` file is regenerated against the current schema. The migration workflow:

1. Developer writes SQL in a new migration file
2. Applies migration via Supabase CLI: `supabase db push`
3. Regenerates TypeScript types: `supabase gen types typescript --local > src/types/supabase-types.ts`
4. Updates service code to use new types

---

## 7. Authentication & Authorization System

### 7.1 Registration Flow

The registration flow (`POST /api/auth/register`) follows a two-step OTP process:

**Step 1 — Initiate Registration:** The client sends email, password, full name, and optional scheme and referral code. The server:
1. Checks if user exists (returns 409 if so)
2. Creates user in `auth.users` via Supabase Admin API
3. Generates a 6-digit OTP stored in-memory (no database storage)
4. In production: sends OTP via email using SendGrid
5. In development: returns OTP `sentAt` and OTP value in response for debugging

**Step 2 — Verify OTP:** The client sends email and OTP. The server:
1. Validates OTP against stored value (hashed comparison)
2. Clears OTP state
3. Calls Supabase Admin API to confirm user email
4. Returns JWT token and user profile

### 7.2 OTP Implementation

OTP generation uses `crypto.randomInt(100000, 999999)`. OTPs are stored in a `Map<string, { otp: string; expiresAt: number }>` in memory with 10-minute expiry. The OTP secret is stored as a SHA-256 hash (salted with the user's email) rather than in plaintext:

```typescript
const hash = crypto.createHash('sha256').update(`${email}:${otp}`).digest('hex');
```

This prevents timing attacks and ensures OTPs are not recoverable from memory in the event of a memory dump. The 10-minute expiry is enforced at verification time by comparing `Date.now()` against `expiresAt`.

### 7.3 JWT Session Management

Tokens are generated by Supabase Auth and returned to the client. The Supabase JWT payload contains:
- `sub` — `auth.users.id` (UUID)
- `email` — User email
- `aud` — `authenticated`
- `role` — `authenticated`
- `iat`/`exp` — Standard JWT timestamps

The backend middleware (`authenticateToken.ts`) validates the JWT by calling Supabase's `admin.getUserById()` with the decoded user ID. This is an in-memory lookup for Supabase (no database query), making it fast. If the user doesn't exist or is disabled, a 401 error is returned.

### 7.4 Onboarding & Scheme Detection

After authentication, the client calls `GET /api/users/me` to get the profile. If the profile is incomplete (missing full_name), the client redirects to the onboarding flow. The onboarding flow:
1. User selects role (individual, sme, entrepreneur, freelancer)
2. User selects financial goals
3. User completes risk assessment
4. Preferences saved via `POST /api/users/preferences`
5. User redirected to role-specific dashboard

The **URL scheme** is detected server-side during registration. When a user signs up through a link containing `?scheme=female_founder`, the scheme is stored in the profile and the user is shown the female-entrepreneur-specific feature set. This enables differentiated onboarding without separate user roles.

### 7.5 Password Validation

Client-side validation uses regex:
- Minimum 8 characters
- At least 1 uppercase letter
- At least 1 lowercase letter
- At least 1 number
- At least 1 special character

Server-side validates minimum length only (8 characters). The Zod schema for registration requires email + password + full_name.

---

## 8. Feature Implementation Analysis

### 8.1 Persona-Specific Dashboards

The system serves four user personas, each with a tailored dashboard:

**Individual Investor Dashboard:** Wealth overview with net worth tracking, asset allocation visualization, performance forecast chart, market insights cards, personalized content recommendations, and risk shield (AI-suggested portfolio optimizations).

**SME Owner Dashboard:** Revenue tracking, burn rate analysis, cash flow runway visualization, team cost breakdown, customer acquisition cost metrics, employee satisfaction index, and AI business advisor.

**Entrepreneur Dashboard:** Combined personal + business wealth tracking, revenue trends, market positioning, expense breakdown by category (incl. marketing/salary/R&D), and AI advisory. Female founder variant adds Women-Led Business Insights.

**Freelancer Dashboard:** Income tracking with platform breakdown, business expense categorization, invoice management, self-employment tax estimation, project-based savings goals, and AI coach.

### 8.2 Financial Coach

The AI Financial Coach (`POST /api/ai/coach`) accepts natural language questions and returns structured coaching responses. The implementation returns rule-based mock coaching responses for demo purposes:

```typescript
const mockResponses: Record<string, string> = {
  budget: "Based on your spending patterns, I recommend the 50/30/20 rule...",
  invest: "Given your risk profile and goals, a diversified portfolio...",
  debt: "Here's a debt snowball strategy tailored to your situation...",
  save: "To reach your savings goals faster, consider...",
  default: "That's a great financial question! Here's what I recommend..."
};
```

The response is enriched with personalized context (user's financial goals, risk tolerance, recent transactions) pulled from the database. The `/coach-user-proxy` endpoint acts as a proxy to the Python AI engine, which currently also returns mock data since the LLM integration is not yet active.

### 8.3 Plaid Integration (Planned)

The `POST /api/plaid/create-link-token` endpoint is a stub for Plaid Link token generation. In production, this would call the Plaid API to create a link token for account linking. The endpoint returns a mock `link_token` value `"link-sandbox-<uuid>"`. Full Plaid integration would enable:
- Real bank account linking via Plaid Link
- Automatic transaction import
- Account balance verification
- Identity verification

The schema includes the `accounts` table with a `plaid_account_id` column, which is null for manual accounts.

### 8.4 CSV Import (Planned)

The `POST /api/plaid/import-csv` endpoint accepts a CSV array of transactions and bulk-inserts them into the `transactions` table. The endpoint accepts a JSON array (not a file upload) with schema: `{ date: string, description: string, amount: number, category: string }`. This is a placeholder for the file-upload version that would parse CSV files client-side.

### 8.5 Daily Briefing Generation

The daily briefing service (`briefing.service.ts`) generates a personalized financial summary for each user. The generation logic:
1. Queries recent transactions
2. Queries budget status
3. Queries savings goal progress
4. Checks fraud alerts
5. Assembles structured data into DailyBriefingResponse

The response data is stored in the `daily_briefings` table for future retrieval. Currently, the briefing is generated on-demand when the user requests their dashboard. The background job system would handle generation at 6 AM daily.

### 8.6 Content Recommendation Engine

The content service (`content.service.ts`) provides personalized recommendations based on:
- User's financial role (individual, sme, etc.)
- Onboarding goals
- Recent transaction categories (e.g., if recent spending is high on dining, recommend budgeting content)
- Current month

Content is stored in the `onboarding_content` table with `id`, `title`, `description`, `type` (article/video/tip/guide), `category`, and `target_role` fields. The recommendation algorithm is a simple `status` filter (`active`) with optional `target_role` matching.

---

## 9. Algorithmic Foundations

### 9.1 Fraud Detection (Isolation Forest)

The fraud detection system uses **Isolation Forest**, an unsupervised anomaly detection algorithm that identifies outliers by isolating them instead of modeling normal behavior. The algorithm works as follows:

**Training Phase:** The algorithm builds a forest of random isolation trees. Each tree is built by:
1. Randomly selecting a feature from the feature vector
2. Randomly selecting a split value within the feature's range
3. Recursively partitioning the data until all points are isolated or max depth is reached

**Inference Phase:** For each transaction, the anomaly score is computed as the average path length across all trees. Shorter paths → more anomalous (easier to isolate).

The implementation in `fraud_service.py` defines these features per transaction:
- `amount_range` — Transaction amount (scaled)
- `hour` — Hour of day (0-23, scaled to 0-1)
- `day_of_week` — Day of week (0-6, scaled)
- `is_weekend` — Boolean (0/1)
- `is_night` — 1 if hour is 22-5, else 0
- `amount_to_income_ratio` — Amount / average daily income
- `merchant_frequency` — How many times this merchant was used in 30 days
- `amount_std_from_avg` — How many standard deviations from user's average
- `rapid_transaction_flag` — 1 if another transaction occurred within 5 minutes

The model is trained per-user (or globally for users with no history) with `contamination=0.1` (expect ~10% anomalies). The decision threshold for flagging is `score > 0.7`.

**Key Limitation:** The model must be retrained periodically to adapt to changing spending patterns. The `pattern_learning_jobs` table tracks when retraining last occurred. For new users with fewer than 10 transactions, the model falls back to rule-based heuristics.

### 9.2 Behavioral Finance Pattern Detection

The `behavioral_service.py` implements detection of cognitive biases in financial behavior:

**Loss Aversion Detection:** Compares frequency of selling winning investments vs losing investments. If `sell_winning_freq > 1.5 * sell_losing_freq`, loss aversion is flagged. Formula: `score = min(100, (sell_winning_freq / max(sell_losing_freq, 1) - 1) * 50)`.

**Mental Accounting Detection:** Analyzes spending across categories. If a user has X active saving goals AND spending in non-essential categories exceeds 30% of income, mental accounting (treating money differently based on its source/purpose) is flagged. Score: `min(100, active_goals * 15 + non_essential_ratio * 50)`.

**Herding Behavior Detection:** Correlates user's investment changes with market trends. Increased buying after market gains suggests herding. Score based on correlation coefficient scaled to 0-100.

**Overconfidence Detection:** Measures trading frequency vs returns. High trade frequency with below-average returns suggests overconfidence. Score: `min(100, trade_frequency_z_score * 30 + (1 - return_percentile) * 70)`.

**Momentum Pricing Sensitivity:** Analyzes sensitivity to price changes in momentum categories. A high score means the user is significantly influenced by market momentum.

These patterns are stored in `behavior_patterns` and used by the financial coach to provide personalized advice.

### 9.3 SME Business Analytics

The business analytics service (`business_analytics.py`) provides domain-specific metrics:

**Revenue Trend Analysis:** Compares current month revenue against previous months to determine trend direction and magnitude.

**Burn Rate Calculation:** Sums all expense transactions for the current month, divides by days in month to get daily burn, annualizes.

**Cash Flow Runway:** Cash on hand / monthly burn rate, expressed in months.

**CAC (Customer Acquisition Cost):** Total marketing spend / number of new customers. Uses mock customer count of 45, then available marketing transactions.

**Team Cost Efficiency:** Total team payroll / total revenue, giving a percentage-based efficiency metric.

**Employee Satisfaction Index:** Mock-based metric (85/100) that would integrate with HR tools in production.

### 9.4 Cashflow Forecasting

The cashflow forecast model (`cashflow_service.py`) generates 90-day projections. The algorithm:
1. Gathers historical transactions (last 90 days)
2. Computes running total for net cashflow
3. Computes daily average change
4. Projects forward for 90 days using the formula: `projected[t] = running_total[-1] + avg_daily_change * t + random_noise * t * 0.1`
5. Random noise (normal distribution, scaled by time) adds realism to projections

**Key Limitation:** This is a simple random-walk-with-drift model, not an ARIMA or LSTM. It does not account for seasonality, day-of-week effects, or known future events (e.g., tax day, quarterly rent).

---

## 10. Background Job System

### 10.1 Bull Queue Architecture

The background job system uses **Bull** (a Redis-backed job queue library for Node.js). Redis is required as the queue backend for three queues:

1. **email** — Sending emails (OTP, password reset, notifications)
2. **daily-briefing** — Generating daily financial summaries
3. **pattern-learning** — Analyzing transaction patterns and running ML models

### 10.2 Email Job Queue

The email queue (`email.queue.ts`) processes email sending jobs. Workers attempt delivery up to 3 times with exponential backoff (2^attempt * 2 seconds). Email jobs contain `to`, `subject`, and `body` fields. The processor calls a service that logs emails to console in development (avoiding SendGrid calls).

### 10.3 Daily Briefing Queue

The daily briefing queue (`briefing.queue.ts`) generates and emails daily briefings. The worker:
1. Queries all active user profiles
2. For each user, calls briefing service to generate daily summary
3. Stores result in `daily_briefings` table
4. Optionally sends via email queue
5. Uses concurrency of 5 (5 users processed in parallel)

The job is scheduled via `cron: '0 6 * * *'` (6 AM daily). In development, the repeat strategy is `'*/5 * * * *'` (every 5 minutes).

### 10.4 Pattern Learning Queue

The pattern learning queue (`pattern-learning.queue.ts`) processes behavioral analysis. The worker:
1. Calls the Python AI service's pattern analysis endpoint
2. Receives detected patterns
3. Upserts into `behavior_patterns` table
4. Updates `pattern_learning_jobs` with completion status

**Incomplete Integration:** The queue processor tries to connect to `http://localhost:8000/patterns/analyze` but if the Python service is not running, it falls back to inline mock patterns. The fallback generates patterns like `{ pattern_type: 'momentum_pricing', pattern_name: 'market_sensitivity', score: 75 }`.

### 10.5 Bull Queue Configuration

```typescript
const connection = { host: 'localhost', port: 6379 };
const defaultJobOptions = {
  attempts: 3,
  backoff: { type: 'exponential', delay: 2000 },
  removeOnComplete: 100,
  removeOnFail: 50,
};
```

The connection uses default Redis host/port. For production, this should point to the managed Redis instance. The `removeOnComplete: 100` and `removeOnFail: 50` settings retain job history for monitoring.

---

## 11. Infrastructure & Deployment Topology

### 11.1 Render Deployment

The application is configured for deployment on **Render** with three services:

**Backend API Service (Node.js):**
- Build Command: `cd backend && npm install && npm run build`
- Start Command: `cd backend && node dist/index.js`
- Health Check Path: `/api/health`
- Environment: Node 18+
- Port: 10000

**Python AI Service:**
- Build Command: `cd backend-ai && pip install -r requirements.txt`
- Start Command: `cd backend-ai && uvicorn app.main:app --host 0.0.0.0 --port 8000`
- Environment: Python 3.11+

**Frontend (React Native Web):**
- Build Command: `npm install && npx expo export --platform web`
- Publish Directory: `dist/`
- Environment: Node 18+

### 11.2 Docker Configuration

The Dockerfile (`Dockerfile`) uses a multi-stage build:
1. **Stage 1 (Build):** Installs dependencies, runs TypeScript compilation
2. **Stage 2 (Production):** Uses `node:18-slim`, copies only `dist/`, `node_modules/`, `package.json` from build stage, exposes port 10000

The `.dockerignore` excludes `node_modules/`, `dist/`, `.env`, and `src/` from the Docker build context.

### 11.3 Redis Dependency

Redis is listed as a dependency in `render.yaml`. The backend connects to Redis on startup for Bull queues. If Redis is unavailable, the queues silently fall back (no crash), but jobs are lost. For production, a managed Redis instance (Redis Labs, Upstash) should be used with the connection string provided via `REDIS_URL` environment variable.

### 11.4 Environment Variables

The backend requires 7 environment variables:
- `PORT` — Server port (default: 10000)
- `SUPABASE_URL` — Supabase project URL
- `SUPABASE_SERVICE_KEY` — Service role key (bypasses RLS)
- `REDIS_URL` — Redis connection string
- `SENDGRID_API_KEY` — Email sending (SendGrid)
- `FROM_EMAIL` — Sender email address
- `JWT_SECRET` — JWT signing secret (used for custom token operations)

The Python service adds:
- `OPENROUTER_API_KEY` — LLM provider key

---

## 12. Security Architecture

### 12.1 Authentication Layer

- OTP codes are SHA-256 hashed in memory
- JWTs validated against Supabase Auth on every request
- Password validation enforced client-side and server-side
- No token persistence between app restarts

### 12.2 API Security

- Helmet.js adds security headers to all responses
- CORS restricted in production
- Global rate limiting: 100 requests per 15 minutes
- JSON body size limit: 10MB

### 12.3 Supabase RLS Bypass

The backend uses the **service role key** which bypasses RLS. This is secure because:
1. The service key is stored server-side only (never sent to client)
2. The backend enforces its own authorization via JWT middleware
3. Direct client-to-Supabase access uses anon key with RLS enabled

### 12.4 Data Protection

- User passwords: Handled entirely by Supabase Auth (bcrypt hashed)
- Financial data: Protected behind authentication and user-scoped queries
- No sensitive data in logs (error handler omits details)

### 12.5 Configuration Security

- `.env` files are gitignored
- Service role keys stored only in server environment
- SendGrid API key scoped to email sending only

---

## 13. Performance Considerations

### 13.1 Query Optimization

Dashboard endpoints use `Promise.all` for parallel Supabase queries, reducing total request time from sum of query latencies to max query latency.

### 13.2 Frontend Bundle Size

Expo's production build tree-shakes unused imports. The main bundle includes:
- React Native core
- react-native-svg
- react-native-reanimated
- react-native-safe-area-context
- expo-router
- Various gluestack-ui components (~200KB)

### 13.3 Python AI Service Limitations

The Isolation Forest model is trained on-demand per user. For a user with 500+ transactions, training takes ~200ms in Python. For 10000+ users being analyzed simultaneously, this creates a CPU bottleneck. The Celery worker pattern (with `worker_concurrency=4`) would allow 4 simultaneous training jobs per worker process.

### 13.4 Redis Queue Throughput

Bull queue throughput is limited by Redis single-threaded nature. With `concurrency: 5` per queue processor and 3 queues, a maximum of 15 simultaneous job processors can run. This is adequate for the expected user base but may need queue sharding for large-scale deployment.

---

## 14. Known Issues, Resolutions & Architectural Debt

### 14.1 Redundant Service Implementations

The pattern analysis logic is implemented in both the Node.js pattern service (`pattern.service.ts`) and the Python AI engine (`pattern_service.py`). The Node.js version is currently the active one (used by the dashboard), while the Python version is intended to replace it. This creates a maintenance burden where changes to pattern detection must be made in two places.

**Resolution Path:** Complete the Python AI engine integration, remove the Node.js pattern service, and route all pattern requests through the Python service.

### 14.2 Python AI Engine Integration Gap

The `POST /api/ai/coach-user-proxy` endpoint calls the Python service, but the Python service currently returns mock data identical to the Node.js fallback. The Pattern Learning queue also falls back to mock data when the Python service is unreachable. The integration is **half-complete**: the HTTP calls exist, the Python endpoints exist, but the Python service has no real business logic beyond what the Node.js service already provides.

**Resolution Path:** Wire OpenRouter API key, implement LLM-based coaching in Python, implement pattern learning that actually reads from Supabase.

### 14.3 Frontend Linting and TypeScript Errors

The frontend has TypeScript errors in several files including `wealth-growth.tsx`, `SME-growth.tsx`, and `gluestack-provider.tsx`. These are primarily related to missing type exports from gluestack-ui components (e.g., `GluestackUIProvider` props, `config` resolution). These errors prevent a clean TypeScript compilation.

**Resolution Path:** Either fix the type imports (may require gluestack-ui version update) or add `// @ts-nocheck` to affected files as a temporary measure. A third option is to upgrade gluestack-ui to the latest version that exports proper types.

### 14.4 Expo SDK Version Compatibility

The frontend configuration references Expo SDK 52 (denoted by the `expo` version in `package.json`), but some dependency versions may be incompatible. Specifically:
- `expo-router` v4 may require at least Expo SDK 51+
- `react-native-reanimated` v3.16+ requires specific Expo dev client configuration
- `gluestack-ui` component library may have version-specific API differences

**Resolution Path:** Run `npx expo doctor` to identify version mismatches and resolve according to Expo's compatibility guide.

### 14.5 No Automated Tests

The codebase has **no test files** (no `*.test.ts`, `*.spec.ts`, `__tests__/` directories found). This means:
- Regression safety is non-existent
- The mock data fallback pattern cannot be verified programmatically
- API contract changes risk breaking frontend expectations without warning

**Resolution Path:** Implement integration tests for critical API endpoints (auth, dashboard, onboarding) using Jest + Supertest, and unit tests for service methods with Jest.

### 14.6 Fallback Data Duplication

Hardcoded fallback values exist in both the backend services (dashboard.service.ts) and the frontend Zustand store (dashboard-store.ts). If the data shape changes, both locations must be updated. This duplication increases the risk of inconsistency between the data the backend returns and what the frontend displays.

**Resolution Path:** Remove fallback data from the frontend store and rely entirely on the server's fallback responses. This makes the backend the single source of truth for data shape.

### 14.7 Rate Limiting Granularity

The current rate limiting applies globally (100 requests per 15 minutes per IP). There is no route-specific rate limiting. A malicious user could hit the resource-intensive dashboard endpoint 100 times without triggering the rate limiter.

**Resolution Path:** Implement route-specific rate limits (e.g., 30 requests per minute for dashboard endpoints, 5 requests per minute for auth endpoints).

### 14.8 No Request Logging Middleware

The backend has no request logging middleware (like Morgan or Winston HTTP). This means:
- No visibility into request patterns, errors, or performance
- No audit trail for security incidents
- No ability to measure endpoint usage for optimization

**Resolution Path:** Add Morgan (or Winston HTTP) middleware before the router in the middleware stack, configured to log method, URL, status code, and response time.

### 14.9 Supabase Service Key Exposure Risk

The service role key is passed to the backend via environment variable but is logged in the server startup (`index.ts` line 24: `env.SUPABASE_SERVICE_KEY`). The `hide` function should mask this in production logs.

**Resolution Path:** Use the `hide()` wrapper for all secrets in environment configuration logging.

---

## 15. Future Architecture Roadmap

### Phase 1: Completing the AI Engine (Current Priority)
- Wire OpenRouter API key and implement LLM-powered financial coach
- Implement real pattern learning in Python with Supabase data
- Full integration testing between Node.js API and Python service
- Remove duplicate pattern logic from Node.js services

### Phase 2: Data Ingestion Pipeline
- Full Plaid integration for real bank account linking
- CSV/OFX/QFX file upload for transaction import
- Automatic transaction categorization with ML
- Real-time transaction sync via webhooks

### Phase 3: Production Hardening
- Add comprehensive test suite (unit, integration, E2E)
- Implement structured logging (Winston/Pino + correlation IDs)
- Route-specific rate limiting with Redis-backed store
- Add request/response logging middleware
- Implement database connection pooling optimization

### Phase 4: Scale & Performance
- Database read replicas for dashboard queries
- Redis caching for frequently accessed data
- Implement Celery workers for Python AI service
- Queue sharding for high-volume job processing
- CDN for static content delivery

### Phase 5: Advanced Features
- Multi-currency support with real-time exchange rates
- Investment portfolio optimization using Modern Portfolio Theory
- Tax optimization suggestions
- Bill negotiation automation
- Integration with accounting software (QuickBooks, Xero)

---

## Appendix A: Complete API Endpoint Registry

### Auth Routes (`/api/auth`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | /register | No | Create account + send OTP |
| POST | /verify-otp | No | Verify email with OTP |
| POST | /login | No | Email/password login |
| POST | /logout | Yes | Invalidate session |
| GET | /session | Yes | Verify current session |
| POST | /refresh | No (uses refresh token) | Extend session |

### User Routes (`/api/users`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | /me | Yes | Get current user profile |
| GET | /preferences | Yes | Get user preferences |
| POST | /preferences | Yes | Save onboarding preferences |
| PUT | /profile | Yes | Update profile |

### Dashboard Routes (`/api/dashboard`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | /overview | Yes | Role-based dashboard overview |
| GET | /fraud | Yes | Fraud protection dashboard |
| GET | /investor-growth | Yes | Individual investor dashboard |
| GET | /sme-growth | Yes | SME dashboard |
| GET | /freelancer-growth | Yes | Freelancer dashboard |
| GET | /entrepreneur-growth | Yes | Entrepreneur dashboard |

### Transaction Routes (`/api/transactions`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | / | Yes | List user transactions |
| POST | / | Yes | Create transaction |
| GET | /:id | Yes | Get specific transaction |
| PUT | /:id | Yes | Update transaction |
| DELETE | /:id | Yes | Delete transaction |

### Plaid Routes (`/api/plaid`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | /create-link-token | Yes | Generate Plaid link token |
| POST | /import-csv | Yes | Bulk import CSV transactions |

### Budget Routes (`/api/budgets`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | / | Yes | List budgets |
| POST | / | Yes | Create budget |
| GET | /:id | Yes | Get specific budget |
| PUT | /:id | Yes | Update budget |
| DELETE | /:id | Yes | Delete budget |

### Savings Routes (`/api/savings`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | / | Yes | List savings goals |
| POST | / | Yes | Create savings goal |
| POST | /:id/contribute | Yes | Contribute to savings goal |

### Investment Routes (`/api/investments`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | / | Yes | List holdings |
| POST | / | Yes | Record investment |

### Bill Routes (`/api/bills`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | / | Yes | List bills |
| POST | / | Yes | Create bill |
| PUT | /:id | Yes | Update bill |
| DELETE | /:id | Yes | Delete bill |

### Loan Routes (`/api/loans`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | / | Yes | List loans |
| POST | / | Yes | Record loan |
| PUT | /:id | Yes | Update loan |

### AI Routes (`/api/ai`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | /coach | Yes | Get financial coaching |
| POST | /coach-user-proxy | Yes | Proxy to Python AI coach |
| POST | /profile | Yes | Get AI profile analysis |
| POST | /daily-briefing | Yes | Get daily financial briefing |
| POST | /analytics | Yes | Get detailed analytics |

### Content Routes (`/api/content`)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | /recommendations | Yes | Personalized content |
| GET | /learning-path | Yes | Learning path progress |

## Appendix B: Database Schema (Complete)

```sql
-- Referential integrity maintained via FK constraints
-- All user-scoped tables include user_id FK to profiles(id)
-- Timestamps use TIMESTAMPTZ for timezone-aware operations
-- JSONB used for extensible metadata fields

CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  scheme TEXT,
  referral_code TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'individual',
  financial_goals TEXT[] DEFAULT '{}',
  money_fears TEXT[] DEFAULT '{}',
  risk_tolerance TEXT DEFAULT 'moderate',
  onboarding_completed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  account_id UUID REFERENCES accounts(id) ON DELETE SET NULL,
  amount DECIMAL(12,2) NOT NULL,
  category TEXT NOT NULL,
  subcategory TEXT,
  description TEXT,
  merchant_name TEXT,
  date DATE NOT NULL,
  is_expense BOOLEAN DEFAULT true,
  is_recurring BOOLEAN DEFAULT false,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  balance DECIMAL(14,2) DEFAULT 0,
  currency TEXT DEFAULT 'USD',
  plaid_account_id TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE fraud_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  transaction_id UUID REFERENCES transactions(id) ON DELETE SET NULL,
  alert_type TEXT NOT NULL,
  severity TEXT DEFAULT 'medium',
  description TEXT,
  anomaly_score DECIMAL(5,4),
  is_resolved BOOLEAN DEFAULT false,
  detected_at TIMESTAMPTZ DEFAULT NOW(),
  resolved_at TIMESTAMPTZ
);

CREATE TABLE behavior_patterns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  pattern_type TEXT NOT NULL,
  pattern_name TEXT NOT NULL,
  score DECIMAL(5,2) NOT NULL,
  metadata JSONB DEFAULT '{}',
  detected_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, pattern_type, pattern_name)
);

CREATE TABLE daily_briefings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  briefing_date DATE NOT NULL,
  summary TEXT,
  data JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, briefing_date)
);

-- Additional tables follow the same patterns:
-- budgets, savings_goals, investments, bills, loans,
-- ai_coach_messages, business_analytics, cashflow_forecasts,
-- spending_patterns, pattern_learning_jobs, market_insights,
-- business_insights, content_recommendations, onboarding_content,
-- learning_paths
```

## Appendix C: Technology Stack

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| Frontend Framework | React Native / Expo | SDK 52 | Cross-platform mobile/web |
| Routing | Expo Router | v4 | File-based navigation |
| Styling | NativeWind + gluestack-ui | Latest | Utility-first CSS + design system |
| State | Zustand | v4 | Lightweight state management |
| Animations | react-native-reanimated | v3+ | 60fps UI animations |
| SVGs | react-native-svg | Latest | Chart and icon rendering |
| HTTP Client | Custom ApiClient (Fetch) | — | API communication |
| Backend Runtime | Node.js / Express | 18+ / 4.x | API server |
| Database | Supabase (PostgreSQL 15) | Latest | Data persistence + auth |
| AI Runtime | Python / FastAPI | 3.11+ | ML inference |
| ML Framework | scikit-learn | 1.3+ | Isolation Forest |
| Queue System | Bull (Redis) | 4.x | Background jobs |
| Email | SendGrid | — | Transactional emails |
| AI Provider | OpenRouter | — | LLM API gateway |
| Deployment | Render | — | Container hosting |
| Container | Docker | Latest | Standardized deployments |

---

*This document is a living reference. Last updated: June 2026.*
