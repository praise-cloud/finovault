import 'dart:convert';

import '../models.dart';

/// Simple key-value abstraction so the mock DB persists via SharedPreferences
/// in production but runs fully in-memory under tests.
abstract class KvStore {
  String? getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
}

class MemoryStore implements KvStore {
  final _map = <String, String>{};
  @override
  String? getString(String key) => _map[key];
  @override
  Future<void> setString(String key, String value) async => _map[key] = value;
  @override
  Future<void> remove(String key) async => _map.remove(key);
}

/// In-memory mock backend database, snapshotted to storage so data survives
/// restarts — mirrors finovault-mobile/lib/api/mock/db.ts + persistence.ts.
class MockDb {
  MockDb({KvStore? store, this.latency = 120})
    : _store = store ?? MemoryStore();

  static const storageKey = 'finovault.flutter.mockdb.v1';
  final KvStore _store;
  final int latency;

  final users = <String, UserProfile>{};
  final credentials = <String, String>{};
  final passwordResetTokens = <String, String>{};
  final passwordResetIssuedAt = <String, DateTime>{};

  final prefsByUser = <String, UserPreferences>{};
  final sessions = <String, String>{};
  final accounts = <String, List<Account>>{};
  final transactions = <String, List<Transaction>>{};
  final budgets = <String, List<Budget>>{};
  final goals = <String, List<SavingsGoal>>{};
  final devices = <String, List<SecurityDevice>>{};
  final securityEvents = <String, List<SecurityEvent>>{};
  final securityOverviews = <String, SecurityOverview>{};
  final invoices = <String, List<Invoice>>{};
  final vendors = <String, List<Vendor>>{};
  final transfers = <String, List<Transfer>>{};
  final billPayments = <String, List<BillPayment>>{};
  final payees = <String, List<Payee>>{};
  final notifications = <String, List<AppNotification>>{};
  final pensions = <String, PensionPlan>{};
  final pensionContributions = <String, List<PensionContribution>>{};
  final mfaSecrets = <String, String>{}; // userId → TOTP secret
  final mfaBackupCodes =
      <String, List<String>>{}; // userId → remaining backup codes
  final mfaChallenges = <String, MfaChallenge>{}; // challengeId → challenge
  int _counter = 0;

  String nextId(String prefix) {
    _counter++;
    return '${prefix}_$_counter';
  }

  UserProfile? userByToken(String? token) {
    if (token == null) return null;
    final uid = sessions[token];
    return uid == null ? null : users[uid];
  }

  // ---- persistence ---------------------------------------------------------

