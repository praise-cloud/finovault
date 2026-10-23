import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/student_vault.dart';
import '../../theme/tokens.dart';

/// The dedicated Budget section for students and daily users.
/// Students can see their overall allowance limit and create specific category
/// budgets (Food, Transport, Chill, Shopping, etc.) that they want to follow.
class StudentBudgetTab extends ConsumerStatefulWidget {
  const StudentBudgetTab({super.key});

  @override
  ConsumerState<StudentBudgetTab> createState() => _StudentBudgetTabState();
}

class _StudentBudgetTabState extends ConsumerState<StudentBudgetTab> {
  void _openAddBudgetModal(BuildContext context, StudentVaultState state) {
    HapticFeedback.lightImpact();
    final catCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    String selectedEmoji = '🍔';

    final emojis = ['🍔', '🛍️', '🥪', '🚌', '🛒', '☕', '🎮', '📚', '🎬', '💳'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheet) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheet).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 16,
          ),
          decoration: const BoxDecoration(
            color: FvColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: FvColors.ink, width: 2.5),
              left: BorderSide(color: FvColors.ink, width: 2.5),
              right: BorderSide(color: FvColors.ink, width: 2.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: FvColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'CREATE A BUDGET TO FOLLOW',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: FvColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Set a target limit for categories you care about.',
                style: TextStyle(fontSize: 12, color: FvColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Emoji Selector
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: emojis.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final em = emojis[i];
                    final isSel = em == selectedEmoji;
                    return InkWell(
                      onTap: () => setModalState(() => selectedEmoji = em),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFFEF3C7) : FvColors.wash,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel ? FvColors.ink : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Text(em, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: catCtrl,
                decoration: InputDecoration(
                  labelText: 'Budget Category (e.g. Food, Weekend Chill, Books)',
                  labelStyle: const TextStyle(fontSize: 12, color: FvColors.textSecondary),
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: FvColors.ink, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: FvColors.ink, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: amtCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Target Limit (${state.currency})',
                  labelStyle: const TextStyle(fontSize: 12, color: FvColors.textSecondary),
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: FvColors.ink, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: FvColors.ink, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              ElevatedButton(
                onPressed: () async {
                  final cat = catCtrl.text.trim();
                  final amt = double.tryParse(amtCtrl.text) ?? 0.0;
                  if (cat.isEmpty || amt <= 0) return;

                  HapticFeedback.heavyImpact();
                  await ref.read(studentVaultProvider.notifier).setCategoryBudget(
                    category: cat,
                    amount: amt,
                    emoji: selectedEmoji,
                  );
                  if (sheet.mounted) Navigator.of(sheet).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: FvColors.ink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: FvColors.ink, width: 1.5),
                  ),
                ),
                child: const Text(
                  'SAVE BUDGET',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editAllowanceBudget(BuildContext context, StudentVaultState state) {
    final ctrl = TextEditingController(
      text: state.activePeriod.budgetAmount.toInt().toString(),
    );
    showDialog(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text(
          'UPDATE TOTAL ALLOWANCE',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Allowance Budget (${state.currency})',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(),
            child: const Text('Cancel', style: TextStyle(color: FvColors.ink)),
          ),
          ElevatedButton(
            onPressed: () {
              final newAmt = double.tryParse(ctrl.text) ?? 0.0;
              if (newAmt > 0) {
                ref.read(studentVaultProvider.notifier).updateBudget(newAmt);
              }
              Navigator.of(dialog).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FvColors.ink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentVaultProvider);
    final currency = state.currency;
    final totalBudget = state.activePeriod.budgetAmount;
    final totalSpent = state.totalSpent;
    final totalRemaining = state.remainingBudget;
    final overallRatio = state.spendRatio;
    final budgets = state.categoryBudgets;

    return Scaffold(
      backgroundColor: FvColors.bg,
      appBar: AppBar(
        backgroundColor: FvColors.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'BUDGETS TO FOLLOW',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: FvColors.ink,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Category Budget',
            icon: const Icon(Icons.add_circle_outline_rounded, color: FvColors.ink, size: 26),
            onPressed: () => _openAddBudgetModal(context, state),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Total Allowance Hero Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: FvColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: FvColors.ink, width: 2),
              boxShadow: const [
                BoxShadow(color: FvColors.ink, offset: Offset(3, 3), blurRadius: 0),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${state.activePeriod.name.toUpperCase()} TOTAL',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: FvColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _editAllowanceBudget(context, state),
                      borderRadius: BorderRadius.circular(6),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined, size: 14, color: FvColors.primary),
                          SizedBox(width: 4),
                          Text(
                            'Edit Allowance',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: FvColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$currency ${totalRemaining.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: FvColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Spent $currency ${totalSpent.toStringAsFixed(0)} of $currency ${totalBudget.toStringAsFixed(0)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: FvColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: state.mood == SpendMood.cruising
                            ? const Color(0xFFD1FAE5)
                            : state.mood == SpendMood.steady
                                ? const Color(0xFFFEF3C7)
                                : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: state.mood == SpendMood.cruising
                              ? const Color(0xFF10B981)
                              : state.mood == SpendMood.steady
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFFEF4444),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        state.moodLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: state.mood == SpendMood.cruising
                              ? const Color(0xFF047857)
                              : state.mood == SpendMood.steady
                                  ? const Color(0xFFB45309)
                                  : const Color(0xFFB91C1C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: overallRatio.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      overallRatio > 0.8
                          ? const Color(0xFFEF4444)
                          : overallRatio > 0.5
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Categories Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CATEGORY TARGETS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: FvColors.ink,
                ),
              ),
              Text(
                '${budgets.length} budgets',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: FvColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // List of Category Budgets
          if (budgets.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: FvColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: FvColors.ink, width: 1.5),
              ),
              child: const Column(
                children: [
                  Icon(Icons.pie_chart_outline, size: 36, color: FvColors.textSecondary),
                  SizedBox(height: 8),
                  Text(
                    'No category budgets set yet',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap the + button to add a budget for Food, Books, or Transport.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: FvColors.textSecondary),
                  ),
                ],
              ),
            )
          else
            ...budgets.map((b) {
              final spent = state.spentForCategory(b.category);
              final remaining = state.remainingForCategory(b);
              final progress = state.progressForCategory(b);
              final isOver = remaining < 0;

              return Dismissible(
                key: Key('budget_${b.category}'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  ref.read(studentVaultProvider.notifier).deleteCategoryBudget(b.category);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Deleted budget for ${b.category}'),
                      backgroundColor: FvColors.ink,
                    ),
                  );
                },
                background: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: FvColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: FvColors.ink, width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: FvColors.ink, offset: Offset(2, 2)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: FvColors.ink, width: 1),
                            ),
                            child: Text(b.emoji, style: const TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.category,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: FvColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isOver
                                      ? 'Over by $currency ${(spent - b.amount).toStringAsFixed(0)}'
                                      : '$currency ${remaining.toStringAsFixed(0)} left of $currency ${b.amount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isOver ? const Color(0xFFEF4444) : FvColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '$currency ${spent.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isOver ? const Color(0xFFEF4444) : FvColors.ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOver
                                ? const Color(0xFFEF4444)
                                : progress > 0.7
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
