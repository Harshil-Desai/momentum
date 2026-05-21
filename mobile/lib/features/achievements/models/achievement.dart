class AchievementItem {
  final String id;
  final String name;
  final String description;
  final String icon;
  final DateTime? earnedAt;

  const AchievementItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.earnedAt,
  });

  factory AchievementItem.fromJson(Map<String, dynamic> json) => AchievementItem(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        icon: json['icon'] as String,
        earnedAt: json['earned_at'] != null
            ? DateTime.parse(json['earned_at'] as String)
            : null,
      );
}

class ProgressItem {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int currentValue;
  final int targetValue;

  const ProgressItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.currentValue,
    required this.targetValue,
  });

  bool get isNearCompletion => (targetValue - currentValue) <= 2;

  factory ProgressItem.fromJson(Map<String, dynamic> json) => ProgressItem(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        icon: json['icon'] as String,
        currentValue: json['current_value'] as int,
        targetValue: json['target_value'] as int,
      );
}

class AchievementsData {
  final List<AchievementItem> earned;
  final List<ProgressItem> inProgress;
  final List<String> newlyEarned;

  const AchievementsData({
    required this.earned,
    required this.inProgress,
    required this.newlyEarned,
  });

  List<ProgressItem> get nudges =>
      inProgress.where((p) => p.isNearCompletion).toList();

  factory AchievementsData.fromJson(Map<String, dynamic> json) => AchievementsData(
        earned: (json['earned'] as List)
            .map((e) => AchievementItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        inProgress: (json['in_progress'] as List)
            .map((e) => ProgressItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        newlyEarned: List<String>.from(json['newly_earned'] as List),
      );
}
