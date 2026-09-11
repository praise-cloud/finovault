import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/models.dart';
import '../theme/tokens.dart';
import 'ui.dart';

/// Compact metric used across dashboards (income, spend, runway, etc.).
class FvStatCard extends StatelessWidget {
  const FvStatCard({
    super.key,
    required this.label,
    required this.value,
    this.sub,
    this.valueColor,
  });

  final String label;
  final String value;
  final String? sub;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(width: 18, height: 3, color: FvColors.primary),
      const SizedBox(height: 6),
      Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: context.fvTextSecondary,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: valueColor ?? context.fvText,
        ),
      ),
      if (sub != null) ...[
        const SizedBox(height: 2),
        Text(
          sub!.toUpperCase(),
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: context.fvTextSecondary,
          ),
        ),
      ],
    ],
  );
}

/// Colour-coded pill for a spending/income category.
class FvCategoryChip extends StatelessWidget {
  const FvCategoryChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(FvRadius.badge),
      border: Border.all(color: context.fvCardBorder, width: 1.5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
            color: color,
          ),
        ),
      ],
    ),
  );
}

/// Bank / mobile-money account row with a tinted icon and live balance.
class FvAccountTile extends StatelessWidget {
  const FvAccountTile({
    super.key,
    required this.account,
    this.onTap,
    this.accent,
    this.trailing,
  });

  final Account account;
  final VoidCallback? onTap;
  final Color? accent;
  final Widget? trailing;

  IconData _icon(AccountType t) => switch (t) {
    AccountType.bank => Icons.account_balance_outlined,
    AccountType.mobileMoney => Icons.smartphone_outlined,
    AccountType.cash => Icons.wallet_outlined,
    _ => Icons.account_balance_wallet_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final a = accent ?? context.fvPrimary;
    return FvCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: a.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(FvRadius.iconContainer),
            ),
            child: Icon(_icon(account.type), size: 20, color: a),
          ),
          const SizedBox(width: FvSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.fvText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  account.institution ?? account.type.name,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: context.fvTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          MoneyText(account.balance, size: MoneySize.md, currency: 'MUR'),
          if (trailing != null) ...[
            const SizedBox(width: FvSpacing.x2),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// One payment-history row: directional icon, merchant, category, signed amount.
class FvTransactionRow extends StatelessWidget {
  const FvTransactionRow({super.key, required this.txn});

  final Transaction txn;

  @override
  Widget build(BuildContext context) {
    final color = FvColors.categoryColor(txn.category);
    final incoming = txn.direction == TransactionDirection.inn;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FvSpacing.x2),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              incoming ? Icons.arrow_downward : Icons.arrow_upward,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: FvSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.merchantName ?? txn.category,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.fvText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  txn.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.fvTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          MoneyText(
            txn.amount,
            size: MoneySize.sm,
            signed: true,
            color: incoming ? context.fvSuccess : context.fvTextSecondary,
          ),
        ],
      ),
    );
  }
}

/// Loading placeholder block (shimmer) for lists and cards.
class FvShimmer extends StatelessWidget {
  const FvShimmer({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 12,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) =>
      Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: context.fvBorder,
              borderRadius: BorderRadius.circular(radius),
            ),
          )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            duration: 1100.ms,
            color: Colors.white.withValues(alpha: 0.55),
          );
}

/// Tappable call-to-action card used for module shortcuts.
class FvActionCard extends StatelessWidget {
  const FvActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.accent,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final a = accent ?? context.fvPrimary;
    return FvCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: a.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(FvRadius.iconContainer),
            ),
            child: Icon(icon, size: 20, color: a),
          ),
          const SizedBox(width: FvSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.fvText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: context.fvTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 18, color: context.fvPrimary),
        ],
      ),
    );
  }
}
