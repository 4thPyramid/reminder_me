import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../../features/reminder/data/models/reminder_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Set the local timezone explicitly (e.g., using a default or device timezone)
    final String timeZoneName = await _getDeviceTimeZone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Initialize notification plugin
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
  }

  Future<String> _getDeviceTimeZone() async {
    // Fallback to a default timezone if needed (e.g., 'UTC')
    return 'UTC'; // You can use a package like `flutter_native_timezone` for accurate device timezone
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    // Ensure initialization before scheduling
    await init();

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Link Reminders',
      channelDescription: 'Reminder notifications for saved links',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      sound: const RawResourceAndroidNotificationSound('reminder_sound'),
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

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

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> _onNotificationTap(
    NotificationResponse notificationResponse,
  ) async {
    final payload = notificationResponse.payload;
    if (payload != null) {
      final reminderBox = Hive.box<ReminderModel>('remindersBox');
      final reminder = reminderBox.values.firstWhere(
        (r) => r.id == payload,
        orElse: () => null as ReminderModel,
      );
      if (reminder != null) {
        // Optionally, open the URL using url_launcher
        // await launchUrl(Uri.parse(reminder.url));
        print(
          'Notification tapped for reminder: ${reminder.title}, URL: ${reminder.url}',
        );
      }
    }
  }
}
