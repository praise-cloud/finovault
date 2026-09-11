import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/format.dart';
import '../core/state/preferences.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'vault_mark.dart';

/// Forces the app's light theme below this point. The onboarding / auth flow
/// always renders on a white background, even when the app is in dark mode.
class FvLightTheme extends StatelessWidget {
  const FvLightTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Theme(data: FvTheme.light(), child: child);
}

/// Brightness-aware token shortcuts.
extension FvContext on BuildContext {
  bool get fvIsDark => Theme.of(this).brightness == Brightness.dark;
  Color get fvText => fvIsDark ? FvColors.textDark : FvColors.ink;
  Color get fvTextSecondary =>
      fvIsDark ? FvColors.textSecondaryDark : FvColors.textSecondary;
  Color get fvSurface => fvIsDark ? FvColors.surfaceDark : FvColors.surface;
  Color get fvBorder => fvIsDark ? FvColors.borderDark : FvColors.border;
  Color get fvCardBorder => fvIsDark ? FvColors.textDark : FvColors.ink;
  Color get fvWash => fvIsDark ? FvColors.washDark : FvColors.wash;
  Color get fvSuccess => fvIsDark ? FvColors.successDark : FvColors.success;
  Color get fvError => fvIsDark ? FvColors.errorDark : FvColors.error;
  Color get fvWarning => fvIsDark ? FvColors.warningDark : FvColors.warning;
  Color get fvPrimary => fvIsDark ? FvColors.accentStrong : FvColors.primary;
  List<BoxShadow> get fvCardShadow =>
      fvIsDark ? const [FvShadows.cardDark] : const [FvShadows.card];
  List<BoxShadow> get fvBrutal =>
      fvIsDark ? const [FvShadows.brutalDark] : const [FvShadows.brutal];
  List<BoxShadow> get fvBrutalSm =>
      fvIsDark ? const [FvShadows.brutalDark] : const [FvShadows.brutalSm];

  /// Plain background for every screen (onboarding, auth, home, money).
  BoxDecoration get fvPageDecoration =>
      BoxDecoration(color: fvIsDark ? FvColors.bgDark : FvColors.bg);

  /// Background for onboarding & auth screens — follows the app theme like the
  /// rest of the app (light or dark).
  BoxDecoration get fvOnboardingDecoration =>
      const BoxDecoration(color: Colors.white);
}

/// Shared top bar for pre-auth screens: brand wordmark plus an optional back
/// button. Keeps navigation consistent across onboarding + auth screens.
class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null)
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: context.fvPrimary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onBack,
          ),
        if (onBack != null) const SizedBox(width: 4),
        Text(
          'Finovault',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: context.fvPrimary,
          ),
        ),
      ],
    );
  }
}

class FvButton extends StatelessWidget {
  const FvButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = FvButtonVariant.primary,
    this.loading = false,
    this.expanded = true,
    this.icon,
    this.fill,
    this.foreground,
  });

  final String label;
  final VoidCallback? onPressed;
  final FvButtonVariant variant;

  /// Optional explicit fill so a button can be tinted to its exact function
  /// (e.g. a warning action) without adding a new enum value.
  final Color? fill;
  final Color? foreground;
  final bool loading;
  final bool expanded;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    var (Color bg, Color fg) = switch (variant) {
      FvButtonVariant.primary => (FvColors.primary, Colors.white),
      FvButtonVariant.secondary => (Colors.transparent, context.fvText),
      FvButtonVariant.danger => (FvColors.error, Colors.white),
      FvButtonVariant.ghost => (Colors.transparent, context.fvText),
      FvButtonVariant.success => (FvColors.success, Colors.white),
    };
    var borderColor = switch (variant) {
      FvButtonVariant.danger => context.fvError,
      FvButtonVariant.ghost => Colors.transparent,
      _ => context.fvCardBorder,
    };
    if (fill != null) {
      bg = fill!;
      borderColor = fill!;
      fg = foreground ?? Colors.white;
    }

    final child = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  maxLines: 1,
                ),
              ),
            ],
          );

    final isGhost = variant == FvButtonVariant.ghost;
    final button = Material(
      color: bg,
      borderRadius: BorderRadius.circular(FvRadius.button),
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(FvRadius.button),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: FvSpacing.x5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FvRadius.button),
            border: Border.all(color: borderColor, width: FvBorders.width),
            boxShadow: isGhost ? null : context.fvBrutalSm,
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );

    return Opacity(
      opacity: disabled && !loading ? 0.55 : 1,
      child: expanded
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}

enum FvButtonVariant { primary, secondary, ghost, danger, success }

class FvCard extends StatelessWidget {
  const FvCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.accent,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  /// When set, a 4px brand (or given) top strip is drawn, tying the card to the
  /// Finovault brand while the brutalist ink border + hard shadow remain.
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final a = accent ?? FvColors.primary;
    final inner = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (accent != null) Container(height: 4, color: a),
        Padding(
          padding: padding ?? const EdgeInsets.all(FvSpacing.x4),
          child: child,
        ),
      ],
    );
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: context.fvSurface,
        borderRadius: BorderRadius.circular(FvRadius.card),
        border: Border.all(color: context.fvCardBorder, width: FvBorders.width),
        boxShadow: context.fvBrutal,
      ),
      child: inner,
    );
    if (onTap == null)
      return card.animate().fadeIn(duration: 200.ms, curve: Curves.easeOut);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(FvRadius.card),
        onTap: onTap,
        child: card,
      ),
    ).animate().fadeIn(duration: 200.ms, curve: Curves.easeOut);
  }
}

