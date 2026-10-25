import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

enum FvNotificationType { info, success, warning, error }

/// Tactile Neo-Brutalist notification toast.
/// Displays a high-contrast floating card with 2px ink black borders and drop shadow.
class FvNotification {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    FvNotificationType type = FvNotificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    HapticFeedback.lightImpact();

    // Use a custom floating snackbar styled cleanly
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          duration: duration,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          padding: EdgeInsets.zero,
          content: FvNotificationCard(
            title: title,
            message: message,
            type: type,
            onClose: () => messenger.hideCurrentSnackBar(),
          ),
        ),
      );
    }
  }
}

class FvNotificationCard extends StatelessWidget {
  const FvNotificationCard({
    super.key,
    required this.message,
    this.title,
    this.type = FvNotificationType.info,
    this.onClose,
  });

  final String message;
  final String? title;
  final FvNotificationType type;
  final VoidCallback? onClose;

  String _icon() {
    return switch (type) {
      FvNotificationType.success => '✅',
      FvNotificationType.warning => '⚠️',
      FvNotificationType.error => '❌',
      FvNotificationType.info => '⚡',
    };
  }

  Color _badgeBg() {
    return switch (type) {
      FvNotificationType.success => const Color(0xFFD1FAE5),
      FvNotificationType.warning => const Color(0xFFFEF3C7),
      FvNotificationType.error => const Color(0xFFFEE2E2),
      FvNotificationType.info => const Color(0xFFF1F5F9),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: FvColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FvColors.ink, width: 2),
        boxShadow: const [
          BoxShadow(
            color: FvColors.ink,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _badgeBg(),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: FvColors.ink, width: 1.2),
            ),
            child: Text(_icon(), style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title!.isNotEmpty) ...[
                  Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: FvColors.ink,
                    ),
                  ),
                  const SizedBox(height: 1),
                ],
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: FvColors.ink,
                  ),
                ),
              ],
            ),
          ),
          if (onClose != null)
            GestureDetector(
              onTap: onClose,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close_rounded, size: 18, color: FvColors.ink),
              ),
            ),
        ],
      ),
    );
  }
}
