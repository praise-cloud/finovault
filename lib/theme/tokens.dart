import 'package:flutter/material.dart';

import '../core/models.dart';

/// Finovault design tokens — mirrors finovault-web/app/globals.css and
/// lib/theme/tokens.ts. Single source of truth for the blue/light-blue brand.
class FvColors {
  FvColors._();

  // Brutalist ink — borders, headings and hard offset shadows
  static const ink = Color(0xFF0A0A0A);

  // Brand
  static const primary = Color(0xFF1D4ED8);
  static const primaryLight = Color(0xFF3B82F6);
  static const accent = Color(0xFF7DD3FC);
  static const accentStrong = Color(0xFF38BDF8);
  static const wash = Color(0xFFEFF6FF);
  static const secondary = Color(0xFF0F2557);

  // Neutrals (light)
  static const bg = Color(0xFFF3F1EA);
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

  /// Subtle brand-blue wash for dark surfaces (~15% primaryLight tint).
  static const washDark = Color(0x263B82F6);

  // Semantic (light)
  static const success = Color(0xFF2E7D5B);
  static const warning = Color(0xFFC99A2E);
  static const error = Color(0xFF8C3A3A);
  static const errorBg = Color(0x1F8C3A3A); // rgba(140,58,58,0.12)
  static const successBg = Color(0x1F2E7D5B); // rgba(46,125,91,0.12)
  static const warningBg = Color(0x1FC99A2E); // rgba(201,154,46,0.12)

  // Semantic (dark) — lighter variants for contrast on deep-blue surfaces
  static const successDark = Color(0xFF4ADE80);
  static const warningDark = Color(0xFFFBBF24);
  static const errorDark = Color(0xFFF87171);

  // Blue hero gradient
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, primary],
  );

  // ---- category palette ------------------------------------------------------
  /// Distinct hue per spending/income category so charts, legends and
  /// transaction rows stay colour-coded and scannable.
  static const categoryPalette = <String, Color>{
    'salary': Color(0xFF2E7D5B),
    'invoice': Color(0xFF1D4ED8),
    'client payment': Color(0xFF0E9F6E),
    'groceries': Color(0xFF16A34A),
    'transport': Color(0xFF0EA5E9),
    'rent': Color(0xFF7C3AED),
    'utilities': Color(0xFFC99A2E),
    'software': Color(0xFFE17055),
    'payroll': Color(0xFFA29BFE),
    'marketing': Color(0xFFFDCB6E),
    'supplies': Color(0xFF55EFC4),
    'dining': Color(0xFFE84393),
    'tax': Color(0xFF8C3A3A),
    'fees': Color(0xFF64748B),
    'other': Color(0xFF64748B),
  };

  static Color categoryColor(String category) =>
      categoryPalette[category.toLowerCase()] ?? categoryPalette['other']!;

  // ---- per-role accent -------------------------------------------------------
  /// Each persona gets its own accent colour, used for hero cards, chips and
  /// the coach FAB so every role feels visually distinct.
  static const roleAccentMap = <PrimaryRole, Color>{
    PrimaryRole.individual: Color(0xFF1D4ED8),
    PrimaryRole.freelancer: Color(0xFF7C3AED),
    PrimaryRole.entrepreneur: Color(0xFF0F766E),
    PrimaryRole.sme: Color(0xFFB45309),
  };

  static Color roleAccent(PrimaryRole role) => roleAccentMap[role] ?? primary;

  static LinearGradient roleGradient(PrimaryRole role) {
    final a = roleAccent(role);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [a, a.withValues(alpha: 0.55)],
    );
  }

  static const successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E7D5B), Color(0xFF38BDF8)],
  );
}

class FvRadius {
  FvRadius._();
  static const card = 0.0;
  static const button = 0.0;
  static const input = 0.0;
  static const badge = 0.0;
  static const iconContainer = 0.0;
  static const pill = 999.0;
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

  /// Neo-brutalist hard shadow: solid offset, no blur.
  static const brutal = BoxShadow(
    color: Color(0xFF0A0A0A),
    blurRadius: 0,
    offset: Offset(5, 5),
  );
  static const brutalSm = BoxShadow(
    color: Color(0xFF0A0A0A),
    blurRadius: 0,
    offset: Offset(3, 3),
  );
  static const brutalDark = BoxShadow(
    color: Color(0xFF000000),
    blurRadius: 0,
    offset: Offset(5, 5),
  );
}

/// Thick, hard borders used across the brutalist UI.
class FvBorders {
  FvBorders._();
  static const width = 2.5;
  static const ink = BorderSide(width: width, color: FvColors.ink);
  static const primary = BorderSide(width: width, color: FvColors.primary);
  static const card = BorderSide(width: width, color: FvColors.ink);
  static const cardDark = BorderSide(width: width, color: FvColors.textDark);
}
