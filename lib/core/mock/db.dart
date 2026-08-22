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
  MockDb({KvStore? store, this.latency = 120}) : _store = store ?? MemoryStore();

  static const storageKey = 'finovault.flutter.mockdb.v1';
  final KvStore _store;
  final int latency;

  final users = <String, UserProfile>{};
  final credentials = <String, String>{};
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
      seedDemoUser();
      await persist();
      return;
    }
    final j = jsonDecode(raw) as Map<String, dynamic>;
    _counter = (j['counter'] as num?)?.toInt() ?? 0;
    users.addEntries(((j['users'] as Map?) ?? {})
        .entries
        .map((e) => MapEntry(e.key as String, UserProfile.fromJson(e.value as Map<String, dynamic>))));
    credentials.addEntries(((j['credentials'] as Map?) ?? {}).entries.map((e) => MapEntry(e.key as String, e.value as String)));
    prefsByUser.addEntries(((j['prefs'] as Map?) ?? {}).entries
        .map((e) => MapEntry(e.key as String, UserPreferences.fromJson(e.value as Map<String, dynamic>))));
    sessions.addEntries(((j['sessions'] as Map?) ?? {}).entries.map((e) => MapEntry(e.key as String, e.value as String)));
    void list<T>(
      Map<String, dynamic>? src,
      Map<String, List<T>> into,
      T Function(Map<String, dynamic>) from,
    ) {
      if (src == null) return;
      src.forEach((k, v) => into[k] = ((v as List).cast<Map<String, dynamic>>()).map(from).toList());
    }

    list(j['accounts'] as Map<String, dynamic>?, accounts, Account.fromJson);
    list(j['transactions'] as Map<String, dynamic>?, transactions, Transaction.fromJson);
    list(j['budgets'] as Map<String, dynamic>?, budgets, Budget.fromJson);
    list(j['goals'] as Map<String, dynamic>?, goals, SavingsGoal.fromJson);
    list(j['devices'] as Map<String, dynamic>?, devices, SecurityDevice.fromJson);
    list(j['securityEvents'] as Map<String, dynamic>?, securityEvents, SecurityEvent.fromJson);
    list(j['invoices'] as Map<String, dynamic>?, invoices, Invoice.fromJson);
    list(j['vendors'] as Map<String, dynamic>?, vendors, Vendor.fromJson);
    list(j['transfers'] as Map<String, dynamic>?, transfers, Transfer.fromJson);
    list(j['billPayments'] as Map<String, dynamic>?, billPayments, BillPayment.fromJson);
    list(j['payees'] as Map<String, dynamic>?, payees, Payee.fromJson);
    ((j['securityOverviews'] as Map?) ?? {}).forEach(
      (k, v) => securityOverviews[k as String] = SecurityOverview.fromJson(v as Map<String, dynamic>),
    );
  }

  Future<void> persist() async {
    final j = {
      'counter': _counter,
      'users': users.map((k, v) => MapEntry(k, v.toJson())),
      'credentials': credentials,
      'prefs': prefsByUser.map((k, v) => MapEntry(k, v.toJson())),
      'sessions': sessions,
      'accounts': accounts.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
      'transactions': transactions.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
      'budgets': budgets.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
      'goals': goals.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
      'devices': devices.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
      'securityEvents': securityEvents.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
      'securityOverviews': securityOverviews.map((k, v) => MapEntry(k, v.toJson())),
      'invoices': invoices.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
      'vendors': vendors.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
      'transfers': transfers.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
      'billPayments': billPayments.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
      'payees': payees.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
    };
    await _store.setString(storageKey, jsonEncode(j));
  }

  Future<void> clearStorage() => _store.remove(storageKey);

  // ---- seed ----------------------------------------------------------------

  /// Demo identity shared across web + mobile: demo@finovault.app / Vault123!
  void seedDemoUser() {
    const uid = 'user_demo';
    final now = DateTime.now();
    users[uid] = UserProfile(
      id: uid,
      email: 'demo@finovault.app',
      fullName: 'Amina Diallo',
      primaryRole: PrimaryRole.entrepreneur,
      scheme: RoleScheme.femaleFounder,
      createdAt: now.subtract(const Duration(days: 90)),
    );
    credentials['demo@finovault.app'] = 'Vault123!';
    prefsByUser[uid] = const UserPreferences(
      financialGoals: ['retirement', 'business'],
      riskTolerance: RiskTolerance.high,
      onboardingCompleted: true,
    );

    final bankId = nextId('acc');
    final momoId = nextId('acc');
    accounts[uid] = [
      Account(id: bankId, name: 'MCB Bank', type: AccountType.bank, institution: 'MCB', balance: 42500),
      Account(id: momoId, name: 'MyT Money', type: AccountType.mobileMoney, institution: 'MyT', balance: 8750),
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
          isExpense: false),
      Transaction(
          id: nextId('tx'),
          accountId: bankId,
          amount: 15000,
          direction: TransactionDirection.out,
          category: 'Rent',
          merchantName: 'Skyline Properties',
          date: now.subtract(const Duration(days: 24))),
      Transaction(
          id: nextId('tx'),
          accountId: momoId,
          amount: 8500,
          direction: TransactionDirection.inn,
          category: 'Invoice',
          merchantName: 'Nova Studio',
          date: now.subtract(const Duration(days: 18)),
          isExpense: false),
      Transaction(
          id: nextId('tx'),
          accountId: momoId,
          amount: 3200,
          direction: TransactionDirection.out,
          category: 'Groceries',
          merchantName: 'Winners Supermarket',
          date: now.subtract(const Duration(days: 9))),
      Transaction(
          id: nextId('tx'),
          accountId: momoId,
          amount: 1800,
          direction: TransactionDirection.out,
          category: 'Transport',
          merchantName: 'Fuel Station',
          date: now.subtract(const Duration(days: 5))),
      Transaction(
          id: nextId('tx'),
          accountId: bankId,
          amount: 2400,
          direction: TransactionDirection.out,
          category: 'Utilities',
          merchantName: 'CEB',
          date: now.subtract(const Duration(days: 2))),
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
        sourceAccountId: bankId);
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
      SecurityDevice(id: nextId('dev'), name: 'Pixel 8 · Port Louis', lastSeen: now, trusted: true),
      SecurityDevice(id: nextId('dev'), name: 'Windows PC · Home office', lastSeen: now.subtract(const Duration(days: 2))),
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
    securityOverviews[uid] = const SecurityOverview(score: 72, twoFactorEnabled: false);
    invoices[uid] = [
      Invoice(
          id: nextId('inv'),
          clientName: 'Bell Attractions',
          amount: 12000,
          dueDate: now.add(const Duration(days: 10)),
          status: InvoiceStatus.sent),
      Invoice(
          id: nextId('inv'),
          clientName: 'Nova Studio',
          amount: 8500,
          dueDate: now.subtract(const Duration(days: 18)),
          status: InvoiceStatus.paid),
      Invoice(
          id: nextId('inv'),
          clientName: 'Kite Media',
          amount: 4500,
          dueDate: now.subtract(const Duration(days: 6)),
          status: InvoiceStatus.overdue),
    ];
    vendors[uid] = const [
      Vendor(id: 'ven_seed_1', name: 'Print Hub Ltd', totalSpend: 12400, reliabilityScore: 92),
      Vendor(id: 'ven_seed_2', name: 'CloudHost', totalSpend: 3600, reliabilityScore: 78),
    ];
    payees[uid] = const [
      Payee(id: 'pay_seed_1', name: 'Jean-Paul R.', destination: '+230 5124 8890'),
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
  }
}
