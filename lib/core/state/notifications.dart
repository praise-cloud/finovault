import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// User-facing notification preferences.
class NotificationSettings {
  const NotificationSettings({
    this.enabled = false,
    this.billReminders = true,
    this.lowBalance = true,
  });

  final bool enabled;
  final bool billReminders;
  final bool lowBalance;

  NotificationSettings copyWith({bool? enabled, bool? billReminders, bool? lowBalance}) =>
      NotificationSettings(
        enabled: enabled ?? this.enabled,
        billReminders: billReminders ?? this.billReminders,
        lowBalance: lowBalance ?? this.lowBalance,
      );

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'billReminders': billReminders,
        'lowBalance': lowBalance,
      };

  static NotificationSettings fromJson(Map<String, dynamic>? j) => NotificationSettings(
        enabled: (j?['enabled'] as bool?) ?? false,
        billReminders: (j?['billReminders'] as bool?) ?? true,
        lowBalance: (j?['lowBalance'] as bool?) ?? true,
      );
}

const _key = 'finovault.notifications.v1';

class NotificationSettingsController extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() {
    final raw = ref.read(kvStoreProvider).getString(_key);
    return NotificationSettings.fromJson(raw == null ? null : jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _persist() async =>
      ref.read(kvStoreProvider).setString(_key, jsonEncode(state.toJson()));

  Future<void> setEnabled(bool v) async => _persistState(state.copyWith(enabled: v));
  Future<void> setBillReminders(bool v) async => _persistState(state.copyWith(billReminders: v));
  Future<void> setLowBalance(bool v) async => _persistState(state.copyWith(lowBalance: v));

  Future<void> _persistState(NotificationSettings next) async {
    state = next;
    await _persist();
  }
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsController, NotificationSettings>(NotificationSettingsController.new);

/// Placeholder delivery channel. Swap this for `firebase_messaging` /
/// `flutter_local_notifications` later; the UI only depends on this interface so
/// the rest of the app stays decoupled from the transport.
abstract class NotificationService {
  Future<void> notifyBillDue(String biller, DateTime due);
  Future<void> notifyLowBalance(String account, double balance);
}

class DebugNotificationService implements NotificationService {
  final List<String> delivered = [];

  @override
  Future<void> notifyBillDue(String biller, DateTime due) async {
    final msg = 'Bill due: $biller on ${due.toIso8601String().substring(0, 10)}';
    delivered.add(msg);
    // ignore: avoid_print
    print('[notify] $msg');
  }

  @override
  Future<void> notifyLowBalance(String account, double balance) async {
    final msg = 'Low balance on $account: $balance';
    delivered.add(msg);
    // ignore: avoid_print
    print('[notify] $msg');
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) => DebugNotificationService());
