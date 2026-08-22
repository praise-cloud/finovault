import 'package:flutter/material.dart';
import '../../core/format.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/money.dart';
import '../../core/state/preferences.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';


class InsightsTab extends ConsumerWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(moneySummaryProvider);
    final language = ref.watch(preferencesProvider).language;

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
            ],
          ),
        ),
        const SectionHeader(title: 'Daily briefing'),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nothing new today',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
              const SizedBox(height: 4),
              Text('Your daily briefing will appear here once your accounts are active.',
                  style: TextStyle(fontSize: 13, color: context.fvTextSecondary, height: 1.5)),
            ],
          ),
        ),
        const SectionHeader(title: 'Spending pattern'),
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: summary.topExpenseCategory == null
              ? Text('Not enough data yet.', style: TextStyle(fontSize: 13, color: context.fvTextSecondary))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Top category this month',
                        style: TextStyle(fontSize: 12, color: context.fvTextSecondary)),
                    const SizedBox(height: 4),
                    Text(summary.topExpenseCategory!,
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
}


