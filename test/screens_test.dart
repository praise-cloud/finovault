import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finovault_flutter/core/models.dart';
import 'package:finovault_flutter/core/state/money.dart';
import 'package:finovault_flutter/screens/auth/login_screen.dart';
import 'package:finovault_flutter/screens/auth/signup_screen.dart';
import 'package:finovault_flutter/screens/home_shell.dart';
import 'package:finovault_flutter/screens/role_screen.dart';
import 'package:finovault_flutter/screens/welcome_screen.dart';
import 'package:finovault_flutter/screens/money/accounts_screen.dart';
import 'package:finovault_flutter/screens/money/bills_screen.dart';
import 'package:finovault_flutter/screens/money/budgets_screen.dart';
import 'package:finovault_flutter/screens/money/goal_new_screen.dart';
import 'package:finovault_flutter/screens/money/goals_list_screen.dart';
import 'package:finovault_flutter/screens/money/invoices_screen.dart';
import 'package:finovault_flutter/screens/money/pension_screen.dart';
import 'package:finovault_flutter/screens/money/pension_setup_screen.dart';
import 'package:finovault_flutter/screens/money/security_screen.dart';
import 'package:finovault_flutter/screens/money/transactions_screen.dart';
import 'package:finovault_flutter/screens/money/transfer_screen.dart';
import 'package:finovault_flutter/screens/money/vendors_screen.dart';
import 'package:finovault_flutter/screens/onboarding/goals_screen.dart';
import 'package:finovault_flutter/screens/onboarding/link_accounts_screen.dart';
import 'package:finovault_flutter/screens/tabs/insights_tab.dart';
import 'package:finovault_flutter/screens/tabs/pay_tab.dart';
import 'package:finovault_flutter/screens/tabs/profile_tab.dart';
import 'package:finovault_flutter/screens/tabs/vault_tab.dart';

import 'helpers.dart';

final _transferDate = DateTime.utc(2024, 1, 1);

void main() {
  group('auth + onboarding screens', () {
    testWidgets('WelcomeScreen', (tester) async {
      await pumpScreen(tester, const WelcomeScreen(), loggedIn: false);
      expect(tester.takeException(), isNull);
    });
    testWidgets('RoleScreen', (tester) async {
      await pumpScreen(tester, const RoleScreen(), loggedIn: false);
      expect(tester.takeException(), isNull);
    });
    testWidgets('LoginScreen', (tester) async {
      await pumpScreen(tester, const LoginScreen(), loggedIn: false);
      expect(tester.takeException(), isNull);
    });
    testWidgets('SignupScreen', (tester) async {
      await pumpScreen(tester, const SignupScreen(), loggedIn: false);
      expect(tester.takeException(), isNull);
    });
    testWidgets('Onboarding GoalsScreen', (tester) async {
      await pumpScreen(tester, const GoalsScreen(), loggedIn: false);
      expect(tester.takeException(), isNull);
    });
    testWidgets('Onboarding LinkAccountsScreen', (tester) async {
      await pumpScreen(tester, const LinkAccountsScreen(), loggedIn: false);
      expect(tester.takeException(), isNull);
    });
  });

  group('shell + tabs', () {
    testWidgets('HomeShell', (tester) async {
      await pumpScreen(tester, const HomeShell());
      expect(tester.takeException(), isNull);
    });
    testWidgets('InsightsTab', (tester) async {
      await pumpScreen(tester, const InsightsTab());
      expect(tester.takeException(), isNull);
    });
    testWidgets('VaultTab', (tester) async {
      await pumpScreen(tester, const VaultTab());
      expect(tester.takeException(), isNull);
    });
    testWidgets('PayTab', (tester) async {
      await pumpScreen(tester, const PayTab());
      expect(tester.takeException(), isNull);
    });
    testWidgets('ProfileTab', (tester) async {
      await pumpScreen(tester, const ProfileTab());
      expect(tester.takeException(), isNull);
    });
  });

  group('money screens', () {
    testWidgets('AccountsScreen', (tester) async {
      await pumpScreen(tester, const AccountsScreen());
      expect(tester.takeException(), isNull);
    });
    testWidgets('TransactionsScreen', (tester) async {
      await pumpScreen(tester, const TransactionsScreen());
      expect(tester.takeException(), isNull);
    });
    testWidgets('BudgetsScreen', (tester) async {
      await pumpScreen(tester, const BudgetsScreen());
      expect(tester.takeException(), isNull);
    });
    testWidgets('GoalsListScreen', (tester) async {
      await pumpScreen(tester, const GoalsListScreen());
      expect(tester.takeException(), isNull);
    });
    testWidgets('GoalNewScreen', (tester) async {
      await pumpScreen(tester, const GoalNewScreen());
      expect(tester.takeException(), isNull);
    });
    testWidgets('InvoicesScreen', (tester) async {
      await pumpScreen(tester, const InvoicesScreen());
      expect(tester.takeException(), isNull);
    });
    testWidgets('VendorsScreen', (tester) async {
      await pumpScreen(tester, const VendorsScreen());
      expect(tester.takeException(), isNull);
    });
    testWidgets('TransferScreen', (tester) async {
      await pumpScreen(tester, const TransferScreen());
      expect(tester.takeException(), isNull);
    });
    testWidgets('TransferReceiptScreen', (tester) async {
      final c = await makeLoggedInContainer();
      final transfer = Transfer(
        id: 't1',
        sourceAccountId: 'a1',
        payeeName: 'Mum',
        destination: '98612345',
        amount: 100,
        fee: 1.5,
        total: 101.5,
        status: TransferStatus.completed,
        createdAt: _transferDate,
        externalRef: 'FV1',
        idempotencyKey: 'k1',
      );
      await pumpScreen(tester, TransferReceiptScreen(transfer: transfer), container: c);
      expect(tester.takeException(), isNull);
    });
    testWidgets('GoalDetailScreen', (tester) async {
      final c = await makeLoggedInContainer();
      final goals = await c.read(goalsProvider.future);
      final id = goals.isNotEmpty ? goals.first.id : 'missing';
      await pumpScreen(tester, GoalDetailScreen(goalId: id), container: c);
      expect(tester.takeException(), isNull);
    });
    testWidgets('BillsScreen', (tester) async {
      await pumpScreen(tester, const BillsScreen());
      expect(tester.takeException(), isNull);
    });
    testWidgets('SecurityScreen', (tester) async {
      await pumpScreen(tester, const SecurityScreen());
      expect(tester.takeException(), isNull);
    });
    testWidgets('PensionScreen', (tester) async {
      await pumpScreen(tester, const PensionScreen());
      expect(tester.takeException(), isNull);
    });
    testWidgets('PensionSetupScreen', (tester) async {
      await pumpScreen(tester, const PensionSetupScreen());
      expect(tester.takeException(), isNull);
    });
  });
}
