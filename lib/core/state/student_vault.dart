import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models.dart';
import '../mock/api.dart';
import '../mock/db.dart';
import '../providers.dart';

/// Represents a student's budget/allowance period (e.g. "October Allowance", "Week 42", "Semester 1").
class StudentPeriod {
  const StudentPeriod({
    required this.id,
    required this.name,
    required this.budgetAmount,
    required this.startDate,
    required this.endDate,
    this.currency = 'MUR',
    this.isArchived = false,
    this.archivedAt,
    this.wrapSummary,
  });

  final String id;
  final String name;
  final double budgetAmount;
  final String currency;
  final DateTime startDate;
  final DateTime endDate;
  final bool isArchived;
  final DateTime? archivedAt;
  final Map<String, dynamic>? wrapSummary;

  int get daysTotal => endDate.difference(startDate).inDays.clamp(1, 365);

  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays.clamp(0, 365) + 1;
  }

  StudentPeriod copyWith({
    String? id,
    String? name,
    double? budgetAmount,
    String? currency,
    DateTime? startDate,
    DateTime? endDate,
    bool? isArchived,
    DateTime? archivedAt,
    Map<String, dynamic>? wrapSummary,
  }) {
    return StudentPeriod(
      id: id ?? this.id,
      name: name ?? this.name,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isArchived: isArchived ?? this.isArchived,
      archivedAt: archivedAt ?? this.archivedAt,
      wrapSummary: wrapSummary ?? this.wrapSummary,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'budgetAmount': budgetAmount,
    'currency': currency,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'isArchived': isArchived,
    'archivedAt': archivedAt?.toIso8601String(),
    'wrapSummary': wrapSummary,
  };

  factory StudentPeriod.fromJson(Map<String, dynamic> json) => StudentPeriod(
    id: json['id'] as String,
    name: json['name'] as String,
    budgetAmount: (json['budgetAmount'] as num).toDouble(),
    currency: (json['currency'] as String?) ?? 'MUR',
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: DateTime.parse(json['endDate'] as String),
    isArchived: (json['isArchived'] as bool?) ?? false,
    archivedAt: json['archivedAt'] != null
        ? DateTime.parse(json['archivedAt'] as String)
        : null,
    wrapSummary: json['wrapSummary'] as Map<String, dynamic>?,
  );
}

/// A frequent place or merchant where the student spends money (Timo, Cascavelle, etc.).
/// This forms the direct data bridge to the V2 student marketplace.
class MerchantSpot {
  const MerchantSpot({
    required this.name,
    required this.category,
    required this.emoji,
    this.visitCount = 0,
    this.totalSpent = 0.0,
    this.currency = 'MUR',
    this.isCampusHotspot = true,
  });

  final String name;
  final String category;
  final String emoji;
  final int visitCount;
  final double totalSpent;
  final String currency;
  final bool isCampusHotspot;

  MerchantSpot copyWith({
    String? name,
    String? category,
    String? emoji,
    int? visitCount,
    double? totalSpent,
    String? currency,
    bool? isCampusHotspot,
  }) {
    return MerchantSpot(
      name: name ?? this.name,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      visitCount: visitCount ?? this.visitCount,
      totalSpent: totalSpent ?? this.totalSpent,
      currency: currency ?? this.currency,
      isCampusHotspot: isCampusHotspot ?? this.isCampusHotspot,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'emoji': emoji,
    'visitCount': visitCount,
    'totalSpent': totalSpent,
    'currency': currency,
    'isCampusHotspot': isCampusHotspot,
  };

  factory MerchantSpot.fromJson(Map<String, dynamic> json) => MerchantSpot(
    name: json['name'] as String,
    category: json['category'] as String,
    emoji: json['emoji'] as String,
    visitCount: (json['visitCount'] as num?)?.toInt() ?? 0,
    totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
    currency: (json['currency'] as String?) ?? 'MUR',
    isCampusHotspot: (json['isCampusHotspot'] as bool?) ?? true,
  );
}

/// A category budget that students set and track (e.g. Food, Transport, Shopping).
class CategoryBudget {
  const CategoryBudget({
    required this.category,
    required this.amount,
    this.emoji = "💳",
  });

