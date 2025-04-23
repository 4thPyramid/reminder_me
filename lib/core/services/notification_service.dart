import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInitSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse : _onNotificationTap,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
     AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  'reminder_channel',
  'Link Reminders',
  channelDescription: 'Reminder notifications for saved links',
  importance: Importance.max,
  priority: Priority.high,
  playSound: true,
  enableVibration: true,
  sound: RawResourceAndroidNotificationSound('reminder_sound'),
  vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
  styleInformation: null, // أضف هذا السطر لتجنب التعارض
);


     NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      payload: payload,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _onNotificationTap(NotificationResponse notificationResponse) async {
  final payload = notificationResponse.payload;
  // هنا تتعامل مع الـ payload حسب المطلوب
}

}