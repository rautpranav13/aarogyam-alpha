// Aarogyam — awesome_notification.dart (rewritten with flutter_local_notifications)
// Schedules daily repeating notifications at a specific time.

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

final FlutterLocalNotificationsPlugin _flnp =
    FlutterLocalNotificationsPlugin();

bool _initialized = false;

Future<void> _ensureInit() async {
  if (_initialized) return;
  tz.initializeTimeZones();

  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const initSettings =
      InitializationSettings(android: androidSettings, iOS: iosSettings);
  await _flnp.initialize(initSettings);
  _initialized = true;
}

const AndroidNotificationDetails _androidDetails = AndroidNotificationDetails(
  'aarogyam_reminder',
  'Aarogyam Reminders',
  channelDescription: 'Daily medication reminder notifications',
  importance: Importance.high,
  priority: Priority.high,
  showWhen: true,
);

const NotificationDetails _notificationDetails =
    NotificationDetails(android: _androidDetails);

Future<void> awesomeNotification(
  int? idMorning,
  String? morningTitle,
  String? morningMessage,
  int? morningHour,
  int? morningMinute,
  bool? morningturnedOn,
) async {
  await _ensureInit();

  final id = idMorning ?? 0;
  final hour = morningHour ?? 8;
  final minute = morningMinute ?? 0;

  if (morningturnedOn == true) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _flnp.zonedSchedule(
      id,
      morningTitle ?? 'Aarogyam Reminder',
      morningMessage ?? 'Time to take your medication!',
      scheduled,
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeats daily
    );
    debugPrint('[Notification] Scheduled id=$id at $hour:$minute');
  } else if (morningturnedOn == false) {
    await _flnp.cancel(id);
    debugPrint('[Notification] Cancelled id=$id');
  }
}