  Future<void> hydrate() async {
    final raw = _store.getString(storageKey);
    if (raw == null) {
      // ponytail: seed demo user so fresh in-memory DBs (tests) can log in;
      // signup() creates a bare individual profile without seeding.
      seedEntrepreneurData('user_demo', 'demo@finovault.app', 'Amina Diallo');
      await persist();
      return;
    }
    final j = jsonDecode(raw) as Map<String, dynamic>;
    _counter = (j['counter'] as num?)?.toInt() ?? 0;
    users.addEntries(
      ((j['users'] as Map?) ?? {}).entries.map(
        (e) => MapEntry(
          e.key as String,
          UserProfile.fromJson(e.value as Map<String, dynamic>),
        ),
      ),
    );
    credentials.addEntries(
      ((j['credentials'] as Map?) ?? {}).entries.map(
        (e) => MapEntry(e.key as String, e.value as String),
      ),
    );
    passwordResetTokens.addEntries(
      ((j['passwordResetTokens'] as Map?) ?? {}).entries.map(
        (e) => MapEntry(e.key as String, e.value as String),
      ),
    );
    passwordResetIssuedAt.addEntries(
      ((j['passwordResetIssuedAt'] as Map?) ?? {}).entries.map(
        (e) => MapEntry(
          e.key as String,
          DateTime.tryParse(e.value as String? ?? '') ?? DateTime.now(),
        ),
      ),
    );
    prefsByUser.addEntries(
      ((j['prefs'] as Map?) ?? {}).entries.map(
        (e) => MapEntry(
          e.key as String,
          UserPreferences.fromJson(e.value as Map<String, dynamic>),
        ),
      ),
    );
    sessions.addEntries(
      ((j['sessions'] as Map?) ?? {}).entries.map(
        (e) => MapEntry(e.key as String, e.value as String),
      ),
    );
    void list<T>(
      Map<String, dynamic>? src,
      Map<String, List<T>> into,
      T Function(Map<String, dynamic>) from,
    ) {
      if (src == null) return;
      src.forEach(
        (k, v) => into[k] = ((v as List).cast<Map<String, dynamic>>())
            .map(from)
            .toList(),
      );
    }

    list(j['accounts'] as Map<String, dynamic>?, accounts, Account.fromJson);
    list(
      j['transactions'] as Map<String, dynamic>?,
      transactions,
      Transaction.fromJson,
    );
    list(j['budgets'] as Map<String, dynamic>?, budgets, Budget.fromJson);
    list(j['goals'] as Map<String, dynamic>?, goals, SavingsGoal.fromJson);
    list(
      j['devices'] as Map<String, dynamic>?,
      devices,
      SecurityDevice.fromJson,
    );
    list(
      j['securityEvents'] as Map<String, dynamic>?,
      securityEvents,
      SecurityEvent.fromJson,
    );
    list(j['invoices'] as Map<String, dynamic>?, invoices, Invoice.fromJson);
    list(j['vendors'] as Map<String, dynamic>?, vendors, Vendor.fromJson);
    list(j['transfers'] as Map<String, dynamic>?, transfers, Transfer.fromJson);
    list(
      j['billPayments'] as Map<String, dynamic>?,
      billPayments,
      BillPayment.fromJson,
    );
    list(j['payees'] as Map<String, dynamic>?, payees, Payee.fromJson);
    list(
      j['notifications'] as Map<String, dynamic>?,
      notifications,
      AppNotification.fromJson,
    );
    pensions.addEntries(
      ((j['pensions'] as Map?) ?? {}).entries.map(
        (e) => MapEntry(
          e.key as String,
          PensionPlan.fromJson(e.value as Map<String, dynamic>),
        ),
      ),
    );
    list(
      j['pensionContributions'] as Map<String, dynamic>?,
      pensionContributions,
      PensionContribution.fromJson,
    );
    mfaSecrets.addEntries(
      ((j['mfaSecrets'] as Map?) ?? {}).entries.map(
        (e) => MapEntry(e.key as String, e.value as String),
      ),
    );
    ((j['mfaBackupCodes'] as Map?) ?? {}).forEach(
      (k, v) => mfaBackupCodes[k as String] = (v as List).cast<String>(),
    );
    ((j['securityOverviews'] as Map?) ?? {}).forEach(
      (k, v) => securityOverviews[k as String] = SecurityOverview.fromJson(
        v as Map<String, dynamic>,
      ),
    );
  }

