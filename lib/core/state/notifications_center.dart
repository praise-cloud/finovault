import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models.dart';
import '../providers.dart';

class NotificationsState {
  const NotificationsState({this.items = const [], this.loading = true});

  final List<AppNotification> items;
  final bool loading;

  int get unreadCount => items.where((n) => !n.isRead).length;

  NotificationsState copyWith({List<AppNotification>? items, bool? loading}) =>
      NotificationsState(
        items: items ?? this.items,
        loading: loading ?? this.loading,
      );
}

class NotificationsController extends Notifier<NotificationsState> {
  Timer? _timer;

  @override
  NotificationsState build() {
    ref.onDispose(() => _timer?.cancel());
    _startPolling();
    return const NotificationsState();
  }

  void _startPolling() {
    _fetch();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _fetch());
  }

  Future<void> _fetch() async {
    final token = currentToken(ref);
    if (token == null) return;
    try {
      final items = await ref.read(apiProvider).notifications(token);
      state = state.copyWith(items: items, loading: false);
    } catch (_) {
      // swallow errors silently (matches web pattern)
    }
  }

  Future<void> markRead(String notificationId) async {
    final token = currentToken(ref);
    if (token == null) return;
    // Optimistic update
    state = state.copyWith(
      items: [
        for (final n in state.items)
          if (n.id == notificationId && !n.isRead) n.markRead() else n,
      ],
    );
    try {
      await ref
          .read(apiProvider)
          .markNotificationRead(token, notificationId: notificationId);
    } catch (_) {
      _fetch(); // revert on failure
    }
  }

  Future<void> markAllRead() async {
    final token = currentToken(ref);
    if (token == null) return;
    // Optimistic update
    state = state.copyWith(
      items: [
        for (final n in state.items)
          if (n.isRead) n else n.markRead(),
      ],
    );
    try {
      await ref.read(apiProvider).markAllNotificationsRead(token);
    } catch (_) {
      _fetch();
    }
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsController, NotificationsState>(
      NotificationsController.new,
    );
