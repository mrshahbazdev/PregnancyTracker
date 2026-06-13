import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/local_store.dart';

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

    // Create Android notification channels.
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

  /// Schedule a daily wellness reminder.
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
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule a weekly pregnancy update.
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
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Schedule a one-time appointment reminder (1 hour before).
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
    );
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Cancel a specific notification by ID.
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

// ---- Notification preferences (persisted) ----

class NotificationPrefs {
  const NotificationPrefs({
    this.wellnessEnabled = false,
    this.wellnessHour = 9,
    this.wellnessMinute = 0,
    this.weeklyEnabled = false,
    this.weeklyDay = DateTime.monday,
    this.weeklyHour = 10,
    this.appointmentEnabled = true,
  });

  final bool wellnessEnabled;
  final int wellnessHour;
  final int wellnessMinute;
  final bool weeklyEnabled;
  final int weeklyDay;
  final int weeklyHour;
  final bool appointmentEnabled;

  NotificationPrefs copyWith({
    bool? wellnessEnabled,
    int? wellnessHour,
    int? wellnessMinute,
    bool? weeklyEnabled,
    int? weeklyDay,
    int? weeklyHour,
    bool? appointmentEnabled,
  }) =>
      NotificationPrefs(
        wellnessEnabled: wellnessEnabled ?? this.wellnessEnabled,
        wellnessHour: wellnessHour ?? this.wellnessHour,
        wellnessMinute: wellnessMinute ?? this.wellnessMinute,
        weeklyEnabled: weeklyEnabled ?? this.weeklyEnabled,
        weeklyDay: weeklyDay ?? this.weeklyDay,
        weeklyHour: weeklyHour ?? this.weeklyHour,
        appointmentEnabled: appointmentEnabled ?? this.appointmentEnabled,
      );

  Map<String, dynamic> toJson() => {
        'wellnessEnabled': wellnessEnabled,
        'wellnessHour': wellnessHour,
        'wellnessMinute': wellnessMinute,
        'weeklyEnabled': weeklyEnabled,
        'weeklyDay': weeklyDay,
        'weeklyHour': weeklyHour,
        'appointmentEnabled': appointmentEnabled,
      };

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) =>
      NotificationPrefs(
        wellnessEnabled: json['wellnessEnabled'] as bool? ?? false,
        wellnessHour: json['wellnessHour'] as int? ?? 9,
        wellnessMinute: json['wellnessMinute'] as int? ?? 0,
        weeklyEnabled: json['weeklyEnabled'] as bool? ?? false,
        weeklyDay: json['weeklyDay'] as int? ?? DateTime.monday,
        weeklyHour: json['weeklyHour'] as int? ?? 10,
        appointmentEnabled: json['appointmentEnabled'] as bool? ?? true,
      );
}

/// Riverpod provider for notification preferences + scheduling.
class NotificationPrefsNotifier extends StateNotifier<NotificationPrefs> {
  NotificationPrefsNotifier(this._store) : super(_store.loadNotificationPrefs());

  final LocalStore _store;

  Future<void> _persist() => _store.saveNotificationPrefs(state);

  Future<void> toggleWellness(bool enabled) async {
    state = state.copyWith(wellnessEnabled: enabled);
    await _persist();
    if (enabled) {
      await NotificationService.instance.requestPermission();
      await NotificationService.instance.scheduleDailyWellness(
        hour: state.wellnessHour,
        minute: state.wellnessMinute,
      );
    } else {
      await NotificationService.instance.cancel(100);
    }
  }

  Future<void> setWellnessTime(int hour, int minute) async {
    state = state.copyWith(wellnessHour: hour, wellnessMinute: minute);
    await _persist();
    if (state.wellnessEnabled) {
      await NotificationService.instance.scheduleDailyWellness(
        hour: hour,
        minute: minute,
      );
    }
  }

  Future<void> toggleWeekly(bool enabled) async {
    state = state.copyWith(weeklyEnabled: enabled);
    await _persist();
    if (enabled) {
      await NotificationService.instance.requestPermission();
      await NotificationService.instance.scheduleWeeklyUpdate(
        weekday: state.weeklyDay,
        hour: state.weeklyHour,
      );
    } else {
      await NotificationService.instance.cancel(200);
    }
  }

  Future<void> toggleAppointment(bool enabled) async {
    state = state.copyWith(appointmentEnabled: enabled);
    await _persist();
  }
}

final notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsNotifier, NotificationPrefs>((ref) {
  return NotificationPrefsNotifier(ref.watch(localStoreProvider));
});
