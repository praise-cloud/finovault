import 'package:flutter_test/flutter_test.dart';

import 'package:finovault_flutter/core/mock/api.dart';
import 'package:finovault_flutter/core/mock/db.dart';
import 'package:finovault_flutter/core/models.dart';

MockFinovaultApi newApi() => MockFinovaultApi(db: MockDb(store: MemoryStore(), latency: 0));

void main() {
  group('MockFinovaultApi', () {
    test('signup then login succeeds', () async {
      final api = newApi();
      final ar = await api.signup(fullName: 'Test User', email: 'test@example.com', password: 'secret123');
      expect(ar.token, isNotEmpty);
      expect(ar.user.email, 'test@example.com');

      final login = await api.login(email: 'test@example.com', password: 'secret123');
      expect(login.token, isNotEmpty);
    });

    test('login with wrong password throws invalid_credentials', () async {
      final api = newApi();
      await api.signup(fullName: 'Test User', email: 'test@example.com', password: 'secret123');
      expect(
        () => api.login(email: 'test@example.com', password: 'nope'),
        throwsA(predicate((e) => e is FvApiException && e.code == 'invalid_credentials')),
      );
    });

    test('signup with existing email throws email_taken', () async {
      final api = newApi();
      await api.signup(fullName: 'A', email: 'dup@example.com', password: 'secret123');
      expect(
        () => api.signup(fullName: 'B', email: 'dup@example.com', password: 'secret123'),
        throwsA(predicate((e) => e is FvApiException && e.code == 'email_taken')),
      );
    });

    test('contribute to goal with insufficient funds throws', () async {
      final api = newApi();
      final ar = await api.signup(fullName: 'U', email: 'u@example.com', password: 'secret123');
      final token = ar.token;
      final acc = await api.linkAccount(token, name: 'Bank', type: AccountType.bank, balance: 100);
      final goal = await api.createGoal(token, name: 'Emergency', type: GoalType.emergency, targetAmount: 500);
      expect(
        () => api.contribute(token, goalId: goal.id, amount: 200, sourceAccountId: acc.id),
        throwsA(predicate((e) => e is FvApiException && e.code == 'insufficient_funds')),
      );
    });

    test('contribute deducts from source account', () async {
      final api = newApi();
      final ar = await api.signup(fullName: 'U', email: 'u@example.com', password: 'secret123');
      final token = ar.token;
      final acc = await api.linkAccount(token, name: 'Bank', type: AccountType.bank, balance: 1000);
      final goal = await api.createGoal(token, name: 'Emergency', type: GoalType.emergency, targetAmount: 500);
      final updated = await api.contribute(token, goalId: goal.id, amount: 200, sourceAccountId: acc.id);
      expect(updated.currentAmount, 200);
      final accounts = await api.accounts(token);
      expect(accounts.first.balance, 800);
    });

    test('transfer with insufficient funds throws', () async {
      final api = newApi();
      final ar = await api.signup(fullName: 'U', email: 'u@example.com', password: 'secret123');
      final token = ar.token;
      final acc = await api.linkAccount(token, name: 'Bank', type: AccountType.bank, balance: 50);
      expect(
        () => api.createTransfer(
          token,
          sourceAccountId: acc.id,
          payeeName: 'Bob',
          destination: 'ACC',
          amount: 100,
          idempotencyKey: 'k1',
        ),
        throwsA(predicate((e) => e is FvApiException && e.code == 'insufficient_funds')),
      );
    });

    test('transfer succeeds and posts a transaction', () async {
      final api = newApi();
      final ar = await api.signup(fullName: 'U', email: 'u@example.com', password: 'secret123');
      final token = ar.token;
      final acc = await api.linkAccount(token, name: 'Bank', type: AccountType.bank, balance: 1000);
      final transfer = await api.createTransfer(
        token,
        sourceAccountId: acc.id,
        payeeName: 'Bob',
        destination: 'ACC',
        amount: 100,
        idempotencyKey: 'k1',
      );
      expect(transfer.status, TransferStatus.completed);
      final accounts = await api.accounts(token);
      expect(accounts.first.balance, lessThan(1000));
      expect((await api.transactions(token)).length, 1);
    });

    test('invoice create + update status', () async {
      final api = newApi();
      final ar = await api.signup(fullName: 'U', email: 'u@example.com', password: 'secret123');
      final token = ar.token;
      final inv = await api.createInvoice(token, clientName: 'Client', amount: 300, dueDate: DateTime.now().add(const Duration(days: 7)));
      expect(inv.status, InvoiceStatus.sent);
      final paid = await api.updateInvoiceStatus(token, invoiceId: inv.id, status: InvoiceStatus.paid);
      expect(paid.status, InvoiceStatus.paid);
    });

    test('vendors and payees CRUD', () async {
      final api = newApi();
      final ar = await api.signup(fullName: 'U', email: 'u@example.com', password: 'secret123');
      final token = ar.token;
      await api.createVendor(token, name: 'Acme');
      expect((await api.vendors(token)).length, 1);
      final p = await api.createPayee(token, name: 'Bob', destination: 'ACC');
      expect((await api.payees(token)).length, 1);
      expect(p.name, 'Bob');
    });

    test('bill pay creates a payment and a transaction', () async {
      final api = newApi();
      final ar = await api.signup(fullName: 'U', email: 'u@example.com', password: 'secret123');
      final token = ar.token;
      final acc = await api.linkAccount(token, name: 'Bank', type: AccountType.bank, balance: 500);
      final payment = await api.payBill(
        token,
        category: BillCategory.electricity,
        billerName: 'CWA',
        amount: 100,
        customerRef: 'REF1',
        sourceAccountId: acc.id,
      );
      expect(payment.status, BillPaymentStatus.paid);
      expect((await api.transactions(token)).length, 1);
    });

    test('scheduleBill stores a scheduled payment', () async {
      final api = newApi();
      final ar = await api.signup(fullName: 'U', email: 'u@example.com', password: 'secret123');
      final token = ar.token;
      final payment = await api.scheduleBill(
        token,
        category: BillCategory.water,
        billerName: 'CWA',
        amount: 80,
        customerRef: 'REF2',
        scheduledFor: DateTime.now().add(const Duration(days: 3)),
      );
      expect(payment.status, BillPaymentStatus.scheduled);
    });

    test('pension contribute deducts from source account', () async {
      final api = newApi();
      final ar = await api.signup(fullName: 'U', email: 'u@example.com', password: 'secret123');
      final token = ar.token;
      final acc = await api.linkAccount(token, name: 'Bank', type: AccountType.bank, balance: 5000);
      await api.upsertPensionPlan(
        token,
        shortPotTarget: 1000,
        longPotTarget: 2000,
        frequency: PensionFrequency.monthly,
        contributionAmount: 100,
        currentShortPot: 0,
        currentLongPot: 0,
        assumedReturnPct: 7,
        inflationPct: 3,
        currentAge: 30,
        retirementAge: 65,
        autoDebit: false,
      );
      final c = await api.contributePension(token, pot: 'short', amount: 200, sourceAccountId: acc.id);
      expect(c.amount, 200);
      expect((await api.accounts(token)).first.balance, 4800);
    });
  });
}
