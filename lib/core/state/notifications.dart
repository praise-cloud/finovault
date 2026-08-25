import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

/// Delivery channel for user alerts. The UI only depends on this interface so
/// the transport stays swappable — `LocalNotificationService` (on-device) today,
/// `firebase_messaging` push later.
abstract class NotificationService {
  /// Platform permission + channel setup. Safe to call once at startup.
  Future<void> initialize();
  Future<void> notifyBillDue(String biller, DateTime due);
  Future<void> notifyLowBalance(String account, double balance);
}

class DebugNotificationService implements NotificationService {
  final List<String> delivered = [];

  @override
  Future<void> initialize() async {}

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

/// Real on-device notifications via `flutter_local_notifications`.
class LocalNotificationService implements NotificationService {
  LocalNotificationService(this._plugin);
  final FlutterLocalNotificationsPlugin _plugin;

  static const String _channelId = 'finovault_alerts';
  static const String _channelName = 'Finovault Alerts';

  bool _ready = false;

  @override
  Future<void> initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );
    await _plugin.initialize(settings: settings);
    // Android 13+ runtime permission.
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _ready = true;
  }

  Future<void> _show(String title, String body) async {
    if (!_ready) return;
    await _plugin.show(
      id: title.hashCode,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  @override
  Future<void> notifyBillDue(String biller, DateTime due) async {
    final date = '${due.year}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}';
    await _show('Bill due soon', '$biller is due on $date');
  }

  @override
  Future<void> notifyLowBalance(String account, double balance) async {
    await _show('Low balance', '$account balance is low: \$${balance.toStringAsFixed(2)}');
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final svc = LocalNotificationService(FlutterLocalNotificationsPlugin());
  // Initialize fires-and-forgets; the app also awaits it at startup.
  svc.initialize();
  return svc;
});
