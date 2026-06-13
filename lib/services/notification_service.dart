import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Notification channel IDs.
class NotifChannel {
  static const wellness = 'wellness_reminder';
  static const appointment = 'appointment_reminder';
  static const weeklyUpdate = 'weekly_update';
}

/// Manages local notifications for the app.
class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification system. Safe to call multiple times.
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;

    if (!kIsWeb && Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        await android.createNotificationChannel(
          const AndroidNotificationChannel(
            NotifChannel.wellness,
            'Wellness Reminders',
            description: 'Daily wellness check-in reminders',
            importance: Importance.defaultImportance,
          ),
        );
        await android.createNotificationChannel(
          const AndroidNotificationChannel(
            NotifChannel.appointment,
            'Appointment Reminders',
            description: 'Prenatal appointment reminders',
            importance: Importance.high,
          ),
        );
        await android.createNotificationChannel(
          const AndroidNotificationChannel(
            NotifChannel.weeklyUpdate,
            'Weekly Updates',
            description: 'Weekly pregnancy development updates',
            importance: Importance.defaultImportance,
          ),
        );
      }
    }
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }

    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  Future<void> scheduleDailyWellness({
    required int hour,
    required int minute,
  }) async {
    await _plugin.zonedSchedule(
      100,
      'Daily Wellness',
      'Time to log your water, vitamin & mood!',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          NotifChannel.wellness,
          'Wellness Reminders',
          channelDescription: 'Daily wellness check-in reminders',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleWeeklyUpdate({
    required int weekday,
    required int hour,
  }) async {
    await _plugin.zonedSchedule(
      200,
      'Weekly Update',
      'See what\'s new with your baby this week!',
      _nextInstanceOfWeekday(weekday, hour),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          NotifChannel.weeklyUpdate,
          'Weekly Updates',
          channelDescription: 'Weekly pregnancy development updates',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> scheduleAppointmentReminder({
    required int id,
    required String title,
    required DateTime appointmentTime,
  }) async {
    final reminderTime =
        appointmentTime.subtract(const Duration(hours: 1));
    if (reminderTime.isBefore(DateTime.now())) return;

    final tzTime = tz.TZDateTime.from(reminderTime, tz.local);

    await _plugin.zonedSchedule(
      300 + id.hashCode,
      'Upcoming: $title',
      'Your appointment is in 1 hour',
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          NotifChannel.appointment,
          'Appointment Reminders',
          channelDescription: 'Prenatal appointment reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day,
        hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour) {
    var date = _nextInstanceOfTime(hour, 0);
    while (date.weekday != weekday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }
}
