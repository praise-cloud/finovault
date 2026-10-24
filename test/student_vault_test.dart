import 'package:flutter_test/flutter_test.dart';
import 'package:finovault_flutter/core/mock/db.dart';
import 'package:finovault_flutter/core/state/student_vault.dart';

void main() {
  group('StudentVault State & Calculations', () {
    test('initial state has default allowance and pre-seeded student entries', () {
      final store = MemoryStore();
      final notifier = StudentVaultNotifier(store: store);
      final state = notifier.state;

      expect(state.activePeriod.budgetAmount, 5000.0);
      expect(state.activePeriod.name, 'Monthly Allowance');
      expect(state.transactions.isNotEmpty, true);
      expect(state.topSpots.isNotEmpty, true);
      // Top spots contain Timo and Cascavelle
      final spotNames = state.merchants.map((m) => m.name.toLowerCase()).toList();
      expect(spotNames.contains('timo'), true);
      expect(spotNames.contains('cascavelle'), true);
    });

    test('logExpense decrements remaining budget and updates merchant stats', () async {
      final store = MemoryStore();
      final notifier = StudentVaultNotifier(store: store);

      final initialRemaining = notifier.state.remainingBudget;

      await notifier.logExpense(
        description: 'Timo Double Burger',
        merchantName: 'Timo',
        amount: 200.0,
        category: 'Food & Drinks',
      );

      final updatedState = notifier.state;
      expect(updatedState.remainingBudget, initialRemaining - 200.0);

      final timo = updatedState.merchants.firstWhere(
        (m) => m.name.toLowerCase() == 'timo',
      );
      expect(timo.totalSpent, greaterThanOrEqualTo(200.0));
      expect(timo.visitCount, greaterThanOrEqualTo(1));
    });

    test('mood transitions to Ramen Mode when spend exceeds 80%', () async {
      final store = MemoryStore();
      final notifier = StudentVaultNotifier(store: store);

      // Log a massive purchase that eats up > 80% of Rs 5000 budget
      await notifier.logExpense(
        description: 'New Semester Books',
        merchantName: 'Cascavelle',
        amount: 4200.0,
        category: 'Shopping & Essentials',
      );

      expect(notifier.state.mood, SpendMood.ramenMode);
      expect(notifier.state.moodLabel.contains('Ramen Mode'), true);
    });

    test('deleteExpense removes item and restores allowance', () async {
      final store = MemoryStore();
      final notifier = StudentVaultNotifier(store: store);

      await notifier.logExpense(
        description: 'Accidental Log',
        merchantName: 'Test Spot',
        amount: 500.0,
      );

      final tx = notifier.state.transactions.firstWhere(
        (t) => t.description == 'Accidental Log',
      );
      final beforeDelete = notifier.state.remainingBudget;

      await notifier.deleteExpense(tx.id);

      expect(notifier.state.remainingBudget, beforeDelete + 500.0);
      expect(
        notifier.state.transactions.any((t) => t.id == tx.id),
        false,
      );
    });

    test('resetPeriod archives the previous period and starts fresh slate', () async {
      final store = MemoryStore();
      final notifier = StudentVaultNotifier(store: store);

      final wrap = await notifier.resetPeriod(
        newPeriodName: 'November Allowance',
        newBudgetAmount: 6000.0,
        durationDays: 30,
      );

      final state = notifier.state;
      expect(state.activePeriod.name, 'November Allowance');
      expect(state.activePeriod.budgetAmount, 6000.0);
      expect(state.transactions.isEmpty, true);
      expect(state.archivedPeriods.length, 1);
      expect(wrap['periodName'], 'Monthly Allowance');
    });

    test('setMerchantFilter filters visible transactions', () async {
      final store = MemoryStore();
      final notifier = StudentVaultNotifier(store: store);

      await notifier.logExpense(
        description: 'Snack at Timo',
        merchantName: 'Timo',
        amount: 100.0,
      );
      await notifier.logExpense(
        description: 'Shopping at Cascavelle',
        merchantName: 'Cascavelle',
        amount: 150.0,
      );

      notifier.setMerchantFilter('Timo');
      expect(
        notifier.state.visibleTransactions.every(
          (t) => t.merchantName?.toLowerCase() == 'timo',
        ),
        true,
      );

      // Clearing filter shows all
      notifier.setMerchantFilter('Timo');
      expect(notifier.state.filterMerchant, null);
    });

    test('category budget tracking and progress calculations', () async {
      final store = MemoryStore();
      final notifier = StudentVaultNotifier(store: store);

      // Pre-seeded has Food & Drinks
      final foodBudget = notifier.state.categoryBudgets.firstWhere(
        (b) => b.category == 'Food & Drinks',
      );
      expect(foodBudget.amount, 1800.0);

      // Log food purchase
      await notifier.logExpense(
        description: 'Lunch at Timo',
        merchantName: 'Timo',
        amount: 300.0,
        category: 'Food & Drinks',
      );

      final spent = notifier.state.spentForCategory('Food & Drinks');
      expect(spent, greaterThanOrEqualTo(300.0));

      final progress = notifier.state.progressForCategory(foodBudget);
      expect(progress, greaterThan(0.0));
      expect(progress, lessThanOrEqualTo(1.0));

      // Add a custom student budget: e.g. "Gaming & Chill"
      await notifier.setCategoryBudget(
        category: 'Gaming & Chill',
        amount: 500.0,
        emoji: '🎮',
      );

      final gaming = notifier.state.categoryBudgets.firstWhere(
        (b) => b.category == 'Gaming & Chill',
      );
      expect(gaming.amount, 500.0);
      expect(gaming.emoji, '🎮');

      // Delete budget
      await notifier.deleteCategoryBudget('Gaming & Chill');
      expect(
        notifier.state.categoryBudgets.any((b) => b.category == 'Gaming & Chill'),
        false,
      );
    });

    test('savings pots tracking, deposits, and calculations', () async {
      final store = MemoryStore();
      final notifier = StudentVaultNotifier(store: store);

      expect(notifier.state.savingsPots.isNotEmpty, true);
      final initialTotalSaved = notifier.state.totalSaved;
      expect(initialTotalSaved, greaterThan(0.0));

      final laptopPot = notifier.state.savingsPots.firstWhere((p) => p.name == 'Campus Laptop');
      final beforeDeposit = laptopPot.currentAmount;

      await notifier.depositToSavingsPot(laptopPot.id, 500.0);

      final updatedLaptop = notifier.state.savingsPots.firstWhere((p) => p.id == laptopPot.id);
      expect(updatedLaptop.currentAmount, beforeDeposit + 500.0);
      expect(notifier.state.totalSaved, initialTotalSaved + 500.0);

      // Add a new pot
      await notifier.addSavingsPot('Sneaker Fund', 4000.0, '👟');
      expect(notifier.state.savingsPots.any((p) => p.name == 'Sneaker Fund'), true);

      // Delete pot
      final sneaker = notifier.state.savingsPots.firstWhere((p) => p.name == 'Sneaker Fund');
      await notifier.deleteSavingsPot(sneaker.id);
      expect(notifier.state.savingsPots.any((p) => p.id == sneaker.id), false);
    });
  });
}
