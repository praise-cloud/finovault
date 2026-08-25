import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finovault_flutter/core/state/notifications.dart';
import 'package:finovault_flutter/screens/tabs/profile_tab.dart';
import 'helpers.dart';

void main() {
  testWidgets('settings switches expose semantic labels and toggle state', (tester) async {
    final c = await makeLoggedInContainer();
    await pumpScreen(tester, const ProfileTab(), container: c);

    // Open the settings sheet.
    await tester.tap(find.byIcon(Icons.tune_outlined));
    await tester.pumpAndSettle();

    // Four labeled switch rows: biometric + 3 notification categories.
    final switches = tester.widgetList<MergeSemantics>(find.byType(MergeSemantics));
    expect(switches.length, 4);

    for (final finder in [
      find.byType(MergeSemantics).at(0),
      find.byType(MergeSemantics).at(1),
      find.byType(MergeSemantics).at(2),
      find.byType(MergeSemantics).at(3),
    ]) {
      final node = tester.getSemantics(finder);
      expect(node.getSemanticsData().label, isNotEmpty, reason: 'switch row must announce its label');
      expect(node.hasFlag(SemanticsFlag.hasToggledState), isTrue,
          reason: 'switch row must expose a toggle state');
    }
  });

  testWidgets('tappable settings rows are announced as buttons', (tester) async {
    final c = await makeLoggedInContainer();
    await pumpScreen(tester, const ProfileTab(), container: c);

    expect(
      tester.getSemantics(find.byIcon(Icons.security_outlined)).hasFlag(SemanticsFlag.isButton),
      isTrue,
    );
  });
}
