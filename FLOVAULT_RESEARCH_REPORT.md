# Finovault Flutter App — Full Research Report

> **Date:** 2026-09-04
> **Purpose:** Complete audit of the Flutter mobile app to drive a full web app realignment.
> **Source:** `finovault-flutter/lib/`

---

## 1. Navigation Architecture

### Entry Point
- **File:** `lib/main.dart` → `MaterialApp` with `FinovaultApp` (ConsumerWidget)
- **Initial route:** Checks `onboardingProvider` state → `WelcomeScreen` (fresh) or `LoginScreen` (returning)

### Screen Flow

```
WelcomeScreen
  ├── "Get Started" → OnboardingProvider.start() → flows through:
  │     Step 1: Login/Signup (LoginScreen / SignupScreen)
  │     Step 2: RoleScreen (role selection)
  │     Step 3: BusinessDetailsScreen (Entrepreneur/SME only)
  │     Step 4: GoalsScreen (role-specific goals)
  │     Step 5: LinkAccountsScreen (bank/mobile money linking)
  │     → Done → HomeShell
  └── "Already have account? Log in" → LoginScreen

HomeShell (bottom 5-tab IndexedStack)
  ├── Tab 0: HomeTab → Role-based PersonaHome (IndividualHome / FreelancerHome / EntrepreneurHome / SmeHome)
  ├── Tab 1: InsightsTab (analytics, charts, CSV export)
  ├── Tab 2: VaultTab (savings goals, pension, wealth card)
  ├── Tab 3: PayTab (transfers, bill pay, payment history)
  └── Tab 4: ProfileTab (settings, security, logout)
```

### Navigation Helpers
- **File:** `lib/screens/home_shell.dart`, lines 8–12
  - `pushScreen(context, widget)` — Navigator.push
  - `replaceScreen(context, widget)` — Navigator.pushReplacement
  - `popScreen(context)` — Navigator.pop
  - `pushAndRemoveAll(context, widget)` — Navigator.pushAndRemoveUntil (used for logout)
- **Tab switching:** `HomeShell` holds `_tabIndex` state; `switchTab(int)` callback exposed via `ref.read(homeShellProvider.notifier)` — allows coach, deep links, and payee screens to jump tabs.

### Tab Bar Details
- **File:** `lib/screens/home_shell.dart`, lines 57–100
- Fixed bottom bar, not hidden on scroll
- 5 tabs: Home (`Icons.house`), Insights (`Icons.insights`), Vault (`Icons.savings`), Pay (`Icons.payments`), Profile (`Icons.person`)
- Active tab: filled icon + role accent color; inactive: `IconsData`
- Role badge: small `RoleBadge` widget shown above the Profile tab icon
- Labels use `AppLocalizations` keys: `navHome`, `navInsights`, `navVault`, `navPay`, `navProfile`

### Deep Navigation (from tabs)
| Tab | Pushed Screens |
|-----|----------------|
| Home | `CoachScreen`, `AccountsScreen`, `GoalDetailScreen`, `GoalNewScreen`, `TransactionsScreen`, `TransferScreen`, `VendorsScreen`, `BudgetsScreen`, `BillsScreen`, `InvoicesScreen`, `PensionScreen`, `SecurityScreen`, `AccountDetailScreen` |
| Vault | `GoalDetailScreen`, `GoalNewScreen`, `PensionScreen`, `PensionSetupScreen` |
| Pay | `TransferScreen`, `BillsScreen` |
| Profile | `EditProfileScreen`, `SecurityScreen`, `ChangePasswordScreen`, `TwoFactorSetupScreen`, `TwoFactorBackupScreen` |

---

## 2. Per-Role Feature Matrix

### Role Definitions
- **File:** `lib/core/models.dart`, lines 6–13
- Enum `PrimaryRole`: `individual`, `freelancer`, `entrepreneur`, `sme`
- Enum `RoleScheme`: `standard`, `femaleFounder` (only for Entrepreneur role)

### Role-Color Mapping
- **File:** `lib/theme/tokens.dart`, lines 85–93

| Role | Accent Color | Hex |
|------|-------------|-----|
| Individual | `FvColors.indigo` | `#6366F1` |
| Freelancer | `FvColors.coral` | `#F97066` |
| Entrepreneur | `FvColors.amber` | `#F59E0B` |
| Entrepreneur (female founder) | `FvColors.plum` | `#A855F7` |
| SME | `FvColors.teal` | `#14B8A6` |

