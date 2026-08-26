import 'package:flutter/material.dart';
import '../../core/format.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/state/money.dart';
import '../../core/state/preferences.dart';
import '../../core/mock/api.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';


class BillsScreen extends ConsumerStatefulWidget {
  const BillsScreen({super.key});

  @override
  ConsumerState<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends ConsumerState<BillsScreen> {
  static const _categories = {
    BillCategory.electricity: 'Electricity',
    BillCategory.water: 'Water',
    BillCategory.data: 'Data',
    BillCategory.airtime: 'Airtime',
    BillCategory.cable: 'Cable TV',
    BillCategory.schoolFees: 'School fees',
  };

  @override
  Widget build(BuildContext context) {
    final payments = ref.watch(billPaymentsProvider);
    final language = ref.watch(preferencesProvider).language;

    return ScreenPage(
      title: 'Pay bills',
      child: ListView(
        padding: const EdgeInsets.all(FvSpacing.x5),
        children: [
          const SectionHeader(title: 'Categories'),
          Wrap(
            spacing: FvSpacing.x2,
            runSpacing: FvSpacing.x2,
            children: _categories.entries
                .map((e) => ChoiceChip(
                      label: Text(e.value),
                      selected: false,
                      selectedColor: FvColors.wash,
                      onSelected: (_) => _pay(context, ref, e.key, e.value),
                    ))
                .toList(),
          ),
          const SizedBox(height: FvSpacing.x5),
          const SectionHeader(title: 'Payment history'),
          payments.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Could not load: $e')),
            data: (list) => list.isEmpty
                ? const EmptyState(title: 'No payments yet', body: 'Pay a bill above to see it here.')
                : Column(
                    children: [
                      for (final p in list)
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
                                child: Icon(Icons.receipt_long_outlined, size: 18, color: FvColors.primary),
                              ),
                              const SizedBox(width: FvSpacing.x3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${p.billerName} · ${_categories[p.category] ?? p.category.name}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
                                    const SizedBox(height: 2),
                                    Text('${FvFormat.formatDate(p.date, language: language)} · ${p.status.name}', style: TextStyle(fontSize: 12.5, color: context.fvTextSecondary)),
                                  ],
                                ),
                              ),
                              MoneyText(p.amount, size: MoneySize.sm, currency: 'MUR'),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _pay(BuildContext context, WidgetRef ref, BillCategory category, String name) {
    final refController = TextEditingController();
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
              Center(child: Text('Pay $name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
              const SizedBox(height: FvSpacing.x4),
              FvTextField(label: 'Customer reference', controller: refController, hint: 'ACC-2291'),
              const SizedBox(height: FvSpacing.x4),
              FvTextField(label: 'Amount', controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: FvSpacing.x5),
              FvButton(
                label: 'Pay now',
                onPressed: () async {
                  final api = ref.read(apiProvider);
                  final token = ref.read(kvStoreProvider).getString(sessionKey);
                  final value = double.tryParse(amount.text.replaceAll(',', '')) ?? 0;
                  if (value <= 0) return;
                  try {
                    await api.payBill(token, category: category, billerName: name, amount: value, customerRef: refController.text);
                    ref.invalidate(billPaymentsProvider);
                    ref.invalidate(accountsProvider);
                    ref.invalidate(transactionsProvider);
                    if (sheet.mounted) Navigator.of(sheet).pop();
                  } on FvApiException catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}