  final String category;
  final double amount;
  final String emoji;

  CategoryBudget copyWith({
    String? category,
    double? amount,
    String? emoji,
  }) {
    return CategoryBudget(
      category: category ?? this.category,
      amount: amount ?? this.amount,
      emoji: emoji ?? this.emoji,
    );
  }

  Map<String, dynamic> toJson() => {
    "category": category,
    "amount": amount,
    "emoji": emoji,
  };

  factory CategoryBudget.fromJson(Map<String, dynamic> json) => CategoryBudget(
    category: json["category"] as String,
    amount: (json["amount"] as num).toDouble(),
    emoji: (json["emoji"] as String?) ?? "💳",
  );
}

/// A savings pot/piggy bank for students (e.g. New Laptop, Vacation Trip, Emergency Stash).
class StudentSavingsPot {
  const StudentSavingsPot({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.emoji = '🐷',
    this.isCompleted = false,
  });

  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String emoji;
  final bool isCompleted;

  double get progress => targetAmount <= 0 ? 0.0 : (currentAmount / targetAmount).clamp(0.0, 1.0);
  double get remaining => (targetAmount - currentAmount).clamp(0.0, targetAmount);

  StudentSavingsPot copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    String? emoji,
    bool? isCompleted,
  }) {
    return StudentSavingsPot(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      emoji: emoji ?? this.emoji,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'emoji': emoji,
    'isCompleted': isCompleted,
  };

  factory StudentSavingsPot.fromJson(Map<String, dynamic> json) => StudentSavingsPot(
    id: json['id'] as String,
    name: json['name'] as String,
    targetAmount: (json['targetAmount'] as num).toDouble(),
    currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
    emoji: (json['emoji'] as String?) ?? '🐷',
    isCompleted: (json['isCompleted'] as bool?) ?? false,
  );
}

enum SpendMood {
  cruising, // < 50% spent -> green
  steady,   // 50% - 80% spent -> yellow
  ramenMode // > 80% spent -> red/coral
}

class StudentVaultState {
  const StudentVaultState({
    required this.activePeriod,
    required this.transactions,
    required this.merchants,
    this.categoryBudgets = const [],
    this.savingsPots = const [],
    this.archivedPeriods = const [],
    this.filterMerchant,
  });

  final StudentPeriod activePeriod;
  final List<Transaction> transactions;
  final List<MerchantSpot> merchants;
  final List<CategoryBudget> categoryBudgets;
  final List<StudentSavingsPot> savingsPots;
  final List<StudentPeriod> archivedPeriods;
  final String? filterMerchant;

  /// Total saved across all savings pots
  double get totalSaved => savingsPots.fold(0.0, (acc, p) => acc + p.currentAmount);

  /// Total target across all savings pots
  double get totalSavingsTarget => savingsPots.fold(0.0, (acc, p) => acc + p.targetAmount);

  /// Overall savings progress (0.0 to 1.0)
  double get savingsProgress => totalSavingsTarget <= 0 ? 0.0 : (totalSaved / totalSavingsTarget).clamp(0.0, 1.0);

  String get currency => activePeriod.currency;

  /// Total amount spent in the active period (only expenses)
  double get totalSpent {
    return transactions
        .where((t) => t.isExpense)
        .fold(0.0, (acc, t) => acc + t.amount);
  }

  /// Remaining allowance/pocket money
  double get remainingBudget => (activePeriod.budgetAmount - totalSpent).clamp(-999999.0, 999999.0);

  /// Spend ratio (0.0 to 1.0+)
  double get spendRatio {
    if (activePeriod.budgetAmount <= 0) return 0.0;
    return (totalSpent / activePeriod.budgetAmount).clamp(0.0, 1.5);
  }

  /// Safe daily burn speed
  double get dailySafeSpend {
    final days = activePeriod.daysRemaining;
    if (days <= 0 || remainingBudget <= 0) return 0.0;
    return remainingBudget / days;
  }

