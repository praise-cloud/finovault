import '../format.dart' show computeTransferFee;
import '../models.dart';
import 'db.dart';

class FvApiException implements Exception {
  FvApiException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

class AuthResult {
  const AuthResult({
    required this.user,
    required this.token,
    this.mfaRequired = false,
    this.challengeId,
    this.methods,
  });

  final UserProfile user;
  final String token;
  final bool mfaRequired;
  final String? challengeId;
  final List<String>? methods;

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'token': token,
    'mfaRequired': mfaRequired,
    'challengeId': challengeId,
    'methods': methods,
  };

  factory AuthResult.fromJson(Map<String, dynamic> j) => AuthResult(
    user: UserProfile.fromJson(j['user'] as Map<String, dynamic>),
    token: j['token'] as String,
    mfaRequired: (j['mfaRequired'] as bool?) ?? false,
    challengeId: j['challengeId'] as String?,
    methods: (j['methods'] as List?)?.cast<String>(),
  );
}

/// Backend-agnostic contract. `MockFinovaultApi` implements it against an
/// in-memory store; `HttpFinovaultApi` implements it against the BFF. Both
/// honour the envelope documented in 18-API-CONTRACTS.md.
abstract class FinovaultApi {
  Future<AuthResult> signup({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String country = 'MU',
  });
  Future<AuthResult> login({required String email, required String password});
  Future<UserProfile?> getSession(String? token);
  Future<void> logout(String? token);
  Future<UserProfile> updateMe(
    String? token, {
    String? fullName,
    String? avatarUrl,
    String? preferredLanguage,
    String? preferredCurrency,
  });
  Future<String> uploadAvatar(
    String? token, {
    required String mimeType,
    required String data,
  });
  Future<SecurityOverview> changePassword(
    String? token, {
    required String currentPassword,
    required String newPassword,
  });
  Future<void> requestPasswordReset(String email);
  Future<void> resetPassword(String resetToken, String newPassword);
  Future<UserPreferences> getPreferences(String? token);
  Future<UserPreferences> savePreferences(String? token, UserPreferences patch);
  Future<UserProfile> setRole(
    String? token, {
    required PrimaryRole primaryRole,
    required RoleScheme scheme,
  });
  Future<UserProfile> saveBusinessProfile(
    String? token,
    BusinessProfile profile,
  );
  Future<List<Account>> accounts(String? token);
  Future<Account> linkAccount(
    String? token, {
    required String name,
    required AccountType type,
    double balance = 0,
    String? institution,
  });
  Future<void> unlinkAccount(String? token, String accountId);
  Future<List<Transaction>> transactions(String? token, {int limit = 20});
  Future<Transaction> createTransaction(
    String? token, {
    required String accountId,
    required double amount,
    required TransactionDirection direction,
    required String category,
    String? merchantName,
  });
  Future<List<Budget>> budgets(String? token);
  Future<Budget> createBudget(
    String? token, {
    required String category,
    required double amount,
  });
  Future<List<SavingsGoal>> goals(String? token);
  Future<SavingsGoal> goal(String? token, String goalId);
  Future<SavingsGoal> createGoal(
    String? token, {
    required String name,
    required GoalType type,
    required double targetAmount,
    DateTime? targetDate,
  });
  Future<SavingsGoal> contribute(
    String? token, {
    required String goalId,
    required double amount,
    String? sourceAccountId,
  });
  Future<PensionPlan?> getPensionPlan(String? token);
  Future<PensionProjection> pensionProjection(String? token);
  Future<PensionPlan> upsertPensionPlan(
    String? token, {
    required double shortPotTarget,
    required double longPotTarget,
    required PensionFrequency frequency,
    required double contributionAmount,
    required double currentShortPot,
    required double currentLongPot,
    required double assumedReturnPct,
    required double inflationPct,
    required int currentAge,
    required int retirementAge,
    required bool autoDebit,
  });
  Future<PensionContribution> contributePension(
    String? token, {
    required String pot,
    required double amount,
    String? sourceAccountId,
  });
  Future<List<PensionContribution>> pensionContributions(String? token);
  Future<SecurityOverview> securityOverview(String? token);
  Future<SecurityOverview> setTwoFactor(String? token, {required bool enabled});
  Future<TwoFactorSetup> beginTwoFactorSetup(String? token);
  Future<SecurityOverview> verifyTwoFactorSetup(String? token, String code);
  Future<SecurityOverview> disableTwoFactor(String? token, String code);
  Future<void> resendOtp(
    String? token, {
    required String challengeId,
    required String method,
  });
  Future<AuthResult> verifyTwoFactorChallenge(String challengeId, String code);
  Future<List<SecurityDevice>> devices(String? token);
  Future<List<SecurityEvent>> securityEvents(String? token);
  Future<SecurityEvent> resolveSecurityEvent(String? token, String eventId);
  Future<List<Invoice>> invoices(String? token);
  Future<Invoice> createInvoice(
    String? token, {
    required String clientName,
    required double amount,
    required DateTime dueDate,
  });
  Future<Invoice> updateInvoiceStatus(
    String? token, {
    required String invoiceId,
    required InvoiceStatus status,
  });
  Future<List<Vendor>> vendors(String? token);
  Future<Vendor> createVendor(String? token, {required String name});
  Future<List<Transfer>> transfers(String? token);
  Future<Transfer> transferById(String? token, String id);
  Future<List<Payee>> payees(String? token);
  Future<Payee> createPayee(
    String? token, {
    required String name,
    String? destination,
  });
  Future<List<BillPayment>> billPayments(String? token);
  Future<BillPayment> payBill(
    String? token, {
    required BillCategory category,
    required String billerName,
    required double amount,
    required String customerRef,
    String? sourceAccountId,
  });
  Future<BillPayment> scheduleBill(
    String? token, {
    required BillCategory category,
    required String billerName,
    required double amount,
    required String customerRef,
    required DateTime scheduledFor,
  });
  Future<List<AppNotification>> notifications(String? token);
  Future<void> markNotificationRead(
    String? token, {
    required String notificationId,
  });
  Future<int> markAllNotificationsRead(String? token);
  Future<UserProfile> acceptPrivacyPolicy(String? token);
  Future<AccountVerification> verifyAccount(
    String? token, {
    required String institution,
    required String identifier,
    required String holderName,
  });

  Future<BankLinkResult> linkBankAccount(
    String? token, {
    required String institution,
    required String accountNumber,
    String? holderName,
  });

  Future<Transfer> createTransfer(
    String? token, {
    required String sourceAccountId,
    required String payeeName,
    required String destination,
    required double amount,
    required String idempotencyKey,
    String? holderName,
  });

  Future<StatementUploadResult> uploadStatement(
    String? token, {
    required String accountId,
    required String fileName,
    required String fileType,
    required String data,
  });
  Future<PaymentLinkResult> generatePaymentLink(
    String? token, {
    required String accountId,
    required double amount,
    required String recipient,
  });
  Future<MauCasQrResult> generateMauCasQr(
    String? token, {
    required double amount,
    required String recipient,
  });
}

