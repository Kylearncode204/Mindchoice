import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/health_reminder.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tapped
      },
    );
  }

  Future<void> scheduleHealthReminder(HealthReminder reminder) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'health_reminders',
      'Health Reminders',
      channelDescription: 'Notifications for health reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Schedule notification based on reminder type and interval
    await flutterLocalNotificationsPlugin.periodicallyShow(
      reminder.id,
      reminder.title,
      reminder.description,
      RepeatInterval.hourly, // Customize based on intervalMinutes
      platformChannelSpecifics,
    );
  }

  Future<void> cancelReminder(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> showBlockedAppNotification(String appName) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'blocked_apps',
      'Blocked Apps',
      channelDescription: 'Notifications for blocked applications',
      importance: Importance.max,
      priority: Priority.high,
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Ứng dụng bị chặn',
      'Ứng dụng $appName đã bị chặn theo lịch trình của bạn',
      platformChannelSpecifics,
    );
  }

  Future<void> showTimeLimitNotification(String appName) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'time_limit',
      'Time Limit',
      channelDescription: 'Notifications for time limit warnings',
      importance: Importance.max,
      priority: Priority.high,
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      1,
      'Cảnh báo giới hạn thời gian',
      'Bạn đã đạt đến giới hạn thời gian cho ứng dụng $appName',
      platformChannelSpecifics,
    );
  }
} 