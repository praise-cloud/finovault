import 'package:flutter/material.dart';
import '../../core/format.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/state/money.dart';
import '../../core/state/preferences.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  @override
  Widget build(BuildContext context) {
    final invoices = ref.watch(invoicesProvider);
    final language = ref.watch(preferencesProvider).language;

    return ScreenPage(
      title: 'Invoices',
      actions: [IconButton(icon: const Icon(Icons.add, color: FvColors.primary), onPressed: _add)],
      child: invoices.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (list) {
          final unpaid = list.where((i) => i.status != InvoiceStatus.paid).toList();
          final total = unpaid.fold(0.0, (s, i) => s + i.amount);
          return list.isEmpty
              ? const Center(child: EmptyState(title: 'No invoices yet', body: 'Track what clients owe you here.'))
              : ListView(
                  padding: const EdgeInsets.all(FvSpacing.x5),
                  children: [
                    if (unpaid.isNotEmpty)
                      FvCard(
                        margin: const EdgeInsets.only(bottom: FvSpacing.x4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Unpaid total', style: TextStyle(fontSize: 13, color: context.fvTextSecondary)),
                            const SizedBox(height: 4),
                            MoneyText(total, size: MoneySize.lg, currency: 'MUR'),
                          ],
                        ),
                      ),
                    for (final inv in list) _invoiceRow(invoice: inv, language: language),
                  ],
                );
        },
      ),
    );
  }

  Widget _invoiceRow({required Invoice invoice, required String language}) {
    final color = invoice.status == InvoiceStatus.overdue
        ? FvColors.error
        : (invoice.status == InvoiceStatus.paid ? FvColors.success : FvColors.warning);
    return FvCard(
      margin: const EdgeInsets.only(bottom: FvSpacing.x3),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice.clientName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
                const SizedBox(height: 2),
                Text('Due ${FvFormat.formatDate(invoice.dueDate, language: language)}', style: TextStyle(fontSize: 12.5, color: context.fvTextSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MoneyText(invoice.amount, size: MoneySize.md, currency: 'MUR'),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusBadge(
                    label: invoice.status == InvoiceStatus.paid
                        ? 'Paid'
                        : (invoice.status == InvoiceStatus.overdue ? 'Overdue' : 'Sent'),
                    foreground: color,
                    background: color == FvColors.success
                        ? FvColors.successBg
                        : (color == FvColors.error ? FvColors.errorBg : FvColors.warningBg),
                  ),
                  if (invoice.status != InvoiceStatus.paid)
                    IconButton(
                      icon: const Icon(Icons.check, color: FvColors.success, size: 18),
                      onPressed: () async {
                        final api = ref.read(apiProvider);
                        final token = ref.read(kvStoreProvider).getString(sessionKey);
                        await api.updateInvoiceStatus(token, invoiceId: invoice.id, status: InvoiceStatus.paid);
                        ref.invalidate(invoicesProvider);
                      },
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _add() {
    final client = TextEditingController();
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
              const Center(child: Text('New invoice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
              const SizedBox(height: FvSpacing.x4),
              FvTextField(label: 'Client name', controller: client, hint: 'Nova Studio'),
              const SizedBox(height: FvSpacing.x4),
              FvTextField(label: 'Amount', controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: FvSpacing.x5),
              FvButton(
                label: 'Add invoice',
                onPressed: () async {
                  final api = ref.read(apiProvider);
                  final token = ref.read(kvStoreProvider).getString(sessionKey);
                  final value = double.tryParse(amount.text.replaceAll(',', '')) ?? 0;
                  if (client.text.isEmpty || value <= 0) return;
                  await api.createInvoice(token, clientName: client.text, amount: value, dueDate: DateTime.now().add(const Duration(days: 14)));
                  ref.invalidate(invoicesProvider);
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


