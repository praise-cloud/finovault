import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'helpers.dart';
import 'package:finovault_flutter/theme/app_theme.dart';
import 'package:finovault_flutter/theme/tokens.dart';
import 'package:finovault_flutter/widgets/ui.dart';
import 'package:finovault_flutter/screens/welcome_screen.dart';
import 'package:finovault_flutter/screens/role_screen.dart';
import 'package:finovault_flutter/screens/onboarding/goals_screen.dart';
import 'package:finovault_flutter/screens/onboarding/link_accounts_screen.dart';
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

/// In light mode every non-button, non-semantic text must be brand-primary:
/// not white (invisible on a white page) and not the old dark/gray tokens.
List<String> findNonBrandText(WidgetTester tester) {
  final out = <String>[];
  for (final t in tester.widgetList<Text>(find.byType(Text))) {
    final color = t.style?.color;
    if (color == null) continue;
    if (_insideButton(tester, t)) continue;
    if (color == FvColors.primary) continue;
    if (color == FvColors.primaryLight) continue;
    if (_semantic.contains(color)) continue;
    out.add(t.data ?? '<no-data>');
  }
  return out;
}

void main() {
  group('onboarding/auth text is brand-primary in light mode', () {
    testWidgets('WelcomeScreen', (tester) async {
      await pumpScreen(tester, const WelcomeScreen(), theme: FvTheme.light(), loggedIn: false);
      expect(findNonBrandText(tester), isEmpty);
    });

    testWidgets('RoleScreen', (tester) async {
      await pumpScreen(tester, const RoleScreen(), theme: FvTheme.light(), loggedIn: false);
      expect(findNonBrandText(tester), isEmpty);
    });

    testWidgets('GoalsScreen', (tester) async {
      await pumpScreen(tester, const GoalsScreen(), theme: FvTheme.light(), loggedIn: false);
      expect(findNonBrandText(tester), isEmpty);
    });

    testWidgets('LinkAccountsScreen', (tester) async {
      await pumpScreen(tester, const LinkAccountsScreen(), theme: FvTheme.light(), loggedIn: false);
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

  group('RoleScreen background', () {
    testWidgets('is white (no brand gradient) in dark mode too', (tester) async {
      await pumpScreen(tester, const RoleScreen(), theme: FvTheme.dark(), loggedIn: false);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      final body = scaffold.body as Container;
      final decoration = body.decoration as BoxDecoration;
      expect(decoration.gradient, isNull);
      expect(decoration.color, Colors.white);
    });

    testWidgets('is white in light mode', (tester) async {
      await pumpScreen(tester, const RoleScreen(), theme: FvTheme.light(), loggedIn: false);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      final body = scaffold.body as Container;
      final decoration = body.decoration as BoxDecoration;
      expect(decoration.gradient, isNull);
      expect(decoration.color, Colors.white);
    });
  });
}
