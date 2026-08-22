import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models.dart';
import '../providers.dart';
import 'auth.dart';

// Data providers. Each watches the auth state so logging in/out refreshes
// everything automatically; mutations invalidate what they touch.

final accountsProvider = FutureProvider<List<Account>>((ref) async {
  ref.watch(authProvider);
  final api = ref.watch(apiProvider);
  return api.accounts(currentToken(ref));
});

final transactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  ref.watch(authProvider);
  final api = ref.watch(apiProvider);
  return api.transactions(currentToken(ref));
});

final budgetsProvider = FutureProvider<List<Budget>>((ref) async {
  ref.watch(authProvider);
  final api = ref.watch(apiProvider);
  return api.budgets(currentToken(ref));
});

final goalsProvider = FutureProvider<List<SavingsGoal>>((ref) async {
  ref.watch(authProvider);
  final api = ref.watch(apiProvider);
  return api.goals(currentToken(ref));
});

final invoicesProvider = FutureProvider<List<Invoice>>((ref) async {
  ref.watch(authProvider);
  final api = ref.watch(apiProvider);
  return api.invoices(currentToken(ref));
});

final vendorsProvider = FutureProvider<List<Vendor>>((ref) async {
  ref.watch(authProvider);
  final api = ref.watch(apiProvider);
  return api.vendors(currentToken(ref));
});

final transfersProvider = FutureProvider<List<Transfer>>((ref) async {
  ref.watch(authProvider);
  final api = ref.watch(apiProvider);
  return api.transfers(currentToken(ref));
});

final billPaymentsProvider = FutureProvider<List<BillPayment>>((ref) async {
  ref.watch(authProvider);
  final api = ref.watch(apiProvider);
  return api.billPayments(currentToken(ref));
});

final payeesProvider = FutureProvider<List<Payee>>((ref) async {
  ref.watch(authProvider);
  final api = ref.watch(apiProvider);
  return api.payees(currentToken(ref));
});

final securityOverviewProvider = FutureProvider<SecurityOverview>((ref) async {
  ref.watch(authProvider);
  final api = ref.watch(apiProvider);
  return api.securityOverview(currentToken(ref));
});

final securityDevicesProvider = FutureProvider<List<SecurityDevice>>((ref) async {
  ref.watch(authProvider);
  final api = ref.watch(apiProvider);
  return api.devices(currentToken(ref));
});

final securityEventsProvider = FutureProvider<List<SecurityEvent>>((ref) async {
  ref.watch(authProvider);
  final api = ref.watch(apiProvider);
  return api.securityEvents(currentToken(ref));
});

final pensionPlanProvider = FutureProvider<PensionPlan?>((ref) async {
  ref.watch(authProvider);
  final api = ref.watch(apiProvider);
  return api.getPensionPlan(currentToken(ref));
});

final pensionContributionsProvider = FutureProvider<List<PensionContribution>>((ref) async {
  ref.watch(authProvider);
  final api = ref.watch(apiProvider);
  return api.pensionContributions(currentToken(ref));
});

/// Derived projection for the current plan (zeros when no plan yet).
final pensionProjectionProvider = Provider<PensionProjection>((ref) {
  final plan = ref.watch(pensionPlanProvider).value;
  if (plan == null) {
    return const PensionProjection(shortPotProjected: 0, longPotProjected: 0, totalProjected: 0, yearsToRetirement: 0);
  }
  return plan.computeProjection();
});

/// Selected bottom tab of the HomeShell (lets quick actions deep-link tabs).
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

// ---- derived summary used by persona homes ---------------------------------

class BudgetLine {
  const BudgetLine({required this.category, required this.amount, required this.spent});

  final String category;
  final double amount;
  final double spent;

  double get progress => amount <= 0 ? 0 : (spent / amount).clamp(0.0, 1.0);

  double get remaining => (amount - spent).clamp(0.0, double.infinity).toDouble();
}

class MoneySummary {
  const MoneySummary({
    required this.totalBalance,
    required this.monthIncome,
    required this.monthExpense,
    required this.unpaidInvoiceCount,
    required this.unpaidInvoiceTotal,
    required this.overdueInvoiceCount,
    required this.savedInGoals,
    required this.runwayMonths,
    required this.budgetLines,
    required this.topExpenseCategory,
    required this.hasVendors,
  });

  final double totalBalance;
  final double monthIncome;
  final double monthExpense;
  final int unpaidInvoiceCount;
  final double unpaidInvoiceTotal;
  final int overdueInvoiceCount;
  final double savedInGoals;
  final double runwayMonths;
  final List<BudgetLine> budgetLines;
  final String? topExpenseCategory;
  final bool hasVendors;

  /// Freelancer tax shield estimate: ~15% of monthly income.
  double get taxEstimate => monthIncome * 0.15;
}

final moneySummaryProvider = Provider<MoneySummary>((ref) {
  final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
  final transactions = ref.watch(transactionsProvider).value ?? const <Transaction>[];
  final budgets = ref.watch(budgetsProvider).value ?? const <Budget>[];
  final goals = ref.watch(goalsProvider).value ?? const <SavingsGoal>[];
  final invoices = ref.watch(invoicesProvider).value ?? const <Invoice>[];
  final vendors = ref.watch(vendorsProvider).value ?? const <Vendor>[];

  final now = DateTime.now();
  final monthTx = transactions.where((t) => t.date.year == now.year && t.date.month == now.month).toList();
  final monthIncome =
      monthTx.where((t) => t.direction == TransactionDirection.inn).fold<double>(0, (s, t) => s + t.amount);
  final monthExpense =
      monthTx.where((t) => t.direction == TransactionDirection.out).fold<double>(0, (s, t) => s + t.amount);

  final unpaid = invoices.where((i) => i.status == InvoiceStatus.sent || i.status == InvoiceStatus.overdue).toList();
  final overdue = invoices.where((i) => i.status == InvoiceStatus.overdue).length;

  final lines = budgets.map((b) {
    final spent = monthTx
        .where((t) => t.direction == TransactionDirection.out && t.category.toLowerCase() == b.category.toLowerCase())
        .fold<double>(0, (s, t) => s + t.amount);
    return BudgetLine(category: b.category, amount: b.amount, spent: spent);
  }).toList();

  var topCategory = -1.0;
  String? topName;
  for (final t in monthTx.where((t) => t.direction == TransactionDirection.out)) {
    if (t.amount > topCategory) {
      topCategory = t.amount;
      topName = t.category;
    }
  }

  return MoneySummary(
    totalBalance: accounts.fold<double>(0, (s, a) => s + a.balance),
    monthIncome: monthIncome,
    monthExpense: monthExpense,
    unpaidInvoiceCount: unpaid.length,
    unpaidInvoiceTotal: unpaid.fold<double>(0, (s, i) => s + i.amount),
    overdueInvoiceCount: overdue,
    savedInGoals: goals.fold<double>(0, (s, g) => s + g.currentAmount),
    runwayMonths: monthExpense <= 0 ? 12 : (accounts.fold<double>(0, (s, a) => s + a.balance) / monthExpense),
    budgetLines: lines,
    topExpenseCategory: topName,
    hasVendors: vendors.isNotEmpty,
  );
});
