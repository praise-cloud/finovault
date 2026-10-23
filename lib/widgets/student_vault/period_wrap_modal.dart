import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/state/student_vault.dart';
import '../../theme/tokens.dart';

/// Fun end-of-period reset and celebration modal (Spotify Wrapped style).
/// Displays a congratulatory summary card of the past period before archiving
/// and starting a fresh budget.
class PeriodWrapModal extends StatefulWidget {
  const PeriodWrapModal({
    super.key,
    required this.state,
    required this.onConfirmReset,
  });

  final StudentVaultState state;
  final Future<void> Function({
    required String newPeriodName,
    required double newBudgetAmount,
    int durationDays,
  }) onConfirmReset;

  static Future<void> show(
    BuildContext context, {
    required StudentVaultState state,
    required Future<void> Function({
      required String newPeriodName,
      required double newBudgetAmount,
      int durationDays,
    }) onConfirmReset,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PeriodWrapModal(
        state: state,
        onConfirmReset: onConfirmReset,
      ),
    );
  }

  @override
  State<PeriodWrapModal> createState() => _PeriodWrapModalState();
}

class _PeriodWrapModalState extends State<PeriodWrapModal> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _budgetCtrl;
  int _durationDays = 30;
  bool _resetting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final nextMonthName = _monthName(now.month);
    _nameCtrl = TextEditingController(text: '$nextMonthName Allowance');
    _budgetCtrl = TextEditingController(
      text: widget.state.activePeriod.budgetAmount.toInt().toString(),
    );
  }

  static String _monthName(int month) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return m[(month - 1) % 12];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final budget = double.tryParse(_budgetCtrl.text) ?? 5000.0;
    final name = _nameCtrl.text.trim().isEmpty ? 'New Allowance' : _nameCtrl.text.trim();

    setState(() => _resetting = true);
    HapticFeedback.heavyImpact();

    await widget.onConfirmReset(
      newPeriodName: name,
      newBudgetAmount: budget,
      durationDays: _durationDays,
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Period archived! Fresh allowance is ready.'),
          backgroundColor: FvColors.ink,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final currency = state.currency;
    final spent = state.totalSpent;
    final budget = state.activePeriod.budgetAmount;
    final saved = (budget - spent).clamp(0.0, budget);
    final topSpot = state.topSpots.isNotEmpty ? state.topSpots.first : null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag indicator
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

              // Title Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PERIOD RESET & WRAP',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: FvColors.textSecondary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: FvColors.ink),
                      onPressed: () => Navigator.of(context).pop(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),

              // The Celebratory "Period Wrap" Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7), // Warm golden parchment
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: FvColors.ink, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: FvColors.ink,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${state.activePeriod.name.toUpperCase()} WRAPPED 🎉',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: Color(0xFF92400E),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: FvColors.ink, width: 1),
                          ),
                          child: Text(
                            '${state.transactions.length} Purchases',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: FvColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL SPENT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF78350F),
                                ),
                              ),
                              Text(
                                '$currency ${spent.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: FvColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'UNSPENT / SAVED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF78350F),
                                ),
                              ),
                              Text(
                                '$currency ${saved.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: saved > 0 ? const Color(0xFF047857) : FvColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (topSpot != null && topSpot.totalSpent > 0) ...[
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFD97706), height: 1),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(topSpot.emoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Top Spot: ${topSpot.name}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: FvColors.ink,
                                  ),
                                ),
                                Text(
                                  'You spent $currency ${topSpot.totalSpent.toStringAsFixed(0)} across ${topSpot.visitCount} visits',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF78350F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Setup Fresh Period Form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'START FRESH PERIOD',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: FvColors.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Period Name (e.g. November Allowance)',
                        labelStyle: const TextStyle(fontSize: 13, color: FvColors.textSecondary),
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: FvColors.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _budgetCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Starting Allowance Budget ($currency)',
                        labelStyle: const TextStyle(fontSize: 13, color: FvColors.textSecondary),
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: FvColors.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _DurationChip(
                          label: '7 Days (Weekly)',
                          selected: _durationDays == 7,
                          onTap: () => setState(() => _durationDays = 7),
                        ),
                        const SizedBox(width: 8),
                        _DurationChip(
                          label: '30 Days (Monthly)',
                          selected: _durationDays == 30,
                          onTap: () => setState(() => _durationDays = 30),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: _resetting ? null : _handleReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FvColors.ink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: FvColors.ink, width: 2),
                    ),
                  ),
                  child: _resetting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.archive_outlined, size: 20, color: Color(0xFFFBBF24)),
                            SizedBox(width: 8),
                            Text(
                              'ARCHIVE & START FRESH 🚀',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? FvColors.ink : FvColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: FvColors.ink, width: 1.2),
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
    );
  }
}
