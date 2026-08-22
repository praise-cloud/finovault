import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/state/money.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  final _name = TextEditingController();
  final _institution = TextEditingController();
  final _balance = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _institution.dispose();
    _balance.dispose();
    super.dispose();
  }

  IconData _icon(AccountType t) => switch (t) {
        AccountType.bank => Icons.account_balance_outlined,
        AccountType.mobileMoney => Icons.smartphone_outlined,
        AccountType.cash => Icons.wallet_outlined,
        _ => Icons.account_balance_wallet_outlined,
      };

  Future<void> _add() async {
    final api = ref.read(apiProvider);
    final token = ref.read(kvStoreProvider).getString(sessionKey);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.fvIsDark ? FvColors.bgDark : FvColors.surface,
      builder: (sheet) => _LinkSheet(
        onLink: (name, type, institution, balance) async {
          await api.linkAccount(token, name: name, type: type, institution: institution, balance: balance);
          ref.invalidate(accountsProvider);
          if (mounted) Navigator.of(sheet).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    return ScreenPage(
      title: 'Accounts',
      child: accounts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load accounts: $e')),
        data: (list) {
          final total = list.fold<double>(0, (s, a) => s + a.balance);
          return ListView(
            padding: const EdgeInsets.all(FvSpacing.x5),
            children: [
              if (list.isEmpty)
                const EmptyState(title: 'No accounts linked', body: 'Link a bank or mobile-money account to see your balance here.')
              else ...[
                FvCard(
                  margin: const EdgeInsets.only(bottom: FvSpacing.x4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total balance', style: TextStyle(fontSize: 13)),
                      const SizedBox(height: 4),
                      MoneyText(total, size: MoneySize.lg, currency: 'MUR'),
                    ],
                  ),
                ),
                for (final a in list)
                  FvCard(
                    margin: const EdgeInsets.only(bottom: FvSpacing.x3),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: FvColors.wash, borderRadius: BorderRadius.circular(FvRadius.iconContainer)),
                          child: Icon(_icon(a.type), size: 20, color: FvColors.primary),
                        ),
                        const SizedBox(width: FvSpacing.x3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.fvText)),
                              const SizedBox(height: 2),
                              Text(a.institution ?? a.type.name, style: TextStyle(fontSize: 12.5, color: context.fvTextSecondary)),
                            ],
                          ),
                        ),
                        MoneyText(a.balance, size: MoneySize.md, currency: 'MUR'),
                        const SizedBox(width: FvSpacing.x2),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: FvColors.error, size: 18),
                          onPressed: () async {
                            final api = ref.read(apiProvider);
                            final token = ref.read(kvStoreProvider).getString(sessionKey);
                            await api.unlinkAccount(token, a.id);
                            ref.invalidate(accountsProvider);
                          },
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: FvSpacing.x3),
              FvButton(label: 'Link an account', icon: Icons.add, onPressed: _add),
            ],
          );
        },
      ),
    );
  }
}

class _LinkSheet extends ConsumerStatefulWidget {
  const _LinkSheet({required this.onLink});

  final Future<void> Function(String name, AccountType type, String institution, double balance) onLink;

  @override
  ConsumerState<_LinkSheet> createState() => _LinkSheetState();
}

class _LinkSheetState extends ConsumerState<_LinkSheet> {
  final _name = TextEditingController();
  final _inst = TextEditingController();
  final _bal = TextEditingController();
  AccountType _type = AccountType.bank;

  @override
  void dispose() {
    _name.dispose();
    _inst.dispose();
    _bal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return showFormSheet(
      context: context,
      title: 'Link an account',
      submitLabel: 'Link account',
      children: [
        FvTextField(label: 'Name', controller: _name, hint: 'My Bank Account'),
        const SizedBox(height: FvSpacing.x4),
        FvTextField(label: 'Institution', controller: _inst, hint: 'MCB'),
        const SizedBox(height: FvSpacing.x4),
        FvTextField(label: 'Starting balance', controller: _bal, keyboardType: const TextInputType.numberWithOptions(decimal: true), hint: '0'),
        const SizedBox(height: FvSpacing.x4),
        const Text('Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<AccountType>(
          value: _type,
          items: AccountType.values
              .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
              .toList(),
          onChanged: (v) => setState(() => _type = v!),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(FvRadius.input)),
            contentPadding: const EdgeInsets.symmetric(horizontal: FvSpacing.x4, vertical: FvSpacing.x3),
          ),
        ),
      ],
      onSubmit: () async {
        final balance = double.tryParse(_bal.text.replaceAll(',', '')) ?? 0;
        await widget.onLink(_name.text, _type, _inst.text, balance);
      },
    );
  }
}
