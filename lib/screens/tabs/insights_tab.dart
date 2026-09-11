import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/csv_export.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/state/auth.dart';
import '../../core/state/money.dart';
import '../../core/state/preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/components.dart';
import '../../widgets/ui.dart';
import '../home/persona_homes.dart';
import '../home_shell.dart';

class InsightsTab extends ConsumerWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final summary = ref.watch(moneySummaryProvider);
    final language = ref.watch(preferencesProvider).language;
    final role =
        ref.watch(currentUserProvider)?.primaryRole ?? PrimaryRole.individual;
    final txs = ref.watch(transactionsProvider).value ?? const <Transaction>[];

    final incomeLabel = switch (role) {
      PrimaryRole.freelancer => s.clientIncome,
      PrimaryRole.sme => s.revenue,
      PrimaryRole.entrepreneur => s.sales,
      _ => s.incomeLabel,
    };
    final expenseLabel = switch (role) {
      PrimaryRole.freelancer => s.businessCosts,
      PrimaryRole.sme => s.overheads,
      PrimaryRole.entrepreneur => s.cogs,
      _ => s.expensesLabel,
    };
    final briefingTitle = switch (role) {
      PrimaryRole.freelancer => s.clientPipeline,
      PrimaryRole.sme => s.cashBufferLabel,
      PrimaryRole.entrepreneur => s.runway,
      _ => s.dailyBriefing,
    };

    final now = DateTime.now();
    final monthTx = txs
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();
    final income = monthTx
        .where((t) => t.direction == TransactionDirection.inn)
        .fold<double>(0, (s, t) => s + t.amount);
    final expense = monthTx
        .where((t) => t.direction == TransactionDirection.out)
        .fold<double>(0, (s, t) => s + t.amount);

    final byCat = <String, double>{};
    for (final t in monthTx.where(
      (t) => t.direction == TransactionDirection.out,
    )) {
      byCat[t.category] = (byCat[t.category] ?? 0) + t.amount;
    }
    final cats = byCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalCat = cats.fold<double>(0, (s, e) => s + e.value);

    return ListView(
      padding: const EdgeInsets.all(FvSpacing.x5),
      children: [
        FvCard(
          accent: FvColors.primary,
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.fvWash,
                  borderRadius: BorderRadius.circular(FvRadius.iconContainer),
                ),
                child: Icon(
                  Icons.psychology_outlined,
                  size: 20,
                  color: context.fvPrimary,
                ),
              ),
              const SizedBox(width: FvSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.moneyCoach,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.fvText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.coachBlurb,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.fvTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: txs.isEmpty ? null : () => _exportCsv(context, txs),
                icon: const Icon(Icons.download_outlined, size: 16),
                label: Text(s.exportCsv),
              ),
            ],
          ),
        ),
        SectionHeader(title: s.thisMonth),
        FvCard(
          accent: FvColors.primary,
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: Row(
            children: [
              Expanded(
                child: FvStatCard(
                  label: incomeLabel,
                  value: FvFormat.formatMoney(income, language: language),
                  valueColor: context.fvSuccess,
                ),
              ),
              Expanded(
                child: FvStatCard(
                  label: expenseLabel,
                  value: FvFormat.formatMoney(expense, language: language),
                  valueColor: context.fvError,
                ),
              ),
              Expanded(
                child: FvStatCard(
                  label: s.netLabel,
                  value: FvFormat.formatMoney(
                    income - expense,
                    language: language,
                  ),
                  valueColor: (income - expense) >= 0
                      ? context.fvSuccess
                      : context.fvError,
                ),
              ),
            ],
          ),
        ),
        SectionHeader(title: s.spendingByCategory),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: cats.isEmpty
              ? Text(
                  s.notEnoughData,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.fvTextSecondary,
                  ),
                )
              : Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: cats.asMap().entries.map((e) {
                            final entry = e.value;
                            final pct = totalCat <= 0
                                ? 0.0
                                : entry.value / totalCat;
                            return PieChartSectionData(
                              value: entry.value,
                              title: '${(pct * 100).round()}%',
                              color: FvColors.categoryColor(entry.key),
                              radius: 70,
                              titleStyle: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: FvSpacing.x3),
                    ...cats.asMap().entries.map((e) {
                      final entry = e.value;
                      final color = FvColors.categoryColor(entry.key);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            FvCategoryChip(label: entry.key, color: color),
                            const Spacer(),
                            Text(
                              FvFormat.formatMoney(
                                entry.value,
                                language: language,
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.fvText,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
        ),
        SectionHeader(title: briefingTitle),
        FvCard(
          accent: FvColors.primary,
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.topCategoryThisMonth,
                style: TextStyle(fontSize: 12, color: context.fvTextSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                summary.topExpenseCategory ?? s.noSpendingYet,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.fvText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.spentSoFar(
                  FvFormat.formatMoney(
                    summary.monthExpense,
                    language: language,
                  ),
                ),
                style: TextStyle(fontSize: 13, color: context.fvTextSecondary),
              ),
            ],
          ),
        ),
        // Role-specific insight cards
        if (role == PrimaryRole.sme) ...[
          const CashFlowForecastCard(),
          const VendorParetoCard(),
          const ComplianceCalendarCard(),
          const PayrollEfficiencyCard(),
        ] else if (role == PrimaryRole.entrepreneur) ...[
          const MrrArrCard(),
          const BurnMultipleCard(),
          const FundraisingTrackerCard(),
          if (ref.watch(currentUserProvider)?.scheme ==
              RoleScheme.femaleFounder) ...[
            const GrantOpportunityCard(),
          ],
        ] else if (role == PrimaryRole.freelancer) ...[
          _FreelancerTaxInsightCard(summary: summary),
          _FreelancerClientInsightCard(summary: summary),
          _FreelancerDsoInsightCard(summary: summary),
        ] else ...[
          _IndividualSavingsInsightCard(summary: summary),
        ],
      ],
    );
  }

  Future<void> _exportCsv(BuildContext context, List<Transaction> txs) async {
    final s = AppLocalizations.of(context);
    final List<List<String>> rows = [
      [s.csvDate, s.csvType, s.csvAmount, s.csvCategory, s.csvMerchant],
      for (final t in txs)
        [
          t.date.toIso8601String(),
          t.direction == TransactionDirection.inn ? 'income' : 'expense',
          (t.direction == TransactionDirection.inn ? t.amount : -t.amount)
              .toStringAsFixed(2),
          t.category,
          t.merchantName ?? '',
        ],
    ];
    final csv = rows
        .map((r) => r.map((c) => '"${c.replaceAll('"', '""')}"').join(','))
        .join('\n');
    await downloadCsv('finovault-transactions.csv', csv);
    if (!kIsWeb && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.csvCopied)));
    }
  }
}

