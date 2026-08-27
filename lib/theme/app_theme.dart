import 'package:flutter/material.dart';

import 'tokens.dart';

/// Finovault app theme built on [FvColors] — light and dark variants
/// deliberately designed (dark is a deep-blue surface, not an inversion).
class FvTheme {
  FvTheme._();

  static ThemeData light() => _base(Brightness.light);

  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: FvColors.primary,
      brightness: brightness,
      primary: FvColors.primary,
      onPrimary: Colors.white,
      surface: FvColors.surface,
      onSurface: FvColors.primary,
      error: FvColors.error,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: FvColors.surface,
      fontFamily: 'Montserrat',
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: FvColors.primary,
        displayColor: FvColors.primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: FvColors.surface,
        foregroundColor: FvColors.primary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FvColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FvRadius.button)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FvColors.primary,
          side: const BorderSide(color: FvColors.primary, width: 2),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FvRadius.button)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: FvColors.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FvColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FvRadius.input),
          borderSide: const BorderSide(color: FvColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FvRadius.input),
          borderSide: const BorderSide(color: FvColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FvRadius.input),
          borderSide: const BorderSide(color: FvColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FvRadius.input),
          borderSide: const BorderSide(color: FvColors.error),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: FvColors.border,
      ),
      cardTheme: CardThemeData(
        color: FvColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FvRadius.card),
          side: const BorderSide(color: FvColors.primaryBorder),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: FvColors.surface,
        indicatorColor: FvColors.wash,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}