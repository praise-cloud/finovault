import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/state/student_vault.dart';
import '../../theme/tokens.dart';
import '../../widgets/student_vault/feed_item_card.dart';
import '../../widgets/student_vault/edit_expense_modal.dart';

/// The dedicated History section for students and daily users.
/// Students can search all their past logged items, filter by merchant or category,
/// see total spent for the filter, swipe to delete, and view archived period wraps.
class StudentHistoryTab extends ConsumerStatefulWidget {
  const StudentHistoryTab({super.key});

  @override
  ConsumerState<StudentHistoryTab> createState() => _StudentHistoryTabState();
}

class _StudentHistoryTabState extends ConsumerState<StudentHistoryTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showVaultHistory(BuildContext context, StudentVaultState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ArchivedPeriodsSheet(
        archivedPeriods: state.archivedPeriods,
        currency: state.currency,
      ),
    );
  }

  void _openEditExpense(Transaction tx, String currency) {
    HapticFeedback.lightImpact();
    EditExpenseModal.show(
      context,
      transaction: tx,
      currency: currency,
      onSave: ({
        required String id,
        String? description,
        String? merchantName,
        double? amount,
        String? category,
        DateTime? date,
      }) async {
        await ref.read(studentVaultProvider.notifier).updateExpense(
          id: id,
          description: description,
          merchantName: merchantName,
          amount: amount,
          category: category,
          date: date,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Updated "${description ?? tx.description}"'),
              backgroundColor: FvColors.ink,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      onDelete: (id) async {
        await ref.read(studentVaultProvider.notifier).deleteExpense(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Removed ${tx.description}'),
              backgroundColor: FvColors.ink,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentVaultProvider);
    final currency = state.currency;
    final allTxs = state.transactions;

    // Filter by query and category
    final query = _searchCtrl.text.trim().toLowerCase();
    final filtered = allTxs.where((t) {
      final matchesQuery = query.isEmpty ||
          (t.description?.toLowerCase().contains(query) ?? false) ||
          (t.merchantName?.toLowerCase().contains(query) ?? false) ||
          t.category.toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == null ||
          t.category.toLowerCase() == _selectedCategory!.toLowerCase();

      return matchesQuery && matchesCategory;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final totalFilteredSpent = filtered
        .where((t) => t.isExpense)
        .fold(0.0, (acc, t) => acc + t.amount);

    final categories = allTxs.map((t) => t.category).toSet().toList();

    return Scaffold(
      backgroundColor: FvColors.bg,
      appBar: AppBar(
        backgroundColor: FvColors.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'LOG HISTORY',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: FvColors.ink,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Past Period Wraps',
            icon: const Icon(Icons.history_rounded, color: FvColors.ink, size: 24),
            onPressed: () => _showVaultHistory(context, state),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search purchase, Timo, Cascavelle...',
                hintStyle: const TextStyle(fontSize: 13, color: FvColors.textSecondary),
                prefixIcon: const Icon(Icons.search_rounded, color: FvColors.ink, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
                isDense: true,
                filled: true,
                fillColor: FvColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: FvColors.ink, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: FvColors.ink, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: FvColors.primary, width: 2),
                ),
              ),
            ),
          ),

          // Category Chips
          if (categories.isNotEmpty)
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterPill(
                    label: 'All',
                    selected: _selectedCategory == null,
                    onTap: () => setState(() => _selectedCategory = null),
                  ),
                  ...categories.map((cat) => _FilterPill(
                        label: cat,
                        selected: _selectedCategory == cat,
                        onTap: () => setState(() {
                          _selectedCategory = _selectedCategory == cat ? null : cat;
                        }),
                      )),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Total Filtered Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: FvColors.wash,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: FvColors.border, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${filtered.length} PURCHASES FOUND',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: FvColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total: $currency ${totalFilteredSpent.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: FvColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // List of Filtered Items
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 44, color: FvColors.textSecondary),
                        const SizedBox(height: 10),
                        const Text(
                          'No purchases found',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _searchCtrl.text.isNotEmpty || _selectedCategory != null
                              ? 'Try adjusting your search query or filter.'
                              : 'Log your first expense from the Home tab!',
                          style: const TextStyle(fontSize: 12, color: FvColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tx = filtered[index];
                      return FeedItemCard(
                        transaction: tx,
                        onTap: () => _openEditExpense(tx, currency),
                        onDelete: () {
                          ref.read(studentVaultProvider.notifier).deleteExpense(tx.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Removed ${tx.description}'),
                              backgroundColor: FvColors.ink,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? FvColors.ink : FvColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? FvColors.ink : FvColors.border,
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : FvColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArchivedPeriodsSheet extends StatelessWidget {
  const _ArchivedPeriodsSheet({
    required this.archivedPeriods,
    required this.currency,
  });

  final List<StudentPeriod> archivedPeriods;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: FvColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: FvColors.ink, width: 2.5),
          left: BorderSide(color: FvColors.ink, width: 2.5),
          right: BorderSide(color: FvColors.ink, width: 2.5),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: FvColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PAST ALLOWANCE WRAPS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: FvColors.ink,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: FvColors.ink),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: archivedPeriods.isEmpty
                  ? const Center(
                      child: Text(
                        'No archived periods yet.\nWhen you reset your period from Home, your past wraps appear here!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: FvColors.textSecondary, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: archivedPeriods.length,
                      itemBuilder: (context, index) {
                        final p = archivedPeriods[index];
                        final wrap = p.wrapSummary;
                        final spent = (wrap?['totalSpent'] as num?)?.toDouble() ?? 0.0;
                        final saved = (wrap?['savedAmount'] as num?)?.toDouble() ?? 0.0;
                        final topSpot = (wrap?['topSpot'] as String?) ?? 'Various';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: FvColors.ink, width: 1.5),
                            boxShadow: const [
                              BoxShadow(color: FvColors.ink, offset: Offset(2, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    p.name.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                  Text(
                                    '${p.startDate.day}/${p.startDate.month} - ${p.endDate.day}/${p.endDate.month}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: FvColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Spent: $currency ${spent.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    'Saved: $currency ${saved.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: Color(0xFF047857),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Top spot: $topSpot',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF78350F),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
