# 18 — API Contracts (Finovault BFF)

The Flutter app talks to a single **Backend-for-Frontend (BFF)** over one RPC
endpoint. This document is the contract any BFF implementation must satisfy. A
reference mock server lives in [`tool/mock_bff`](tool/mock_bff) and can be used
to verify the app end-to-end without a real backend.

## Transport

- **Base URL** — configured at runtime from Profile → Settings → *Backend URL*
  (persisted in `KvStore`), seeded from the `API_BASE_URL` compile-time variable
  when nothing is stored. The app uses `HttpFinovaultApi` whenever the URL is
  non-empty, otherwise it falls back to the in-memory mock.
- **Endpoint** — `POST {baseUrl}/rpc` (a single method dispatcher).
- **Headers** — `Content-Type: application/json` and, when authenticated,
  `Authorization: Bearer <token>`.

### Request envelope

```json
{ "method": "<RpcName>", "args": { "...": "..." } }
```

### Response envelope

```json
{ "data": <json> | null, "error": { "code": "string", "message": "string" } | null }
```

- On success: `error` is `null` and `data` carries the result (may itself be
  `null`, e.g. `getSession` for an unknown token).
- On failure: `data` is `null` and `error` carries a `code` + human-readable
  `message`.

## Authentication

- `login` / `signup` return `AuthResult { token, user }`. The app stores `token`
  (in `KvStore`, key `finovault.session`) and sends it as a Bearer token.
- `getSession(token)` re-validates a stored token on cold start.
- Returning **HTTP 401** (or an error `code` of `unauthorized`) makes the client
  drop the stored session and return to the welcome gate.

## Encoding rules

- **Enums** are sent/received as their `.name` (`lowerCamel` string), e.g.
  `TransactionDirection.inn` → `"inn"`.
- **DateTime** is ISO-8601 UTC string (`2026-08-25T12:00:00.000Z`).
- **Money / amounts** are JSON numbers (doubles); the BFF stores the currency on
  the account/profile, not per-amount.
- **Booleans / numbers** use their JSON forms.

## Error codes

| code           | meaning                                              |
| -------------- | ---------------------------------------------------- |
| `unauthorized` | bad/expired token (also HTTP 401)                    |
| `validation`   | invalid args                                         |
| `not_found`    | referenced entity (account/goal/invoice) missing     |
| `network`      | client-side: timeout / unreachable (not from BFF)    |
| `incorrect_password` | `changePassword` current password mismatch     |
| `invalid_reset_token` | `resetPassword` token unknown or expired       |
| `invalid_code` | 2FA TOTP/backup/OTP code was wrong                    |
| `invalid_challenge` | 2FA challenge unknown or expired                 |
| `error`        | generic server failure                              |

## RPC method catalog

> `token` is omitted below for brevity but is required (except `login`/`signup`).
> Return types are JSON shapes produced by the app's `*.fromJson` factories.

### Auth & profile
| method          | args                                                              | returns            |
| --------------- | ----------------------------------------------------------------- | ------------------ |
| `login`         | `email`, `password`                                              | `AuthResult`       |
| `signup`        | `fullName`, `email`, `password`                                  | `AuthResult`       |
| `getSession`    | —                                                                | `UserProfile?`     |
| `logout`        | —                                                                | `void`             |
| `updateMe`      | `fullName?`, `avatarUrl?`, `preferredLanguage?`, `preferredCurrency?` | `UserProfile`  |
| `getPreferences`| —                                                                | `UserPreferences`  |
| `savePreferences`| `patch: UserPreferences`                                        | `UserPreferences`  |
| `setRole`       | `primaryRole: PrimaryRole`, `scheme: RoleScheme`                | `UserProfile`      |
| `uploadAvatar`  | `mimeType` (must start with `image/`), `data` (base64)          | `avatarUrl` (string) |
| `changePassword`| `currentPassword`, `newPassword`                                | `SecurityOverview` |
| `requestPasswordReset` | `email`                                                   | `void`             |
| `resetPassword` | `resetToken`, `newPassword`                                     | `void`             |

### Two-factor authentication (2FA)