  /// Fun visual mood
  SpendMood get mood {
    if (spendRatio < 0.50) return SpendMood.cruising;
    if (spendRatio < 0.80) return SpendMood.steady;
    return SpendMood.ramenMode;
  }

  String get moodLabel => switch (mood) {
    SpendMood.cruising => 'Cruising 🟢',
    SpendMood.steady => 'Steady 🟡',
    SpendMood.ramenMode => 'Ramen Mode 🍜',
  };

  String get moodSubtitle => switch (mood) {
    SpendMood.cruising => 'Plenty of fuel left! You are pacing well.',
    SpendMood.steady => 'Halfway mark. Keep an eye on non-essentials.',
    SpendMood.ramenMode => 'Low fuel warning! Prioritize basics only.',
  };

  /// Total spent in this active period for a specific category
  double spentForCategory(String category) {
    final cat = category.toLowerCase().trim();
    return transactions
        .where((t) => t.isExpense && t.category.toLowerCase().trim() == cat)
        .fold(0.0, (acc, t) => acc + t.amount);
  }

  /// Remaining amount in a category budget
  double remainingForCategory(CategoryBudget b) {
    return b.amount - spentForCategory(b.category);
  }

  /// Progress ratio for a category budget (0.0 to 1.0)
  double progressForCategory(CategoryBudget b) {
    if (b.amount <= 0) return 0.0;
    return (spentForCategory(b.category) / b.amount).clamp(0.0, 1.0);
  }
  /// Transactions filtered by merchant (if filter active) and ordered latest first
  List<Transaction> get visibleTransactions {
    var list = transactions.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    if (filterMerchant != null && filterMerchant!.isNotEmpty) {
      list = list.where((t) => (t.merchantName ?? '').toLowerCase() == filterMerchant!.toLowerCase()).toList();
    }
    return list;
  }

  /// Top spots sorted by spend
  List<MerchantSpot> get topSpots {
    final sorted = merchants.toList()
      ..sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
    return sorted;
  }

  StudentVaultState copyWith({
    StudentPeriod? activePeriod,
    List<Transaction>? transactions,
    List<MerchantSpot>? merchants,
    List<CategoryBudget>? categoryBudgets,
    List<StudentSavingsPot>? savingsPots,
    List<StudentPeriod>? archivedPeriods,
    String? filterMerchant,
    bool clearFilter = false,
  }) {
    return StudentVaultState(
      activePeriod: activePeriod ?? this.activePeriod,
      transactions: transactions ?? this.transactions,
      merchants: merchants ?? this.merchants,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
      savingsPots: savingsPots ?? this.savingsPots,
      archivedPeriods: archivedPeriods ?? this.archivedPeriods,
      filterMerchant: clearFilter ? null : (filterMerchant ?? this.filterMerchant),
    );
  }
}

class StudentVaultNotifier extends StateNotifier<StudentVaultState> {
  StudentVaultNotifier({
    required KvStore? store,
    FinovaultApi? api,
    String? Function()? tokenGetter,
  })  : _store = store,
        _api = api,
        _tokenGetter = tokenGetter,
        super(_initialState()) {
    _hydrate();
  }

  final KvStore? _store;
  final FinovaultApi? _api;
  final String? Function()? _tokenGetter;
  static const _storageKey = 'finovault.student_vault.v1';

  static StudentVaultState _initialState() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final defaultPeriod = StudentPeriod(
      id: 'period_default',
      name: 'Monthly Allowance',
      budgetAmount: 5000.0,
      currency: 'MUR',
      startDate: startOfMonth,
      endDate: endOfMonth,
    );

    final defaultMerchants = [
      const MerchantSpot(name: 'Timo', category: 'Food & Drinks', emoji: '🍔', isCampusHotspot: true),
      const MerchantSpot(name: 'Cascavelle', category: 'Shopping & Essentials', emoji: '🛍️', isCampusHotspot: true),
      const MerchantSpot(name: 'Campus Tuck', category: 'Snacks & Study', emoji: '🥪', isCampusHotspot: true),
      const MerchantSpot(name: 'Metro Express', category: 'Transport', emoji: '🚌', isCampusHotspot: true),
      const MerchantSpot(name: 'Winners', category: 'Groceries', emoji: '🛒', isCampusHotspot: true),
    ];