class FvTextField extends StatelessWidget {
  const FvTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.errorText,
    this.keyboardType,
    this.hint,
    this.enabled = true,
    this.suffix,
    this.maxLines = 1,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final String? errorText;
  final TextInputType? keyboardType;
  final String? hint;
  final bool enabled;
  final Widget? suffix;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: context.fvText,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          enabled: enabled,
          maxLines: maxLines,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: context.fvText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.fvTextSecondary),
            errorText: errorText,
            suffixIcon: suffix,
            filled: true,
            fillColor: context.fvSurface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: FvSpacing.x4,
              vertical: FvSpacing.x3,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FvRadius.input),
              borderSide: BorderSide(
                color: context.fvCardBorder,
                width: FvBorders.width,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FvRadius.input),
              borderSide: BorderSide(
                color: context.fvCardBorder,
                width: FvBorders.width,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FvRadius.input),
              borderSide: BorderSide(
                color: context.fvPrimary,
                width: FvBorders.width,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FvRadius.input),
              borderSide: BorderSide(
                color: context.fvError,
                width: FvBorders.width,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum MoneySize { xl, lg, md, sm }

class MoneyText extends ConsumerWidget {
  const MoneyText(
    this.amount, {
    super.key,
    this.size = MoneySize.md,
    this.color,
    this.signed = false,
    this.currency = 'MUR',
    this.overflow,
    this.maxLines,
  });

  final num amount;
  final MoneySize size;
  final Color? color;
  final bool signed;
  final String currency;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(preferencesProvider).language;
    final text = signed
        ? FvFormat.formatMoneySigned(
            amount,
            currency: currency,
            language: language,
          )
        : FvFormat.formatMoney(amount, currency: currency, language: language);
    final style = switch (size) {
      MoneySize.xl => TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color ?? context.fvText,
      ),
      MoneySize.lg => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color ?? context.fvText,
      ),
      MoneySize.md => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: color ?? context.fvText,
      ),
      MoneySize.sm => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color ?? context.fvTextSecondary,
      ),
    };
    return Text(text, style: style, overflow: overflow, maxLines: maxLines);
  }
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 56,
    this.stroke = 5,
    this.child,
  });

  final double progress; // 0..1
  final double size;
  final double stroke;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: p,
              stroke: stroke,
              track: context.fvBorder,
              arc: context.fvPrimary,
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.stroke,
    required this._track,
    required this.arc,
  });

  final double progress;
  final double stroke;
  final Color _track;
  final Color arc;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = stroke;
    final rect = Offset.zero & size;
    final inset = strokeWidth / 2;
    final arcRect = Rect.fromLTRB(
      rect.left + inset,
      rect.top + inset,
      rect.right - inset,
      rect.bottom - inset,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = _track;
    canvas.drawArc(arcRect, 0, 3.14159 * 2, false, paint);
    if (progress > 0) {
      paint.color = arc;
      canvas.drawArc(
        arcRect,
        -3.14159 / 2,
        3.14159 * 2 * progress,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.stroke != stroke ||
      oldDelegate._track != _track ||
      oldDelegate.arc != arc;
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: FvSpacing.x2, top: FvSpacing.x1),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: FvColors.primary.withValues(alpha: 0.25),
            width: 2,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: FvSpacing.x3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(width: 10, height: 18, color: FvColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: context.fvText,
                ),
              ),
            ),
            if (actionLabel != null)
              GestureDetector(
                onTap: onAction,
                child: Text(
                  actionLabel!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: context.fvPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.body,
    this.ctaLabel,
    this.onCta,
  });

  final String title;
  final String body;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FvSpacing.x8),
      child: Column(
        children: [
          const VaultMark(size: 48, subdued: true),
          const SizedBox(height: FvSpacing.x4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.fvText,
            ),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: context.fvTextSecondary,
              ),
            ),
          ),
          if (ctaLabel != null) ...[
            const SizedBox(height: FvSpacing.x4),
            FvButton(
              label: ctaLabel!,
              onPressed: onCta,
              variant: FvButtonVariant.secondary,
              expanded: false,
            ),
          ],
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

/// Scaffold wrapper for pushed ("money") screens: gradient page, back header.
class ScreenPage extends StatelessWidget {
  const ScreenPage({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FvSpacing.x4,
                FvSpacing.x3,
                FvSpacing.x4,
                FvSpacing.x3,
              ),
              child: Row(
                children: [
                  _BackButton(),
                  const SizedBox(width: FvSpacing.x3),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: context.fvText,
                      ),
                    ),
                  ),
                  ...?actions,
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.fvSurface,
          shape: BoxShape.circle,
          border: Border.all(color: context.fvCardBorder),
        ),
        child: Icon(Icons.arrow_back, size: 18, color: context.fvPrimary),
      ),
    );
  }
}

/// Consistent bottom-sheet form container: title + fields + footer button.
Widget showFormSheet({
  required BuildContext context,
  required String title,
  required List<Widget> children,
  required String submitLabel,
  VoidCallback? onSubmit,
  bool submitEnabled = true,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(FvSpacing.x5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.fvBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: FvSpacing.x4),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.fvText,
            ),
          ),
          const SizedBox(height: FvSpacing.x4),
          ...children,
          const SizedBox(height: FvSpacing.x5),
          FvButton(
            label: submitLabel,
            onPressed: submitEnabled ? onSubmit : null,
          ),
        ],
      ),
    ),
  );
}

Future<T?> pushScreen<T>(BuildContext context, Widget screen) =>
    Navigator.of(context).push<T>(
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => screen,
        transitionsBuilder: (_, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
