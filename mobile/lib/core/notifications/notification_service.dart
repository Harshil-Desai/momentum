import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Top-level callback required by flutter_local_notifications on Android.
@pragma('vm:entry-point')
void _onNotificationResponse(NotificationResponse response) {
  NotificationService._tapPayloadController.add(response.payload ?? '');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  /// Emits the habit ID payload whenever a notification is tapped.
  static final _tapPayloadController =
      StreamController<String>.broadcast();
  static Stream<String> get onTap => _tapPayloadController.stream;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onNotificationResponse,
    );

    // Handle tap when app was terminated and launched via notification.
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      final payload = launchDetails!.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        _tapPayloadController.add(payload);
      }
    }

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  /// Schedules a daily reminder for a habit at [hour]:[minute] local time.
  /// [habitId] is used as the notification ID (hashed to int).
  Future<void> scheduleHabitReminder({
    required String habitId,
    required String habitName,
    required String? habitIcon,
    required int hour,
    required int minute,
  }) async {
    await init();
    final id = _notifId(habitId);
    final title =
        habitIcon != null ? '$habitIcon $habitName' : habitName;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'habit_reminders_alarm',
      'Habit Reminders',
      channelDescription: 'Daily reminders for your habits',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      channelShowBadge: true,
      actions: [
        AndroidNotificationAction('done', 'Done for today'),
        AndroidNotificationAction('snooze_15', 'Snooze 15 min'),
        AndroidNotificationAction('snooze_60', 'Snooze 1 hr'),
      ],
    );
    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'habit_reminder',
    );

    await _plugin.zonedSchedule(
      id,
      title,
      'Time to check in',
      scheduled,
      const NotificationDetails(
          android: androidDetails, iOS: iosDetails),
      payload: habitId,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelReminder(String habitId) async {
    await init();
    await _plugin.cancel(_notifId(habitId));
  }

  Future<void> snooze(String habitId, Duration duration) async {
    await init();
    await _plugin.cancel(_notifId(habitId));
    final id = _notifId(habitId);
    final scheduled = tz.TZDateTime.now(tz.local).add(duration);

    const androidDetails = AndroidNotificationDetails(
      'habit_reminders_alarm',
      'Habit Reminders',
      channelDescription: 'Daily reminders for your habits',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _plugin.zonedSchedule(
      id,
      'Habit reminder',
      'You snoozed this — time to check in',
      scheduled,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  int _notifId(String habitId) =>
      habitId.hashCode.abs() % 100000;
}
