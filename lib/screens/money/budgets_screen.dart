import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/state/money.dart';
import '../../core/state/preferences.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(budgetsProvider);
    final txs = ref.watch(transactionsProvider);
    final language = ref.watch(preferencesProvider).language;

    return ScreenPage(
      title: 'Budgets',
      actions: [IconButton(icon: const Icon(Icons.add, color: FvColors.primary), onPressed: _add)],
      child: budgets.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (list) {
          final now = DateTime.now();
          final monthTx = (txs.value ?? []).where((t) => t.date.year == now.year && t.date.month == now.month).toList();
          double spentFor(Budget b) => monthTx
              .where((t) => t.direction == TransactionDirection.out && t.category.toLowerCase() == b.category.toLowerCase())
              .fold(0.0, (s, t) => s + t.amount);

          return list.isEmpty
              ? const Center(child: EmptyState(title: 'No budgets yet', body: 'Set a monthly budget for a category to stay on track.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(FvSpacing.x5),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: FvSpacing.x3),
                  itemBuilder: (_, i) {
                    final b = list[i];
                    final spent = spentFor(b);
                    final progress = b.amount <= 0 ? 0.0 : (spent / b.amount).clamp(0.0, 1.0);
                    final over = spent > b.amount;
                    return FvCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(b.category, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.fvText))),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '${FvFormat.formatMoney(spent, language: language)} / ${FvFormat.formatMoney(b.amount, language: language)}',
                                  style: TextStyle(fontSize: 13, color: context.fvTextSecondary),
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: FvSpacing.x3),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                            backgroundColor: context.fvBorder,
                            color: over ? FvColors.error : FvColors.primary,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            over ? 'Over budget by ${FvFormat.formatMoney(spent - b.amount, language: language)}'
                                : '${FvFormat.formatMoney(b.amount - spent, language: language)} remaining',
                            style: TextStyle(fontSize: 12.5, color: over ? FvColors.error : context.fvTextSecondary),
                          ),
                        ],
                      ),
                    );
                  },
                );
        },
      ),
    );
  }

  void _add() {
    final category = TextEditingController();
    final amount = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.fvIsDark ? FvColors.bgDark : FvColors.surface,
      builder: (sheet) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheet).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(FvSpacing.x5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: Text('New budget', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
              const SizedBox(height: FvSpacing.x4),
              FvTextField(label: 'Category', controller: category, hint: 'Groceries'),
              const SizedBox(height: FvSpacing.x4),
              FvTextField(label: 'Monthly amount', controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: FvSpacing.x5),
              FvButton(
                label: 'Save budget',
                onPressed: () async {
                  final api = ref.read(apiProvider);
                  final token = ref.read(kvStoreProvider).getString(sessionKey);
                  final value = double.tryParse(amount.text.replaceAll(',', '')) ?? 0;
                  if (category.text.isEmpty || value <= 0) return;
                  await api.createBudget(token, category: category.text, amount: value);
                  ref.invalidate(budgetsProvider);
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