    final defaultBudgets = [
      const CategoryBudget(category: 'Food & Drinks', amount: 1800.0, emoji: '🍔'),
      const CategoryBudget(category: 'Shopping & Essentials', amount: 1000.0, emoji: '🛍️'),
      const CategoryBudget(category: 'Snacks & Study', amount: 600.0, emoji: '🥪'),
      const CategoryBudget(category: 'Transport', amount: 400.0, emoji: '🚌'),
      const CategoryBudget(category: 'Groceries', amount: 800.0, emoji: '🛒'),
    ];

    final defaultPots = [
      const StudentSavingsPot(
        id: 'pot_1',
        name: 'Campus Laptop',
        targetAmount: 15000.0,
        currentAmount: 6500.0,
        emoji: '💻',
      ),
      const StudentSavingsPot(
        id: 'pot_2',
        name: 'Grand Baie Trip',
        targetAmount: 3000.0,
        currentAmount: 1800.0,
        emoji: '🌴',
      ),
      const StudentSavingsPot(
        id: 'pot_3',
        name: 'Emergency Stash',
        targetAmount: 2000.0,
        currentAmount: 1200.0,
        emoji: '🆘',
      ),
    ];

    return StudentVaultState(
      activePeriod: defaultPeriod,
      transactions: [],
      merchants: defaultMerchants,
      categoryBudgets: defaultBudgets,
      savingsPots: defaultPots,
      archivedPeriods: [],
    );
  }

  void _hydrate() {
    if (_store == null) {
      _seedSampleDataIfEmpty();
      return;
    }
    try {
      final raw = _store.getString(_storageKey);
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final activePeriod = StudentPeriod.fromJson(data['activePeriod'] as Map<String, dynamic>);
        final rawTx = (data['transactions'] as List<dynamic>? ?? []);
        final txs = rawTx.map((e) => _txFromJson(e as Map<String, dynamic>)).toList();
        final rawM = (data['merchants'] as List<dynamic>? ?? []);
        final merchants = rawM.map((e) => MerchantSpot.fromJson(e as Map<String, dynamic>)).toList();
        final rawB = (data['categoryBudgets'] as List<dynamic>? ?? []);
        final budgets = rawB.map((e) => CategoryBudget.fromJson(e as Map<String, dynamic>)).toList();
        final rawP = (data['savingsPots'] as List<dynamic>? ?? []);
        final pots = rawP.map((e) => StudentSavingsPot.fromJson(e as Map<String, dynamic>)).toList();
        final rawArch = (data['archivedPeriods'] as List<dynamic>? ?? []);
        final archived = rawArch.map((e) => StudentPeriod.fromJson(e as Map<String, dynamic>)).toList();

        state = StudentVaultState(
          activePeriod: activePeriod,
          transactions: txs,
          merchants: merchants.isNotEmpty ? merchants : state.merchants,
          categoryBudgets: budgets.isNotEmpty ? budgets : state.categoryBudgets,
          savingsPots: pots.isNotEmpty ? pots : state.savingsPots,
          archivedPeriods: archived,
        );
      } else {
        _seedSampleDataIfEmpty();
      }
    } catch (_) {
      _seedSampleDataIfEmpty();
    }
    _fetchFromBackend();
  }

  void _syncToBackend(Future<void> Function(FinovaultApi api, String? token) action) {
    final api = _api;
    if (api == null) return;
    final token = _tokenGetter?.call();
    action(api, token).catchError((err) {
      debugPrint('StudentVault backend sync note: $err');
    });
  }

  Future<void> _fetchFromBackend() async {
    final api = _api;
    if (api == null) return;
    try {
      final token = _tokenGetter?.call();
      final data = await api.getStudentVault(token);
      if (data.isNotEmpty && data['activePeriod'] != null) {
        final activePeriod = StudentPeriod.fromJson(data['activePeriod'] as Map<String, dynamic>);
        final rawTx = (data['transactions'] as List<dynamic>? ?? []);
        final txs = rawTx.map((e) => _txFromJson(e as Map<String, dynamic>)).toList();
        final rawM = (data['merchants'] as List<dynamic>? ?? []);
        final merchants = rawM.map((e) => MerchantSpot.fromJson(e as Map<String, dynamic>)).toList();
        final rawB = (data['categoryBudgets'] as List<dynamic>? ?? []);
        final budgets = rawB.map((e) => CategoryBudget.fromJson(e as Map<String, dynamic>)).toList();
        final rawP = (data['savingsPots'] as List<dynamic>? ?? []);
        final pots = rawP.map((e) => StudentSavingsPot.fromJson(e as Map<String, dynamic>)).toList();
        final rawArch = (data['archivedPeriods'] as List<dynamic>? ?? []);
        final archived = rawArch.map((e) => StudentPeriod.fromJson(e as Map<String, dynamic>)).toList();

        state = StudentVaultState(
          activePeriod: activePeriod,
          transactions: txs,
          merchants: merchants.isNotEmpty ? merchants : state.merchants,
          categoryBudgets: budgets.isNotEmpty ? budgets : state.categoryBudgets,
          savingsPots: pots.isNotEmpty ? pots : state.savingsPots,
          archivedPeriods: archived,
        );
        await _persist();
      }
    } catch (_) {
      // Offline fallback: keep local hydrated state
    }
  }

  Future<void> _persist() async {
    if (_store == null) return;
    try {
      final map = {
        'activePeriod': state.activePeriod.toJson(),
        'transactions': state.transactions.map(_txToJson).toList(),
        'merchants': state.merchants.map((m) => m.toJson()).toList(),
        'categoryBudgets': state.categoryBudgets.map((b) => b.toJson()).toList(),
        'savingsPots': state.savingsPots.map((p) => p.toJson()).toList(),
        'archivedPeriods': state.archivedPeriods.map((p) => p.toJson()).toList(),
      };
      await _store.setString(_storageKey, jsonEncode(map));
    } catch (e) {
      debugPrint('StudentVault persist error: $e');
    }
  }

  void _seedSampleDataIfEmpty() {
    if (state.transactions.isNotEmpty) return;
    final now = DateTime.now();

    final samples = [
      Transaction(
        id: 'st_1',
        accountId: 'acc_wallet',
        amount: 150.0,
        direction: TransactionDirection.out,
        category: 'Food & Drinks',
        merchantName: 'Timo',
        date: now.subtract(const Duration(hours: 2)),
        isExpense: true,
      ),
      Transaction(
        id: 'st_2',
        accountId: 'acc_wallet',
        amount: 45.0,
        direction: TransactionDirection.out,
        category: 'Transport',
        merchantName: 'Metro Express',
        date: now.subtract(const Duration(hours: 5)),
        isExpense: true,
      ),
      Transaction(
        id: 'st_3',
        accountId: 'acc_wallet',
        amount: 280.0,
        direction: TransactionDirection.out,
        category: 'Shopping & Essentials',
        merchantName: 'Cascavelle',
        date: now.subtract(const Duration(days: 1, hours: 3)),
        isExpense: true,
      ),
      Transaction(
        id: 'st_4',
        accountId: 'acc_wallet',
        amount: 85.0,
        direction: TransactionDirection.out,
        category: 'Snacks & Study',
        merchantName: 'Campus Tuck',
        date: now.subtract(const Duration(days: 1, hours: 7)),
        isExpense: true,
      ),
      Transaction(
        id: 'st_5',
        accountId: 'acc_wallet',
        amount: 320.0,
        direction: TransactionDirection.out,
        category: 'Groceries',
        merchantName: 'Winners',
        date: now.subtract(const Duration(days: 3)),
        isExpense: true,
      ),
      Transaction(
        id: 'st_6',
        accountId: 'acc_wallet',
        amount: 95.0,
        direction: TransactionDirection.out,
        category: 'Food & Drinks',
        merchantName: 'Timo',
        date: now.subtract(const Duration(days: 4)),
        isExpense: true,
      ),
    ];

    // Recalculate merchant stats from samples
    final updatedMerchants = _recalculateMerchants(state.merchants, samples);

    state = state.copyWith(
      transactions: samples,
      merchants: updatedMerchants,
    );
    _persist();
  }

  /// 1-Tap Log Expense ("I bought X from Y for Z")
  Future<void> logExpense({
    required String description,
    required String merchantName,
    required double amount,
    String category = 'Food & Drinks',
    DateTime? date,
  }) async {
    final cleanMerchant = merchantName.trim();
    final cleanDesc = description.trim().isEmpty ? 'Purchase at $cleanMerchant' : description.trim();
    final now = date ?? DateTime.now();

    final newTx = Transaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      accountId: 'acc_wallet',
      amount: amount.abs(),
      direction: TransactionDirection.out,
      category: category,
      merchantName: cleanMerchant,
      description: cleanDesc,
      date: now,
      isExpense: true,
    );

    final updatedTxList = [newTx, ...state.transactions];
    final updatedMerchants = _recalculateMerchants(state.merchants, updatedTxList);

    state = state.copyWith(
      transactions: updatedTxList,
      merchants: updatedMerchants,
    );
    await _persist();
    _syncToBackend((api, token) async {
      await api.logStudentExpense(
        token,
        description: cleanDesc,
        merchantName: cleanMerchant,
        amount: amount.abs(),
        category: category,
        date: now,
      );
    });
  }

  /// Delete an incorrectly logged item
  Future<void> deleteExpense(String transactionId) async {
    final updatedTxList = state.transactions.where((t) => t.id != transactionId).toList();
    final updatedMerchants = _recalculateMerchants(state.merchants, updatedTxList);

    state = state.copyWith(
      transactions: updatedTxList,
      merchants: updatedMerchants,
    );
    await _persist();
    _syncToBackend((api, token) async {
      await api.deleteStudentExpense(token, id: transactionId);
    });
  }

  /// Update an existing logged purchase (description, merchant, amount, category, date)
  Future<void> updateExpense({
    required String id,
    String? description,
    String? merchantName,
    double? amount,
    String? category,
    DateTime? date,
  }) async {
    final updatedTxList = state.transactions.map((t) {
      if (t.id == id) {
        final newDesc = description?.trim();
        final newMerchant = merchantName?.trim();
        return t.copyWith(
          description: (newDesc != null && newDesc.isNotEmpty) ? newDesc : t.description,
          merchantName: (newMerchant != null && newMerchant.isNotEmpty) ? newMerchant : t.merchantName,
          amount: (amount != null && amount > 0) ? amount.abs() : t.amount,
          category: (category != null && category.isNotEmpty) ? category : t.category,
          date: date ?? t.date,
        );
      }
      return t;
    }).toList();

    final updatedMerchants = _recalculateMerchants(state.merchants, updatedTxList);

    state = state.copyWith(
      transactions: updatedTxList,
      merchants: updatedMerchants,
    );
    await _persist();
    _syncToBackend((api, token) async {
      await api.updateStudentExpense(
        token,
        id: id,
        description: description,
        merchantName: merchantName,
        amount: amount,
        category: category,
        date: date,
      );
    });
  }

  /// Update allowance budget amount
  Future<void> updateBudget(double newBudget) async {
    final updatedPeriod = state.activePeriod.copyWith(budgetAmount: newBudget.abs());
    state = state.copyWith(activePeriod: updatedPeriod);
    await _persist();
    _syncToBackend((api, token) async {
      await api.updateStudentBudget(token, budgetAmount: newBudget.abs());
    });
  }

  /// Update allowance budget amount and optional period name
  Future<void> updatePeriodAllowance({
    required double newBudgetAmount,
    String? newName,
  }) async {
    final updatedPeriod = state.activePeriod.copyWith(
      budgetAmount: newBudgetAmount.abs(),
      name: (newName != null && newName.trim().isNotEmpty) ? newName.trim() : state.activePeriod.name,
    );
    state = state.copyWith(activePeriod: updatedPeriod);
    await _persist();
    _syncToBackend((api, token) async {
      await api.updateStudentBudget(token, budgetAmount: newBudgetAmount.abs(), name: newName);
    });
  }

  /// End current period, generate "Period Wrap", and start fresh
  Future<Map<String, dynamic>> resetPeriod({
    required String newPeriodName,
    required double newBudgetAmount,
    int durationDays = 30,
  }) async {
    final current = state.activePeriod;
    final spent = state.totalSpent;
    final topSpot = state.topSpots.isNotEmpty ? state.topSpots.first.name : 'Various';

    // Generate celebratory wrap summary
    final wrap = {
      'periodName': current.name,
      'budgetAmount': current.budgetAmount,
      'totalSpent': spent,
      'savedAmount': (current.budgetAmount - spent).clamp(0.0, current.budgetAmount),
      'topSpot': topSpot,
      'totalTransactions': state.transactions.length,
      'completedAt': DateTime.now().toIso8601String(),
    };

    final archived = current.copyWith(
      isArchived: true,
      archivedAt: DateTime.now(),
      wrapSummary: wrap,
    );

    final now = DateTime.now();
    final newPeriod = StudentPeriod(
      id: 'period_${DateTime.now().millisecondsSinceEpoch}',
      name: newPeriodName.trim().isEmpty ? 'New Allowance' : newPeriodName.trim(),
      budgetAmount: newBudgetAmount.abs(),
      currency: current.currency,
      startDate: now,
      endDate: now.add(Duration(days: durationDays)),
    );

    state = StudentVaultState(
      activePeriod: newPeriod,
      transactions: [], // Fresh slate!
      merchants: state.merchants.map((m) => m.copyWith(visitCount: 0, totalSpent: 0)).toList(),
      archivedPeriods: [archived, ...state.archivedPeriods],
    );

    await _persist();
    _syncToBackend((api, token) async {
      await api.resetStudentPeriod(
        token,
        newPeriodName: newPeriodName,
        newBudgetAmount: newBudgetAmount,
        durationDays: durationDays,
      );
    });
    return wrap;
  }

  Future<void> setCategoryBudget({
    required String category,
    required double amount,
    String? emoji,
  }) async {
    final cat = category.trim();
    final cleanEmoji = emoji ?? _pickEmoji(cat, cat);
    final existingIndex = state.categoryBudgets.indexWhere(
      (b) => b.category.toLowerCase() == cat.toLowerCase(),
    );

    List<CategoryBudget> updated;
    if (existingIndex >= 0) {
      updated = List.of(state.categoryBudgets);
      updated[existingIndex] = CategoryBudget(
        category: cat,
        amount: amount.abs(),
        emoji: cleanEmoji,
      );
    } else {
      updated = [
        ...state.categoryBudgets,
        CategoryBudget(category: cat, amount: amount.abs(), emoji: cleanEmoji),
      ];
    }

    state = state.copyWith(categoryBudgets: updated);
    await _persist();
    _syncToBackend((api, token) async {
      await api.setStudentCategoryBudget(
        token,
        category: cat,
        amount: amount.abs(),
        emoji: cleanEmoji,
      );
    });
  }

  Future<void> deleteCategoryBudget(String category) async {
    final updated = state.categoryBudgets
        .where((b) => b.category.toLowerCase() != category.toLowerCase().trim())
        .toList();
    state = state.copyWith(categoryBudgets: updated);
    await _persist();
    _syncToBackend((api, token) async {
      await api.deleteStudentCategoryBudget(token, category: category);
    });
  }
  void setMerchantFilter(String? merchant) {
    if (state.filterMerchant == merchant) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(filterMerchant: merchant);
    }
  }


  // ---- Savings Pots Management ---------------------------------------------

  Future<void> addSavingsPot(String name, double targetAmount, String emoji) async {
    if (name.trim().isEmpty || targetAmount <= 0) return;
    final pot = StudentSavingsPot(
      id: 'pot_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      targetAmount: targetAmount,
      emoji: emoji.trim().isEmpty ? '🐷' : emoji.trim(),
    );
    state = state.copyWith(savingsPots: [...state.savingsPots, pot]);
    await _persist();
    _syncToBackend((api, token) async {
      await api.addStudentSavingsPot(
        token,
        name: name.trim(),
        targetAmount: targetAmount,
        emoji: emoji.trim().isEmpty ? '🐷' : emoji.trim(),
      );
    });
  }

  Future<void> depositToSavingsPot(String potId, double amount) async {
    if (amount <= 0) return;
    final updated = state.savingsPots.map((p) {
      if (p.id == potId) {
        final newAmount = p.currentAmount + amount;
        return p.copyWith(
          currentAmount: newAmount,
          isCompleted: newAmount >= p.targetAmount,
        );
      }
      return p;
    }).toList();
    state = state.copyWith(savingsPots: updated);
    await _persist();
    _syncToBackend((api, token) async {
      await api.depositStudentSavingsPot(token, potId: potId, amount: amount);
    });
  }

  Future<void> deleteSavingsPot(String potId) async {
    state = state.copyWith(
      savingsPots: state.savingsPots.where((p) => p.id != potId).toList(),
    );
    await _persist();
    _syncToBackend((api, token) async {
      await api.deleteStudentSavingsPot(token, potId: potId);
    });
  }

  List<MerchantSpot> _recalculateMerchants(List<MerchantSpot> existing, List<Transaction> txs) {
    final map = <String, MerchantSpot>{};
    for (final m in existing) {
      map[m.name.toLowerCase()] = m.copyWith(visitCount: 0, totalSpent: 0);
    }

    for (final t in txs) {
      final name = (t.merchantName ?? 'Other').trim();
      if (name.isEmpty) continue;
      final key = name.toLowerCase();

      final current = map[key] ?? MerchantSpot(
        name: name,
        category: t.category,
        emoji: _pickEmoji(name, t.category),
        isCampusHotspot: false,
      );

      map[key] = current.copyWith(
        visitCount: current.visitCount + 1,
        totalSpent: current.totalSpent + t.amount,
      );
    }

    return map.values.toList();
  }

  static String _pickEmoji(String name, String category) {
    final n = name.toLowerCase();
    if (n.contains('timo') || n.contains('burger') || n.contains('food')) return '🍔';
    if (n.contains('cascavelle') || n.contains('shop') || n.contains('mall')) return '🛍️';
    if (n.contains('metro') || n.contains('bus') || n.contains('transport')) return '🚌';
    if (n.contains('campus') || n.contains('tuck') || n.contains('snack')) return '🥪';
    if (n.contains('coffee') || n.contains('cafe')) return '☕';
    if (n.contains('winners') || n.contains('grocery') || n.contains('market')) return '🛒';
    if (n.contains('book') || n.contains('study') || n.contains('pen')) return '📚';
    return '💳';
  }

  static Map<String, dynamic> _txToJson(Transaction t) => {
    'id': t.id,
    'accountId': t.accountId,
    'amount': t.amount,
    'direction': t.direction.name,
    'category': t.category,
    'merchantName': t.merchantName,
    'date': t.date.toIso8601String(),
    'isExpense': t.isExpense,
    'currency': t.currency,
  };

  static Transaction _txFromJson(Map<String, dynamic> j) => Transaction(
    id: j['id'] as String,
    accountId: (j['accountId'] as String?) ?? 'acc_wallet',
    amount: (j['amount'] as num).toDouble(),
    direction: j['direction'] == 'inn' ? TransactionDirection.inn : TransactionDirection.out,
    category: (j['category'] as String?) ?? 'General',
    merchantName: j['merchantName'] as String?,
    date: DateTime.parse(j['date'] as String),
    isExpense: (j['isExpense'] as bool?) ?? true,
    currency: (j['currency'] as String?) ?? 'MUR',
  );
}

final studentVaultProvider = StateNotifierProvider<StudentVaultNotifier, StudentVaultState>((ref) {
  final store = ref.watch(kvStoreProvider);
  final api = ref.watch(apiProvider);
  return StudentVaultNotifier(
    store: store,
    api: api,
    tokenGetter: () => currentToken(ref),
  );
});
