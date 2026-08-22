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
  const AuthResult({required this.user, required this.token});

  final UserProfile user;
  final String token;
}

/// Mock API standing in for the future Finovault backend — same endpoints and
/// envelope semantics as finovault-web/lib/api + the Expo app's handlers.
/// Swap the internals for HTTP when the real backend lands.
class FinovaultApi {
  FinovaultApi({required MockDb db, this.latency = const Duration(milliseconds: 250)})
      : _db = db;

  final MockDb _db;
  Duration latency;

  Future<void> _tick() async {
    if (latency > Duration.zero) await Future.delayed(latency);
  }

  UserProfile? userByToken(String? token) => _db.userByToken(token);

  Future<UserProfile> _requireUser(String? token) async {
    await _tick();
    final user = _db.userByToken(token);
    if (user == null) throw FvApiException('unauthorized', 'Your session has expired. Please log in again.');
    return user;
  }

  void _requireUserSync(String? token) {
    final user = _db.userByToken(token);
    if (user == null) throw FvApiException('unauthorized', 'Your session has expired. Please log in again.');
  }

  // ---- auth ----------------------------------------------------------------

  Future<AuthResult> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _tick();
    final normalized = email.trim().toLowerCase();
    if (fullName.trim().isEmpty || normalized.isEmpty || password.isEmpty) {
      throw FvApiException('validation', 'Please fill in every field.');
    }
    if (_db.credentials.containsKey(normalized)) {
      throw FvApiException('email_taken', 'An account with this email already exists.');
    }
    final uid = _db.nextId('user');
    final user = UserProfile(
      id: uid,
      email: normalized,
      fullName: fullName.trim(),
      primaryRole: PrimaryRole.individual,
      scheme: RoleScheme.standard,
      createdAt: DateTime.now(),
    );
    _db.users[uid] = user;
    _db.credentials[normalized] = password;
    _db.prefsByUser[uid] = const UserPreferences();
    return AuthResult(user: user, token: _createSession(uid));
  }

  Future<AuthResult> login({required String email, required String password}) async {
    await _tick();
    final normalized = email.trim().toLowerCase();
    final uid = _db.users.entries
        .where((e) => e.value.email == normalized)
        .map((e) => e.key)
        .firstWhere((_) => true, orElse: () => '');
    final stored = _db.credentials[normalized];
    if (uid.isEmpty || stored == null || stored != password) {
      throw FvApiException('invalid_credentials', 'Incorrect email or password. Please try again.');
    }
    return AuthResult(user: _db.users[uid]!, token: _createSession(uid));
  }

  String _createSession(String uid) {
    final token = 'mock_jwt_${uid}_${DateTime.now().millisecondsSinceEpoch}';
    _db.sessions[token] = uid;
    return token;
  }

  /// Re-validates a stored token on cold start; returns null when stale.
  Future<UserProfile?> getSession(String? token) async {
    try {
      return await _requireUser(token);
    } on FvApiException {
      return null;
    }
  }

  Future<void> logout(String? token) async {
    await _tick();
    _db.sessions.remove(token);
  }

  // ---- users ----------------------------------------------------------------

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

  Future<UserPreferences> getPreferences(String? token) async {
    final user = await _requireUser(token);
    return _db.prefsByUser[user.id] ?? const UserPreferences();
  }

  Future<UserPreferences> savePreferences(String? token, UserPreferences patch) async {
    final user = await _requireUser(token);
    final merged = (_db.prefsByUser[user.id] ?? const UserPreferences()).copyWith(
      financialGoals: patch.financialGoals.isNotEmpty ? patch.financialGoals : null,
      riskTolerance: patch.riskTolerance,
      moneyFears: patch.moneyFears,
      onboardingCompleted: patch.onboardingCompleted,
    );
    _db.prefsByUser[user.id] = merged;
    await _db.persist();
    return merged;
  }

  Future<UserProfile> setRole(String? token, {required PrimaryRole primaryRole, required RoleScheme scheme}) async {
    final user = await _requireUser(token);
    final updated = user.copyWith(primaryRole: primaryRole, scheme: scheme);
    _db.users[user.id] = updated;
    await _db.persist();
    return updated;
  }

  // ---- money: accounts & transactions ---------------------------------------

  Future<List<Account>> accounts(String? token) async {
    final user = await _requireUser(token);
    return List.of(_db.accounts[user.id] ?? const <Account>[]);
  }

  Future<Account> linkAccount(String? token,
      {required String name, required AccountType type, double balance = 0, String? institution}) async {
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

  Future<void> unlinkAccount(String? token, String accountId) async {
    final user = await _requireUser(token);
    _db.accounts[user.id]?.removeWhere((a) => a.id == accountId);
    await _db.persist();
  }

  Future<List<Transaction>> transactions(String? token, {int limit = 20}) async {
    final user = await _requireUser(token);
    final list = List.of(_db.transactions[user.id] ?? const <Transaction>[]);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list.take(limit).toList();
  }

  Future<Transaction> createTransaction(
    String? token, {
    required String accountId,
    required double amount,
    required TransactionDirection direction,
    required String category,
    String? merchantName,
  }) async {
    _requireUserSync(token);
    if (amount <= 0) throw FvApiException('validation', 'Amount must be greater than zero.');
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

  Future<List<Budget>> budgets(String? token) async {
    final user = await _requireUser(token);
    return List.of(_db.budgets[user.id] ?? const <Budget>[]);
  }

  Future<Budget> createBudget(String? token, {required String category, required double amount}) async {
    final user = await _requireUser(token);
    final existing = _db.budgets[user.id] ?? <Budget>[];
    final match = existing.where((b) => b.category.toLowerCase() == category.trim().toLowerCase()).toList();
    Budget budget;
    if (match.isNotEmpty) {
      budget = Budget(id: match.first.id, category: category.trim(), amount: amount);
      existing[existing.indexOf(match.first)] = budget;
    } else {
      budget = Budget(id: _db.nextId('bud'), category: category.trim(), amount: amount);
      existing.add(budget);
    }
    _db.budgets[user.id] = existing;
    await _db.persist();
    return budget;
  }

  // ---- goals -----------------------------------------------------------------

  Future<List<SavingsGoal>> goals(String? token) async {
    final user = await _requireUser(token);
    return List.of(_db.goals[user.id] ?? const <SavingsGoal>[]);
  }

  Future<SavingsGoal> goal(String? token, String goalId) async {
    final user = await _requireUser(token);
    final match = (_db.goals[user.id] ?? []).where((g) => g.id == goalId).toList();
    if (match.isEmpty) throw FvApiException('not_found', 'Goal not found.');
    return match.first;
  }

  Future<SavingsGoal> createGoal(String? token,
      {required String name, required GoalType type, required double targetAmount, DateTime? targetDate}) async {
    _requireUserSync(token);
    if (name.trim().isEmpty || targetAmount <= 0) {
      throw FvApiException('validation', 'Give your goal a name and a target above zero.');
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

  Future<SavingsGoal> contribute(String? token,
      {required String goalId, required double amount, String? sourceAccountId}) async {
    final user = await _requireUser(token);
    final list = _db.goals[user.id] ?? [];
    final index = list.indexWhere((g) => g.id == goalId);
    if (index < 0) throw FvApiException('not_found', 'Goal not found.');
    if (amount <= 0) throw FvApiException('validation', 'Amount must be greater than zero.');

    if (sourceAccountId != null) {
      final accs = _db.accounts[user.id] ?? [];
      final ai = accs.indexWhere((a) => a.id == sourceAccountId);
      if (ai < 0) throw FvApiException('not_found', 'Account not found.');
      if (accs[ai].balance < amount) throw FvApiException('insufficient_funds', 'Not enough funds in this account.');
      accs[ai] = accs[ai].copyWith(balance: accs[ai].balance - amount);
      (_db.transactions[user.id] ??= []).add(Transaction(
            id: _db.nextId('tx'),
            accountId: sourceAccountId,
            amount: amount,
            direction: TransactionDirection.out,
            category: 'Savings',
            merchantName: list[index].name,
            date: DateTime.now(),
          ));
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

  // ---- security ----------------------------------------------------------------

  int securityScoreFor(String userId) {
    final open = (_db.securityEvents[userId] ?? []).where((e) => !e.resolved).toList();
    final twoFactor = _db.securityOverviews[userId]?.twoFactorEnabled ?? false;
    var score = 100 - (twoFactor ? 0 : 20);
    for (final e in open) {
      score -= e.severity == EventSeverity.high ? 15 : (e.severity == EventSeverity.medium ? 8 : 3);
    }
    return score.clamp(5, 99);
  }

  Future<SecurityOverview> securityOverview(String? token) async {
    final user = await _requireUser(token);
    final stored = _db.securityOverviews[user.id] ?? const SecurityOverview(score: 72);
    return stored.copyWith(score: securityScoreFor(user.id));
  }

  Future<SecurityOverview> setTwoFactor(String? token, {required bool enabled}) async {
    final user = await _requireUser(token);
    final updated = (_db.securityOverviews[user.id] ?? const SecurityOverview(score: 72)).copyWith(twoFactorEnabled: enabled);
    _db.securityOverviews[user.id] = updated;
    await _db.persist();
    return securityOverview(token);
  }

  Future<List<SecurityDevice>> devices(String? token) async {
    final user = await _requireUser(token);
    return List.of(_db.devices[user.id] ?? const <SecurityDevice>[]);
  }

  Future<List<SecurityEvent>> securityEvents(String? token) async {
    final user = await _requireUser(token);
    return List.of(_db.securityEvents[user.id] ?? const <SecurityEvent>[]);
  }

  Future<SecurityEvent> resolveSecurityEvent(String? token, String eventId) async {
    final user = await _requireUser(token);
    final list = _db.securityEvents[user.id] ?? [];
    final index = list.indexWhere((e) => e.id == eventId);
    if (index < 0) throw FvApiException('not_found', 'Event not found.');
    list[index] = list[index].copyWith(resolved: true);
    await _db.persist();
    return list[index];
  }

  // ---- invoices & vendors ---------------------------------------------------------

  Future<List<Invoice>> invoices(String? token) async {
    final user = await _requireUser(token);
    final list = List.of(_db.invoices[user.id] ?? const <Invoice>[]);
    list.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    return list;
  }

  Future<Invoice> createInvoice(String? token,
      {required String clientName, required double amount, required DateTime dueDate}) async {
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

  Future<Invoice> updateInvoiceStatus(String? token,
      {required String invoiceId, required InvoiceStatus status}) async {
    final user = await _requireUser(token);
    final list = _db.invoices[user.id] ?? [];
    final index = list.indexWhere((i) => i.id == invoiceId);
    if (index < 0) throw FvApiException('not_found', 'Invoice not found.');
    list[index] = list[index].copyWith(status: status);
    await _db.persist();
    return list[index];
  }

  Future<List<Vendor>> vendors(String? token) async {
    final user = await _requireUser(token);
    return List.of(_db.vendors[user.id] ?? const <Vendor>[]);
  }

  Future<Vendor> createVendor(String? token, {required String name}) async {
    final user = await _requireUser(token);
    if (name.trim().isEmpty) throw FvApiException('validation', 'Vendor name is required.');
    final vendor = Vendor(id: _db.nextId('ven'), name: name.trim());
    (_db.vendors[user.id] ??= []).add(vendor);
    await _db.persist();
    return vendor;
  }

  // ---- transfers -----------------------------------------------------------------

  Future<List<Transfer>> transfers(String? token) async {
    final user = await _requireUser(token);
    final list = List.of(_db.transfers[user.id] ?? const <Transfer>[]);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<Transfer> transferById(String? token, String id) async {
    final user = await _requireUser(token);
    final match = (_db.transfers[user.id] ?? []).where((t) => t.id == id).toList();
    if (match.isEmpty) throw FvApiException('not_found', 'Transfer not found.');
    return match.first;
  }

  Future<Transfer> createTransfer(String? token,
      {required String sourceAccountId,
      required String payeeName,
      required String destination,
      required double amount,
      required String idempotencyKey}) async {
    final user = await _requireUser(token);
    final existing = (_db.transfers[user.id] ?? []).where((t) => t.idempotencyKey == idempotencyKey).toList();
    if (existing.isNotEmpty) return existing.first;

    final accs = _db.accounts[user.id] ?? [];
    final index = accs.indexWhere((a) => a.id == sourceAccountId);
    if (index < 0) throw FvApiException('not_found', 'Source account not found.');
    if (amount <= 0) throw FvApiException('validation', 'Amount must be greater than zero.');
    final fee = computeTransferFee(amount);
    final total = amount + fee;
    if (accs[index].balance < total) {
      throw FvApiException('insufficient_funds', 'Not enough funds — total with fees is $total.');
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
    (_db.transactions[user.id] ??= []).add(Transaction(
          id: _db.nextId('tx'),
          accountId: sourceAccountId,
          amount: total,
          direction: TransactionDirection.out,
          category: 'Transfer',
          merchantName: transfer.payeeName,
          date: transfer.createdAt,
        ));
    await _db.persist();
    return transfer;
  }

  // ---- bills & payees -------------------------------------------------------------

  Future<List<Payee>> payees(String? token) async {
    final user = await _requireUser(token);
    return List.of(_db.payees[user.id] ?? const <Payee>[]);
  }

  Future<Payee> createPayee(String? token, {required String name, String? destination}) async {
    final user = await _requireUser(token);
    if (name.trim().isEmpty) throw FvApiException('validation', 'Payee name is required.');
    final payee = Payee(id: _db.nextId('pay'), name: name.trim(), destination: destination?.trim());
    (_db.payees[user.id] ??= []).add(payee);
    await _db.persist();
    return payee;
  }

  static const billCategories = BillCategory.values;

  Future<List<BillPayment>> billPayments(String? token) async {
    final user = await _requireUser(token);
    final list = List.of(_db.billPayments[user.id] ?? const <BillPayment>[]);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<BillPayment> payBill(String? token,
      {required BillCategory category,
      required String billerName,
      required double amount,
      required String customerRef,
      String? sourceAccountId}) async {
    final user = await _requireUser(token);
    final accs = _db.accounts[user.id] ?? [];
    final accId = sourceAccountId ?? (accs.isNotEmpty ? accs.first.id : '');
    final index = accs.indexWhere((a) => a.id == accId);
    if (index < 0) throw FvApiException('not_found', 'No account to pay from.');
    if (amount <= 0) throw FvApiException('validation', 'Amount must be greater than zero.');
    if (accs[index].balance < amount) throw FvApiException('insufficient_funds', 'Not enough funds for this bill.');

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
    (_db.transactions[user.id] ??= []).add(Transaction(
          id: _db.nextId('tx'),
          accountId: accId,
          amount: amount,
          direction: TransactionDirection.out,
          category: 'Bills',
          merchantName: billerName,
          date: payment.date,
        ));
    await _db.persist();
    return payment;
  }

  Future<BillPayment> scheduleBill(String? token,
      {required BillCategory category,
      required String billerName,
      required double amount,
      required String customerRef,
      required DateTime scheduledFor}) async {
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

  // ---- helpers ----------------------------------------------------------------------

  String? tokenUserId(String? token) => _db.sessions[token];

  Future<void> persist() => _db.persist();

  MockDb get db => _db;
}
