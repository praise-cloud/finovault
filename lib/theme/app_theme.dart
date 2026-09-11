import 'package:flutter/material.dart';

import 'tokens.dart';

/// Finovault app theme built on [FvColors] — light and dark variants
/// deliberately designed (dark is a deep-blue surface, not an inversion).
class FvTheme {
  FvTheme._();

  static ThemeData light() => _base(Brightness.light);

  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: FvColors.primary,
      brightness: brightness,
      primary: FvColors.primary,
      onPrimary: Colors.white,
      surface: dark ? FvColors.bgDark : FvColors.surface,
      onSurface: dark ? FvColors.textDark : FvColors.ink,
      error: dark ? FvColors.errorDark : FvColors.error,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? FvColors.bgDark : FvColors.bg,
      fontFamily: 'Montserrat',
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: dark ? FvColors.textDark : FvColors.ink,
        displayColor: dark ? FvColors.textDark : FvColors.ink,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? FvColors.surfaceDark : FvColors.surface,
        foregroundColor: dark ? FvColors.textDark : FvColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FvColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FvRadius.button),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: dark ? FvColors.accentStrong : FvColors.primary,
          side: BorderSide(
            color: dark ? FvColors.accentStrong : FvColors.primary,
            width: 2,
          ),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FvRadius.button),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: dark ? FvColors.accentStrong : FvColors.primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? FvColors.surfaceDark : FvColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FvRadius.input),
          borderSide: BorderSide(
            color: dark ? FvColors.borderDark : FvColors.ink,
            width: FvBorders.width,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FvRadius.input),
          borderSide: BorderSide(
            color: dark ? FvColors.borderDark : FvColors.ink,
            width: FvBorders.width,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FvRadius.input),
          borderSide: BorderSide(
            color: dark ? FvColors.accentStrong : FvColors.primary,
            width: FvBorders.width,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FvRadius.input),
          borderSide: BorderSide(
            color: dark ? FvColors.errorDark : FvColors.error,
            width: FvBorders.width,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: dark ? FvColors.borderDark : FvColors.border,
      ),
      cardTheme: CardThemeData(
        color: dark ? FvColors.surfaceDark : FvColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FvRadius.card),
          side: BorderSide(
            color: dark ? FvColors.textDark : FvColors.ink,
            width: FvBorders.width,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? FvColors.surfaceDark : FvColors.surface,
        indicatorColor: dark ? FvColors.washDark : FvColors.wash,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FvRadius.card),
        ),
      ),
    );
  }
}
