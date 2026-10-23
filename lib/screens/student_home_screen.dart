import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models.dart';
import '../core/state/auth.dart';
import '../core/state/student_vault.dart';
import '../theme/tokens.dart';
import '../widgets/student_vault/vault_fuel_gauge.dart';
import '../widgets/student_vault/quick_log_pad.dart';
import '../widgets/student_vault/merchant_spots_bar.dart';
import '../widgets/student_vault/feed_item_card.dart';
import '../widgets/student_vault/period_wrap_modal.dart';
import '../widgets/vault_mark.dart';

/// The new primary screen of Finovault — the simple, fun, tactile financial logging
/// companion for students and daily users.
class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  void _openQuickLog(BuildContext context, WidgetRef ref, StudentVaultState state) {
    HapticFeedback.mediumImpact();
    QuickLogPad.show(
      context,
      currency: state.currency,
      merchants: state.merchants,
      onSave: ({
        required String description,
        required String merchantName,
        required double amount,
        required String category,
      }) async {
        await ref.read(studentVaultProvider.notifier).logExpense(
          description: description,
          merchantName: merchantName,
          amount: amount,
          category: category,
        );
      },
    );
  }

  void _openPeriodReset(BuildContext context, WidgetRef ref, StudentVaultState state) {
    HapticFeedback.mediumImpact();
    PeriodWrapModal.show(
      context,
      state: state,
      onConfirmReset: ({
        required String newPeriodName,
        required double newBudgetAmount,
        int durationDays = 30,
      }) async {
        await ref.read(studentVaultProvider.notifier).resetPeriod(
          newPeriodName: newPeriodName,
          newBudgetAmount: newBudgetAmount,
          durationDays: durationDays,
        );
      },
    );
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studentVaultProvider);
    final user = ref.watch(currentUserProvider);
    final userName = user?.fullName.split(' ').first ?? 'Student';
    final transactions = state.visibleTransactions;

    return Scaffold(
      backgroundColor: FvColors.bg,
      appBar: AppBar(
        backgroundColor: FvColors.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 16,
        title: Row(
          children: [
            const VaultMark(size: 28),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FINOVAULT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: FvColors.ink,
                  ),
                ),
                Text(
                  'Hey $userName 👋',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: FvColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Archive / Past Wraps Button
          IconButton(
            tooltip: 'Vault Archive',
            icon: const Icon(Icons.history_rounded, color: FvColors.ink, size: 24),
            onPressed: () => _showVaultHistory(context, state),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Hero Visual Gauge
            SliverToBoxAdapter(
              child: VaultFuelGauge(
                state: state,
                onResetTap: () => _openPeriodReset(context, ref, state),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Student Hangout Spots (Timo, Cascavelle, etc.)
            SliverToBoxAdapter(
              child: MerchantSpotsBar(
                merchants: state.topSpots,
                selectedFilter: state.filterMerchant,
                onSelectSpot: (merchant) {
                  ref.read(studentVaultProvider.notifier).setMerchantFilter(merchant);
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 18)),

            // Activity Feed Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.filterMerchant != null
                          ? 'PURCHASES AT ${state.filterMerchant!.toUpperCase()}'
                          : 'RECENT PURCHASES',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: FvColors.ink,
                      ),
                    ),
                    Text(
                      '${transactions.length} entries',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: FvColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Transactions Feed List
            if (transactions.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: FvColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: FvColors.ink, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.receipt_long_outlined, size: 40, color: FvColors.textSecondary),
                      const SizedBox(height: 10),
                      Text(
                        state.filterMerchant != null
                            ? 'No entries for ${state.filterMerchant} yet'
                            : 'No expenses logged this period!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: FvColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap the button below to log your first coffee, lunch, or transport.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: FvColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tx = transactions[index];
                    return FeedItemCard(
                      transaction: tx,
                      onDelete: () {
                        ref.read(studentVaultProvider.notifier).deleteExpense(tx.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Removed ${tx.description}'),
                            backgroundColor: FvColors.ink,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    );
                  },
                  childCount: transactions.length,
                ),
              ),

            // Bottom padding for FAB
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),

      // Large Tactile Bottom Bar / Action
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _openQuickLog(context, ref, state),
            style: ElevatedButton.styleFrom(
              backgroundColor: FvColors.ink,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: FvColors.ink, width: 2),
              ),
              shadowColor: Colors.black26,
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 20, color: Color(0xFFFBBF24)),
                  SizedBox(width: 8),
                  Text(
                    'LOG EXPENSE',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
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
                    'VAULT ARCHIVE & WRAPS',
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
                        'No archived periods yet.\nWhen you reset your allowance, your wraps appear here!',
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
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF78350F)),
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
