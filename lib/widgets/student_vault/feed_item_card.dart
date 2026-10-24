import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models.dart';
import '../../theme/tokens.dart';

/// Clean, high-contrast brutalist bank feed item.
/// Supports swipe-to-delete with tactile feedback.
class FeedItemCard extends StatelessWidget {
  const FeedItemCard({
    super.key,
    required this.transaction,
    required this.onDelete,
    this.onTap,
  });

  final Transaction transaction;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDate = DateTime(dt.year, dt.month, dt.day);

    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$min';

    if (txDate == today) {
      return 'Today, $timeStr';
    } else if (txDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, $timeStr';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}, $timeStr';
    }
  }

  String _merchantEmoji(String? merchant, String category) {
    final m = (merchant ?? '').toLowerCase();
    if (m.contains('timo')) return '🍔';
    if (m.contains('cascavelle')) return '🛍️';
    if (m.contains('metro')) return '🚌';
    if (m.contains('campus') || m.contains('tuck')) return '🥪';
    if (m.contains('winners')) return '🛒';
    if (m.contains('coffee')) return '☕';

    final c = category.toLowerCase();
    if (c.contains('food')) return '🍕';
    if (c.contains('transport')) return '🚕';
    if (c.contains('shop')) return '🛍️';
    if (c.contains('study') || c.contains('snack')) return '📚';
    return '💳';
  }

  @override
  Widget build(BuildContext context) {
    final merchant = transaction.merchantName ?? 'Unknown';
    final desc = transaction.description;
    final amount = transaction.amount;
    final currency = transaction.currency;
    final emoji = _merchantEmoji(merchant, transaction.category);

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        onDelete();
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FvColors.ink, width: 2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
            SizedBox(width: 6),
            Text(
              'DELETE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: FvColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FvColors.ink, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: FvColors.ink,
              offset: Offset(2.5, 2.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap != null
                ? () {
                    HapticFeedback.lightImpact();
                    onTap!();
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Emoji Avatar
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: FvColors.ink, width: 1.2),
                    ),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Description, Spot, and Time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (desc != null && desc.isNotEmpty) ? desc : merchant,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: FvColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: FvColors.ink.withValues(alpha: 0.2), width: 1),
                                ),
                                child: Text(
                                  merchant,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: FvColors.ink,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _formatDate(transaction.date),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                  ),

                  // Price Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '- $currency ${amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: FvColors.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        transaction.category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: FvColors.textSecondary,
                        ),
                      ),
                    ],
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
