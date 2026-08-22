import 'package:flutter/material.dart';
import '../../core/format.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/money.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import '../home_shell.dart';

class PayTab extends ConsumerWidget {
  const PayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(billPaymentsProvider);
    final recent = (payments.value ?? []).take(3).toList();

    return ListView(
      padding: const EdgeInsets.all(FvSpacing.x5),
      children: [
        FvCard(
          onTap: () => openTransfer(context),
          margin: const EdgeInsets.only(bottom: FvSpacing.x3),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: FvColors.wash, borderRadius: BorderRadius.circular(FvRadius.iconContainer)),
                child: const Icon(Icons.send_outlined, size: 20, color: FvColors.primary),
              ),
              const SizedBox(width: FvSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Transfer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.fvText)),
                    const SizedBox(height: 2),
                    Text('Send to a payee or account', style: TextStyle(fontSize: 13, color: context.fvTextSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
        FvCard(
          onTap: () => openBills(context),
          margin: const EdgeInsets.only(bottom: FvSpacing.x4),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: FvColors.wash, borderRadius: BorderRadius.circular(FvRadius.iconContainer)),
                child: const Icon(Icons.receipt_long_outlined, size: 20, color: FvColors.primary),
              ),
              const SizedBox(width: FvSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pay a bill', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.fvText)),
                    const SizedBox(height: 2),
                    Text('Electricity, water, airtime and more', style: TextStyle(fontSize: 13, color: context.fvTextSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
        const SectionHeader(title: 'Recent payments'),
        if (payments.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (recent.isEmpty)
          const EmptyState(title: 'No payments yet', body: 'Transfers and bill payments will show up here.')
        else
          for (final p in recent)
            FvCard(
              margin: const EdgeInsets.only(bottom: FvSpacing.x3),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.fvSurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.fvCardBorder),
                    ),
                    child: const Icon(Icons.check_circle_outline, size: 18, color: FvColors.success),
                  ),
                  const SizedBox(width: FvSpacing.x3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.billerName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
                        const SizedBox(height: 2),
                        Text(FvFormat.formatDate(p.date), style: TextStyle(fontSize: 12.5, color: context.fvTextSecondary)),
                      ],
                    ),
                  ),
                  MoneyText(p.amount, size: MoneySize.sm, currency: 'MUR'),
                ],
              ),
            ),
      ],
    );
  }
}


