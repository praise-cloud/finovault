import 'package:flutter/material.dart';
import '../../core/format.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/state/money.dart';
import '../../core/state/preferences.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';


class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  TransactionDirection _dir = TransactionDirection.out;

  @override
  Widget build(BuildContext context) {
    final txs = ref.watch(transactionsProvider);
    final accounts = ref.watch(accountsProvider);
    final language = ref.watch(preferencesProvider).language;

    return ScreenPage(
      title: 'Transactions',
      actions: [
        IconButton(icon: const Icon(Icons.add, color: FvColors.primary), onPressed: () => _add(accounts.value)),
      ],
      child: txs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (list) => list.isEmpty
            ? const Center(child: EmptyState(title: 'No transactions yet', body: 'Add one manually to keep your records complete.'))
            : ListView.separated(
                padding: const EdgeInsets.all(FvSpacing.x5),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: FvSpacing.x3),
                itemBuilder: (_, i) {
                  final t = list[i];
                  final color = t.direction == TransactionDirection.inn ? FvColors.success : context.fvText;
                  return FvCard(
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
                          child: Icon(t.direction == TransactionDirection.inn ? Icons.arrow_downward : Icons.arrow_upward, size: 18, color: color),
                        ),
                        const SizedBox(width: FvSpacing.x3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.merchantName ?? t.category, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.fvText)),
                              const SizedBox(height: 2),
                              Text('${t.category} · ${FvFormat.formatDate(t.date, language: language)}', style: TextStyle(fontSize: 12.5, color: context.fvTextSecondary)),
                            ],
                          ),
                        ),
                        MoneyText(t.amount, size: MoneySize.md, currency: 'MUR', color: color, signed: t.direction == TransactionDirection.inn),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _add(List<Account>? accounts) {
    if (accounts == null || accounts.isEmpty) return;
    String accountId = accounts.first.id;
    final category = TextEditingController();
    final merchant = TextEditingController();
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
              const Center(child: Text('Add transaction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
              const SizedBox(height: FvSpacing.x4),
              StatefulBuilder(
                builder: (ctx, setInner) => Row(
                  children: [
                    Expanded(child: _DirChip(label: 'Expense', selected: _dir == TransactionDirection.out, onTap: () => setInner(() => _dir = TransactionDirection.out))),
                    const SizedBox(width: FvSpacing.x2),
                    Expanded(child: _DirChip(label: 'Income', selected: _dir == TransactionDirection.inn, onTap: () => setInner(() => _dir = TransactionDirection.inn))),
                  ],
                ),
              ),
              const SizedBox(height: FvSpacing.x4),
              FvTextField(label: 'Amount', controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: FvSpacing.x4),
              FvTextField(label: 'Category', controller: category, hint: 'Groceries'),
              const SizedBox(height: FvSpacing.x4),
              FvTextField(label: 'Merchant (optional)', controller: merchant),
              const SizedBox(height: FvSpacing.x4),
              DropdownButtonFormField<String>(
                initialValue: accountId,
                items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                onChanged: (v) => accountId = v!,
                decoration: InputDecoration(
                  labelText: 'Account',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(FvRadius.input)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: FvSpacing.x4, vertical: FvSpacing.x3),
                ),
              ),
              const SizedBox(height: FvSpacing.x5),
              FvButton(
                label: 'Add transaction',
                onPressed: () async {
                  final api = ref.read(apiProvider);
                  final token = ref.read(kvStoreProvider).getString(sessionKey);
                  final value = double.tryParse(amount.text.replaceAll(',', '')) ?? 0;
                  if (value <= 0) return;
                  await api.createTransaction(token, accountId: accountId, amount: value, direction: _dir, category: category.text, merchantName: merchant.text);
                  ref.invalidate(transactionsProvider);
                  if (mounted) Navigator.of(sheet).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirChip extends StatelessWidget {
  const _DirChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Material(
          color: selected ? FvColors.wash : context.fvSurface,
          borderRadius: BorderRadius.circular(FvRadius.button),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(FvRadius.button),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(FvRadius.button),
                border: Border.all(color: selected ? FvColors.primary : context.fvBorder, width: selected ? 1.5 : 1),
              ),
              child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? FvColors.primary : context.fvText)),
            ),
          ),
        ),
      );
}


