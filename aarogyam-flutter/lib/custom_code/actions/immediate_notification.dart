// Automatic FlutterFlow imports
// Imports other custom actions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!

import 'package:awesome_notifications/awesome_notifications.dart';

Future<void> immediateNotification(
    int? notificationId, String? title, String? message) async {
  // Initialize the notification channel
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'tap_in_notification',
        channelName: 'TapIn Notification',
        channelDescription: 'Notifications for TapIn app',
        importance: NotificationImportance.High,
        channelShowBadge: true,
        locked: false,
      ),
    ],
  );

  // Check if notification permissions are granted
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      // Request permission to send notifications if not allowed
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  // Send the immediate notification
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: notificationId ?? 0, // Default ID to 0 if null
      channelKey: 'tap_in_notification',
      title: title,
      body: message,
    ),
  );

  print('Immediate notification sent: $title - $message');
}
