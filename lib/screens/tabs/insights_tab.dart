import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/csv_export.dart';
import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/state/money.dart';
import '../../core/state/preferences.dart';
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
                    Text('Your money coach', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.fvText)),
                    const SizedBox(height: 2),
                    Text('Guidance tailored to your vault', style: TextStyle(fontSize: 13, color: context.fvTextSecondary)),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: txs.isEmpty ? null : () => _exportCsv(context, txs),
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text('Export CSV'),
              ),
            ],
          ),
        ),
        const SectionHeader(title: 'This month'),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: Row(
            children: [
              Expanded(
                child: _Stat(label: 'Income', value: FvFormat.formatMoney(income, language: language), color: FvColors.success),
              ),
              Expanded(
                child: _Stat(label: 'Expenses', value: FvFormat.formatMoney(expense, language: language), color: FvColors.error),
              ),
              Expanded(
                child: _Stat(
                  label: 'Net',
                  value: FvFormat.formatMoney(income - expense, language: language),
                  color: (income - expense) >= 0 ? FvColors.success : FvColors.error,
                ),
              ),
            ],
          ),
        ),
        const SectionHeader(title: 'Spending by category'),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: cats.isEmpty
              ? Text('Not enough data yet.', style: TextStyle(fontSize: 13, color: context.fvTextSecondary))
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
        const SectionHeader(title: 'Daily briefing'),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Top category this month', style: TextStyle(fontSize: 12, color: context.fvTextSecondary)),
              const SizedBox(height: 4),
              Text(summary.topExpenseCategory ?? 'No spending yet',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.fvText)),
              const SizedBox(height: 4),
              Text('You spent ${FvFormat.formatMoney(summary.monthExpense, language: language)} so far this month.',
                  style: TextStyle(fontSize: 13, color: context.fvTextSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _exportCsv(BuildContext context, List<Transaction> txs) async {
    final List<List<String>> rows = [
      ['Date', 'Type', 'Amount', 'Category', 'Merchant'],
      for (final t in txs)
        [
          t.date.toIso8601String(),
          t.direction == TransactionDirection.inn ? 'income' : 'expense',
          (t.direction == TransactionDirection.inn ? t.amount : -t.amount).toStringAsFixed(2),
          t.category,
          t.merchantName ?? '',
        ],
    ];
    final csv = rows.map((r) => r.map((c) => '"${c.replaceAll('"', '""')}"').join(',')).join('\n');
    await downloadCsv('finovault-transactions.csv', csv);
    if (!kIsWeb && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV copied to clipboard')));
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
