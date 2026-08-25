import 'package:flutter_test/flutter_test.dart';
import 'package:finovault_flutter/core/format.dart';
import 'package:finovault_flutter/core/models.dart';
import 'package:finovault_flutter/core/mock/db.dart';
import 'package:finovault_flutter/core/mock/api.dart';
import 'package:finovault_flutter/core/providers.dart';
import 'package:finovault_flutter/core/state/auth.dart';
import 'package:finovault_flutter/core/state/onboarding.dart';
import 'package:finovault_flutter/core/state/preferences.dart';
import 'package:finovault_flutter/core/state/money.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<ProviderContainer> makeContainer({Duration latency = Duration.zero}) async {
  final store = MemoryStore();
  final db = MockDb(store: store, latency: 0);
  await db.hydrate();
  return ProviderContainer(overrides: [
    kvStoreProvider.overrideWithValue(store),
    mockDbProvider.overrideWithValue(db),
    apiLatencyProvider.overrideWith((ref) => latency),
    initialPreferencesProvider.overrideWithValue(loadInitialPreferences(store)),
    initialOnboardingProvider.overrideWithValue(loadInitialOnboarding(store)),
  ]);
}

void main() {
  group('format + fees', () {
    test('formatMoney uses the MUR symbol and thousands separators', () {
      expect(FvFormat.formatMoney(42500), 'Rs 42,500.00');
      expect(FvFormat.formatMoney(0), 'Rs 0.00');
      expect(FvFormat.formatMoney(1234.5), 'Rs 1,234.50');
    });

    test('passwordStrength rates length and variety', () {
      expect(FvFormat.passwordStrength('abc'), lessThan(4));
      expect(FvFormat.passwordStrength('Vault123!Strong'), 4);
    });

    test('computeTransferFee is 1.5% clamped to [20, 500]', () {
      expect(computeTransferFee(100), 20);
      expect(computeTransferFee(5000), 75);
      expect(computeTransferFee(100000), 500);
    });
  });

  group('mock api', () {
    test('demo login resolves the seeded user and a session', () async {
      final db = MockDb(store: MemoryStore(), latency: 0);
      await db.hydrate();
      final api = MockFinovaultApi(db: db, latency: Duration.zero);
      final result = await api.login(email: 'demo@finovault.app', password: 'Vault123!');
      expect(result.user.email, 'demo@finovault.app');
      expect(result.token, isNotEmpty);
      final session = await api.getSession(result.token);
      expect(session?.fullName, 'Amina Diallo');
    });

    test('contribute to a goal reduces the source account balance', () async {
      final db = MockDb(store: MemoryStore(), latency: 0);
      await db.hydrate();
      final api = MockFinovaultApi(db: db, latency: Duration.zero);
      final result = await api.login(email: 'demo@finovault.app', password: 'Vault123!');
      final goals = await api.goals(result.token);
      final accounts = await api.accounts(result.token);
      final before = accounts.first.balance;
      await api.contribute(result.token, goalId: goals.first.id, amount: 500, sourceAccountId: accounts.first.id);
      final after = (await api.accounts(result.token)).first.balance;
      expect(after, closeTo(before - 500, 0.001));
      final updated = await api.goals(result.token);
      expect(updated.first.currentAmount, closeTo(goals.first.currentAmount + 500, 0.001));
    });
  });

  group('onboarding controller', () {
    test('advances through welcome -> role -> goals -> complete', () async {
      final c = await makeContainer();
      final ob = c.read(onboardingProvider.notifier);
      expect(ob.state.step, OnboardingStep.welcome);

      ob.start();
      expect(ob.state.step, OnboardingStep.role);

      ob.selectRole(PrimaryRole.individual, femaleFounder: false);
      expect(ob.state.step, OnboardingStep.goals);
      expect(ob.state.role, PrimaryRole.individual);

      ob.setGoals(['Save for a home', 'Build an emergency fund'], null);
      expect(ob.state.financialGoals.length, 2);

      ob.complete();
      expect(ob.state.isComplete, isTrue);
    });
  });

  group('auth + money providers', () {
    test('login populates currentUser and accounts providers', () async {
      final c = await makeContainer();
      await c.read(authProvider.notifier).login('demo@finovault.app', 'Vault123!');
      final user = c.read(currentUserProvider);
      expect(user, isNotNull);
      expect(user!.email, 'demo@finovault.app');

      final accounts = await c.read(accountsProvider.future);
      expect(accounts, isNotEmpty);
      final summary = c.read(moneySummaryProvider);
      expect(summary.totalBalance, greaterThan(0));
    });
  });

  group('pension (Phase 4)', () {
    test('projection grows with contributions and discounts by inflation', () {
      final plan = PensionPlan(
        id: 'p',
        shortPotTarget: 50000,
        longPotTarget: 750000,
        frequency: PensionFrequency.monthly,
        contributionAmount: 100,
        currentShortPot: 0,
        currentLongPot: 0,
        assumedReturnPct: 7,
        inflationPct: 0,
        currentAge: 30,
        retirementAge: 65,
      );
      final proj = plan.computeProjection();
      expect(proj.yearsToRetirement, 35);
      // 35 years of MUR 100/month compounding at 7% must beat naive saving.
      expect(proj.totalProjected, greaterThan(100 * 12 * 35));
      expect(proj.shortPotProjected, lessThanOrEqualTo(proj.totalProjected));

      final realPlan = plan.copyWith(inflationPct: 4);
      final realProj = realPlan.computeProjection();
      // Real (today's-money) value is lower than nominal when inflation > 0.
      expect(realProj.totalProjected, lessThan(proj.totalProjected));
    });

    test('api upsert + contribute updates pots and history', () async {
      final db = MockDb(store: MemoryStore(), latency: 0);
      await db.hydrate();
      final api = MockFinovaultApi(db: db, latency: Duration.zero);
      final result = await api.login(email: 'demo@finovault.app', password: 'Vault123!');

      final plan = await api.upsertPensionPlan(result.token,
          shortPotTarget: 50000,
          longPotTarget: 750000,
          frequency: PensionFrequency.monthly,
          contributionAmount: 2000,
          currentShortPot: 1000,
          currentLongPot: 2000,
          assumedReturnPct: 7,
          inflationPct: 4,
          currentAge: 34,
          retirementAge: 65,
          autoDebit: true);
      expect(plan.currentShortPot, 1000);

      await api.contributePension(result.token, pot: 'short', amount: 500, sourceAccountId: db.accounts['user_demo']!.first.id);
      final updated = (await api.getPensionPlan(result.token))!;
      expect(updated.currentShortPot, 1500);
      final history = await api.pensionContributions(result.token);
      expect(history.length, 1);
      expect(history.first.pot, 'short');

      final proj = await api.pensionProjection(result.token);
      expect(proj.totalProjected, greaterThan(0));
    });

    test('pensionPlanProvider exposes the seeded plan', () async {
      final c = await makeContainer();
      await c.read(authProvider.notifier).login('demo@finovault.app', 'Vault123!');
      final plan = await c.read(pensionPlanProvider.future);
      expect(plan, isNotNull);
      expect(plan!.shortPotTarget, greaterThan(0));
      final proj = c.read(pensionProjectionProvider);
      expect(proj.totalProjected, greaterThan(0));
    });
  });
}
