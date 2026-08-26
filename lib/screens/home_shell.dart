import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models.dart';
import '../core/state/auth.dart';
import '../core/state/money.dart';
import '../core/state/onboarding.dart';
import '../l10n/app_localizations.dart';
import '../theme/tokens.dart';
import '../widgets/ui.dart';
import 'home/persona_homes.dart';
import 'money/accounts_screen.dart';
import 'money/bills_screen.dart';
import 'money/budgets_screen.dart';
import 'money/goal_new_screen.dart';
import 'money/goals_list_screen.dart';
import 'money/pension_screen.dart';
import 'money/invoices_screen.dart';
import 'money/security_screen.dart';
import 'money/transactions_screen.dart';
import 'money/transfer_screen.dart';
import 'money/vendors_screen.dart';
import 'tabs/insights_tab.dart';
import 'tabs/pay_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/vault_tab.dart';

/// Authenticated shell: bottom 5-tab bar (Home/Insights/Vault/Pay/Profile).
/// The Home tab is role-aware — each persona sees its own hero metric and
/// modules (never a generic dashboard).
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeTabIndexProvider);
    final scheme = ref.watch(onboardingProvider).scheme;
    final user = ref.watch(currentUserProvider);
    final s = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: context.fvPageDecoration,
        child: SafeArea(
          child: IndexedStack(
            index: index,
            children: [
              _HomeTab(user: user, femaleFounder: scheme == RoleScheme.femaleFounder),
              const InsightsTab(),
              const VaultTab(),
              const PayTab(),
              const ProfileTab(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => ref.read(homeTabIndexProvider.notifier).state = i,
        backgroundColor: context.fvIsDark ? FvColors.bgDark : FvColors.surface,
        indicatorColor: FvColors.wash,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: s.navHome),
          NavigationDestination(icon: const Icon(Icons.psychology_outlined), selectedIcon: const Icon(Icons.psychology), label: s.navInsights),
          NavigationDestination(icon: const Icon(Icons.lock_outline), selectedIcon: const Icon(Icons.lock), label: s.navVault),
          NavigationDestination(icon: const Icon(Icons.send_outlined), selectedIcon: const Icon(Icons.send), label: s.navPay),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: s.navProfile),
        ],
      ),
    );
  }
}

// ---- Home tab ---------------------------------------------------------------

class _HomeTab extends ConsumerWidget {
  const _HomeTab({required this.user, required this.femaleFounder});

  final UserProfile? user;
  final bool femaleFounder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = user?.primaryRole ?? ref.watch(onboardingProvider).role ?? PrimaryRole.individual;

    return ListView(
      padding: const EdgeInsets.all(FvSpacing.x5),
      children: [
        GreetingHeader(name: user?.fullName ?? 'Welcome'),
        const SizedBox(height: FvSpacing.x4),
        switch (role) {
          PrimaryRole.individual => const IndividualHome(),
          PrimaryRole.freelancer => const FreelancerHome(),
          PrimaryRole.entrepreneur => EntrepreneurHome(femaleFounder: femaleFounder),
          PrimaryRole.sme => const SMEHome(),
        },
      ],
    );
  }
}

class GreetingHeader extends ConsumerWidget {
  const GreetingHeader({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context);
    final firstName = name.split(' ').first;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? s.goodMorning : (hour < 18 ? s.goodAfternoon : s.goodEvening);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting, $firstName',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: context.fvText)),
              const SizedBox(height: 4),
              Text(s.appTagline,
                  style: TextStyle(fontSize: 13, color: context.fvTextSecondary)),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.fvSurface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: context.fvCardBorder),
          ),
          child: const Icon(Icons.notifications_outlined, size: 20, color: FvColors.primary),
        ),
      ],
    );
  }
}

// ---- shared quick-action helper used by persona homes ------------------------

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key, required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final action in actions)
          GestureDetector(
            onTap: action.onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.fvSurface,
                    borderRadius: BorderRadius.circular(FvRadius.iconContainer),
                    border: Border.all(color: context.fvCardBorder),
                  ),
                  child: Icon(action.icon, size: 20, color: FvColors.primary),
                ),
                const SizedBox(height: 6),
                Text(action.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: context.fvTextSecondary)),
              ],
            ),
          ),
      ],
    );
  }
}

class QuickAction {
  const QuickAction(this.label, this.icon, this.onTap);

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

// Convenience navigation helpers used across tabs.
void openAccounts(BuildContext context) => pushScreen(context, const AccountsScreen());
void openTransactions(BuildContext context) => pushScreen(context, const TransactionsScreen());
void openBudgets(BuildContext context) => pushScreen(context, const BudgetsScreen());
void openGoals(BuildContext context) => pushScreen(context, const GoalsListScreen());
void openNewGoal(BuildContext context) => pushScreen(context, const GoalNewScreen());
void openSecurity(BuildContext context) => pushScreen(context, const SecurityScreen());
void openInvoices(BuildContext context) => pushScreen(context, const InvoicesScreen());
void openVendors(BuildContext context) => pushScreen(context, const VendorsScreen());
void openTransfer(BuildContext context) => pushScreen(context, const TransferScreen());
void openBills(BuildContext context) => pushScreen(context, const BillsScreen());
void openPension(BuildContext context) => pushScreen(context, const PensionScreen());