  Future<void> persist() async {
    final j = {
      'counter': _counter,
      'users': users.map((k, v) => MapEntry(k, v.toJson())),
      'credentials': credentials,
      'passwordResetTokens': passwordResetTokens,
      'passwordResetIssuedAt': passwordResetIssuedAt.map(
        (k, v) => MapEntry(k, v.toIso8601String()),
      ),
      'prefs': prefsByUser.map((k, v) => MapEntry(k, v.toJson())),
      'sessions': sessions,
      'accounts': accounts.map(
        (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
      ),
      'transactions': transactions.map(
        (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
      ),
      'budgets': budgets.map(
        (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
      ),
      'goals': goals.map(
        (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
      ),
      'devices': devices.map(
        (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
      ),
      'securityEvents': securityEvents.map(
        (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
      ),
      'securityOverviews': securityOverviews.map(
        (k, v) => MapEntry(k, v.toJson()),
      ),
      'invoices': invoices.map(
        (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
      ),
      'vendors': vendors.map(
        (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
      ),
      'transfers': transfers.map(
        (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
      ),
      'billPayments': billPayments.map(
        (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
      ),
      'payees': payees.map(
        (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
      ),
      'notifications': notifications.map(
        (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
      ),
      'pensions': pensions.map((k, v) => MapEntry(k, v.toJson())),
      'pensionContributions': pensionContributions.map(
        (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
      ),
      'mfaSecrets': mfaSecrets,
      'mfaBackupCodes': mfaBackupCodes,
    };
    await _store.setString(storageKey, jsonEncode(j));
  }

  Future<void> clearStorage() => _store.remove(storageKey);

  // ---- seed ----------------------------------------------------------------

  void seedEntrepreneurData(String uid, String email, String fullName) {
    final now = DateTime.now();
    users[uid] = UserProfile(
      id: uid,
      email: email,
      fullName: fullName,
      primaryRole: PrimaryRole.entrepreneur,
      scheme: RoleScheme.femaleFounder,
      createdAt: now.subtract(const Duration(days: 90)),
    );
    credentials[email] = 'Vault123!';
    prefsByUser[uid] = const UserPreferences(
      financialGoals: ['retirement', 'business'],
      riskTolerance: RiskTolerance.high,
      onboardingCompleted: true,
    );

    final bankId = nextId('acc');
    final momoId = nextId('acc');
    accounts[uid] = [
      Account(
        id: bankId,
        name: 'MCB Bank',
        type: AccountType.bank,
        institution: 'MCB',
        balance: 42500,
      ),
      Account(
        id: momoId,
        name: 'MyT Money',
        type: AccountType.mobileMoney,
        institution: 'MyT',
        balance: 8750,
      ),
    ];
    transactions[uid] = [
      Transaction(
        id: nextId('tx'),
        accountId: bankId,
        amount: 32000,
        direction: TransactionDirection.inn,
        category: 'Salary',
        merchantName: 'Retail Consulting Ltd',
        date: now.subtract(const Duration(days: 26)),
        isExpense: false,
      ),
      Transaction(
        id: nextId('tx'),
        accountId: bankId,
        amount: 15000,
        direction: TransactionDirection.out,
        category: 'Rent',
        merchantName: 'Skyline Properties',
        date: now.subtract(const Duration(days: 24)),
      ),
      Transaction(
        id: nextId('tx'),
        accountId: momoId,
        amount: 8500,
        direction: TransactionDirection.inn,
        category: 'Invoice',
        merchantName: 'Nova Studio',
        date: now.subtract(const Duration(days: 18)),
        isExpense: false,
      ),
      Transaction(
        id: nextId('tx'),
        accountId: momoId,
        amount: 3200,
        direction: TransactionDirection.out,
        category: 'Groceries',
        merchantName: 'Winners Supermarket',
        date: now.subtract(const Duration(days: 9)),
      ),
      Transaction(
        id: nextId('tx'),
        accountId: momoId,
        amount: 1800,
        direction: TransactionDirection.out,
        category: 'Transport',
        merchantName: 'Fuel Station',
        date: now.subtract(const Duration(days: 5)),
      ),
      Transaction(
        id: nextId('tx'),
        accountId: bankId,
        amount: 2400,
        direction: TransactionDirection.out,
        category: 'Utilities',
        merchantName: 'CEB',
        date: now.subtract(const Duration(days: 2)),
      ),
    ];
    budgets[uid] = const [
      Budget(id: 'bud_seed_1', category: 'Groceries', amount: 6000),
      Budget(id: 'bud_seed_2', category: 'Transport', amount: 2500),
      Budget(id: 'bud_seed_3', category: 'Dining', amount: 3000),
    ];
    final emergencyId = nextId('goal');
    final emergencyContribution = GoalContribution(
      id: nextId('con'),
      goalId: emergencyId,
      amount: 12000,
      date: now.subtract(const Duration(days: 15)),
      sourceAccountId: bankId,
    );
    goals[uid] = [
      SavingsGoal(
        id: emergencyId,
        name: 'Emergency Fund',
        type: GoalType.emergency,
        targetAmount: 50000,
        currentAmount: 12000,
        contributions: [emergencyContribution],
      ),
      SavingsGoal(
        id: nextId('goal'),
        name: 'Retirement Pension',
        type: GoalType.pensionLinked,
        targetAmount: 250000,
        currentAmount: 18500,
        targetDate: now.add(const Duration(days: 365 * 10)),
      ),
    ];
    devices[uid] = [
      SecurityDevice(
        id: nextId('dev'),
        name: 'Pixel 8 · Port Louis',
        lastSeen: now,
        trusted: true,
      ),
      SecurityDevice(
        id: nextId('dev'),
        name: 'Windows PC · Home office',
        lastSeen: now.subtract(const Duration(days: 2)),
      ),
    ];
    securityEvents[uid] = [
      SecurityEvent(
        id: nextId('evt'),
        title: 'New device sign-in',
        description: 'A sign-in from Windows PC · Home office was recorded.',
        severity: EventSeverity.medium,
        date: now.subtract(const Duration(days: 2)),
      ),
      SecurityEvent(
        id: nextId('evt'),
        title: 'Password changed',
        severity: EventSeverity.low,
        date: now.subtract(const Duration(days: 40)),
        resolved: true,
      ),
    ];
    securityOverviews[uid] = const SecurityOverview(
      score: 72,
      twoFactorEnabled: false,
    );
    pensions[uid] = PensionPlan(
      id: 'pen_$uid',
      shortPotTarget: 50000,
      longPotTarget: 750000,
      frequency: PensionFrequency.monthly,
      contributionAmount: 2500,
      currentShortPot: 18500,
      currentLongPot: 42000,
      assumedReturnPct: 7,
      inflationPct: 4,
      currentAge: 34,
      retirementAge: 65,
      autoDebit: true,
    );
    invoices[uid] = [
      Invoice(
        id: nextId('inv'),
        clientName: 'Bell Attractions',
        amount: 12000,
        dueDate: now.add(const Duration(days: 10)),
        status: InvoiceStatus.sent,
      ),
      Invoice(
        id: nextId('inv'),
        clientName: 'Nova Studio',
        amount: 8500,
        dueDate: now.subtract(const Duration(days: 18)),
        status: InvoiceStatus.paid,
      ),
      Invoice(
        id: nextId('inv'),
        clientName: 'Kite Media',
        amount: 4500,
        dueDate: now.subtract(const Duration(days: 6)),
        status: InvoiceStatus.overdue,
      ),
    ];
    vendors[uid] = const [
      Vendor(
        id: 'ven_seed_1',
        name: 'Print Hub Ltd',
        totalSpend: 12400,
        reliabilityScore: 92,
      ),
      Vendor(
        id: 'ven_seed_2',
        name: 'CloudHost',
        totalSpend: 3600,
        reliabilityScore: 78,
      ),
    ];
    payees[uid] = const [
      Payee(
        id: 'pay_seed_1',
        name: 'Jean-Paul R.',
        destination: '+230 5124 8890',
      ),
      Payee(id: 'pay_seed_2', name: 'CEB Bill', destination: 'ACC-2291'),
    ];
    billPayments[uid] = [
      BillPayment(
        id: nextId('bill'),
        category: BillCategory.electricity,
        billerName: 'CEB',
        amount: 1450,
        status: BillPaymentStatus.paid,
        date: now.subtract(const Duration(days: 12)),
        customerRef: 'ACC-2291',
      ),
    ];
    // Seed 5 notifications (mix of read/unread, all types)
    notifications[uid] = [
      AppNotification(
        id: nextId('ntf'),
        title: 'Transfer received',
        body: 'You received MUR 8,500 from Nova Studio.',
        type: NotificationType.transfer,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: nextId('ntf'),
        title: 'Bill due soon',
        body: 'CEB electricity bill of MUR 1,450 is due in 3 days.',
        type: NotificationType.bill,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      AppNotification(
        id: nextId('ntf'),
        title: 'Security alert',
        body: 'New sign-in detected from Windows PC.',
        type: NotificationType.security,
        readAt: now.subtract(const Duration(hours: 8)),
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      AppNotification(
        id: nextId('ntf'),
        title: 'Goal milestone',
        body: 'Your Emergency Fund is 24% complete.',
        type: NotificationType.goal,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: nextId('ntf'),
        title: 'System update',
        body: 'Finovault v1.2 is now available with pension projections.',
        type: NotificationType.system,
        readAt: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  void seedFreelancerData(String uid, String email, String fullName) {
    final now = DateTime.now();
    users[uid] = UserProfile(
      id: uid,
      email: email,
      fullName: fullName,
      primaryRole: PrimaryRole.freelancer,
      scheme: RoleScheme.standard,
      createdAt: now.subtract(const Duration(days: 40)),
    );
    credentials[email] = 'Vault123!';
    prefsByUser[uid] = const UserPreferences(
      financialGoals: ['tax', 'equipment'],
      riskTolerance: RiskTolerance.moderate,
      onboardingCompleted: true,
    );
    final bankId = nextId('acc');
    final momoId = nextId('acc');
    accounts[uid] = [
      Account(
        id: bankId,
        name: 'MCB Bank',
        type: AccountType.bank,
        institution: 'MCB',
        balance: 31200,
      ),
      Account(
        id: momoId,
        name: 'MyT Money',
        type: AccountType.mobileMoney,
        institution: 'MyT',
        balance: 5400,
      ),
    ];
    transactions[uid] = [
      Transaction(
        id: nextId('tx'),
        accountId: bankId,
        amount: 28000,
        direction: TransactionDirection.inn,
        category: 'Client Payment',
        merchantName: 'Studio Lume',
        date: now.subtract(const Duration(days: 20)),
        isExpense: false,
      ),
      Transaction(
        id: nextId('tx'),
        accountId: bankId,
        amount: 6500,
        direction: TransactionDirection.out,
        category: 'Rent',
        merchantName: 'Skyline Properties',
        date: now.subtract(const Duration(days: 18)),
      ),
      Transaction(
        id: nextId('tx'),
        accountId: momoId,
        amount: 9000,
        direction: TransactionDirection.inn,
        category: 'Invoice',
        merchantName: 'Kite Media',
        date: now.subtract(const Duration(days: 12)),
        isExpense: false,
      ),
      Transaction(
        id: nextId('tx'),
        accountId: momoId,
        amount: 2200,
        direction: TransactionDirection.out,
        category: 'Software',
        merchantName: 'Adobe CC',
        date: now.subtract(const Duration(days: 9)),
      ),
      Transaction(
        id: nextId('tx'),
        accountId: momoId,
        amount: 1400,
        direction: TransactionDirection.out,
        category: 'Groceries',
        merchantName: 'Winners Supermarket',
        date: now.subtract(const Duration(days: 5)),
      ),
      Transaction(
        id: nextId('tx'),
        accountId: momoId,
        amount: 800,
        direction: TransactionDirection.out,
        category: 'Transport',
        merchantName: 'Fuel Station',
        date: now.subtract(const Duration(days: 3)),
      ),
      Transaction(
        id: nextId('tx'),
        accountId: bankId,
        amount: 500,
        direction: TransactionDirection.out,
        category: 'Utilities',
        merchantName: 'CEB',
        date: now.subtract(const Duration(days: 2)),
      ),
    ];
    budgets[uid] = const [
      Budget(id: 'bud_fre_1', category: 'Groceries', amount: 6000),
      Budget(id: 'bud_fre_2', category: 'Software', amount: 3000),
      Budget(id: 'bud_fre_3', category: 'Transport', amount: 2500),
    ];
    final taxId = nextId('goal');
    final taxContribution = GoalContribution(
      id: nextId('con'),
      goalId: taxId,
      amount: 22000,
      date: now.subtract(const Duration(days: 10)),
      sourceAccountId: bankId,
    );
    goals[uid] = [
      SavingsGoal(
        id: taxId,
        name: 'Tax Set-Aside',
        type: GoalType.taxShield,
        targetAmount: 60000,
        currentAmount: 22000,
        contributions: [taxContribution],
      ),
      SavingsGoal(
        id: nextId('goal'),
        name: 'New Laptop Fund',
        type: GoalType.project,
        targetAmount: 120000,
        currentAmount: 45000,
      ),
    ];
    invoices[uid] = [
      Invoice(
        id: nextId('inv'),
        clientName: 'Belle Agency',
        amount: 9000,
        dueDate: now.add(const Duration(days: 12)),
        status: InvoiceStatus.sent,
      ),
      Invoice(
        id: nextId('inv'),
        clientName: 'Kite Media',
        amount: 6000,
        dueDate: now.subtract(const Duration(days: 6)),
        status: InvoiceStatus.overdue,
      ),
      Invoice(
        id: nextId('inv'),
        clientName: 'Nova Studio',
        amount: 12000,
        dueDate: now.subtract(const Duration(days: 18)),
        status: InvoiceStatus.paid,
      ),
    ];
    devices[uid] = [
      SecurityDevice(
        id: nextId('dev'),
        name: 'iPhone 15 · Port Louis',
        lastSeen: now,
        trusted: true,
      ),
      SecurityDevice(
        id: nextId('dev'),
        name: 'MacBook Air · Co-working',
        lastSeen: now.subtract(const Duration(days: 3)),
      ),
    ];
    securityEvents[uid] = [
      SecurityEvent(
        id: nextId('evt'),
        title: 'New device sign-in',
        description: 'A sign-in from MacBook Air · Co-working was recorded.',
        severity: EventSeverity.low,
        date: now.subtract(const Duration(days: 3)),
      ),
    ];
    securityOverviews[uid] = const SecurityOverview(
      score: 88,
      twoFactorEnabled: true,
    );
  }

  void seedSmeData(String uid, String email, String fullName) {
    final now = DateTime.now();
    users[uid] = UserProfile(
      id: uid,
      email: email,
      fullName: fullName,
      primaryRole: PrimaryRole.sme,
      scheme: RoleScheme.standard,
      createdAt: now.subtract(const Duration(days: 120)),
    );
    credentials[email] = 'Vault123!';
    prefsByUser[uid] = const UserPreferences(
      financialGoals: ['payroll', 'growth'],
      riskTolerance: RiskTolerance.high,
      onboardingCompleted: true,
    );
    final bankId = nextId('acc');
    final momoId = nextId('acc');
    accounts[uid] = [
      Account(
        id: bankId,
        name: 'Business MCB',
        type: AccountType.bank,
        institution: 'MCB',
        balance: 168000,
      ),
      Account(
        id: momoId,
        name: 'Tropipay',
        type: AccountType.mobileMoney,
        institution: 'Tropipay',
        balance: 23000,
      ),
    ];
    transactions[uid] = [
      Transaction(
        id: nextId('tx'),
        accountId: bankId,
        amount: 95000,
        direction: TransactionDirection.inn,
        category: 'Client Payment',
        merchantName: 'Coastal Tours',
        date: now.subtract(const Duration(days: 21)),
        isExpense: false,
      ),
      Transaction(
        id: nextId('tx'),
        accountId: bankId,
        amount: 42000,
        direction: TransactionDirection.out,
        category: 'Payroll',
        merchantName: 'Staff Payroll',
        date: now.subtract(const Duration(days: 19)),
      ),
      Transaction(
        id: nextId('tx'),
        accountId: bankId,
        amount: 30000,
        direction: TransactionDirection.inn,
        category: 'Invoice',
        merchantName: 'Maple Co',
        date: now.subtract(const Duration(days: 14)),
        isExpense: false,
      ),
      Transaction(
        id: nextId('tx'),
        accountId: bankId,
        amount: 12000,
        direction: TransactionDirection.out,
        category: 'Rent',
        merchantName: 'Skyline Properties',
        date: now.subtract(const Duration(days: 12)),
      ),
      Transaction(
        id: nextId('tx'),
        accountId: momoId,
        amount: 6500,
        direction: TransactionDirection.out,
        category: 'Utilities',
        merchantName: 'CEB',
        date: now.subtract(const Duration(days: 8)),
      ),
      Transaction(
        id: nextId('tx'),
        accountId: momoId,
        amount: 4000,
        direction: TransactionDirection.out,
        category: 'Marketing',
        merchantName: 'Kite Media',
        date: now.subtract(const Duration(days: 5)),
      ),
      Transaction(
        id: nextId('tx'),
        accountId: bankId,
        amount: 2500,
        direction: TransactionDirection.out,
        category: 'Supplies',
        merchantName: 'Office Mart',
        date: now.subtract(const Duration(days: 2)),
      ),
    ];
    budgets[uid] = const [
      Budget(id: 'bud_sme_1', category: 'Payroll', amount: 45000),
      Budget(id: 'bud_sme_2', category: 'Rent', amount: 15000),
      Budget(id: 'bud_sme_3', category: 'Marketing', amount: 8000),
    ];
    final expansionId = nextId('goal');
    final expansionContribution = GoalContribution(
      id: nextId('con'),
      goalId: expansionId,
      amount: 180000,
      date: now.subtract(const Duration(days: 20)),
      sourceAccountId: bankId,
    );
    goals[uid] = [
      SavingsGoal(
        id: expansionId,
        name: 'Expansion Fund',
        type: GoalType.project,
        targetAmount: 500000,
        currentAmount: 180000,
        contributions: [expansionContribution],
      ),
      SavingsGoal(
        id: nextId('goal'),
        name: 'Equipment Upgrade',
        type: GoalType.project,
        targetAmount: 200000,
        currentAmount: 60000,
      ),
    ];
    invoices[uid] = [
      Invoice(
        id: nextId('inv'),
        clientName: 'Coastal Tours',
        amount: 45000,
        dueDate: now.add(const Duration(days: 9)),
        status: InvoiceStatus.sent,
      ),
      Invoice(
        id: nextId('inv'),
        clientName: 'Maple Co',
        amount: 30000,
        dueDate: now.subtract(const Duration(days: 4)),
        status: InvoiceStatus.overdue,
      ),
      Invoice(
        id: nextId('inv'),
        clientName: 'Bright Ltd',
        amount: 22000,
        dueDate: now.subtract(const Duration(days: 10)),
        status: InvoiceStatus.overdue,
      ),
      Invoice(
        id: nextId('inv'),
        clientName: 'Sunrise Group',
        amount: 38000,
        dueDate: now.subtract(const Duration(days: 20)),
        status: InvoiceStatus.paid,
      ),
    ];
    vendors[uid] = const [
      Vendor(
        id: 'ven_sme_1',
        name: 'Print Hub Ltd',
        totalSpend: 24000,
        reliabilityScore: 92,
      ),
      Vendor(
        id: 'ven_sme_2',
        name: 'CloudHost',
        totalSpend: 9600,
        reliabilityScore: 80,
      ),
      Vendor(
        id: 'ven_sme_3',
        name: 'Office Mart',
        totalSpend: 15000,
        reliabilityScore: 88,
      ),
    ];
    payees[uid] = const [
      Payee(id: 'pay_sme_1', name: 'CEB Bill', destination: 'ACC-2291'),
    ];
    billPayments[uid] = [
      BillPayment(
        id: nextId('bill'),
        category: BillCategory.electricity,
        billerName: 'CEB',
        amount: 6500,
        status: BillPaymentStatus.paid,
        date: now.subtract(const Duration(days: 8)),
        customerRef: 'ACC-2291',
      ),
    ];
    devices[uid] = [
      SecurityDevice(
        id: nextId('dev'),
        name: 'iPad · Front desk',
        lastSeen: now,
        trusted: true,
      ),
      SecurityDevice(
        id: nextId('dev'),
        name: 'Windows PC · Back office',
        lastSeen: now.subtract(const Duration(days: 2)),
      ),
    ];
    securityEvents[uid] = [
      SecurityEvent(
        id: nextId('evt'),
        title: 'New device sign-in',
        description: 'A sign-in from Windows PC · Back office was recorded.',
        severity: EventSeverity.medium,
        date: now.subtract(const Duration(days: 2)),
      ),
    ];
    securityOverviews[uid] = const SecurityOverview(
      score: 79,
      twoFactorEnabled: false,
    );
  }

  /// Simulates an incoming notification (mirrors web's simulateIncomingNotification).
  /// Caps unread simulated at 5, rotates 5 templates.
  static const _simTemplates =
      <({String title, String body, NotificationType type})>[
        (
          title: 'Transfer received',
          body: 'You received MUR 8,500 from Nova Studio.',
          type: NotificationType.transfer,
        ),
        (
          title: 'Bill due soon',
          body: 'CEB electricity bill of MUR 1,450 is due in 3 days.',
          type: NotificationType.bill,
        ),
        (
          title: 'Security alert',
          body: 'New sign-in detected from an unknown device.',
          type: NotificationType.security,
        ),
        (
          title: 'Goal milestone',
          body: 'Your Emergency Fund is now 30% complete.',
          type: NotificationType.goal,
        ),
        (
          title: 'System update',
          body: 'Finovault v1.2 is now available.',
          type: NotificationType.system,
        ),
      ];

  void simulateIncomingNotification(String userId) {
    final existing = notifications[userId] ?? [];
    final unreadCount = existing.where((n) => !n.isRead).length;
    if (unreadCount >= 5) return; // cap at 5 unread simulated
    final template = _simTemplates[existing.length % _simTemplates.length];
    final ntf = AppNotification(
      id: nextId('ntf'),
      title: template.title,
      body: template.body,
      type: template.type,
      createdAt: DateTime.now(),
    );
    existing.insert(0, ntf);
    notifications[userId] = existing;
    persist();
  }
}

class MfaChallenge {
  MfaChallenge({
    required this.userId,
    required this.methods,
    DateTime? expiresAt,
  }) : expiresAt = expiresAt ?? DateTime.now().add(const Duration(minutes: 10));

  final String userId;
  final List<String> methods;
  final DateTime? expiresAt;

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}
