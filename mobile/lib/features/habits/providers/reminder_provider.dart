import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/notifications/notification_service.dart';
import '../models/habit.dart';

part 'reminder_provider.g.dart';

class HabitReminder {
  final bool enabled;
  final int hour;
  final int minute;

  const HabitReminder({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  String get label =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

String _key(String habitId) => 'reminder_$habitId';

@riverpod
class HabitReminderNotifier extends _$HabitReminderNotifier {
  @override
  Future<HabitReminder?> build(String habitId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(habitId));
    if (raw == null) return null;
    final parts = raw.split(':');
    if (parts.length != 2) return null;
    return HabitReminder(
      enabled: true,
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Future<bool> set(Habit habit, TimeOfDay time) async {
    final ns = NotificationService();
    final granted = await ns.requestPermission();
    if (!granted) return false;

    final prefs = await SharedPreferences.getInstance();
    final value =
        '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    await prefs.setString(_key(habitId), value);

    await ns.scheduleHabitReminder(
      habitId: habitId,
      habitName: habit.name,
      habitIcon: habit.icon,
      hour: time.hour,
      minute: time.minute,
    );

    state = AsyncData(HabitReminder(
      enabled: true,
      hour: time.hour,
      minute: time.minute,
    ));
    return true;
  }

  Future<void> cancel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(habitId));
    await NotificationService().cancelReminder(habitId);
    state = const AsyncData(null);
  }
}
