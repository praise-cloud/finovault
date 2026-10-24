import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finovault_flutter/core/models.dart';
import 'package:finovault_flutter/widgets/student_vault/feed_item_card.dart';
import 'package:finovault_flutter/widgets/student_vault/edit_expense_modal.dart';

void main() {
  group('FeedItemCard and EditExpenseModal', () {
    final testTx = Transaction(
      id: 'tx_test_1',
      accountId: 'acc_student',
      amount: 150.0,
      direction: TransactionDirection.out,
      category: 'Food & Drinks',
      date: DateTime(2024, 10, 24, 12, 30),
      merchantName: 'Timo',
      description: 'Burger & Fries',
    );

    testWidgets('FeedItemCard triggers onTap callback when clicked', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedItemCard(
              transaction: testTx,
              onDelete: () {},
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Burger & Fries'), findsOneWidget);
      expect(find.text('Timo'), findsOneWidget);

      await tester.tap(find.text('Burger & Fries'));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('EditExpenseModal pre-fills values and invokes onSave with updated values', (tester) async {
      String? savedDesc;
      String? savedMerchant;
      double? savedAmount;
      String? savedCat;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditExpenseModal(
              transaction: testTx,
              currency: 'MUR',
              onSave: ({
                required String id,
                String? description,
                String? merchantName,
                double? amount,
                String? category,
                DateTime? date,
              }) async {
                savedDesc = description;
                savedMerchant = merchantName;
                savedAmount = amount;
                savedCat = category;
              },
            ),
          ),
        ),
      );

      // Verify header and pre-filled fields
      expect(find.text('EDIT PURCHASE'), findsOneWidget);
      expect(find.text('Burger & Fries'), findsOneWidget);
      expect(find.text('Timo'), findsOneWidget);
      expect(find.text('150'), findsOneWidget);

      // Change description
      await tester.enterText(find.widgetWithText(TextField, 'Burger & Fries'), 'Double Cheeseburger');
      // Change amount
      await tester.enterText(find.widgetWithText(TextField, '150'), '220');

      // Tap SAVE CHANGES button
      await tester.tap(find.text('SAVE CHANGES'));
      await tester.pump();

      expect(savedDesc, 'Double Cheeseburger');
      expect(savedAmount, 220.0);
      expect(savedMerchant, 'Timo');
      expect(savedCat, 'Food & Drinks');
    });

    testWidgets('EditExpenseModal quick spot chip updates merchant name', (tester) async {
      String? savedMerchant;
      String? savedCat;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditExpenseModal(
              transaction: testTx,
              currency: 'MUR',
              onSave: ({
                required String id,
                String? description,
                String? merchantName,
                double? amount,
                String? category,
                DateTime? date,
              }) async {
                savedMerchant = merchantName;
                savedCat = category;
              },
            ),
          ),
        ),
      );

      // Tap quick spot Cascavelle
      await tester.tap(find.text('🛍️ Cascavelle'));
      await tester.pump();

      // Tap SAVE CHANGES
      await tester.tap(find.text('SAVE CHANGES'));
      await tester.pump();

      expect(savedMerchant, 'Cascavelle');
      expect(savedCat, 'Shopping & Essentials');
    });
  });
}
