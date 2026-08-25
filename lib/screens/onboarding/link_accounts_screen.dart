import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/mock/api.dart';
import '../../core/providers.dart';
import '../../core/state/money.dart';
import '../../core/state/onboarding.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import '../../widgets/vault_mark.dart';

/// Simulated institution linking — mirrors the Expo onboarding step.
class LinkAccountsScreen extends ConsumerStatefulWidget {
  const LinkAccountsScreen({super.key});

  @override
  ConsumerState<LinkAccountsScreen> createState() => _LinkAccountsScreenState();
}

class _LinkAccountsScreenState extends ConsumerState<LinkAccountsScreen> {
  bool _bankLinked = false;
  bool _momoLinked = false;
  bool _finishing = false;

  Future<void> _link(_InstitutionRow row) async {
    final api = ref.read(apiProvider);
    final token = ref.read(kvStoreProvider).getString(sessionKey);
    try {
      await api.linkAccount(
        token,
        name: row.accountName,
        type: row.type,
        institution: row.institution,
        balance: 0,
      );
      ref.invalidate(accountsProvider);
      setState(() => row.linkedSetter(true));
    } on FvApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _finish() async {
    setState(() => _finishing = true);
    await ref.read(onboardingProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final bank = _InstitutionRow(
      icon: Icons.account_balance_outlined,
      title: s.bankAccount,
      subtitle: 'MCB, SBM, Barclays and more',
      accountName: 'My Bank Account',
      type: AccountType.bank,
      institution: 'MCB',
      linked: _bankLinked,
      linkedSetter: (v) => _bankLinked = v,
    );
    final momo = _InstitutionRow(
      icon: Icons.smartphone_outlined,
      title: s.mobileMoney,
      subtitle: 'MyT, Juice, Ezi Cash',
      accountName: 'My Mobile Money',
      type: AccountType.mobileMoney,
      institution: 'MyT',
      linked: _momoLinked,
      linkedSetter: (v) => _momoLinked = v,
    );

    return Scaffold(
      body: Container(
        decoration: context.fvPageDecoration,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(FvSpacing.x6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Row(
                  children: [
                    VaultMark(size: 28),
                    SizedBox(width: 10),
                    Text('Finovault', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: FvColors.primary)),
                  ],
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: FvSpacing.x8),
                    children: <Widget>[
                      Text(s.linkAccounts,
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: FvColors.primary)),
                      const SizedBox(height: 8),
                      Text(
                        s.linkSubtitle,
                        style: TextStyle(fontSize: 15, height: 1.5, color: context.fvTextSecondary),
                      ),
                      const SizedBox(height: FvSpacing.x6),
                      _LinkCard(row: bank, onLink: () => _link(bank)),
                      const SizedBox(height: FvSpacing.x3),
                      _LinkCard(row: momo, onLink: () => _link(momo)),
                    ],
                  ),
                ),
                FvButton(label: s.finish, onPressed: _finishing ? null : _finish, loading: _finishing),
                const SizedBox(height: FvSpacing.x3),
                Center(
                  child: TextButton(
                    onPressed: _finishing ? null : _finish,
                    child: Text(s.skipForNow,
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: context.fvTextSecondary)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InstitutionRow {
  _InstitutionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accountName,
    required this.type,
    required this.institution,
    required this.linked,
    required this.linkedSetter,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String accountName;
  final AccountType type;
  final String institution;
  final bool linked;
  final ValueChanged<bool> linkedSetter;
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({required this.row, required this.onLink});

  final _InstitutionRow row;
  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    return FvCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: FvColors.wash, borderRadius: BorderRadius.circular(FvRadius.iconContainer)),
            child: Icon(row.icon, size: 20, color: FvColors.primary),
          ),
          const SizedBox(width: FvSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: FvColors.primary)),
                const SizedBox(height: 2),
                Text(row.subtitle, style: TextStyle(fontSize: 12.5, color: context.fvTextSecondary)),
              ],
            ),
          ),
          const SizedBox(width: FvSpacing.x2),
          if (row.linked)
            StatusBadge(label: AppLocalizations.of(context)!.linked, foreground: FvColors.success, background: FvColors.successBg)
          else
            FvButton(label: AppLocalizations.of(context)!.linkAccount, onPressed: onLink, variant: FvButtonVariant.secondary, expanded: false),
        ],
      ),
    );
  }
}
