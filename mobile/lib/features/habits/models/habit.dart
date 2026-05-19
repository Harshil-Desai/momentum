class HabitFrequency {
  final String type; // daily, weekly, times_per_week, interval
  final int? timesPerDay;
  final List<int>? days; // 0-6 for weekly specific days
  final int? times; // for times_per_week
  final int? everyNDays; // for interval

  const HabitFrequency({
    required this.type,
    this.timesPerDay,
    this.days,
    this.times,
    this.everyNDays,
  });

  factory HabitFrequency.fromJson(Map<String, dynamic> json) {
    return HabitFrequency(
      type: json['type'] as String? ?? 'daily',
      timesPerDay: json['times_per_day'] as int?,
      days: (json['days'] as List<dynamic>?)?.map((e) => e as int).toList(),
      times: json['times'] as int?,
      everyNDays: json['every_n_days'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        if (timesPerDay != null) 'times_per_day': timesPerDay,
        if (days != null) 'days': days,
        if (times != null) 'times': times,
        if (everyNDays != null) 'every_n_days': everyNDays,
      };

  String get label {
    switch (type) {
      case 'times_per_week':
        return '${times ?? 1}× per week';
      case 'interval':
        return 'Every ${everyNDays ?? 1} day${(everyNDays ?? 1) == 1 ? '' : 's'}';
      case 'weekly':
        if (days != null && days!.isNotEmpty) {
          const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
          return days!.map((d) => dayNames[d]).join(', ');
        }
        return 'Weekly';
      default:
        return 'Daily';
    }
  }
}

class HabitSubtask {
  final String id;
  final String habitId;
  final String label;
  final int sortOrder;

  const HabitSubtask({
    required this.id,
    required this.habitId,
    required this.label,
    required this.sortOrder,
  });

  factory HabitSubtask.fromJson(Map<String, dynamic> json) {
    return HabitSubtask(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      label: json['label'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}

class Habit {
  final String id;
  final String userId;
  final String name;
  final String? icon;
  final String? color;
  final String? note;
  final String? twoMinuteVersion;
  final String? stackAfterHabitId;
  final bool archived;
  final bool isNegative;
  final HabitFrequency frequency;
  final List<HabitSubtask> subtasks;
  final DateTime? createdAt;

  const Habit({
    required this.id,
    required this.userId,
    required this.name,
    this.icon,
    this.color,
    this.note,
    this.twoMinuteVersion,
    this.stackAfterHabitId,
    required this.archived,
    this.isNegative = false,
    required this.frequency,
    this.subtasks = const [],
    this.createdAt,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      note: json['note'] as String?,
      twoMinuteVersion: json['two_minute_version'] as String?,
      stackAfterHabitId: json['stack_after_habit_id'] as String?,
      archived: json['archived'] as bool? ?? false,
      isNegative: json['is_negative'] as bool? ?? false,
      frequency: json['frequency'] != null
          ? HabitFrequency.fromJson(json['frequency'] as Map<String, dynamic>)
          : const HabitFrequency(type: 'daily'),
      subtasks: (json['subtasks'] as List<dynamic>?)
              ?.map((e) => HabitSubtask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