| method                      | args                        | returns              |
| --------------------------- | --------------------------- | -------------------- |
| `login`*                    | `email`, `password`         | `AuthResult`         |
| `beginTwoFactorSetup`       | —                           | `TwoFactorSetup`     |
| `verifyTwoFactorSetup`      | `code`                      | `SecurityOverview`   |
| `disableTwoFactor`          | `code`                      | `SecurityOverview`   |
| `resendOtp`                 | `challengeId`, `method`     | `void`               |
| `verifyTwoFactorChallenge`  | `challengeId`, `code`       | `AuthResult`         |

> `*` **`login` breaking change (Phase 2):** when 2FA is enabled, `login` does
> **not** return a token. Instead it returns `{ mfaRequired: true, challengeId,
> methods, user }` with an empty `token`. The client then calls
> `verifyTwoFactorChallenge` with the 6-digit code (TOTP, backup code, or email
> OTP) to obtain the real session token.

- **`TwoFactorSetup`** shape: `{ secret, qrUrl, backupCodes }` — `qrUrl` is an
  `otpauth://` URI the app renders as a QR code; `backupCodes` is an array of 8
  single-use codes.
- **`beginTwoFactorSetup`** — starts setup for an authenticated user: generates
  a TOTP secret + QR URL and 8 backup codes, but does **not** enable 2FA yet.
- **`verifyTwoFactorSetup`** — verifies the user entered a valid TOTP code
  (accepts a ±30s window), then enables 2FA and bumps the security score.
- **`disableTwoFactor`** — requires a valid code (TOTP or unused backup code);
  on success removes the secret + backup codes and marks 2FA off.
- **`resendOtp`** — for `method: 'email'`, re-issues a one-time code. TOTP needs
  no resend. Email OTP is the launch fallback; SMS arrives post-launch via Twilio.
- **Methods** offered in a login challenge are listed in `methods` (e.g.
  `["totp","email"]`).
- Error codes: `invalid_code` (bad code), `invalid_challenge` (expired/unknown
  challenge).

### Profile & password notes

- **`uploadAvatar`** — the app resizes images to ≤ 512px, JPEG, quality 85 and
  sends the base64 payload over RPC. The BFF responds with a URL: the in-memory
  mock returns an inline `data:` URI; the real backend uploads to Supabase
  Storage and returns its public URL.
- **`changePassword`** — requires the *current* password; on mismatch the BFF
  returns `incorrect_password`. On success it bumps the security score (cap 99),
  records a `Password changed` security event, sets `lastPasswordChange`, and
  invalidates all other sessions. When 2FA is enabled the app first re-authenticates
  via the 2FA challenge (see Phase 2).
- **`requestPasswordReset`** — never reveals whether an email exists (identical
  response for unknown accounts). The mock stores the issued token in
  `MockDb.lastResetToken` (demo only, printed in the forgot-password screen).
- **`resetPassword`** — accepts a token valid for 30 minutes, then invalidates
  all sessions for the account. Unknown or expired tokens return
  `invalid_reset_token`. Email stays immutable; the reset flow only changes the
  password.

### Accounts & transactions
| method             | args                                                            | returns         |
| ------------------ | --------------------------------------------------------------- | --------------- |
| `accounts`         | —                                                              | `Account[]`     |
| `linkAccount`      | `name`, `type: AccountType`, `balance?=0`, `institution?`      | `Account`       |
| `unlinkAccount`    | `accountId`                                                    | `void`          |
| `transactions`     | `limit?=20`                                                    | `Transaction[]` |
| `createTransaction`| `accountId`, `amount`, `direction: TransactionDirection`, `category`, `merchantName?` | `Transaction` |

### Budgets & goals
| method          | args                                                          | returns          |
| --------------- | ------------------------------------------------------------- | ---------------- |
| `budgets`       | —                                                            | `Budget[]`       |
| `createBudget`  | `category`, `amount`                                         | `Budget`         |
| `goals`         | —                                                            | `SavingsGoal[]`  |
| `goal`          | `goalId`                                                     | `SavingsGoal`    |
| `createGoal`    | `name`, `type: GoalType`, `targetAmount`, `targetDate?`      | `SavingsGoal`    |
| `contribute`    | `goalId`, `amount`, `sourceAccountId?`                       | `SavingsGoal`    |

