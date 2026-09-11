import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models.dart';
import '../core/state/notifications_center.dart';
import '../l10n/app_localizations.dart';
import '../theme/tokens.dart';
import 'ui.dart';

/// Bell icon with unread count badge + tap opens notification bottom sheet.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    final unread = state.unreadCount;

    return GestureDetector(
      onTap: () => _openPanel(context),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: context.fvSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: context.fvCardBorder),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 20,
              color: context.fvPrimary,
            ),
            if (unread > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: FvColors.error,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: context.fvSurface, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationPanel(),
    );
  }
}

// ---- Bottom sheet panel --------------------------------------------------------

class NotificationPanel extends ConsumerWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    final s = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (ctx, scrollController) => Container(
        decoration: BoxDecoration(
          color: context.fvSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
          border: Border(
            top: BorderSide(
              width: FvBorders.width,
              color: context.fvCardBorder,
            ),
            left: BorderSide(
              width: FvBorders.width,
              color: context.fvCardBorder,
            ),
            right: BorderSide(
              width: FvBorders.width,
              color: context.fvCardBorder,
            ),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: context.fvBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: FvSpacing.x5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      s.notifications,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: context.fvText,
                      ),
                    ),
                  ),
                  if (state.items.any((n) => !n.isRead))
                    TextButton(
                      onPressed: () => ref
                          .read(notificationsProvider.notifier)
                          .markAllRead(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        s.markAllRead,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.fvPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Content
            Expanded(
              child: state.loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: context.fvPrimary,
                      ),
                    )
                  : state.items.isEmpty
                  ? _EmptyState(s: s)
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: FvSpacing.x5,
                      ),
                      itemCount: state.items.length,
                      itemBuilder: (_, i) => _NotificationItem(
                        notification: state.items[i],
                        onTap: () {
                          ref
                              .read(notificationsProvider.notifier)
                              .markRead(state.items[i].id);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Empty state ---------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.s});
  final AppLocalizations s;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none, size: 48, color: context.fvBorder),
          const SizedBox(height: FvSpacing.x3),
          Text(
            s.noNotifications,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.fvText,
            ),
          ),
          const SizedBox(height: FvSpacing.x1),
          Text(
            s.noNotificationsBody,
            style: TextStyle(fontSize: 13, color: context.fvTextSecondary),
          ),
        ],
      ),
    );
  }
}

// ---- Single notification item ---------------------------------------------------

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({required this.notification, required this.onTap});
  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cfg = _typeConfig(context, notification.type);
    final s = AppLocalizations.of(context);

    return GestureDetector(
      onTap: notification.isRead ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(FvSpacing.x3),
        decoration: BoxDecoration(
          color: cfg.$2,
          border: Border.all(
            width: FvBorders.width,
            color: notification.isRead
                ? context.fvBorder
                : context.fvCardBorder,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.fvSurface,
                border: Border.all(width: 1.5, color: context.fvCardBorder),
              ),
              alignment: Alignment.center,
              child: Icon(cfg.$1, size: 16, color: context.fvText),
            ),
            const SizedBox(width: FvSpacing.x3),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: notification.isRead
                          ? FontWeight.w500
                          : FontWeight.w700,
                      color: context.fvText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.fvTextSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: FvSpacing.x2),
            // Time + unread dot
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: const BoxDecoration(
                      color: FvColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  _relativeTime(notification.createdAt, s),
                  style: TextStyle(
                    fontSize: 10,
                    color: context.fvTextSecondary,
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

// ---- Helpers -------------------------------------------------------------------

/// (icon, tinted background) per notification type — mirrors web TYPE_CONFIG.
(IconData, Color) _typeConfig(BuildContext context, NotificationType type) =>
    switch (type) {
      NotificationType.transfer => (Icons.arrow_outward, FvColors.successBg),
      NotificationType.bill => (Icons.receipt_long, FvColors.warningBg),
      NotificationType.security => (
        Icons.warning_amber_outlined,
        FvColors.warningBg,
      ),
      NotificationType.goal => (Icons.emoji_events_outlined, context.fvWash),
      NotificationType.system => (Icons.notifications_outlined, context.fvWash),
    };

String _relativeTime(DateTime dt, AppLocalizations s) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return s.timeJustNow;
  if (diff.inHours < 1) return s.timeMinutes(diff.inMinutes);
  if (diff.inDays < 1) return s.timeHours(diff.inHours);
  return s.timeDays(diff.inDays);
}
