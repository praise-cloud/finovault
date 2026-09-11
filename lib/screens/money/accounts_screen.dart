import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/banking/connector.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/state/money.dart';
import '../../theme/tokens.dart';
import '../../widgets/components.dart';
import '../../widgets/ui.dart';
import 'account_detail_screen.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  bool _connecting = false;

  Future<void> _connect(Institution inst, BuildContext sheet) async {
    final navigator = Navigator.of(sheet);
    final s = AppLocalizations.of(context);
    final api = ref.read(apiProvider);
    final token = ref.read(kvStoreProvider).getString(sessionKey);
    final connector = ref.read(bankConnectorProvider);
    if (navigator.canPop()) navigator.pop();
    setState(() => _connecting = true);
    try {
      final plan = await connector.planFor(inst.id, inst.type);
      final acc = await api.linkAccount(
        token,
        name: inst.name,
        type: inst.type,
        balance: plan.startingBalance,
        institution: inst.name,
      );
      for (final seed in plan.history) {
        await api.createTransaction(
          token,
          accountId: acc.id,
          amount: seed.amount,
          direction: seed.direction,
          category: seed.category,
          merchantName: seed.merchantName,
        );
      }
      ref.invalidate(accountsProvider);
      ref.invalidate(transactionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              s.importedTransactions(plan.history.length, inst.name),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  void _openConnectSheet() {
    final s = AppLocalizations.of(context);
    final connector = ref.read(bankConnectorProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.fvSurface,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FvSpacing.x5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.connectBankTitle.toUpperCase(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.connectBankBody,
                style: TextStyle(fontSize: 13, color: context.fvTextSecondary),
              ),
              const SizedBox(height: FvSpacing.x4),
              FutureBuilder<List<Institution>>(
                future: connector.institutions(),
                builder: (context, snap) {
                  if (!snap.hasData)
                    return const FvShimmer(height: 240, radius: FvRadius.card);
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: snap.data!.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: FvSpacing.x2),
                    itemBuilder: (_, i) {
                      final inst = snap.data![i];
                      return FvCard(
                        onTap: _connecting ? null : () => _connect(inst, sheet),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: FvColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                  FvRadius.iconContainer,
                                ),
                              ),
                              child: Icon(
                                inst.type == AccountType.mobileMoney
                                    ? Icons.smartphone
                                    : Icons.account_balance,
                                size: 20,
                                color: context.fvPrimary,
                              ),
                            ),
                            const SizedBox(width: FvSpacing.x3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    inst.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: context.fvText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    inst.blurb ?? inst.type.name,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: context.fvTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: context.fvPrimary,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: FvSpacing.x4),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final s = AppLocalizations.of(context);
    return ScreenPage(
      title: s.accounts,
      child: accounts.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(FvSpacing.x5),
          children: const [
            FvShimmer(height: 96, radius: FvRadius.card),
            SizedBox(height: FvSpacing.x3),
            FvShimmer(height: 64, radius: FvRadius.card),
            SizedBox(height: FvSpacing.x3),
            FvShimmer(height: 64, radius: FvRadius.card),
            SizedBox(height: FvSpacing.x3),
            FvShimmer(height: 64, radius: FvRadius.card),
          ],
        ),
        error: (e, _) => Center(child: Text('Could not load accounts: $e')),
        data: (list) {
          final total = list.fold<double>(0, (sum, a) => sum + a.balance);
          return ListView(
            padding: const EdgeInsets.all(FvSpacing.x5),
            children: [
              if (list.isEmpty)
                const EmptyState(
                  title: 'No accounts linked',
                  body: 'Link a bank or mobile-money account to see your balance here.',
                )
              else ...[
                Container(
                  margin: const EdgeInsets.only(bottom: FvSpacing.x4),
                  padding: const EdgeInsets.all(FvSpacing.x5),
                  decoration: BoxDecoration(
                    gradient: FvColors.heroGradient,
                    borderRadius: BorderRadius.circular(FvRadius.card),
                    border: Border.all(
                      color: context.fvCardBorder,
                      width: FvBorders.width,
                    ),
                    boxShadow: context.fvBrutal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.totalCash.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      MoneyText(
                        total,
                        size: MoneySize.xl,
                        color: Colors.white,
                        currency: 'MUR',
                      ),
                    ],
                  ),
                ),
                for (final a in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: FvSpacing.x3),
                    child: FvAccountTile(
                      account: a,
                      onTap: () => pushScreen(
                        context,
                        AccountDetailScreen(accountId: a.id),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: context.fvError,
                          size: 18,
                        ),
                        onPressed: () async {
                          final api = ref.read(apiProvider);
                          final token = ref
                              .read(kvStoreProvider)
                              .getString(sessionKey);
                          await api.unlinkAccount(token, a.id);
                          ref.invalidate(accountsProvider);
                        },
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: FvSpacing.x3),
              FvButton(
                label: 'Link an account',
                icon: Icons.add,
                variant: FvButtonVariant.success,
                onPressed: _connecting ? null : _openConnectSheet,
              ),
            ],
          );
        },
      ),
    );
  }
}