### Dashboard Modules by Role
- **File:** `lib/screens/home/persona_homes.dart`

#### Individual (lines 265–353)
| Module | Description |
|--------|-------------|
| `HeroCard` | Net worth, total balance, role-adaptive color |
| Quick actions | Send, Save, Coach, Budget (role-specific set) |
| InsightsCard | Income vs expenses mini chart |
| GoalsProgressList | Up to 3 active goals with progress |
| RecentTransactionsMini | Last 5 transactions with direction + category |
| **Coach CTA** | "Get insights" button → `CoachScreen` |

#### Freelancer (lines 355–437)
| Module | Description |
|--------|-------------|
| `HeroCard` | Net worth, total balance |
| Quick actions | Invoice, Send, Coach, Tax shield |
| UnpaidInvoicesCard | Unpaid invoice count + total (delegated) |
| InsightsCard | Income vs expenses |
| GoalsProgressList | Up to 3 goals |
| **Coach CTA** | "Get insights" → `CoachScreen` |

#### Entrepreneur (lines 439–533)
| Module | Description |
|--------|-------------|
| `HeroCard` | Net worth, total balance, business metrics summary |
| Quick actions | Send, Tax, Coach, Cash flow |
| BusinessMetricsCard | MRR/ARR, burn rate, burn multiple |
| InsightsCard | Income vs expenses |
| GoalsProgressList | Up to 3 goals |
| **Coach CTA** | "Get insights" → `CoachScreen` |

#### Entrepreneur (Female Founder) (lines 535–625)
Same as Entrepreneur + `FemaleFounderCard` module (grant opportunities, curated content).

#### SME (lines 627–717)
| Module | Description |
|--------|-------------|
| `HeroCard` | Net worth, total balance, treasury summary |
| Quick actions | Pay vendor, Send, Coach, Bills |
| ComplianceCard | Tax/PAYE/VAT filing deadlines |
| CashFlowCard | Monthly burn, runway, net flow |
| GoalsProgressList | Up to 3 goals |
| **Coach CTA** | "Get insights" → `CoachScreen` |

### Features Visible Per Role (cross-screen)

| Feature | Individual | Freelancer | Entrepreneur | Entrepreneur (FF) | SME |
|---------|:----------:|:----------:|:------------:|:-----------------:|:---:|
| Hero net worth card | ✅ | ✅ | ✅ | ✅ | ✅ |
| Goals + progress | ✅ | ✅ | ✅ | ✅ | ✅ |
| Insights charts | ✅ | ✅ | ✅ | ✅ | ✅ |
| Transactions list | ✅ | ✅ | ✅ | ✅ | ✅ |
| Transfer / send money | ✅ | ✅ | ✅ | ✅ | ✅ |
| Bill pay (utilities) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Pension builder | ✅ | ✅ | ✅ | ✅ | ✅ |
| Budgets | ✅ | ✅ | ✅ | ✅ | ✅ |
| Linked accounts | ✅ | ✅ | ✅ | ✅ | ✅ |
| Security / 2FA | ✅ | ✅ | ✅ | ✅ | ✅ |
| Money Coach | ✅ | ✅ | ✅ | ✅ | ✅ |
| Coach: tax shield | ❌ | ✅ | ✅ | ✅ | ✅ |
| Coach: invoice DSO | ❌ | ✅ | ❌ | ❌ | ❌ |
| Unpaid invoices | ❌ | ✅ | ❌ | ❌ | ❌ |
| Vendor tracking | ❌ | ❌ | ✅ | ✅ | ✅ |
| Business metrics (MRR/burn) | ❌ | ❌ | ✅ | ✅ | ✅ |
| Compliance calendar | ❌ | ❌ | ❌ | ❌ | ✅ |
| Grant opportunities card | ❌ | ❌ | ❌ | ✅ | ❌ |
| Fundraising tracker | ❌ | ❌ | ✅ | ✅ | ❌ |
| Cash flow forecast | ❌ | ❌ | ❌ | ❌ | ✅ |
| Payroll efficiency | ❌ | ❌ | ❌ | ❌ | ✅ |

---

## 3. Full Screen Inventory

### Core Screens

