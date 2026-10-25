import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

enum FvAlertSeverity { info, warning, danger, success }

/// Neo-Brutalist high-contrast dialog.
/// Displays a high-contrast modal with 2.5px ink black borders and hard offset shadow.
class FvAlertDialog extends StatelessWidget {
  const FvAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'CONFIRM',
    this.cancelLabel = 'CANCEL',
    this.onConfirm,
    this.onCancel,
    this.severity = FvAlertSeverity.info,
    this.isConfirm = true,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final FvAlertSeverity severity;
  final bool isConfirm;

  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'CONFIRM',
    String cancelLabel = 'CANCEL',
    FvAlertSeverity severity = FvAlertSeverity.info,
  }) async {
    HapticFeedback.mediumImpact();
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => FvAlertDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        severity: severity,
        isConfirm: true,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
    return res ?? false;
  }

  static Future<void> showAlert(
    BuildContext context, {
    required String title,
    required String message,
    String buttonLabel = 'GOT IT',
    FvAlertSeverity severity = FvAlertSeverity.info,
  }) async {
    HapticFeedback.lightImpact();
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => FvAlertDialog(
        title: title,
        message: message,
        confirmLabel: buttonLabel,
        severity: severity,
        isConfirm: false,
        onConfirm: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  String _severityIcon() {
    return switch (severity) {
      FvAlertSeverity.info => '💡',
      FvAlertSeverity.warning => '⚠️',
      FvAlertSeverity.danger => '🗑️',
      FvAlertSeverity.success => '✅',
    };
  }

  Color _severityBg() {
    return switch (severity) {
      FvAlertSeverity.info => const Color(0xFFF1F5F9),
      FvAlertSeverity.warning => const Color(0xFFFEF3C7),
      FvAlertSeverity.danger => const Color(0xFFFEE2E2),
      FvAlertSeverity.success => const Color(0xFFD1FAE5),
    };
  }

  Color _confirmBtnColor() {
    return switch (severity) {
      FvAlertSeverity.danger => const Color(0xFFEF4444),
      FvAlertSeverity.warning => const Color(0xFFD97706),
      FvAlertSeverity.success => const Color(0xFF059669),
      FvAlertSeverity.info => FvColors.ink,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: FvColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: FvColors.ink, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: FvColors.ink,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _severityBg(),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: FvColors.ink, width: 1.5),
                  ),
                  child: Text(
                    _severityIcon(),
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: FvColors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Message text
            Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: FvColors.textSecondary,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 22),

            // Actions row
            Row(
              children: [
                if (isConfirm) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: FvColors.ink,
                        backgroundColor: FvColors.surface,
                        side: const BorderSide(color: FvColors.ink, width: 1.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        cancelLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: Colors.white,
                      backgroundColor: _confirmBtnColor(),
                      elevation: 0,
                      side: const BorderSide(color: FvColors.ink, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