/// Freelancer: tax shield estimate card.
class _FreelancerTaxInsightCard extends StatelessWidget {
  const _FreelancerTaxInsightCard({required this.summary});

  final MoneySummary summary;

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final language =
        Localizations.localeOf(context).languageCode.startsWith('fr')
        ? 'fr'
        : 'en';
    final tax = summary.taxEstimate;
    return _InsightCard(
      icon: Icons.umbrella_outlined,
      title: s.taxEfficiency,
      rows: [
        _InsightRow(
          label: s.taxEstimate,
          value: FvFormat.formatMoney(tax, language: language),
          color: context.fvWarning,
        ),
        _InsightRow(label: s.approxTax, value: '20%', color: context.fvPrimary),
      ],
      tip: s.coachFreelancerTax(
        FvFormat.formatMoney(summary.monthIncome, language: language),
        FvFormat.formatMoney(tax, language: language),
      ),
      onTap: () => openNewGoal(context),
    );
  }
}

/// Freelancer: client concentration card (top payees by income).
class _FreelancerClientInsightCard extends ConsumerWidget {
  const _FreelancerClientInsightCard({required this.summary});

  final MoneySummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final language = ref.watch(preferencesProvider).language;
    final txs = ref.watch(transactionsProvider).value ?? const <Transaction>[];
    final byClient = <String, double>{};
    for (final t in txs.where((t) => t.direction == TransactionDirection.inn)) {
      final client = t.merchantName ?? t.category;
      byClient[client] = (byClient[client] ?? 0) + t.amount;
    }
    final sorted = byClient.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = sorted.fold<double>(0, (a, e) => a + e.value);
    final top = sorted.take(3).toList();