### Pension
| method              | args                                                                              | returns             |
| ------------------- | --------------------------------------------------------------------------------- | ------------------- |
| `getPensionPlan`    | —                                                                                 | `PensionPlan?`      |
| `pensionProjection` | —                                                                                 | `PensionProjection` |
| `upsertPensionPlan` | `shortPotTarget`, `longPotTarget`, `frequency: PensionFrequency`, `contributionAmount`, `currentShortPot`, `currentLongPot`, `assumedReturnPct`, `inflationPct`, `currentAge`, `retirementAge`, `autoDebit` | `PensionPlan` |
| `contributePension` | `pot`, `amount`, `sourceAccountId?`                                              | `PensionContribution` |
| `pensionContributions` | —                                                                             | `PensionContribution[]` |

### Security
| method                | args                              | returns              |
| --------------------- | --------------------------------- | -------------------- |
| `securityOverview`    | —                                | `SecurityOverview`   |
| `setTwoFactor`        | `enabled`                        | `SecurityOverview`   |
| `devices`             | —                                | `SecurityDevice[]`   |
| `securityEvents`      | —                                | `SecurityEvent[]`    |
| `resolveSecurityEvent`| `eventId`                       | `SecurityEvent`      |

### Invoices & vendors
| method                 | args                                          | returns       |
| ---------------------- | --------------------------------------------- | ------------- |
| `invoices`             | —                                            | `Invoice[]`   |
| `createInvoice`        | `clientName`, `amount`, `dueDate`            | `Invoice`     |
| `updateInvoiceStatus`  | `invoiceId`, `status: InvoiceStatus`         | `Invoice`     |
| `vendors`              | —                                            | `Vendor[]`    |
| `createVendor`         | `name`                                       | `Vendor`      |

### Transfers & bill payments
| method           | args                                                                       | returns         |
| ---------------- | -------------------------------------------------------------------------- | --------------- |
| `transfers`      | —                                                                         | `Transfer[]`    |
| `transferById`   | `id`                                                                      | `Transfer`      |
| `createTransfer` | `sourceAccountId`, `payeeName`, `destination`, `amount`, `idempotencyKey` | `Transfer`      |
| `payees`        | —                                                                         | `Payee[]`      |
| `createPayee`    | `name`, `destination?`                                                    | `Payee`        |
| `billPayments`   | —                                                                         | `BillPayment[]`|
| `payBill`        | `category: BillCategory`, `billerName`, `amount`, `customerRef`, `sourceAccountId?` | `BillPayment` |
| `scheduleBill`   | `category: BillCategory`, `billerName`, `amount`, `customerRef`, `scheduledFor` | `BillPayment` |

## Enum `.name` values

- `PrimaryRole`: `individual`, `freelancer`, `entrepreneur`, `sme`
- `RoleScheme`: `standard`, `femaleFounder`
- `AccountType`: `checking`, `savings`, `mobileMoney`, `investment`, `loan`, `other`
- `TransactionDirection`: `inn`, `out`
- `GoalType`: `emergency`, `retirement`, `debt`, `home`, `education`, `taxShield`, `equipment`, `business`, `cashBuffer`, `other`
- `PensionFrequency`: `daily`, `weekly`, `monthly`
- `InvoiceStatus`: `draft`, `sent`, `paid`, `overdue`, `cancelled`
- `BillCategory`: `electricity`, `water`, `internet`, `airtime`, `tv`, `tax`, `insurance`, `rent`, `other`

## Example

Request:

```bash
curl -X POST https://your-bff.example.com/rpc \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <token>' \
  -d '{"method":"accounts","args":{}}'
```

Success:

```json
{ "data": [{ "id": "acc_1", "name": "Main", "type": "checking", "balance": 12500.0, "currency": "MUR", "institution": null }], "error": null }
```

Failure:

```json
{ "data": null, "error": { "code": "unauthorized", "message": "Session expired" } }
```
