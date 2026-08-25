import 'package:flutter/material.dart';
import '../../core/format.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/state/money.dart';
import '../../core/state/preferences.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import '../home_shell.dart';

class VaultTab extends ConsumerWidget {
  const VaultTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final summary = ref.watch(moneySummaryProvider);

    return ListView(
      padding: const EdgeInsets.all(FvSpacing.x5),
      children: [
        FvCard(
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total saved', style: TextStyle(fontSize: 13, color: context.fvTextSecondary)),
              const SizedBox(height: 4),
              MoneyText(summary.savedInGoals, size: MoneySize.lg, currency: 'MUR'),
              const SizedBox(height: FvSpacing.x4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FvButton(
                    label: 'Create Goal',
                    onPressed: () => openNewGoal(context),
                    expanded: true,
                  ),
                  const SizedBox(height: FvSpacing.x3),
                  FvButton(
                    label: 'Start Pension',
                    variant: FvButtonVariant.secondary,
                    onPressed: () => openPension(context),
                    expanded: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (goals.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (goals.hasError)
          const EmptyState(title: 'Could not load goals', body: 'Please try again in a moment.')
        else if ((goals.value ?? []).isEmpty)
          const EmptyState(
            title: 'No goals yet',
            body: 'Create a goal to start building your rainy-day fund or retirement pot.',
            ctaLabel: 'Create a goal',
          )
        else ...[
          for (final g in (goals.value!).take(4)) _GoalRow(goal: g),
        ],
        if ((goals.value ?? []).length > 4)
          Center(
            child: TextButton(
              onPressed: () => openGoals(context),
              child: const Text('All goals', style: TextStyle(color: FvColors.primary, fontWeight: FontWeight.w600)),
            ),
          ),
      ],
    );
  }
}

class _GoalRow extends ConsumerWidget {
  const _GoalRow({required this.goal});

  final SavingsGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(preferencesProvider).language;
    final pct = goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;

    return FvCard(
      onTap: () => openGoals(context),
      margin: const EdgeInsets.only(bottom: FvSpacing.x3),
      child: Row(
        children: [
          ProgressRing(progress: pct, size: 48, stroke: 5),
          const SizedBox(width: FvSpacing.x4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.fvText)),
                const SizedBox(height: 2),
                Text(
                  goal.completed
                      ? 'Completed'
                      : '${FvFormat.formatMoney(goal.currentAmount, language: language)} of ${FvFormat.formatMoney(goal.targetAmount, language: language)}',
                  style: TextStyle(fontSize: 12.5, color: context.fvTextSecondary),
                ),
              ],
            ),
          ),
          if (goal.completed) const StatusBadge(label: 'Done', foreground: FvColors.success, background: FvColors.successBg),
        ],
      ),
    );
  }
}


