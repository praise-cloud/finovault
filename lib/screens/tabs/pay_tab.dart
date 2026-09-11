import 'package:flutter/material.dart';

import '../../core/format.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/state/money.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import '../home_shell.dart';

/// Pay Hub (docs 6.1): fast access to money movement — transfer/pay-bill
/// CTAs, recent payees, scheduled/auto-pay bills, and a short history preview.
class PayTab extends ConsumerWidget {
  const PayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final payments = ref.watch(billPaymentsProvider);
    final payees = ref.watch(payeesProvider);

    final allPayments = (payments.value ?? const <BillPayment>[]);
    final recent = allPayments.take(3).toList();
    final scheduled = allPayments
        .where((p) => p.status == BillPaymentStatus.scheduled)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(FvSpacing.x5),
      children: [
        Row(
          children: [
            Expanded(
              child: FvCard(
                onTap: () => openTransfer(context),
                margin: const EdgeInsets.only(bottom: FvSpacing.x3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.fvWash,
                        borderRadius: BorderRadius.circular(
                          FvRadius.iconContainer,
                        ),
                      ),
                      child: Icon(
                        Icons.send_outlined,
                        size: 20,
                        color: context.fvPrimary,
                      ),
                    ),
                    const SizedBox(height: FvSpacing.x3),
                    Text(
                      s.transferLabel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.fvText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.sendToPayee,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.fvTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: FvSpacing.x3),
            Expanded(
              child: FvCard(
                onTap: () => openBills(context),
                margin: const EdgeInsets.only(bottom: FvSpacing.x3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.fvWash,
                        borderRadius: BorderRadius.circular(
                          FvRadius.iconContainer,
                        ),
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        size: 20,
                        color: context.fvPrimary,
                      ),
                    ),
                    const SizedBox(height: FvSpacing.x3),
                    Text(
                      s.payABill,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.fvText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.billBlurb,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.fvTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SectionHeader(title: s.payRecentPayees),
        if (payees.isLoading)
          const Center(child: CircularProgressIndicator())
        else if ((payees.value ?? []).isEmpty)
          Text(
            s.payNoPayeesBody,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: context.fvTextSecondary,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in (payees.value!))
                _PayeeChip(payee: p, onTap: () => openTransfer(context)),
            ],
          ),
        const SizedBox(height: FvSpacing.x4),
        SectionHeader(title: s.payScheduledBills),
        if (scheduled.isEmpty)
          Text(
            s.payNoScheduledBody,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: context.fvTextSecondary,
            ),
          )
        else
          for (final pb in scheduled)
            FvCard(
              onTap: () => openBills(context),
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
                    child: Icon(
                      Icons.schedule,
                      size: 18,
                      color: context.fvPrimary,
                    ),
                  ),
                  const SizedBox(width: FvSpacing.x3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pb.billerName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.fvText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pb.scheduledFor != null
                              ? FvFormat.formatDate(pb.scheduledFor!)
                              : FvFormat.formatDate(pb.date),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: context.fvTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    label: s.scheduled,
                    foreground: context.fvPrimary,
                    background: context.fvWash,
                  ),
                ],
              ),
            ),
        const SizedBox(height: FvSpacing.x2),
        SectionHeader(
          title: s.payHistoryTitle,
          actionLabel: s.payViewHistory,
          onAction: () => openBills(context),
        ),
        if (payments.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (recent.isEmpty)
          EmptyState(title: s.noPaymentsYet, body: s.paymentsEmptyBody)
        else
          for (final p in recent)
            FvCard(
              onTap: () => openBills(context),
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
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: context.fvSuccess,
                    ),
                  ),
                  const SizedBox(width: FvSpacing.x3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.billerName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.fvText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          FvFormat.formatDate(p.date),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: context.fvTextSecondary,
                          ),
                        ),
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

class _PayeeChip extends StatelessWidget {
  const _PayeeChip({required this.payee, required this.onTap});

  final Payee payee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FvSpacing.x3,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: context.fvSurface,
          borderRadius: BorderRadius.circular(FvRadius.input),
          border: Border.all(color: context.fvCardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: context.fvWash,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                payee.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: context.fvPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              payee.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.fvText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
