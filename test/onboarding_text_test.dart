import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'helpers.dart';
import 'package:finovault_flutter/theme/app_theme.dart';
import 'package:finovault_flutter/theme/tokens.dart';
import 'package:finovault_flutter/widgets/ui.dart';
import 'package:finovault_flutter/screens/welcome_screen.dart';
import 'package:finovault_flutter/screens/auth/login_screen.dart';
import 'package:finovault_flutter/screens/auth/signup_screen.dart';

/// True if [textWidget] is rendered inside an [FvButton] (its label color is
/// intentionally white/brand on a filled background — not our concern).
bool _insideButton(WidgetTester tester, Text textWidget) {
  try {
    final matches = tester.widgetList(
      find.descendant(
        of: find.byType(FvButton),
        matching: find.byWidget(textWidget),
      ),
    );
    return matches.isNotEmpty;
  } catch (_) {
    return false;
  }
}

/// Semantic colors that are intentionally not brand-primary (status, errors).
final _semantic = {
  FvColors.success,
  FvColors.warning,
  FvColors.error,
  FvColors.errorBg,
  FvColors.successBg,
  FvColors.warningBg,
};

/// In light mode every non-button, non-semantic text must use the brand ink
/// (brutalist default) or brand-primary — never invisible white on a white page
/// and never the old dark/gray tokens.
List<String> findNonBrandText(WidgetTester tester) {
  final out = <String>[];
  for (final t in tester.widgetList<Text>(find.byType(Text))) {
    final color = t.style?.color;
    if (color == null) continue;
    if (_insideButton(tester, t)) continue;
    if (color == FvColors.primary) continue;
    if (color == FvColors.primaryLight) continue;
    if (color == FvColors.ink) continue;
    if (color == FvColors.text) continue;
    if (color == FvColors.textSecondary) continue;
    if (_semantic.contains(color)) continue;
    out.add(t.data ?? '<no-data>');
  }
  return out;
}

void main() {
  group('auth text is brand-primary in light mode', () {
    testWidgets('WelcomeScreen', (tester) async {
      await pumpScreen(tester, const WelcomeScreen(), theme: FvTheme.light(), loggedIn: false);
      expect(findNonBrandText(tester), isEmpty);
    });

    testWidgets('LoginScreen', (tester) async {
      await pumpScreen(tester, const LoginScreen(), theme: FvTheme.light(), loggedIn: false);
      expect(findNonBrandText(tester), isEmpty);
    });

    testWidgets('SignupScreen', (tester) async {
      await pumpScreen(tester, const SignupScreen(), theme: FvTheme.light(), loggedIn: false);
      expect(findNonBrandText(tester), isEmpty);
    });
  });
}
