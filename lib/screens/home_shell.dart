import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models.dart';
import '../core/state/auth.dart';
import '../core/state/money.dart';
import '../core/state/onboarding.dart';
import '../l10n/app_localizations.dart';
import '../theme/tokens.dart';
import '../widgets/ui.dart';
import '../widgets/notification_bell.dart';
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
import 'coach/coach_screen.dart';
import 'student_home_screen.dart';
import 'tabs/student_budget_tab.dart';
import 'tabs/student_history_tab.dart';

/// Authenticated shell: 4-tab bar (Home, Budgets & Savings, History, Settings).
/// Strictly follows the app's brutalist styling (ink borders, clean surfaces,
/// black active badge pill with white text/icon, zero blue background).
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeTabIndexProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: FvColors.bg,
      body: Container(
        color: FvColors.bg,
        child: SafeArea(
          child: IndexedStack(
            index: index.clamp(0, 3),
            children: const [
              StudentHomeScreen(),
              StudentBudgetTab(),
              StudentHistoryTab(),
              ProfileTab(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: StudentBottomBar(
        currentIndex: index.clamp(0, 3),
        onTap: (i) => ref.read(homeTabIndexProvider.notifier).state = i,
      ),
    );
  }
}

/// Custom brutalist bottom navigation bar.
/// Uses the app's signature high-contrast ink styling with solid borders,
/// zero blue background, and tactile active indicators.
class StudentBottomBar extends StatelessWidget {
  const StudentBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: FvColors.surface,
        border: Border(
          top: BorderSide(color: FvColors.ink, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StudentNavBtn(
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.bolt_rounded,
                label: 'Home',
                onTap: onTap,
              ),
              _StudentNavBtn(
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.pie_chart_rounded,
                label: 'Budgets',
                onTap: onTap,
              ),
              _StudentNavBtn(
                index: 2,
                currentIndex: currentIndex,
                icon: Icons.receipt_long_rounded,
                label: 'History',
                onTap: onTap,
              ),
              _StudentNavBtn(
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.tune_rounded,
                label: 'Settings',
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentNavBtn extends StatelessWidget {
  const _StudentNavBtn({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: selected ? FvColors.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? FvColors.ink : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x33000000),
                      offset: Offset(1.5, 1.5),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? Colors.white : FvColors.textSecondary,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  letterSpacing: 0.3,
                  color: selected ? Colors.white : FvColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- shared quick-action helper used by legacy persona screens ---------------

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
                  child: Icon(action.icon, size: 20, color: context.fvPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  action.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: context.fvTextSecondary,
                  ),
                ),
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

// Convenience navigation helpers used across money screens.
void openAccounts(BuildContext context) =>
    pushScreen(context, const AccountsScreen());
void openTransactions(BuildContext context) =>
    pushScreen(context, const TransactionsScreen());
void openBudgets(BuildContext context) =>
    pushScreen(context, const BudgetsScreen());
void openGoals(BuildContext context) =>
    pushScreen(context, const GoalsListScreen());
void openNewGoal(BuildContext context) =>
    pushScreen(context, const GoalNewScreen());
void openSecurity(BuildContext context) =>
    pushScreen(context, const SecurityScreen());
void openInvoices(BuildContext context) =>
    pushScreen(context, const InvoicesScreen());
void openVendors(BuildContext context) =>
    pushScreen(context, const VendorsScreen());
void openTransfer(BuildContext context) =>
    pushScreen(context, const TransferScreen());
void openBills(BuildContext context) =>
    pushScreen(context, const BillsScreen());
void openPension(BuildContext context) =>
    pushScreen(context, const PensionScreen());
