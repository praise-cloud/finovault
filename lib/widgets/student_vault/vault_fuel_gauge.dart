import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/state/student_vault.dart';
import '../../theme/tokens.dart';

/// Tactile, modern bank gauge displaying the student's allowance "fuel".
/// Visual feedback changes dynamically between:
/// - Cruising 🟢 (< 50% spent)
/// - Steady 🟡 (50% - 80% spent)
/// - Ramen Mode 🍜 (> 80% spent)
class VaultFuelGauge extends StatelessWidget {
  const VaultFuelGauge({
    super.key,
    required this.state,
    required this.onResetTap,
    this.onBudgetTap,
  });

  final StudentVaultState state;
  final VoidCallback onResetTap;
  final VoidCallback? onBudgetTap;

  Color _moodColor(SpendMood mood) => switch (mood) {
    SpendMood.cruising => const Color(0xFF10B981), // Emerald green
    SpendMood.steady => const Color(0xFFF59E0B),   // Amber
    SpendMood.ramenMode => const Color(0xFFEF4444), // Crimson/Coral
  };

  Color _moodBg(SpendMood mood) => switch (mood) {
    SpendMood.cruising => const Color(0xFFD1FAE5),
    SpendMood.steady => const Color(0xFFFEF3C7),
    SpendMood.ramenMode => const Color(0xFFFEE2E2),
  };

  @override
  Widget build(BuildContext context) {
    final currency = state.currency;
    final remaining = state.remainingBudget;
    final totalBudget = state.activePeriod.budgetAmount;
    final spent = state.totalSpent;
    final ratio = state.spendRatio;
    final moodColor = _moodColor(state.mood);
    final moodBg = _moodBg(state.mood);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FvColors.surface,
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
          // Period Header & Reset action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.activePeriod.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: FvColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${state.activePeriod.daysRemaining} days left in period',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: FvColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onResetTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: FvColors.wash,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: FvColors.ink, width: 1.5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, size: 14, color: FvColors.ink),
                      SizedBox(width: 4),
                      Text(
                        'New Period',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: FvColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Main Hero Numbers + Dynamic Mood Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Radial Arc Tank
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(96, 96),
                      painter: _GaugeArcPainter(
                        progress: ratio,
                        progressColor: moodColor,
                        trackColor: const Color(0xFFE2E8F0),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${((1.0 - ratio) * 100).clamp(0, 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: FvColors.ink,
                          ),
                        ),
                        const Text(
                          'FUEL',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: FvColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 18),

              // Balances and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: moodBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: moodColor, width: 1.5),
                      ),
                      child: Text(
                        state.moodLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: moodColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$currency ${remaining.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: FvColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Spent $currency ${spent.toStringAsFixed(0)} of $currency ${totalBudget.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: FvColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),

          // Safe Daily Spend & Subtitle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 16, color: FvColors.primary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Safe pace: $currency ${state.dailySafeSpend.toStringAsFixed(0)} / day',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: FvColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  state.moodSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: FvColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugeArcPainter extends CustomPainter {
  _GaugeArcPainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
  });

  final double progress;
  final Color progressColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 9.0;
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Full 360 circle track
    canvas.drawCircle(center, radius, trackPaint);

    // Remaining fuel arc (starts at top -pi/2, sweeps clockwise based on remaining)
    final remainingRatio = (1.0 - progress).clamp(0.0, 1.0);
    final sweepAngle = 2 * math.pi * remainingRatio;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugeArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}