| Screen | File | Description |
|--------|------|-------------|
| `WelcomeScreen` | `lib/screens/welcome_screen.dart` | Branded hero, Get Started + Login CTAs |
| `LoginScreen` | `lib/screens/auth/login_screen.dart` | Email/password, demo mode |
| `SignupScreen` | `lib/screens/auth/signup_screen.dart` | Registration |
| `RoleScreen` | `lib/screens/role_screen.dart` | Role selection (4 cards + female founder checkbox) |
| `HomeShell` | `lib/screens/home_shell.dart` | Bottom tab bar + IndexedStack host |
| `CoachScreen` | `lib/screens/coach/coach_screen.dart` | Chat-style financial coach |

### Persona Homes

| Screen | File | Description |
|--------|------|-------------|
| `IndividualHome` | `lib/screens/home/persona_homes.dart` (line 265) | Personal finance dashboard |
| `FreelancerHome` | `lib/screens/home/persona_homes.dart` (line 355) | Freelancer dashboard + invoices |
| `EntrepreneurHome` | `lib/screens/home/persona_homes.dart` (line 439) | Startup dashboard + metrics |
| `SmeHome` | `lib/screens/home/persona_homes.dart` (line 627) | SME dashboard + compliance |

### Tab Screens

| Screen | File | Description |
|--------|------|-------------|
| `InsightsTab` | `lib/screens/tabs/insights_tab.dart` | Charts, briefing, CSV export |
| `VaultTab` | `lib/screens/tabs/vault_tab.dart` | Wealth card, goals list, pension |
| `PayTab` | `lib/screens/tabs/pay_tab.dart` | Transfer/Bill pay CTAs, history |
| `ProfileTab` | `lib/screens/tabs/profile_tab.dart` | User info, settings, logout |

### Money / Feature Screens

| Screen | File | Description |
|--------|------|-------------|
| `AccountsScreen` | `lib/screens/money/accounts_screen.dart` | Linked accounts list, add account |
| `AccountDetailScreen` | `lib/screens/money/account_detail_screen.dart` | Balance chart (fl_chart), transaction list, CSV export |
| `TransactionsScreen` | `lib/screens/money/transactions_screen.dart` | Filterable transaction list |
| `TransferScreen` | `lib/screens/money/transfer_screen.dart` | Send money form + payee management |
| `BillsScreen` | `lib/screens/money/bills_screen.dart` | Bill categories (6 types), payment flow |
| `BudgetsScreen` | `lib/screens/money/budgets_screen.dart` | Budget CRUD, spend tracking |
| `GoalsListScreen` | `lib/screens/money/goals_list_screen.dart` | Goals list with progress bars |
| `GoalDetailScreen` | `lib/screens/money/goal_detail_screen.dart` | Single goal detail + contribute |
| `GoalNewScreen` | `lib/screens/money/goal_new_screen.dart` | Create goal form |
| `InvoicesScreen` | `lib/screens/money/invoices_screen.dart` | Invoice CRUD (freelancer) |
| `VendorsScreen` | `lib/screens/money/vendors_screen.dart` | Vendor list with reliability + spend |
| `PensionScreen` | `lib/screens/money/pension_screen.dart` | Pension overview + contribute |
| `PensionSetupScreen` | `lib/screens/money/pension_setup_screen.dart` | Pension configuration form |
| `SecurityScreen` | `lib/screens/money/security_screen.dart` | Devices, events, OTP verification |

### Onboarding Screens

| Screen | File | Description |
|--------|------|-------------|
| `BusinessDetailsScreen` | `lib/screens/onboarding/business_details_screen.dart` | Entrepreneur/SME business info |
| `GoalsScreen` | `lib/screens/onboarding/goals_screen.dart` | Role-specific goal selection + risk tolerance |
| `LinkAccountsScreen` | `lib/screens/onboarding/link_accounts_screen.dart` | Bank/mobile money linking simulation |

### Profile / Settings Screens

| Screen | File | Description |
|--------|------|-------------|
| `EditProfileScreen` | `lib/screens/profile/edit_profile_screen.dart` | Name, photo, email |
| `ChangePasswordScreen` | `lib/screens/profile/change_password_screen.dart` | Password change |
| `TwoFactorSetupScreen` | `lib/screens/profile/two_factor_setup_screen.dart` | 2FA QR + verification |
| `TwoFactorBackupScreen` | `lib/screens/profile/two_factor_backup_screen.dart` | Backup codes display |