/// Mock API standing in for the future Finovault backend — same endpoints and
/// envelope semantics as finovault-web/lib/api + the Expo app's handlers.
/// Swap the internals for HTTP when the real backend lands.
class MockFinovaultApi extends FinovaultApi {
  MockFinovaultApi({
    required this._db,
    this.latency = const Duration(milliseconds: 250),
  });

  final MockDb _db;
  Duration latency;

  Future<void> _tick() async {
    if (latency > Duration.zero) await Future.delayed(latency);
  }

  UserProfile? userByToken(String? token) => _db.userByToken(token);

  Future<UserProfile> _requireUser(String? token) async {
    await _tick();
    final user = _db.userByToken(token);
    if (user == null)
      throw FvApiException(
        'unauthorized',
        'Your session has expired. Please log in again.',
      );
    return user;
  }

  void _requireUserSync(String? token) {
    final user = _db.userByToken(token);
    if (user == null)
      throw FvApiException(
        'unauthorized',
        'Your session has expired. Please log in again.',
      );
  }

  // ---- auth ----------------------------------------------------------------

  @override
  Future<AuthResult> signup({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String country = 'MU',
  }) async {
    await _tick();
    final normalized = email.trim().toLowerCase();
    final phoneClean = phone.trim();
    final ctry = country.trim().toUpperCase();
    if (fullName.trim().isEmpty ||
        normalized.isEmpty ||
        password.isEmpty ||
        phoneClean.isEmpty) {
      throw FvApiException('validation', 'Please fill in every field.');
    }
    final isNg = ctry == 'NG';
    if (isNg) {
      if (!_nigerianPhonePattern.hasMatch(phoneClean)) {
        throw FvApiException(
          'validation',
          'Please enter a valid Nigerian mobile number (e.g. 08012345678).',
        );
      }
    } else {
      if (_mobilePattern.hasMatch(phoneClean) == false) {
        throw FvApiException(
          'validation',
          'Phone must be 5–8 digits starting with 5–7.',
        );
      }
    }
    if (_db.credentials.containsKey(normalized)) {
      throw FvApiException(
        'email_taken',
        'An account with this email already exists.',
      );
    }
    final uid = _db.nextId('user');
    final user = UserProfile(
      id: uid,
      email: normalized,
      fullName: fullName.trim(),
      phone: phoneClean,
      country: isNg ? 'NG' : 'MU',
      primaryRole: PrimaryRole.individual,
      scheme: RoleScheme.standard,
      preferredCurrency: isNg ? 'NGN' : 'MUR',
      createdAt: DateTime.now(),
    );
    _db.users[uid] = user;
    _db.credentials[normalized] = password;
    _db.prefsByUser[uid] = const UserPreferences();

    // Seed default accounts based on country
    if (isNg) {
      _db.accounts[uid] = [
        Account(
          id: _db.nextId('acc'),
          name: 'GTBank Current',
          type: AccountType.bank,
          balance: 850000.0,
          institution: 'GTBank',
          currency: 'NGN',
          accountNumber: '0123456789',
        ),
        Account(
          id: _db.nextId('acc'),
          name: 'OPay Wallet',
          type: AccountType.mobileMoney,
          balance: 45000.0,
          institution: 'OPay',
          currency: 'NGN',
          accountNumber: phoneClean,
        ),
      ];
    } else {
      _db.accounts[uid] = [
        Account(
          id: _db.nextId('acc'),
          name: 'SBM Current',
          type: AccountType.bank,
          balance: 124500.0,
          institution: 'SBM',
          currency: 'MUR',
          accountNumber: '12345678',
        ),
        Account(
          id: _db.nextId('acc'),
          name: 'MCB Mobile',
          type: AccountType.mobileMoney,
          balance: 8600.0,
          institution: 'MCB',
          currency: 'MUR',
          accountNumber: phoneClean,
        ),
      ];
    }
    await _db.persist();

    return AuthResult(user: user, token: _createSession(uid));
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    await _tick();
    final normalized = email.trim().toLowerCase();
    final uid = _db.users.entries
        .where((e) => e.value.email == normalized)
        .map((e) => e.key)
        .firstWhere((_) => true, orElse: () => '');
    final stored = _db.credentials[normalized];
    if (uid.isEmpty || stored == null || stored != password) {
      throw FvApiException(
        'invalid_credentials',
        'Incorrect email or password. Please try again.',
      );
    }
    final ov = _db.securityOverviews[uid];
    if (ov?.twoFactorEnabled == true) {
      final challengeId = _db.nextId('mfa');
      _db.mfaChallenges[challengeId] = MfaChallenge(
        userId: uid,
        methods: ['totp', 'email'],
      );
      return AuthResult(
        user: UserProfile(
          id: uid,
          email: normalized,
          fullName: '',
          primaryRole: PrimaryRole.individual,
          scheme: RoleScheme.standard,
          createdAt: DateTime.now(),
        ),
        token: '',
        mfaRequired: true,
        challengeId: challengeId,
        methods: ['totp', 'email'],
      );
    }
    return AuthResult(user: _db.users[uid]!, token: _createSession(uid));
  }

  String _createSession(String uid) {
    final token = 'mock_jwt_${uid}_${DateTime.now().millisecondsSinceEpoch}';
    _db.sessions[token] = uid;
    return token;
  }

  /// Re-validates a stored token on cold start; returns null when stale.
  @override
  Future<UserProfile?> getSession(String? token) async {
    try {
      return await _requireUser(token);
    } on FvApiException {
      return null;
    }
  }

  @override
  Future<void> logout(String? token) async {
    await _tick();
    _db.sessions.remove(token);
  }

  // ---- users ----------------------------------------------------------------

  @override
  Future<UserProfile> updateMe(
    String? token, {
    String? fullName,
    String? avatarUrl,
    String? preferredLanguage,
    String? preferredCurrency,
  }) async {
    final user = await _requireUser(token);
    final updated = user.copyWith(
      fullName: fullName,
      avatarUrl: avatarUrl,
      preferredLanguage: preferredLanguage,
      preferredCurrency: preferredCurrency,
    );
    _db.users[user.id] = updated;
    await _db.persist();
    return updated;
  }

  @override
  Future<String> uploadAvatar(
    String? token, {
    required String mimeType,
    required String data,
  }) async {
    final user = await _requireUser(token);
    if (data.isEmpty || !mimeType.startsWith('image/')) {
      throw FvApiException(
        'validation',
        'Please choose an image to use as your profile picture.',
      );
    }
    // Mock: store the base64 blob inline as a data URI so it renders anywhere
    // without a storage bucket. The real backend uploads to Supabase Storage
    // and returns a public https URL — same contract.
    final uri = 'data:$mimeType;base64,$data';
    final updated = _db.users[user.id]!.copyWith(avatarUrl: uri);
    _db.users[user.id] = updated;
    await _db.persist();
    return uri;
  }

