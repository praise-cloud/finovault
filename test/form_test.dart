import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finovault_flutter/core/state/auth.dart';
import 'package:finovault_flutter/screens/auth/login_screen.dart';

import 'test_utils.dart';

void main() {
  testWidgets('login with wrong password surfaces an error message', (tester) async {
    final c = makeContainer();
    // Seed a known account so invalid_credentials (not unauthorized) is returned.
    await c.read(authProvider.notifier).signup('U', 'u@e.com', 'secret123');

    await tester.pumpWidget(
      UncontrolledProviderScope(container: c, child: const MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'u@e.com');
    await tester.enterText(fields.at(1), 'wrong-password');
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.text('Incorrect email or password. Please try again.'), findsOneWidget);
    c.dispose();
  });
}
