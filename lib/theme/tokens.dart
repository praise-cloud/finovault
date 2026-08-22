import 'package:flutter/material.dart';

/// Finovault design tokens — mirrors finovault-web/app/globals.css and
/// lib/theme/tokens.ts. Single source of truth for the blue/light-blue brand.
class FvColors {
  FvColors._();

  // Brand
  static const primary = Color(0xFF1D4ED8);
  static const primaryLight = Color(0xFF3B82F6);
  static const accent = Color(0xFF7DD3FC);
  static const accentStrong = Color(0xFF38BDF8);
  static const wash = Color(0xFFEFF6FF);
  static const secondary = Color(0xFF0F2557);

  // Neutrals (light)
  static const bg = Color(0xFFF7FAFF);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF43474D);
  static const border = Color(0xFFC8D3E8);
  static const primaryBorder = Color(0x2E1D4ED8); // rgba(29,78,216,0.18)

  // Neutrals (dark)
  static const bgDark = Color(0xFF0F2557);
  static const surfaceDark = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const surfaceGlassDark = Color(0x1AFFFFFF); // rgba(255,255,255,0.10)
  static const textDark = Color(0xFFFFFFFF);
  static const textSecondaryDark = Color(0xFFB8C4DC);
  static const borderDark = Color(0x26FFFFFF); // rgba(255,255,255,0.15)
  static const primaryBorderDark = Color(0x407DD3FC); // rgba(125,211,252,0.25)

  // Semantic
  static const success = Color(0xFF2E7D5B);
  static const warning = Color(0xFFC99A2E);
  static const error = Color(0xFF8C3A3A);
  static const errorBg = Color(0x1F8C3A3A); // rgba(140,58,58,0.12)
  static const successBg = Color(0x1F2E7D5B); // rgba(46,125,91,0.12)
  static const warningBg = Color(0x1FC99A2E); // rgba(201,154,46,0.12)

  // Blue hero gradient
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, primary],
  );
}

class FvRadius {
  FvRadius._();
  static const card = 14.0;
  static const button = 12.0;
  static const input = 10.0;
  static const badge = 8.0;
  static const iconContainer = 12.0;
}

class FvSpacing {
  FvSpacing._();
  static const x1 = 4.0;
  static const x2 = 8.0;
  static const x3 = 12.0;
  static const x4 = 16.0;
  static const x5 = 20.0;
  static const x6 = 24.0;
  static const x8 = 32.0;
  static const x10 = 40.0;
  static const x12 = 48.0;
}

class FvShadows {
  FvShadows._();
  static const card = BoxShadow(
    color: Color(0x141D4ED8), // rgba(15,37,87,0.08)
    blurRadius: 24,
    offset: Offset(0, 4),
  );
  static const cardDark = BoxShadow(
    color: Color(0x59000000),
    blurRadius: 24,
    offset: Offset(0, 4),
  );
}