  @override
  Future<SecurityOverview> changePassword(
    String? token, {
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = await _requireUser(token);
    if (newPassword.length < 8) {
      throw FvApiException(
        'validation',
        'Password must be at least 8 characters.',
      );
    }
    if (_db.credentials[user.email] != currentPassword) {
      throw FvApiException(
        'incorrect_password',
        'Your current password is incorrect.',
      );
    }
    if (currentPassword == newPassword) {
      throw FvApiException(
        'validation',
        'New password must be different from your current password.',
      );
    }
    _db.credentials[user.email] = newPassword;
    (_db.securityEvents[user.id] ??= []).add(
      SecurityEvent(
        id: _db.nextId('evt'),
        title: 'Password changed',
        description: 'Your password was changed from this device.',
        severity: EventSeverity.low,
        date: DateTime.now(),
      ),
    );
    final overview =
        _db.securityOverviews[user.id] ?? const SecurityOverview(score: 72);
    _db.securityOverviews[user.id] = overview.copyWith(
      score: (overview.score + 5).clamp(5, 99),
      lastPasswordChange: DateTime.now(),
    );
    await _db.persist();
    return securityOverview(token);
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await _tick();
    final normalized = email.trim().toLowerCase();
    if (!_db.credentials.containsKey(normalized))
      return; // never confirm account existence
    final token =
        'reset_${DateTime.now().millisecondsSinceEpoch}_${_db.nextId('rst')}';
    _db.passwordResetTokens[token] = normalized;
    _db.passwordResetIssuedAt[token] = DateTime.now();
    await _db.persist();
  }

  @override
  Future<void> resetPassword(String resetToken, String newPassword) async {
    await _tick();
    final email = _db.passwordResetTokens[resetToken];
    if (email == null) {
      throw FvApiException(
        'invalid_reset_token',
        'This reset link has expired or has already been used.',
      );
    }
    final issued = _db.passwordResetIssuedAt[resetToken];
    if (issued == null ||
        DateTime.now().difference(issued) > const Duration(minutes: 30)) {
      _db.passwordResetTokens.remove(resetToken);
      _db.passwordResetIssuedAt.remove(resetToken);
      throw FvApiException(
        'invalid_reset_token',
        'This reset link has expired or has already been used.',
      );
    }
    if (newPassword.length < 8) {
      throw FvApiException(
        'validation',
        'Password must be at least 8 characters.',
      );
    }
    _db.credentials[email] = newPassword;
    _db.passwordResetTokens.remove(resetToken);
    _db.passwordResetIssuedAt.remove(resetToken);
    // Invalidate any existing sessions so a reset can't be replayed.
    _db.sessions.removeWhere((_, uid) => _db.users[uid]?.email == email);
    await _db.persist();
  }

  @override
  Future<UserPreferences> getPreferences(String? token) async {
    final user = await _requireUser(token);
    return _db.prefsByUser[user.id] ?? const UserPreferences();
  }

  @override
  Future<UserPreferences> savePreferences(
    String? token,
    UserPreferences patch,
  ) async {
    final user = await _requireUser(token);
    final merged = (_db.prefsByUser[user.id] ?? const UserPreferences())
        .copyWith(
          financialGoals: patch.financialGoals.isNotEmpty
              ? patch.financialGoals
              : null,
          riskTolerance: patch.riskTolerance,
          moneyFears: patch.moneyFears,
          onboardingCompleted: patch.onboardingCompleted,
        );
    _db.prefsByUser[user.id] = merged;
    await _db.persist();
    return merged;
  }

  @override
  Future<UserProfile> setRole(
    String? token, {
    required PrimaryRole primaryRole,
    required RoleScheme scheme,
  }) async {
    final user = await _requireUser(token);
    final updated = user.copyWith(primaryRole: primaryRole, scheme: scheme);
    _db.users[user.id] = updated;
    await _db.persist();
    return updated;
  }

  @override
  Future<UserProfile> saveBusinessProfile(
    String? token,
    BusinessProfile profile,
  ) async {
    final user = await _requireUser(token);
    final updated = user.copyWith(businessProfile: profile);
    _db.users[user.id] = updated;
    await _db.persist();
    return updated;
  }

  // ---- money: accounts & transactions ---------------------------------------

  @override
  Future<List<Account>> accounts(String? token) async {
    final user = await _requireUser(token);
    return List.of(_db.accounts[user.id] ?? const <Account>[]);
  }

  @override
  Future<Account> linkAccount(
    String? token, {
    required String name,
    required AccountType type,
    double balance = 0,
    String? institution,
  }) async {
    final user = await _requireUser(token);
    final account = Account(
      id: _db.nextId('acc'),
      name: name.trim(),
      type: type,
      balance: balance,
      institution: institution?.trim(),
    );
    (_db.accounts[user.id] ??= []).add(account);
    await _db.persist();
    return account;
  }

  @override
  Future<void> unlinkAccount(String? token, String accountId) async {
    final user = await _requireUser(token);
    _db.accounts[user.id]?.removeWhere((a) => a.id == accountId);
    await _db.persist();
  }

  @override
  Future<List<Transaction>> transactions(
    String? token, {
    int limit = 20,
  }) async {
    final user = await _requireUser(token);
    final list = List.of(_db.transactions[user.id] ?? const <Transaction>[]);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list.take(limit).toList();
  }

  @override
  Future<Transaction> createTransaction(
    String? token, {
    required String accountId,
    required double amount,
    required TransactionDirection direction,
    required String category,
    String? merchantName,
  }) async {
    _requireUserSync(token);
    if (amount <= 0)
      throw FvApiException('validation', 'Amount must be greater than zero.');
    final tx = Transaction(
      id: _db.nextId('tx'),
      accountId: accountId,
      amount: amount,
      direction: direction,
      category: category.trim(),
      merchantName: merchantName?.trim(),
      date: DateTime.now(),
      isExpense: direction == TransactionDirection.out,
    );
    (_db.transactions[tokenUserId(token)!] ??= []).add(tx);
    await _db.persist();
    return tx;
  }

  // ---- budgets ---------------------------------------------------------------

  @override
  Future<List<Budget>> budgets(String? token) async {
    final user = await _requireUser(token);
    return List.of(_db.budgets[user.id] ?? const <Budget>[]);
  }

  @override
  Future<Budget> createBudget(
    String? token, {
    required String category,
    required double amount,
  }) async {
    final user = await _requireUser(token);
    final existing = _db.budgets[user.id] ?? <Budget>[];
    final match = existing
        .where((b) => b.category.toLowerCase() == category.trim().toLowerCase())
        .toList();
    Budget budget;
    if (match.isNotEmpty) {
      budget = Budget(
        id: match.first.id,
        category: category.trim(),
        amount: amount,
      );
      existing[existing.indexOf(match.first)] = budget;
    } else {
      budget = Budget(
        id: _db.nextId('bud'),
        category: category.trim(),
        amount: amount,
      );
      existing.add(budget);
    }
    _db.budgets[user.id] = existing;
    await _db.persist();
    return budget;
  }

  // ---- goals -----------------------------------------------------------------

  @override
  Future<List<SavingsGoal>> goals(String? token) async {
    final user = await _requireUser(token);
    return List.of(_db.goals[user.id] ?? const <SavingsGoal>[]);
  }

  @override
  Future<SavingsGoal> goal(String? token, String goalId) async {
    final user = await _requireUser(token);
    final match = (_db.goals[user.id] ?? [])
        .where((g) => g.id == goalId)
        .toList();
    if (match.isEmpty) throw FvApiException('not_found', 'Goal not found.');
    return match.first;
  }

  @override
  Future<SavingsGoal> createGoal(
    String? token, {
    required String name,
    required GoalType type,
    required double targetAmount,
    DateTime? targetDate,
  }) async {
    _requireUserSync(token);
    if (name.trim().isEmpty || targetAmount <= 0) {
      throw FvApiException(
        'validation',
        'Give your goal a name and a target above zero.',
      );
    }
    final g = SavingsGoal(
      id: _db.nextId('goal'),
      name: name.trim(),
      type: type,
      targetAmount: targetAmount,
      targetDate: targetDate,
    );
    (_db.goals[tokenUserId(token)!] ??= []).add(g);
    await _db.persist();
    return g;
  }

  @override
  Future<SavingsGoal> contribute(
    String? token, {
    required String goalId,
    required double amount,
    String? sourceAccountId,
  }) async {
    final user = await _requireUser(token);
    final list = _db.goals[user.id] ?? [];
    final index = list.indexWhere((g) => g.id == goalId);
    if (index < 0) throw FvApiException('not_found', 'Goal not found.');
    if (amount <= 0)
      throw FvApiException('validation', 'Amount must be greater than zero.');

    if (sourceAccountId != null) {
      final accs = _db.accounts[user.id] ?? [];
      final ai = accs.indexWhere((a) => a.id == sourceAccountId);
      if (ai < 0) throw FvApiException('not_found', 'Account not found.');
      if (accs[ai].balance < amount)
        throw FvApiException(
          'insufficient_funds',
          'Not enough funds in this account.',
        );
      accs[ai] = accs[ai].copyWith(balance: accs[ai].balance - amount);
      (_db.transactions[user.id] ??= []).add(
        Transaction(
          id: _db.nextId('tx'),
          accountId: sourceAccountId,
          amount: amount,
          direction: TransactionDirection.out,
          category: 'Savings',
          merchantName: list[index].name,
          date: DateTime.now(),
        ),
      );
    }

    var updated = list[index];
    final contribution = GoalContribution(
      id: _db.nextId('con'),
      goalId: goalId,
      amount: amount,
      date: DateTime.now(),
      sourceAccountId: sourceAccountId,
    );
    final newCurrent = updated.currentAmount + amount;
    updated = updated.copyWith(
      currentAmount: newCurrent,
      completed: updated.completed || newCurrent >= updated.targetAmount,
      contributions: [...updated.contributions, contribution],
    );
    list[index] = updated;
    await _db.persist();
    return updated;
  }

  // ---- pension (Phase 4) -------------------------------------------------------

  @override
  Future<PensionPlan?> getPensionPlan(String? token) async {
    final uid = tokenUserId(token);
    if (uid == null) return null;
    return _db.pensions[uid];
  }

  @override
  Future<PensionProjection> pensionProjection(String? token) async {
    final plan = await getPensionPlan(token);
    if (plan == null) {
      return const PensionProjection(
        shortPotProjected: 0,
        longPotProjected: 0,
        totalProjected: 0,
        yearsToRetirement: 0,
      );
    }
    return plan.computeProjection();
  }

  @override
  Future<PensionPlan> upsertPensionPlan(
    String? token, {
    required double shortPotTarget,
    required double longPotTarget,
    required PensionFrequency frequency,
    required double contributionAmount,
    required double currentShortPot,
    required double currentLongPot,
    required double assumedReturnPct,
    required double inflationPct,
    required int currentAge,
    required int retirementAge,
    required bool autoDebit,
  }) async {
    final uid = tokenUserId(token);
    if (uid == null)
      throw FvApiException(
        'unauthorized',
        'Your session has expired. Please log in again.',
      );
    if (shortPotTarget <= 0 || longPotTarget <= 0 || contributionAmount <= 0) {
      throw FvApiException(
        'validation',
        'Set a positive target and contribution for both pots.',
      );
    }
    final existing = _db.pensions[uid];
    final plan = PensionPlan(
      id: existing?.id ?? _db.nextId('pen'),
      shortPotTarget: shortPotTarget,
      longPotTarget: longPotTarget,
      frequency: frequency,
      contributionAmount: contributionAmount,
      currentShortPot: currentShortPot,
      currentLongPot: currentLongPot,
      assumedReturnPct: assumedReturnPct,
      inflationPct: inflationPct,
      currentAge: currentAge,
      retirementAge: retirementAge,
      autoDebit: autoDebit,
      updatedAt: DateTime.now(),
    );
    _db.pensions[uid] = plan;
    await _db.persist();
    return plan;
  }

  @override
  Future<PensionContribution> contributePension(
    String? token, {
    required String pot,
    required double amount,
    String? sourceAccountId,
  }) async {
    final user = await _requireUser(token);
    final plan = _db.pensions[user.id];
    if (plan == null)
      throw FvApiException(
        'not_found',
        'No pension plan found. Create one first.',
      );
    if (amount <= 0)
      throw FvApiException('validation', 'Amount must be greater than zero.');

    final isShort = pot == 'short';
    if (sourceAccountId != null) {
      final accs = _db.accounts[user.id] ?? [];
      final ai = accs.indexWhere((a) => a.id == sourceAccountId);
      if (ai < 0) throw FvApiException('not_found', 'Account not found.');
      if (accs[ai].balance < amount)
        throw FvApiException(
          'insufficient_funds',
          'Not enough funds in this account.',
        );
      accs[ai] = accs[ai].copyWith(balance: accs[ai].balance - amount);
      (_db.transactions[user.id] ??= []).add(
        Transaction(
          id: _db.nextId('tx'),
          accountId: sourceAccountId,
          amount: amount,
          direction: TransactionDirection.out,
          category: 'Pension',
          merchantName: 'Finovault Pension',
          date: DateTime.now(),
        ),
      );
    }

    _db.pensions[user.id] = plan.copyWith(
      currentShortPot: isShort
          ? plan.currentShortPot + amount
          : plan.currentShortPot,
      currentLongPot: isShort
          ? plan.currentLongPot
          : plan.currentLongPot + amount,
    );

    final contribution = PensionContribution(
      id: _db.nextId('pencon'),
      planId: plan.id,
      pot: pot,
      amount: amount,
      date: DateTime.now(),
      sourceAccountId: sourceAccountId,
    );
    (_db.pensionContributions[user.id] ??= []).add(contribution);
    await _db.persist();
    return contribution;
  }

  @override
  Future<List<PensionContribution>> pensionContributions(String? token) async {
    final user = await _requireUser(token);
    final list =
        _db.pensionContributions[user.id] ?? const <PensionContribution>[];
    return [...list]..sort((a, b) => b.date.compareTo(a.date));
  }

  // ---- security ----------------------------------------------------------------

  int securityScoreFor(String userId) {
    final open = (_db.securityEvents[userId] ?? [])
        .where((e) => !e.resolved)
        .toList();
    final twoFactor = _db.securityOverviews[userId]?.twoFactorEnabled ?? false;
    var score = 100 - (twoFactor ? 0 : 20);
    for (final e in open) {
      score -= e.severity == EventSeverity.high
          ? 15
          : (e.severity == EventSeverity.medium ? 8 : 3);
    }
    return score.clamp(5, 99);
  }

  @override
  Future<SecurityOverview> securityOverview(String? token) async {
    final user = await _requireUser(token);
    final stored =
        _db.securityOverviews[user.id] ?? const SecurityOverview(score: 72);
    return stored.copyWith(score: securityScoreFor(user.id));
  }

  @override
  Future<SecurityOverview> setTwoFactor(
    String? token, {
    required bool enabled,
  }) async {
    final user = await _requireUser(token);
    final updated =
        (_db.securityOverviews[user.id] ?? const SecurityOverview(score: 72))
            .copyWith(twoFactorEnabled: enabled);
    _db.securityOverviews[user.id] = updated;
    await _db.persist();
    return securityOverview(token);
  }

  // ---- 2FA -----------------------------------------------------------------

  String _generateTotpSecret() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    return List.generate(
      16,
      (_) => chars[DateTime.now().microsecondsSinceEpoch % chars.length],
    ).join();
  }

