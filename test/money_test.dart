import 'package:flutter_test/flutter_test.dart';

import 'package:finovault_flutter/core/format.dart';
import 'package:finovault_flutter/core/models.dart';
import 'package:finovault_flutter/core/providers.dart';
import 'package:finovault_flutter/core/state/auth.dart';
import 'package:finovault_flutter/core/state/money.dart';

import 'test_utils.dart';

void main() {
  group('FvFormat', () {
    test('formatMoney groups thousands and uses currency code', () {
      expect(FvFormat.formatMoney(1200), 'MUR 1,200.00');
      expect(FvFormat.formatMoney(125000.5), 'MUR 125,000.50');
    });

    test('formatMoney French locale uses space grouping and comma decimals', () {
      expect(FvFormat.formatMoney(1200, language: 'fr'), 'MUR 1 200,00');
    });

    test('formatMoney negative keeps sign', () {
      expect(FvFormat.formatMoney(-50), '-MUR 50.00');
    });

    test('formatPercent rounds to whole percent', () {
      expect(FvFormat.formatPercent(0.5), '50%');
      expect(FvFormat.formatPercent(0.755), '76%');
    });

    test('formatDate renders en and fr month names', () {
      expect(FvFormat.formatDate(DateTime(2026, 3, 5)), '5 Mar 2026');
      expect(FvFormat.formatDate(DateTime(2026, 3, 5), language: 'fr'), '5 mars 2026');
    });

    test('computeTransferFee is 1.5% clamped to [20, 500]', () {
      expect(computeTransferFee(1000), 20.0); // 15 -> min 20
      expect(computeTransferFee(20000), 300.0); // 300
      expect(computeTransferFee(100000), 500.0); // 1500 -> max 500
    });

    test('passwordStrength scores length/case/digit/symbol', () {
      expect(FvFormat.passwordStrength('short'), 0);
      expect(FvFormat.passwordStrength('longenough'), 1);
      expect(FvFormat.passwordStrength('Longenough1'), 3);
      expect(FvFormat.passwordStrength('Longenough1!'), 4);
    });
  });

  group('moneySummaryProvider', () {
    test('net worth, income, runway and tax estimate', () async {
      final c = makeContainer();
      final auth = c.read(authProvider.notifier);
      expect(await auth.signup('U', 'u@e.com', 'secret123'), isTrue);
      final token = c.read(kvStoreProvider).getString(sessionKey)!;
      final api = c.read(apiProvider);
      final acc = await api.linkAccount(token, name: 'Bank', type: AccountType.bank, balance: 1200);
      await api.createTransaction(token, accountId: acc.id, amount: 500, direction: TransactionDirection.inn, category: 'Salary');

      c.invalidate(accountsProvider);
      c.invalidate(transactionsProvider);
      await c.read(accountsProvider.future);
      await c.read(transactionsProvider.future);

      final summary = c.read(moneySummaryProvider);
      expect(summary.totalBalance, 1200);
      expect(summary.monthIncome, 500);
      expect(summary.monthExpense, 0);
      expect(summary.runwayMonths, 12); // no expense -> 12 floor
      expect(summary.taxEstimate, 75); // 500 * 0.15
      expect(summary.topExpenseCategory, isNull);
      c.dispose();
    });

    test('captures expenses, top category and runway', () async {
      final c = makeContainer();
      final auth = c.read(authProvider.notifier);
      await auth.signup('U', 'u@e.com', 'secret123');
      final token = c.read(kvStoreProvider).getString(sessionKey)!;
      final api = c.read(apiProvider);
      final acc = await api.linkAccount(token, name: 'Bank', type: AccountType.bank, balance: 2000);
      await api.createTransaction(token, accountId: acc.id, amount: 800, direction: TransactionDirection.inn, category: 'Salary');
      await api.createTransaction(token, accountId: acc.id, amount: 200, direction: TransactionDirection.out, category: 'Food');
      await api.createTransaction(token, accountId: acc.id, amount: 100, direction: TransactionDirection.out, category: 'Transport');

      c.invalidate(accountsProvider);
      c.invalidate(transactionsProvider);
      await c.read(accountsProvider.future);
      await c.read(transactionsProvider.future);

      final s = c.read(moneySummaryProvider);
      expect(s.totalBalance, 2000);
      expect(s.monthIncome, 800);
      expect(s.monthExpense, 300);
      expect(s.topExpenseCategory, 'Food'); // 200 > 100
      expect(s.runwayMonths, closeTo(2000 / 300, 0.001));
      c.dispose();
    });

    test('unpaid/overdue invoice totals', () async {
      final c = makeContainer();
      final auth = c.read(authProvider.notifier);
      await auth.signup('U', 'u@e.com', 'secret123');
      final token = c.read(kvStoreProvider).getString(sessionKey)!;
      final api = c.read(apiProvider);
      await api.createInvoice(token, clientName: 'A', amount: 300, dueDate: DateTime.now().add(const Duration(days: 7)));
      await api.createInvoice(token, clientName: 'B', amount: 150, dueDate: DateTime.now().add(const Duration(days: -2)));
      final overdue = await api.invoices(token);
      await api.updateInvoiceStatus(token, invoiceId: overdue[1].id, status: InvoiceStatus.overdue);

      c.invalidate(invoicesProvider);
      await c.read(invoicesProvider.future);

      final s = c.read(moneySummaryProvider);
      expect(s.unpaidInvoiceCount, 2);
      expect(s.overdueInvoiceCount, 1);
      expect(s.unpaidInvoiceTotal, 450);
      c.dispose();
    });
  });
}
