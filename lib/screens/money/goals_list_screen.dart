import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/format.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/state/money.dart';
import '../../core/state/preferences.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import '../home_shell.dart';


class GoalsListScreen extends ConsumerWidget {
  const GoalsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final language = ref.watch(preferencesProvider).language;

    return ScreenPage(
      title: AppLocalizations.of(context).goals,
      actions: [IconButton(icon: const Icon(Icons.add, color: FvColors.primary), onPressed: () => openNewGoal(context))],
      child: goals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (list) => list.isEmpty
            ? const Center(child: EmptyState(title: 'No goals yet', body: 'Create a goal to start building your future.'))
            : ListView.separated(
                padding: const EdgeInsets.all(FvSpacing.x5),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: FvSpacing.x3),
                itemBuilder: (_, i) {
                  final g = list[i];
                  final pct = g.targetAmount > 0 ? (g.currentAmount / g.targetAmount).clamp(0.0, 1.0) : 0.0;
                  return FvCard(
                    onTap: () => pushScreen(context, GoalDetailScreen(goalId: g.id)),
                    child: Row(
                      children: [
                        ProgressRing(progress: pct, size: 52, stroke: 5),
                        const SizedBox(width: FvSpacing.x4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.fvText)),
                              const SizedBox(height: 2),
                              Text(
                                g.completed
                                    ? 'Completed'
                                    : '${FvFormat.formatMoney(g.currentAmount, language: language)} of ${FvFormat.formatMoney(g.targetAmount, language: language)}',
                                style: TextStyle(fontSize: 12.5, color: context.fvTextSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (g.completed) const StatusBadge(label: 'Done', foreground: FvColors.success, background: FvColors.successBg),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final accounts = ref.watch(accountsProvider);
    final language = ref.watch(preferencesProvider).language;

    return ScreenPage(
      title: 'Goal',
      child: goals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Could not load goal.')),
        data: (list) {
          final goal = list.where((g) => g.id == goalId).firstOrNull;
          if (goal == null) return const Center(child: Text('Goal not found.'));
          final pct = goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;

          return ListView(
            padding: const EdgeInsets.all(FvSpacing.x5),
            children: [
              FvCard(
                margin: const EdgeInsets.only(bottom: FvSpacing.x4),
                child: Column(
                  children: [
                    ProgressRing(progress: pct, size: 88, stroke: 8),
                    const SizedBox(height: FvSpacing.x3),
                    Text(goal.name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: context.fvText)),
                    const SizedBox(height: 4),
                    Text(
                      goal.completed
                          ? 'Goal completed'
                          : '${FvFormat.formatMoney(goal.currentAmount, language: language)} of ${FvFormat.formatMoney(goal.targetAmount, language: language)}',
                      style: TextStyle(fontSize: 14, color: context.fvTextSecondary),
                    ),
                  ],
                ),
              ),
              if (!goal.completed)
                FvButton(
                  label: 'Contribute',
                  onPressed: () => _contribute(context, ref, goal, accounts.value),
                ),
              const SizedBox(height: FvSpacing.x4),
              const SectionHeader(title: 'Contributions'),
              if (goal.contributions.isEmpty)
                const EmptyState(title: 'No contributions yet', body: 'Your contributions will appear here.')
              else
                for (final c in goal.contributions)
                  FvCard(
                    margin: const EdgeInsets.only(bottom: FvSpacing.x3),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: FvColors.successBg, borderRadius: BorderRadius.circular(20)),
                          child: const Icon(Icons.add, size: 18, color: FvColors.success),
                        ),
                        const SizedBox(width: FvSpacing.x3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MoneyText(c.amount, size: MoneySize.md, currency: 'MUR', color: FvColors.success),
                              const SizedBox(height: 2),
                              Text(FvFormat.formatDate(c.date, language: language), style: TextStyle(fontSize: 12.5, color: context.fvTextSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  void _contribute(BuildContext context, WidgetRef ref, SavingsGoal goal, List<Account>? accounts) {
    if (accounts == null || accounts.isEmpty) return;
    String source = accounts.first.id;
    final amount = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FvColors.surface,
      builder: (sheet) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheet).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(FvSpacing.x5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: Text('Contribute', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
              const SizedBox(height: FvSpacing.x4),
              FvTextField(label: 'Amount', controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: FvSpacing.x4),
              DropdownButtonFormField<String>(
                initialValue: source,
                items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.name} (${FvFormat.formatMoney(a.balance)})'))).toList(),
                onChanged: (v) => source = v!,
                decoration: InputDecoration(
                  labelText: 'From account',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(FvRadius.input)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: FvSpacing.x4, vertical: FvSpacing.x3),
                ),
              ),
              const SizedBox(height: FvSpacing.x5),
              FvButton(
                label: 'Contribute',
                onPressed: () async {
                  final api = ref.read(apiProvider);
                  final token = ref.read(kvStoreProvider).getString(sessionKey);
                  final value = double.tryParse(amount.text.replaceAll(',', '')) ?? 0;
                  if (value <= 0) return;
                  await api.contribute(token, goalId: goal.id, amount: value, sourceAccountId: source);
                  ref.invalidate(goalsProvider);
                  ref.invalidate(accountsProvider);
                  if (sheet.mounted) Navigator.of(sheet).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}