  List<String> _generateBackupCodes() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = DateTime.now().microsecondsSinceEpoch;
    return List.generate(8, (i) {
      final seed = rng + i * 137;
      return List.generate(
        8,
        (j) => chars[(seed + j * 31) % chars.length],
      ).join();
    });
  }

  String _computeTotpCode(String secret, DateTime time) {
    final window = (time.millisecondsSinceEpoch ~/ 30000).toRadixString(16);
    final hash =
        (secret.codeUnits.fold<int>(
          0,
          (h, c) => (h * 31 + c) ^ window.hashCode,
        ) &
        0x7FFFFFFF);
    return (hash % 1000000).toString().padLeft(6, '0');
  }

  @override
  Future<TwoFactorSetup> beginTwoFactorSetup(String? token) async {
    final user = await _requireUser(token);
    final secret = _generateTotpSecret();
    _db.mfaSecrets[user.id] = secret;
    final codes = _generateBackupCodes();
    _db.mfaBackupCodes[user.id] = codes;
    final qrUrl =
        'otpauth://totp/Finovault:${user.email}?secret=$secret&issuer=Finovault&algorithm=SHA1&digits=6&period=30';
    await _db.persist();
    return TwoFactorSetup(secret: secret, qrUrl: qrUrl, backupCodes: codes);
  }

  @override
  Future<SecurityOverview> verifyTwoFactorSetup(
    String? token,
    String code,
  ) async {
    final user = await _requireUser(token);
    final secret = _db.mfaSecrets[user.id];
    if (secret == null)
      throw FvApiException(
        'validation',
        'No pending 2FA setup. Start setup first.',
      );
    final now = DateTime.now();
    final currentCode = _computeTotpCode(secret, now);
    final prevCode = _computeTotpCode(
      secret,
      now.subtract(const Duration(seconds: 30)),
    );
    final nextCode = _computeTotpCode(
      secret,
      now.add(const Duration(seconds: 30)),
    );
    if (code != currentCode && code != prevCode && code != nextCode) {
      throw FvApiException(
        'invalid_code',
        'Invalid code. Please check your authenticator app and try again.',
      );
    }
    _db.securityOverviews[user.id] =
        (_db.securityOverviews[user.id] ?? const SecurityOverview(score: 72))
            .copyWith(
              twoFactorEnabled: true,
              score: ((_db.securityOverviews[user.id]?.score ?? 72) + 20).clamp(
                5,
                99,
              ),
            );
    (_db.securityEvents[user.id] ??= []).insert(
      0,
      SecurityEvent(
        id: _db.nextId('evt'),
        title: 'Two-factor authentication enabled',
        severity: EventSeverity.low,
        date: DateTime.now(),
      ),
    );
    await _db.persist();
    return securityOverview(token);
  }

  @override
  Future<SecurityOverview> disableTwoFactor(String? token, String code) async {
    final user = await _requireUser(token);
    final secret = _db.mfaSecrets[user.id];
    if (secret != null) {
      final now = DateTime.now();
      final currentCode = _computeTotpCode(secret, now);
      final prevCode = _computeTotpCode(
        secret,
        now.subtract(const Duration(seconds: 30)),
      );
      final nextCode = _computeTotpCode(
        secret,
        now.add(const Duration(seconds: 30)),
      );
      if (code != currentCode && code != prevCode && code != nextCode) {
        final backupCodes = _db.mfaBackupCodes[user.id];
        if (backupCodes == null || !backupCodes.contains(code)) {
          throw FvApiException(
            'invalid_code',
            'Invalid code. Please try again.',
          );
        }
        backupCodes.remove(code);
      }
    }
    _db.mfaSecrets.remove(user.id);
    _db.mfaBackupCodes.remove(user.id);
    _db.securityOverviews[user.id] =
        (_db.securityOverviews[user.id] ?? const SecurityOverview(score: 72))
            .copyWith(twoFactorEnabled: false);
    (_db.securityEvents[user.id] ??= []).insert(
      0,
      SecurityEvent(
        id: _db.nextId('evt'),
        title: 'Two-factor authentication disabled',
        severity: EventSeverity.medium,
        date: DateTime.now(),
      ),
    );
    await _db.persist();
    return securityOverview(token);
  }

  @override
  Future<void> resendOtp(
    String? token, {
    required String challengeId,
    required String method,
  }) async {
    await _tick();
    // In mock mode, the OTP code is derived from the TOTP secret + current window.
    // For email OTP we just log it to console — the real backend sends via Resend.
    final challenge = _db.mfaChallenges[challengeId];
    if (challenge == null || challenge.isExpired) {
      throw FvApiException(
        'invalid_challenge',
        'This challenge has expired. Please log in again.',
      );
    }
    if (method == 'email') {
      final secret = _db.mfaSecrets[challenge.userId] ?? _generateTotpSecret();
      final code = _computeTotpCode(secret, DateTime.now());
      // ignore: avoid_print
      print('[DEV] Email OTP for challenge $challengeId: $code');
    }
  }

  @override
  Future<AuthResult> verifyTwoFactorChallenge(
    String challengeId,
    String code,
  ) async {
    await _tick();
    final challenge = _db.mfaChallenges[challengeId];
    if (challenge == null || challenge.isExpired) {
      throw FvApiException(
        'invalid_challenge',
        'This challenge has expired. Please log in again.',
      );
    }
    final secret = _db.mfaSecrets[challenge.userId];
    if (secret != null) {
      final now = DateTime.now();
      final currentCode = _computeTotpCode(secret, now);
      final prevCode = _computeTotpCode(
        secret,
        now.subtract(const Duration(seconds: 30)),
      );
      final nextCode = _computeTotpCode(
        secret,
        now.add(const Duration(seconds: 30)),
      );
      if (code != currentCode && code != prevCode && code != nextCode) {
        final backupCodes = _db.mfaBackupCodes[challenge.userId];
        if (backupCodes == null || !backupCodes.contains(code)) {
          throw FvApiException(
            'invalid_code',
            'Invalid code. Please try again.',
          );
        }
        backupCodes.remove(code);
      }
    }
    _db.mfaChallenges.remove(challengeId);
    final user = _db.users[challenge.userId]!;
    (_db.securityEvents[challenge.userId] ??= []).insert(
      0,
      SecurityEvent(
        id: _db.nextId('evt'),
        title: 'Successful login with 2FA',
        severity: EventSeverity.low,
        date: DateTime.now(),
      ),
    );
    await _db.persist();
    return AuthResult(user: user, token: _createSession(challenge.userId));
  }

  @override
  Future<List<SecurityDevice>> devices(String? token) async {
    final user = await _requireUser(token);
    return List.of(_db.devices[user.id] ?? const <SecurityDevice>[]);
  }

  @override
  Future<List<SecurityEvent>> securityEvents(String? token) async {
    final user = await _requireUser(token);
    return List.of(_db.securityEvents[user.id] ?? const <SecurityEvent>[]);
  }

  @override
  Future<SecurityEvent> resolveSecurityEvent(
    String? token,
    String eventId,
  ) async {
    final user = await _requireUser(token);
    final list = _db.securityEvents[user.id] ?? [];
    final index = list.indexWhere((e) => e.id == eventId);
    if (index < 0) throw FvApiException('not_found', 'Event not found.');
    list[index] = list[index].copyWith(resolved: true);
    await _db.persist();
    return list[index];
  }

  // ---- invoices & vendors ---------------------------------------------------------

  @override
  Future<List<Invoice>> invoices(String? token) async {
    final user = await _requireUser(token);
    final list = List.of(_db.invoices[user.id] ?? const <Invoice>[]);
    list.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    return list;
  }

  @override
  Future<Invoice> createInvoice(
    String? token, {
    required String clientName,
    required double amount,
    required DateTime dueDate,
  }) async {
    _requireUserSync(token);
    if (clientName.trim().isEmpty || amount <= 0) {
      throw FvApiException('validation', 'Client and amount are required.');
    }
    final invoice = Invoice(
      id: _db.nextId('inv'),
      clientName: clientName.trim(),
      amount: amount,
      dueDate: dueDate,
      status: InvoiceStatus.sent,
    );
    (_db.invoices[tokenUserId(token)!] ??= []).add(invoice);
    await _db.persist();
    return invoice;
  }

  @override
  Future<Invoice> updateInvoiceStatus(
    String? token, {
    required String invoiceId,
    required InvoiceStatus status,
  }) async {
    final user = await _requireUser(token);
    final list = _db.invoices[user.id] ?? [];
    final index = list.indexWhere((i) => i.id == invoiceId);
    if (index < 0) throw FvApiException('not_found', 'Invoice not found.');
    list[index] = list[index].copyWith(status: status);
    await _db.persist();
    return list[index];
  }

  @override
  Future<List<Vendor>> vendors(String? token) async {
    final user = await _requireUser(token);
    return List.of(_db.vendors[user.id] ?? const <Vendor>[]);
  }

  @override
  Future<Vendor> createVendor(String? token, {required String name}) async {
    final user = await _requireUser(token);
    if (name.trim().isEmpty)
      throw FvApiException('validation', 'Vendor name is required.');
    final vendor = Vendor(id: _db.nextId('ven'), name: name.trim());
    (_db.vendors[user.id] ??= []).add(vendor);
    await _db.persist();
    return vendor;
  }

  // ---- transfers -----------------------------------------------------------------

  @override
  Future<List<Transfer>> transfers(String? token) async {
    final user = await _requireUser(token);
    final list = List.of(_db.transfers[user.id] ?? const <Transfer>[]);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<Transfer> transferById(String? token, String id) async {
    final user = await _requireUser(token);
    final match = (_db.transfers[user.id] ?? [])
        .where((t) => t.id == id)
        .toList();
    if (match.isEmpty) throw FvApiException('not_found', 'Transfer not found.');
    return match.first;
  }

  @override
  Future<Transfer> createTransfer(
    String? token, {
    required String sourceAccountId,
    required String payeeName,
    required String destination,
    required double amount,
    required String idempotencyKey,
    String? holderName,
  }) async {
    final user = await _requireUser(token);
    final existing = (_db.transfers[user.id] ?? [])
        .where((t) => t.idempotencyKey == idempotencyKey)
        .toList();
    if (existing.isNotEmpty) return existing.first;

    final accs = _db.accounts[user.id] ?? [];
    final index = accs.indexWhere((a) => a.id == sourceAccountId);
    if (index < 0)
      throw FvApiException('not_found', 'Source account not found.');
    if (amount <= 0)
      throw FvApiException('validation', 'Amount must be greater than zero.');

    if (holderName != null) {
      final check = await verifyAccount(
        token,
        institution: 'juice',
        identifier: destination.replaceAll(RegExp(r'\s'), ''),
        holderName: holderName,
      );
      if (!check.verified) {
        throw FvApiException(
          'verification_failed',
          check.exists
              ? 'The holder name does not match the registered name.'
              : 'Destination account not found.',
        );
      }
    }
    final fee = computeTransferFee(amount);
    final total = amount + fee;
    if (accs[index].balance < total) {
      throw FvApiException(
        'insufficient_funds',
        'Not enough funds — total with fees is $total.',
      );
    }

    accs[index] = accs[index].copyWith(balance: accs[index].balance - total);
    final transfer = Transfer(
      id: _db.nextId('trf'),
      sourceAccountId: sourceAccountId,
      payeeName: payeeName.trim(),
      destination: destination.trim(),
      amount: amount,
      fee: fee,
      total: total,
      status: TransferStatus.completed,
      createdAt: DateTime.now(),
      externalRef: 'FV${DateTime.now().millisecondsSinceEpoch % 1000000}',
      idempotencyKey: idempotencyKey,
    );
    (_db.transfers[user.id] ??= []).insert(0, transfer);
    (_db.transactions[user.id] ??= []).add(
      Transaction(
        id: _db.nextId('tx'),
        accountId: sourceAccountId,
        amount: total,
        direction: TransactionDirection.out,
        category: 'Transfer',
        merchantName: transfer.payeeName,
        date: transfer.createdAt,
      ),
    );
    await _db.persist();
    return transfer;
  }

  // ---- bills & payees -------------------------------------------------------------

  @override
  Future<List<Payee>> payees(String? token) async {
    final user = await _requireUser(token);
    return List.of(_db.payees[user.id] ?? const <Payee>[]);
  }

  @override
  Future<Payee> createPayee(
    String? token, {
    required String name,
    String? destination,
  }) async {
    final user = await _requireUser(token);
    if (name.trim().isEmpty)
      throw FvApiException('validation', 'Payee name is required.');
    final payee = Payee(
      id: _db.nextId('pay'),
      name: name.trim(),
      destination: destination?.trim(),
    );
    (_db.payees[user.id] ??= []).add(payee);
    await _db.persist();
    return payee;
  }

  static const billCategories = BillCategory.values;

  @override
  Future<List<BillPayment>> billPayments(String? token) async {
    final user = await _requireUser(token);
    final list = List.of(_db.billPayments[user.id] ?? const <BillPayment>[]);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<BillPayment> payBill(
    String? token, {
    required BillCategory category,
    required String billerName,
    required double amount,
    required String customerRef,
    String? sourceAccountId,
  }) async {
    final user = await _requireUser(token);
    final accs = _db.accounts[user.id] ?? [];
    final accId = sourceAccountId ?? (accs.isNotEmpty ? accs.first.id : '');
    final index = accs.indexWhere((a) => a.id == accId);
    if (index < 0) throw FvApiException('not_found', 'No account to pay from.');
    if (amount <= 0)
      throw FvApiException('validation', 'Amount must be greater than zero.');
    if (accs[index].balance < amount)
      throw FvApiException(
        'insufficient_funds',
        'Not enough funds for this bill.',
      );

    accs[index] = accs[index].copyWith(balance: accs[index].balance - amount);
    final payment = BillPayment(
      id: _db.nextId('bill'),
      category: category,
      billerName: billerName,
      amount: amount,
      status: BillPaymentStatus.paid,
      date: DateTime.now(),
      customerRef: customerRef,
    );
    (_db.billPayments[user.id] ??= []).insert(0, payment);
    (_db.transactions[user.id] ??= []).add(
      Transaction(
        id: _db.nextId('tx'),
        accountId: accId,
        amount: amount,
        direction: TransactionDirection.out,
        category: 'Bills',
        merchantName: billerName,
        date: payment.date,
      ),
    );
    await _db.persist();
    return payment;
  }

  @override
  Future<BillPayment> scheduleBill(
    String? token, {
    required BillCategory category,
    required String billerName,
    required double amount,
    required String customerRef,
    required DateTime scheduledFor,
  }) async {
    final user = await _requireUser(token);
    final payment = BillPayment(
      id: _db.nextId('bill'),
      category: category,
      billerName: billerName,
      amount: amount,
      status: BillPaymentStatus.scheduled,
      date: DateTime.now(),
      customerRef: customerRef,
      scheduledFor: scheduledFor,
    );
    (_db.billPayments[user.id] ??= []).insert(0, payment);
    await _db.persist();
    return payment;
  }

  // ---- notifications ------------------------------------------------------------

  @override
  Future<List<AppNotification>> notifications(String? token) async {
    final user = await _requireUser(token);
    final list = List.of(
      _db.notifications[user.id] ?? const <AppNotification>[],
    );
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> markNotificationRead(
    String? token, {
    required String notificationId,
  }) async {
    final user = await _requireUser(token);
    final list = _db.notifications[user.id];
    if (list == null) return;
    final index = list.indexWhere((n) => n.id == notificationId);
    if (index < 0) throw FvApiException('not_found', 'Notification not found.');
    list[index] = list[index].markRead();
    await _db.persist();
  }

  @override
  Future<int> markAllNotificationsRead(String? token) async {
    final user = await _requireUser(token);
    final list = _db.notifications[user.id];
    if (list == null) return 0;
    var count = 0;
    for (var i = 0; i < list.length; i++) {
      if (!list[i].isRead) {
        list[i] = list[i].markRead();
        count++;
      }
    }
    await _db.persist();
    return count;
  }

  @override
  Future<UserProfile> acceptPrivacyPolicy(String? token) async {
    final user = await _requireUser(token);
    final now = DateTime.now();
    final updated = user.copyWith(privacyPolicyAcceptedAt: now);
    _db.users[user.id] = updated;
    await _db.persist();
    return updated;
  }

  static const _bankInstitutions = [
    'MCB', 'SBM', 'Bank One', 'Maubank',
    'GTBank', 'Access Bank', 'Zenith Bank', 'First Bank', 'UBA', 'Kuda Bank', 'Moniepoint',
  ];

  static const _nigerianInstitutions = [
    'GTBank', 'Access Bank', 'Zenith Bank', 'First Bank', 'UBA', 'Kuda Bank', 'Moniepoint',
    'OPay', 'PalmPay',
  ];

  static const _holderNames = [
    'Jean Claude Riviere',
    'Priya Ramgoolam',
    'Marie Noelle',
    'Kevin Appadoo',
    'Aisha Bibi',
    'Ravi Sookoo',
    'Chioma Adeleke',
    'Emeka Okafor',
    'Babatunde Balogun',
    'Fatima Danjuma',
    'Ngozi Eze',
    'Oluwaseun Adeyemi',
  ];

  static final _phoneRe = RegExp(r'^(\+?234|0)[789][01]\d{8}$|^[5-7]\d{4,7}$|^\d{10,11}$');
  static final _bankRe = RegExp(r'^\d{8,16}$');

  @override
  Future<AccountVerification> verifyAccount(
    String? token, {
    required String institution,
    required String identifier,
    required String holderName,
  }) async {
    await _requireUser(token);
    final cleaned = identifier.replaceAll(RegExp(r'\s'), '');
    final isBank = _bankInstitutions.contains(institution);
    final exists = isBank
        ? _bankRe.hasMatch(cleaned)
        : _phoneRe.hasMatch(cleaned);
    final expected = _holderNames[cleaned.hashCode.abs() % _holderNames.length];
    final verified =
        exists && holderName.trim().toLowerCase() == expected.toLowerCase();
    return AccountVerification(
      exists: exists,
      holderName: verified ? expected : null,
      verified: verified,
    );
  }

  @override
  Future<BankLinkResult> linkBankAccount(
    String? token, {
    required String institution,
    required String accountNumber,
    String? holderName,
  }) async {
    final user = await _requireUser(token);
    final acctNum = accountNumber.trim();
    if (acctNum.isEmpty) {
      throw FvApiException('validation', 'Account number is required.');
    }
    final isNigerian = _nigerianInstitutions.contains(institution) || user.country == 'NG';
    final isBank = _bankInstitutions.contains(institution);

    if (isNigerian) {
      if (isBank && !_nigerianNubanPattern.hasMatch(acctNum)) {
        throw FvApiException(
          'validation',
          'Nigerian bank account number (NUBAN) must be 10 digits.',
        );
      }
      if (!isBank && !_nigerianWalletPattern.hasMatch(acctNum)) {
        throw FvApiException(
          'validation',
          'Nigerian wallet number must be 10–11 digits.',
        );
      }
    } else {
      if (isBank && !_bankPattern.hasMatch(acctNum)) {
        throw FvApiException(
          'validation',
          'Bank account number must be 8–16 digits.',
        );
      }
      if (!isBank && !_mobilePattern.hasMatch(acctNum)) {
        throw FvApiException(
          'validation',
          'Mobile money number must be 5–8 digits starting with 5–7.',
        );
      }
    }

    if (holderName != null) {
      final check = await verifyAccount(
        token,
        institution: institution,
        identifier: acctNum,
        holderName: holderName,
      );
      if (!check.verified) {
        throw FvApiException(
          'verification_failed',
          check.exists
              ? 'The holder name does not match the registered name.'
              : 'Account not found.',
        );
      }
    }

    final seed = (institution + acctNum).hashCode;
    final isWallet = !isBank;
    final currency = isNigerian ? 'NGN' : 'MUR';
    final startingBalance = isNigerian
        ? (isWallet ? 25000.0 + (seed % 35000) : 350000.0 + (seed % 500000))
        : (isWallet ? 3200.0 + (seed % 900) : 64000.0 + (seed % 40000));
    final last4 = acctNum.length >= 4 ? acctNum.substring(acctNum.length - 4) : acctNum;
    final type = isWallet ? AccountType.mobileMoney : AccountType.bank;
    final account = Account(
      id: _db.nextId('acc'),
      name: '$institution ••$last4',
      type: type,
      balance: startingBalance.toDouble(),
      institution: institution.trim(),
      currency: currency,
      accountNumber: acctNum,
    );
    (_db.accounts[user.id] ??= []).add(account);

    // Generate 45 days of transaction history (automatic history fetch).
    final txList = _db.transactions[user.id] ??= <Transaction>[];
    var imported = 0;
    final spendCats = isNigerian
        ? const ['groceries', 'transport', 'utilities', 'dining', 'airtime', 'shopping']
        : const ['groceries', 'transport', 'utilities', 'dining', 'software', 'supplies'];
    final merchants = isNigerian
        ? const ['Jumia', 'Chicken Republic', 'MTN Airtime', 'Ikeja Electric', 'Fuel / NNPC', 'Spar Supermarket', 'Uber Lagos']
        : const ['Shoprite', 'Bus ticket', 'CEB', 'Lambrooks', 'Flicks', 'Canva', 'Office Supplies'];
    final now = DateTime.now();
    for (var d = 1; d <= 45; d++) {
      final k = (seed + d * 7) % 10;
      final date = now.subtract(Duration(days: d));
      if (d % 3 == 0) {
        final creditAmt = isNigerian
            ? (isWallet ? 15000.0 + (k * 2500) : 120000.0 + (k * 25000))
            : (isWallet ? 60.0 + (k * 17) : 1400.0 + (k * 320));
        txList.add(
          Transaction(
            id: _db.nextId('tx'),
            accountId: account.id,
            amount: creditAmt,
            direction: TransactionDirection.inn,
            category: isWallet ? 'client payment' : 'salary',
            merchantName: isWallet ? 'Transfer in' : 'Payroll / Salary',
            date: date,
            currency: currency,
            isExpense: false,
          ),
        );
        imported++;
      }
      if (d % 2 == 0) {
        final debitAmt = isNigerian
            ? (isWallet ? 2500.0 + (k * 800) : 12000.0 + (k * 3500))
            : (isWallet ? 40.0 + (k * 9) : 380.0 + (k * 70));
        txList.add(
          Transaction(
            id: _db.nextId('tx'),
            accountId: account.id,
            amount: debitAmt,
            direction: TransactionDirection.out,
            category: spendCats[k % spendCats.length],
            merchantName: merchants[k % merchants.length],
            date: date,
            currency: currency,
            isExpense: true,
          ),
        );
        imported++;
      }
    }
    await _db.persist();
    return BankLinkResult(account: account, imported: imported);
  }

  static final _bankPattern = RegExp(r'^\d{8,16}$');
  static final _mobilePattern = RegExp(r'^[5-7]\d{4,7}$');
  static final _nigerianPhonePattern = RegExp(r'^(\+?234|0)?[789][01]\d{8}$');
  static final _nigerianNubanPattern = RegExp(r'^\d{10}$');
  static final _nigerianWalletPattern = RegExp(r'^(\+?234|0)?[789][01]\d{8}$|^\d{10,11}$');

  // ---- statement upload ---------------------------------------------------------

  @override
  Future<StatementUploadResult> uploadStatement(
    String? token, {
    required String accountId,
    required String fileName,
    required String fileType,
    required String data,
  }) async {
    await _tick();
    _requireUserSync(token);
    final uid = tokenUserId(token)!;
    final match = (_db.accounts[uid] ?? const <Account>[])
        .where((a) => a.id == accountId)
        .toList();
    if (match.isEmpty) {
      throw FvApiException('not_found', 'Account not found.');
    }
    final cleanType = fileType.toLowerCase();
    if (cleanType != 'csv' && cleanType != 'pdf') {
      throw FvApiException(
        'validation',
        'Only CSV or PDF statements are supported.',
      );
    }
    if (fileName.trim().isEmpty) {
      throw FvApiException('validation', 'Please choose a statement file.');
    }
    if (data.isEmpty) {
      throw FvApiException('validation', 'The file is empty.');
    }
    // ponytail: mock synthesises rows instead of parsing the upload; the BFF
    // does real CSV/PDF parsing. Upgrade path: decode `data` and parse for real.
    const cats = <String>['groceries', 'dining', 'transport'];
    final txList = _db.transactions[uid] ??= <Transaction>[];
    final now = DateTime.now();
    var count = 0;
    for (final cat in cats) {
      txList.add(
        Transaction(
          id: _db.nextId('tx'),
          accountId: accountId,
          amount: 320 + count * 145,
          direction: TransactionDirection.out,
          category: cat,
          merchantName: 'Statement import',
          date: now.subtract(Duration(days: count + 1)),
          isExpense: true,
        ),
      );
      count++;
    }
    await _db.persist();
    return StatementUploadResult(
      statementId: _db.nextId('stmt'),
      accountId: accountId,
      count: count,
      categories: cats,
    );
  }

  @override
  Future<PaymentLinkResult> generatePaymentLink(
    String? token, {
    required String accountId,
    required double amount,
    required String recipient,
  }) async {
    await _tick();
    _requireUserSync(token);
    if (amount <= 0) {
      throw FvApiException('validation', 'Amount must be greater than zero.');
    }
    if (recipient.trim().isEmpty) {
      throw FvApiException('validation', 'Please fill in every field.');
    }
    return PaymentLinkResult(
      deepLink:
          'mcbjuice://pay?amount=${amount.toStringAsFixed(2)}&recipient=${Uri.encodeComponent(recipient.trim())}&account=$accountId',
    );
  }

  @override
  Future<MauCasQrResult> generateMauCasQr(
    String? token, {
    required double amount,
    required String recipient,
  }) async {
    await _tick();
    _requireUserSync(token);
    if (amount <= 0) {
      throw FvApiException('validation', 'Amount must be greater than zero.');
    }
    if (recipient.trim().isEmpty) {
      throw FvApiException('validation', 'Please fill in every field.');
    }
    return MauCasQrResult(
      qrData:
          'MAUCAS:PAY:${amount.toStringAsFixed(2)}:${Uri.encodeComponent(recipient.trim())}',
    );
  }

  // ---- helpers ----------------------------------------------------------------------

  String? tokenUserId(String? token) => _db.sessions[token];

  Future<void> persist() => _db.persist();

  MockDb get db => _db;
}