---

## 4. Coach Features

### Architecture
- **File:** `lib/core/coach/coach_service.dart`
- Abstract `CoachService` with `MockCoachService` implementation
- `MockCoachService.getReply()` returns a `CoachStream` (`Stream<CoachPart>`) — word-by-word streaming
- No real LLM backend; all replies are role-aware templates with data injection

### Coach Context Model
- **File:** `lib/core/coach/coach_models.dart`

```dart
class CoachContext {
  final PrimaryRole role;
  final RoleScheme scheme;
  final double balance;
  final double income;
  final double expense;
  final List<Goal> goals;
  final double vendorSpend;
  final List<String> complianceDeadlines;
  final int runwayMonths;
  final int dso; // days sales outstanding (freelancer)
  final int dpo; // days payable outstanding (sme)
  final int employeeCount;
  final double payroll;
  final double mrr;
  final String? topGoalName;
  final double goalSavedAmount;
  final double goalTargetAmount;
}
```

### Role-Specific Coach Prompts
- **File:** `lib/core/coach/coach_service.dart`, `_buildPrompt()` method

| Role | Templates Used |
|------|---------------|
| Individual | `coachDefault` — generic balance, cash flow, goal focus |
| Freelancer | `coachFreelancerInvoices` (DSO tracking, reminder cadence) + `coachFreelancerTax` (20% set-aside) |
| Entrepreneur | `coachEntrepreneurFundraising` (runway, investor timing) + `coachEntrepreneurBurn` (burn multiple) + `coachEntrepreneurHiring` (rev per employee) + `coachEntrepreneurRevenue` (MRR focus) |
| Entrepreneur (FF) | All entrepreneur prompts + `coachFemaleFounderGrants` (grant opportunities) |
| SME | `coachSmeCashFlow` (runway, burn) + `coachSmeVendors` (payment terms) + `coachSmeCompliance` (deadlines) + `coachSmePayroll` (payroll efficiency %) |

### Coach UI
- **File:** `lib/screens/coach/coach_screen.dart`
- Chat-style interface with message bubbles (user right, coach left)
- **Snapshot card** at top: role-dependent financial summary (income, expenses, net, DSO for freelancer, burn/runway for SME, etc.)
- **Quick action chips** at bottom: "Review my spending", "Help me save", "How do I grow?"
- Input field + send button
- Streaming response: `CoachPart` chunks appended word-by-word to displayed message

---

## 5. Onboarding Flow

### State Management
- **File:** `lib/core/state/onboarding.dart` (Provider: `onboardingProvider`)

### Steps
1. **Welcome** → `WelcomeScreen` — "Get Started" button calls `OnboardingProvider.start()`
2. **Login/Signup** → `LoginScreen` / `SignupScreen` — auth gate
3. **Role Selection** → `RoleScreen` — pick Individual / Freelancer / Entrepreneur / SME; Entrepreneur shows "Female founder" checkbox
4. **Business Details** → `BusinessDetailsScreen` (Entrepreneur/SME only) — employee count, revenue range, industry, business stage, payment terms; SME adds: tax ID, registration number, payroll
5. **Goals** → `GoalsScreen` — role-specific goal cards (Emergency fund, Retirement, Debt, Home, Education, Tax shield, Equipment, Business growth, Cash buffer) + risk tolerance picker (Low/Moderate/High)
6. **Link Accounts** → `LinkAccountsScreen` — simulated bank linking (MCB, SBM, Bank One, Maubank) + mobile money (my.t money, Emtel Money); optional, can skip
7. **Done** → `HomeShell`

### Role-Specific Goal Options
- **File:** `lib/screens/onboarding/goals_screen.dart`, lines 30–65

| Role | Available Goals |
|------|----------------|
| Individual | Emergency fund, Retirement, Pay down debt, Buy a home, Education, Tax shield |
| Freelancer | Emergency fund, Retirement, Pay down debt, Tax shield, Buy a home, Education |
| Entrepreneur | Emergency fund, Business growth, Tax shield, Retirement, Equipment, Cash buffer |
| SME | Cash buffer, Tax shield, Business growth, Emergency fund, Equipment, Retirement |

---

## 6. Design Tokens

