// Aarogyam — immediate_notification.dart (rewritten with flutter_local_notifications)

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;

final FlutterLocalNotificationsPlugin _flnpImmediate =
    FlutterLocalNotificationsPlugin();

bool _immediateInitialized = false;

Future<void> _ensureImmediateInit() async {
  if (_immediateInitialized) return;
  tz.initializeTimeZones();
  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const initSettings =
      InitializationSettings(android: androidSettings, iOS: iosSettings);
  await _flnpImmediate.initialize(initSettings);
  _immediateInitialized = true;
}

Future<void> immediateNotification(
  int? notificationId,
  String? title,
  String? message,
) async {
  await _ensureImmediateInit();

  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'aarogyam_immediate',
      'Aarogyam Alerts',
      channelDescription: 'Immediate in-app alerts',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  await _flnpImmediate.show(
    notificationId ?? 0,
    title ?? 'Aarogyam',
    message ?? '',
    details,
  );
  debugPrint('[Notification] Immediate: $title — $message');
}
