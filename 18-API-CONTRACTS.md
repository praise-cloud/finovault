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