### Color Palette
- **File:** `lib/theme/tokens.dart`, lines 21–83

| Token | Hex | Usage |
|-------|-----|-------|
| `FvColors.primary` | `#2563EB` | Primary brand (buttons, links) |
| `FvColors.primaryDark` | `#1D4ED8` | Hover/pressed states |
| `FvColors.wash` | `#F5F7FF` | Card/surface backgrounds |
| `FvColors.ink` | `#1A1A2E` | Primary text |
| `FvColors.muted` | `#6B7280` | Secondary text |
| `FvColors.slate` | `#CBD5E1` | Borders |
| `FvColors.success` | `#10B981` | Positive values, income |
| `FvColors.warning` | `#F59E0B` | Warnings |
| `FvColors.error` | `#EF4444` | Errors, expenses, negative |
| `FvColors.indigo` | `#6366F1` | Individual role |
| `FvColors.coral` | `#F97066` | Freelancer role |
| `FvColors.amber` | `#F59E0B` | Entrepreneur role |
| `FvColors.plum` | `#A855F7` | Female founder role |
| `FvColors.teal` | `#14B8A6` | SME role |
| `FvColors.white` | `#FFFFFF` | Text on dark, backgrounds |

### Spacing Scale
- **File:** `lib/theme/tokens.dart`, lines 104–114

| Token | Value |
|-------|-------|
| `FvSpacing.x1` | `2` |
| `FvSpacing.x2` | `4` |
| `FvSpacing.x3` | `8` |
| `FvSpacing.x4` | `12` |
| `FvSpacing.x5` | `16` |
| `FvSpacing.x6` | `20` |
| `FvSpacing.x7` | `24` |
| `FvSpacing.x8` | `32` |
| `FvSpacing.x10` | `40` |
| `FvSpacing.x12` | `48` |

### Border Radii
- **File:** `lib/theme/tokens.dart`, lines 116–120

| Token | Value |
|-------|-------|
| `FvRadius.sm` | `4` |
| `FvRadius.md` | `8` |
| `FvRadius.card` | `12` |
| `FvRadius.lg` | `16` |
| `FvRadius.iconContainer` | `10` |

### Borders
- **File:** `lib/theme/tokens.dart`, lines 122–126

| Token | Value |
|-------|-------|
| `FvBorders.width` | `2` |
| `FvBorders.brutal` | `Border.all(color: FvColors.ink, width: 2)` |

### Shadows (Neo-Brutalist)
- **File:** `lib/theme/tokens.dart`, lines 128–132

| Token | Value |
|-------|-------|
| `FvShadows.brutal` | `BoxShadow(offset: Offset(3, 3), color: FvColors.ink, blurRadius: 0)` |

### Typography
- **File:** `lib/theme/app_theme.dart`, lines 18–23
- Font family: `Montserrat` (weights 400, 500, 600, 700, 800)
- Heading sizes: 32 (h1), 24 (h2), 18 (body-large), 15 (body), 13 (caption)
- Letter spacing: `-0.4` for headings, default for body

### Text Colors (Context Extension)
- **File:** `lib/theme/tokens.dart`, lines 143–151

| Extension | Value |
|-----------|-------|
| `context.fvText` | `FvColors.ink` (`#1A1A2E`) |
| `context.fvTextSecondary` | `FvColors.muted` (`#6B7280`) |
| `context.fvSurface` | `FvColors.white` (`#FFFFFF`) |
| `context.fvBackground` | `FvColors.wash` (`#F5F7FF`) |
| `context.fvBorder` | `FvColors.slate` (`#CBD5E1`) |

### Onboarding Background
- **File:** `lib/theme/tokens.dart`, lines 134–141
- Linear gradient from `#EEF2FF` (top) to `#F5F7FF` (bottom)

### Theme Mode
- **File:** `lib/theme/app_theme.dart`
- Light theme: `FvColors.wash` background, white cards
- Dark theme: `#0F172A` background, `#1E293B` cards
- System default follows device setting

### Component Style (Neo-Brutalist)
- Cards: `FvBorders.brutal` (2px solid ink) + `FvShadows.brutal` (3px offset, no blur) + `FvRadius.card` (12px)
- Buttons: Solid primary bg, 2px ink border, 3px offset shadow, Montserrat 600 weight
- Chips: 2px border, role-accent fill on selected

---

## 7. Features Not Yet in the Web App

