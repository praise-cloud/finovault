import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finovault_flutter/widgets/fv_alert_dialog.dart';
import 'package:finovault_flutter/widgets/fv_notification.dart';

void main() {
  group('FvAlertDialog & FvNotification Tests', () {
    testWidgets('FvAlertDialog shows title, message, and handles confirm/cancel', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  result = await FvAlertDialog.showConfirm(
                    ctx,
                    title: 'Delete Purchase?',
                    message: 'Remove this logged item permanently?',
                    confirmLabel: 'YES, DELETE',
                    cancelLabel: 'KEEP',
                    severity: FvAlertSeverity.danger,
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Check content
      expect(find.text('Delete Purchase?'), findsOneWidget);
      expect(find.text('Remove this logged item permanently?'), findsOneWidget);
      expect(find.text('YES, DELETE'), findsOneWidget);
      expect(find.text('KEEP'), findsOneWidget);

      // Tap confirm button
      await tester.tap(find.text('YES, DELETE'));
      await tester.pumpAndSettle();

      expect(result, true);
    });

    testWidgets('FvNotificationCard displays custom message and severity badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FvNotificationCard(
              title: 'Success',
              message: 'Logged expense at Timo (MUR 150)',
              type: FvNotificationType.success,
            ),
          ),
        ),
      );

      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Logged expense at Timo (MUR 150)'), findsOneWidget);
      expect(find.text('✅'), findsOneWidget);
    });
  });
}
