import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/state/money.dart';
import '../../theme/tokens.dart';
import '../../widgets/components.dart';
import '../../widgets/ui.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  TransactionDirection _dir = TransactionDirection.out;
  String? _filter;

  @override
  Widget build(BuildContext context) {
    final txs = ref.watch(transactionsProvider);
    final accounts = ref.watch(accountsProvider);
    final s = AppLocalizations.of(context);

    return ScreenPage(
      title: s.transactions,
      actions: [
        IconButton(
          icon: Icon(Icons.add, color: context.fvPrimary),
          onPressed: () => _add(accounts.value),
        ),
      ],
      child: txs.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(FvSpacing.x5),
          children: const [
            FvShimmer(height: 64, radius: FvRadius.card),
            SizedBox(height: FvSpacing.x3),
            FvShimmer(height: 64, radius: FvRadius.card),
            SizedBox(height: FvSpacing.x3),
            FvShimmer(height: 64, radius: FvRadius.card),
          ],
        ),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (list) {
          final cats = list.map((t) => t.category).toSet().toList()..sort();
          final filtered = _filter == null
              ? list
              : list.where((t) => t.category == _filter).toList();
          return Column(
            children: [
              if (cats.isNotEmpty)
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(
                      FvSpacing.x5,
                      FvSpacing.x3,
                      FvSpacing.x5,
                      0,
                    ),
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _filter == null,
                        onTap: () => setState(() => _filter = null),
                      ),
                      for (final c in cats)
                        _FilterChip(
                          label: c,
                          selected: _filter == c,
                          color: FvColors.categoryColor(c),
                          onTap: () =>
                              setState(() => _filter = _filter == c ? null : c),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: EmptyState(
                          title: 'No transactions yet',
                          body:
                              'Add one manually to keep your records complete.',
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(FvSpacing.x5),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: FvSpacing.x3),
                        itemBuilder: (_, i) =>
                            FvTransactionRow(txn: filtered[i]),
                      ),
              ),
            ],
          );
        },
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
      backgroundColor: context.fvSurface,
      builder: (sheet) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheet).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(FvSpacing.x5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Add transaction',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: FvSpacing.x4),
              StatefulBuilder(
                builder: (ctx, setInner) => Row(
                  children: [
                    Expanded(
                      child: _DirChip(
                        label: 'Expense',
                        selected: _dir == TransactionDirection.out,
                        onTap: () =>
                            setInner(() => _dir = TransactionDirection.out),
                      ),
                    ),
                    const SizedBox(width: FvSpacing.x2),
                    Expanded(
                      child: _DirChip(
                        label: 'Income',
                        selected: _dir == TransactionDirection.inn,
                        onTap: () =>
                            setInner(() => _dir = TransactionDirection.inn),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FvSpacing.x4),
              FvTextField(
                label: 'Amount',
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: FvSpacing.x4),
              FvTextField(
                label: 'Category',
                controller: category,
                hint: 'Groceries',
              ),
              const SizedBox(height: FvSpacing.x4),
              FvTextField(label: 'Merchant (optional)', controller: merchant),
              const SizedBox(height: FvSpacing.x4),
              DropdownButtonFormField<String>(
                initialValue: accountId,
                items: accounts
                    .map(
                      (a) => DropdownMenuItem(value: a.id, child: Text(a.name)),
                    )
                    .toList(),
                onChanged: (v) => accountId = v!,
                decoration: InputDecoration(
                  labelText: 'Account',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(FvRadius.input),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: FvSpacing.x4,
                    vertical: FvSpacing.x3,
                  ),
                ),
              ),
              const SizedBox(height: FvSpacing.x5),
              FvButton(
                label: 'Add transaction',
                variant: FvButtonVariant.success,
                onPressed: () async {
                  final api = ref.read(apiProvider);
                  final token = ref.read(kvStoreProvider).getString(sessionKey);
                  final value =
                      double.tryParse(amount.text.replaceAll(',', '')) ?? 0;
                  if (value <= 0) return;
                  final navigator = Navigator.of(sheet);
                  await api.createTransaction(
                    token,
                    accountId: accountId,
                    amount: value,
                    direction: _dir,
                    category: category.text,
                    merchantName: merchant.text,
                  );
                  ref.invalidate(transactionsProvider);
                  if (mounted) navigator.pop();
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
  const _DirChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Material(
      color: selected ? context.fvWash : context.fvSurface,
      borderRadius: BorderRadius.circular(FvRadius.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FvRadius.button),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FvRadius.button),
            border: Border.all(
              color: selected ? context.fvPrimary : context.fvBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? context.fvPrimary : context.fvText,
            ),
          ),
        ),
      ),
    ),
  );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.fvPrimary;
    return Padding(
      padding: const EdgeInsets.only(right: FvSpacing.x2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? c.withValues(alpha: 0.14) : context.fvSurface,
            borderRadius: BorderRadius.circular(FvRadius.badge),
            border: Border.all(color: selected ? c : context.fvBorder),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: selected ? c : context.fvTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
