import 'habit.dart';

class HabitTemplate {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final String? note;
  final String? twoMinuteVersion;
  final String category;
  final int sortOrder;
  final HabitFrequency frequency;
  final bool isNegative;

  const HabitTemplate({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.note,
    this.twoMinuteVersion,
    required this.category,
    required this.sortOrder,
    required this.frequency,
    this.isNegative = false,
  });

  factory HabitTemplate.fromJson(Map<String, dynamic> json) {
    return HabitTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      note: json['note'] as String?,
      twoMinuteVersion: json['two_minute_version'] as String?,
      category: json['category'] as String? ?? '',
      sortOrder: json['sort_order'] as int? ?? 0,
      isNegative: json['is_negative'] as bool? ?? false,
      frequency: json['frequency'] != null
          ? HabitFrequency.fromJson(json['frequency'] as Map<String, dynamic>)
          : const HabitFrequency(type: 'daily'),
    );
  }
}