> Compared against `finovault-web` codebase (Next.js/React).

### Confirmed Present in Flutter, Missing from Web

| Feature | Flutter Location | Web Status |
|---------|-----------------|------------|
| **Role-based dashboards** (4 distinct personas) | `lib/screens/home/persona_homes.dart` | Web has single generic dashboard |
| **Money Coach** (chat-style, role-aware, streaming) | `lib/screens/coach/coach_screen.dart` | Not in web |
| **Pension Builder** (short/long pot, projections) | `lib/screens/money/pension_screen.dart` | Not in web |
| **Budgets** (category-based monthly tracking) | `lib/screens/money/budgets_screen.dart` | Not in web |
| **Bill Pay** (6 utility types, meter/account flow) | `lib/screens/money/bills_screen.dart` | Not in web |
| **Invoices** (freelancer CRUD, unpaid tracking) | `lib/screens/money/invoices_screen.dart` | Not in web |
| **Vendor Tracking** (reliability score, spend) | `lib/screens/money/vendors_screen.dart` | Not in web |
| **Compliance Calendar** (SME tax/PAYE/VAT) | `lib/screens/home/persona_homes.dart` (SME) | Not in web |
| **Fundraising Tracker** (entrepreneur runway/burn) | `lib/screens/home/persona_homes.dart` (Entrepreneur) | Not in web |
| **Cash Flow Forecast** (SME burn/runway/net) | `lib/screens/home/persona_homes.dart` (SME) | Not in web |
| **Business Metrics** (MRR/ARR, burn multiple) | `lib/screens/home/persona_homes.dart` (Entrepreneur) | Not in web |
| **Female Founder Grants Card** | `lib/screens/home/persona_homes.dart` (FF) | Not in web |
| **Security Score** + device/event log | `lib/screens/money/security_screen.dart` | Basic settings only in web |
| **2FA Setup** (QR code, backup codes) | `lib/screens/profile/two_factor_setup_screen.dart` | Not in web |
| **Linked Accounts** (6 institutions, balance import) | `lib/screens/money/accounts_screen.dart` | Not in web |
| **fl_chart Balance Trend** (per account) | `lib/screens/money/account_detail_screen.dart` | Not in web |
| **CSV Export** (transactions, account history) | `lib/screens/tabs/insights_tab.dart`, `account_detail_screen.dart` | Not in web |
| **Daily Briefing** (role-adaptive) | `lib/screens/tabs/insights_tab.dart` | Not in web |
| **Goal Progress Cards** (dashboard inline) | `lib/screens/home/persona_homes.dart` (all roles) | Not in web |
| **Quick Action Buttons** (role-specific CTA grid) | `lib/screens/home/persona_homes.dart` | Not in web |
| **Role Badge** (on profile tab icon) | `lib/screens/home_shell.dart` | Not in web |
| **Onboarding Flow** (role → goals → linking) | `lib/screens/onboarding/` | Not in web |
| **Welcome/Landing Screen** | `lib/screens/welcome_screen.dart` | Web has different landing |

### Localization
- **File:** `lib/l10n/app_en.arb` (467 lines)
- Full i18n support via `AppLocalizations`
- 180+ string keys covering all features, roles, and error states
- Currency: MUR (Mauritian Rupee) — hardcoded in labels like "Under 1M MUR"
- Web app should adopt the same ARB keys for consistency

### Banking Integration Layer
- **File:** `lib/core/banking/connector.dart`
- Abstract `BankConnector` with `MockBankConnector`
- 6 institutions: MCB, SBM, Bank One, Maubank (banks) + my.t money, Emtel Money (mobile money)
- `ConnectPlan`: generates 45-day seed transaction history with believable patterns
- Clean seam for real OFX/Open Banking implementation

### Shared Widget Library
- **File:** `lib/widgets/ui.dart` — `FvCard`, `FvButton`, `FvChip`, `FvSectionHeader`, `OnboardingHeader`, etc.
- **File:** `lib/widgets/components.dart` — `FvStatCard`, `FvCategoryChip`
- **File:** `lib/widgets/fv_avatar.dart` — Avatar with URL/data URI/initials fallback
- **File:** `lib/widgets/vault_mark.dart` — Brand logo (CustomPaint, vault wheel + keyhole)
- All neo-brutalist styled, role-accent-aware
