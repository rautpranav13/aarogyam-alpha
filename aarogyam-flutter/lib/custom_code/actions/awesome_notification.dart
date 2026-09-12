// Automatic FlutterFlow imports
// Imports other custom actions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!

import 'package:awesome_notifications/awesome_notifications.dart';

Future awesomeNotification(
    int? idMorning,
    String? morningTitle,
    String? morningMessage,
    int? morningHour,
    int? morningMinute,
    bool? morningturnedOn) async {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'tap_in_notification',
        channelName: 'TapIn Notification',
        channelDescription: 'tap_in',
        importance: NotificationImportance.High,
        channelShowBadge: true,
        locked: false,
      ),
    ],
  );
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  String localTimeZone =
      await AwesomeNotifications().getLocalTimeZoneIdentifier();

  if (morningturnedOn == true) {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: idMorning!,
            channelKey: 'tap_in_notification',
            title: morningTitle,
            body: morningMessage),
        schedule: NotificationCalendar(
            hour: morningHour,
            minute: morningMinute,
            second: 00,
            timeZone: localTimeZone,
            preciseAlarm: true,
            repeats: true));

    print('Reminder set for $morningHour:$morningMinute');
  }
  if (morningturnedOn == false) {
    await AwesomeNotifications().cancel(idMorning!);
    print('Reminder cancelled for $morningHour:$morningMinute');
  }
}
