import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/csv_export.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/state/money.dart';
import '../../core/state/preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

const _palette = [
  Color(0xFF6C5CE7),
  Color(0xFF00B894),
  Color(0xFF0984E3),
  Color(0xFFFDCB6E),
  Color(0xFFE17055),
  Color(0xFFA29BFE),
  Color(0xFFFAB1A0),
  Color(0xFF55EFC4),
];

class InsightsTab extends ConsumerWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context)!;
    final summary = ref.watch(moneySummaryProvider);
    final language = ref.watch(preferencesProvider).language;
    final txs = ref.watch(transactionsProvider).value ?? const <Transaction>[];

    final now = DateTime.now();
    final monthTx = txs.where((t) => t.date.year == now.year && t.date.month == now.month).toList();
    final income = monthTx.where((t) => t.direction == TransactionDirection.inn).fold<double>(0, (s, t) => s + t.amount);
    final expense = monthTx.where((t) => t.direction == TransactionDirection.out).fold<double>(0, (s, t) => s + t.amount);

    final byCat = <String, double>{};
    for (final t in monthTx.where((t) => t.direction == TransactionDirection.out)) {
      byCat[t.category] = (byCat[t.category] ?? 0) + t.amount;
    }
    final cats = byCat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final totalCat = cats.fold<double>(0, (s, e) => s + e.value);

    return ListView(
      padding: const EdgeInsets.all(FvSpacing.x5),
      children: [
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: FvColors.wash, borderRadius: BorderRadius.circular(FvRadius.iconContainer)),
                child: const Icon(Icons.psychology_outlined, size: 20, color: FvColors.primary),
              ),
              const SizedBox(width: FvSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.moneyCoach, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.fvText)),
                    const SizedBox(height: 2),
                    Text(s.coachBlurb, style: TextStyle(fontSize: 13, color: context.fvTextSecondary)),
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
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: Row(
            children: [
              Expanded(
                child: _Stat(label: s.incomeLabel, value: FvFormat.formatMoney(income, language: language), color: FvColors.success),
              ),
              Expanded(
                child: _Stat(label: s.expensesLabel, value: FvFormat.formatMoney(expense, language: language), color: FvColors.error),
              ),
              Expanded(
                child: _Stat(
                  label: s.netLabel,
                  value: FvFormat.formatMoney(income - expense, language: language),
                  color: (income - expense) >= 0 ? FvColors.success : FvColors.error,
                ),
              ),
            ],
          ),
        ),
        SectionHeader(title: s.spendingByCategory),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: cats.isEmpty
              ? Text(s.notEnoughData, style: TextStyle(fontSize: 13, color: context.fvTextSecondary))
              : Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: cats.asMap().entries.map((e) {
                            final idx = e.key;
                            final entry = e.value;
                            final pct = totalCat <= 0 ? 0.0 : entry.value / totalCat;
                            return PieChartSectionData(
                              value: entry.value,
                              title: '${(pct * 100).round()}%',
                              color: _palette[idx % _palette.length],
                              radius: 70,
                              titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
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
                      final color = _palette[e.key % _palette.length];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                            const SizedBox(width: 8),
                            Expanded(child: Text(entry.key, style: TextStyle(fontSize: 13, color: context.fvText))),
                            Text(FvFormat.formatMoney(entry.value, language: language),
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.fvText)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
        ),
        SectionHeader(title: s.dailyBriefing),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.topCategoryThisMonth, style: TextStyle(fontSize: 12, color: context.fvTextSecondary)),
              const SizedBox(height: 4),
              Text(summary.topExpenseCategory ?? s.noSpendingYet,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.fvText)),
              const SizedBox(height: 4),
              Text(s.spentSoFar(FvFormat.formatMoney(summary.monthExpense, language: language)),
                  style: TextStyle(fontSize: 13, color: context.fvTextSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _exportCsv(BuildContext context, List<Transaction> txs) async {
    final s = AppLocalizations.of(context)!;
    final List<List<String>> rows = [
      [s.csvDate, s.csvType, s.csvAmount, s.csvCategory, s.csvMerchant],
      for (final t in txs)
        [
          t.date.toIso8601String(),
          t.direction == TransactionDirection.inn ? 'income' : 'expense',
          (t.direction == TransactionDirection.inn ? t.amount : -t.amount).toStringAsFixed(2),
          t.category,
          t.merchantName ?? '',
        ],
    ];
    final csv = rows.map((r) => r.map((c) => '"${(c ?? '').replaceAll('"', '""')}"').join(',')).join('\n');
    await downloadCsv('finovault-transactions.csv', csv);
    if (!kIsWeb && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.csvCopied)));
    }
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: context.fvTextSecondary)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ],
      );
}