    return _InsightCard(
      icon: Icons.people_outline,
      title: s.clientConcentration,
      rows: [
        for (final e in top)
          _InsightRow(
            label: e.key,
            value: total <= 0 ? '—' : '${((e.value / total) * 100).round()}%',
            color: context.fvPrimary,
          ),
        if (top.isEmpty)
          _InsightRow(
            label: s.noSpendingYet,
            value: '',
            color: context.fvTextSecondary,
          ),
      ],
      tip: s.coachFreelancerInvoices(
        '30',
        FvFormat.formatMoney(summary.monthIncome, language: language),
      ),
      onTap: () => openInvoices(context),
    );
  }
}

/// Freelancer: days sales outstanding card.
class _FreelancerDsoInsightCard extends ConsumerWidget {
  const _FreelancerDsoInsightCard({required this.summary});

  final MoneySummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final language = ref.watch(preferencesProvider).language;
    final dso = _computeDso(ref);

    return _InsightCard(
      icon: Icons.schedule_outlined,
      title: s.dso,
      rows: [
        _InsightRow(
          label: s.dso,
          value: dso.toStringAsFixed(0),
          color: dso <= 30
              ? context.fvSuccess
              : (dso <= 45 ? context.fvWarning : context.fvError),
        ),
        _InsightRow(
          label: s.unpaidInvoices,
          value: '${summary.unpaidInvoiceCount}',
          color: context.fvPrimary,
        ),
      ],
      tip: s.coachFreelancerInvoices(
        dso.toStringAsFixed(0),
        FvFormat.formatMoney(summary.monthIncome, language: language),
      ),
      onTap: () => openInvoices(context),
    );
  }

  double _computeDso(WidgetRef ref) {
    final invoices = ref.watch(invoicesProvider).value ?? const <Invoice>[];
    final paid = invoices.where((i) => i.status == InvoiceStatus.paid).toList();
    if (paid.isEmpty) return 30;
    final now = DateTime.now();
    final totalDays = paid.fold<int>(
      0,
      (a, i) => a + now.difference(i.dueDate).inDays.clamp(0, 365),
    );
    return totalDays / paid.length;
  }
}

/// Individual: savings snapshot card.
class _IndividualSavingsInsightCard extends StatelessWidget {
  const _IndividualSavingsInsightCard({required this.summary});

  final MoneySummary summary;

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final language =
        Localizations.localeOf(context).languageCode.startsWith('fr')
        ? 'fr'
        : 'en';
    return _InsightCard(
      icon: Icons.savings_outlined,
      title: s.savingsSection,
      rows: [
        _InsightRow(
          label: s.savedInGoalsLabel,
          value: FvFormat.formatMoney(summary.savedInGoals, language: language),
          color: context.fvSuccess,
        ),
        _InsightRow(
          label: s.rainyDayFund,
          value: FvFormat.formatMoney(
            summary.monthIncome - summary.monthExpense,
            language: language,
          ),
          color: context.fvPrimary,
        ),
      ],
      tip: s.coachSave(
        summary.topExpenseCategory ?? s.noSpendingYet,
        FvFormat.formatMoney(summary.monthExpense, language: language),
        s.yourTopGoal,
        FvFormat.formatMoney(summary.monthIncome, language: language),
        FvFormat.formatMoney(
          summary.monthIncome - summary.monthExpense,
          language: language,
        ),
      ),
      onTap: () => openGoals(context),
    );
  }
}

/// Shared layout for a single insight card (title, metric rows, coach tip).
class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.title,
    required this.rows,
    required this.tip,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final List<_InsightRow> rows;
  final String tip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FvCard(
      margin: const EdgeInsets.only(bottom: FvSpacing.x4),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(FvSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: FvColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(FvRadius.iconContainer),
                  ),
                  child: Icon(icon, size: 18, color: context.fvPrimary),
                ),
                const SizedBox(width: FvSpacing.x3),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.fvText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FvSpacing.x3),
            for (final row in rows) ...[
              row,
              const SizedBox(height: FvSpacing.x2),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(FvSpacing.x3),
              decoration: BoxDecoration(
                color: context.fvWash,
                borderRadius: BorderRadius.circular(FvRadius.button),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.tips_and_updates_outlined,
                    size: 16,
                    color: context.fvPrimary,
                  ),
                  const SizedBox(width: FvSpacing.x2),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: context.fvTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: context.fvText),
          ),
        ),
        const SizedBox(width: FvSpacing.x2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color == context.fvTextSecondary
                ? context.fvTextSecondary
                : color,
          ),
        ),
      ],
    );
  }
}
