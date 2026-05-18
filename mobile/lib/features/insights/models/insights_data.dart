class DayCount {
  final int dayOfWeek;
  final int count;
  const DayCount({required this.dayOfWeek, required this.count});

  factory DayCount.fromJson(Map<String, dynamic> json) => DayCount(
        dayOfWeek: json['day_of_week'] as int,
        count: json['count'] as int,
      );

  static const dayNames = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];

  String get name => dayOfWeek >= 0 && dayOfWeek <= 6
      ? dayNames[dayOfWeek]
      : '?';
}

class HabitStreakSummary {
  final String habitId;
  final String habitName;
  final int currentStreak;
  final int bestStreak;

  const HabitStreakSummary({
    required this.habitId,
    required this.habitName,
    required this.currentStreak,
    required this.bestStreak,
  });

  factory HabitStreakSummary.fromJson(Map<String, dynamic> json) =>
      HabitStreakSummary(
        habitId: json['habit_id'] as String,
        habitName: json['habit_name'] as String,
        currentStreak: json['current_streak'] as int,
        bestStreak: json['best_streak'] as int,
      );
}

class EnergyCorrelationPoint {
  final int energyLevel;
  final double completionRate;
  const EnergyCorrelationPoint(
      {required this.energyLevel, required this.completionRate});

  factory EnergyCorrelationPoint.fromJson(Map<String, dynamic> json) =>
      EnergyCorrelationPoint(
        energyLevel: json['energy_level'] as int,
        completionRate: (json['completion_rate'] as num).toDouble(),
      );

  static const labels = ['', 'Drained', 'Low', 'Okay', 'Good', 'Energized'];
}

class HabitCorrelation {
  final String habitAId;
  final String habitAName;
  final String habitBId;
  final String habitBName;
  final double percentage;

  const HabitCorrelation({
    required this.habitAId,
    required this.habitAName,
    required this.habitBId,
    required this.habitBName,
    required this.percentage,
  });

  factory HabitCorrelation.fromJson(Map<String, dynamic> json) =>
      HabitCorrelation(
        habitAId: json['habit_a_id'] as String,
        habitAName: json['habit_a_name'] as String,
        habitBId: json['habit_b_id'] as String,
        habitBName: json['habit_b_name'] as String,
        percentage: (json['percentage'] as num).toDouble(),
      );
}

class HabitForecast {
  final String habitId;
  final String habitName;
  final int dayOfWeek;
  final double completionRate;
  final int sampleWeeks;
  final String nudgeCopy;

  const HabitForecast({
    required this.habitId,
    required this.habitName,
    required this.dayOfWeek,
    required this.completionRate,
    required this.sampleWeeks,
    required this.nudgeCopy,
  });

  factory HabitForecast.fromJson(Map<String, dynamic> json) => HabitForecast(
        habitId: json['habit_id'] as String,
        habitName: json['habit_name'] as String,
        dayOfWeek: json['day_of_week'] as int,
        completionRate: (json['completion_rate'] as num).toDouble(),
        sampleWeeks: json['sample_weeks'] as int,
        nudgeCopy: json['nudge_copy'] as String? ?? '',
      );
}

class HabitMonthlySummary {
  final String habitId;
  final String habitName;
  final int checkins;
  final double ratePct;

  const HabitMonthlySummary({
    required this.habitId,
    required this.habitName,
    required this.checkins,
    required this.ratePct,
  });

  factory HabitMonthlySummary.fromJson(Map<String, dynamic> json) =>
      HabitMonthlySummary(
        habitId: json['habit_id'] as String,
        habitName: json['habit_name'] as String,
        checkins: json['checkins'] as int,
        ratePct: (json['rate_pct'] as num).toDouble(),
      );
}

class WeekSummary {
  final String weekStart;
  final int checkins;
  const WeekSummary({required this.weekStart, required this.checkins});

  factory WeekSummary.fromJson(Map<String, dynamic> json) => WeekSummary(
        weekStart: json['week_start'] as String,
        checkins: json['checkins'] as int,
      );
}

class MonthlyReview {
  final String month;
  final int totalCheckins;
  final List<HabitMonthlySummary> wins;
  final List<HabitMonthlySummary> droppedOff;
  final List<HabitMonthlySummary> held;
  final WeekSummary lowestWeek;

  const MonthlyReview({
    required this.month,
    required this.totalCheckins,
    required this.wins,
    required this.droppedOff,
    required this.held,
    required this.lowestWeek,
  });

  factory MonthlyReview.fromJson(Map<String, dynamic> json) => MonthlyReview(
        month: json['month'] as String,
        totalCheckins: json['total_checkins'] as int,
        wins: (json['wins'] as List<dynamic>?)
                ?.map((e) =>
                    HabitMonthlySummary.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        droppedOff: (json['dropped_off'] as List<dynamic>?)
                ?.map((e) =>
                    HabitMonthlySummary.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        held: (json['held'] as List<dynamic>?)
                ?.map((e) =>
                    HabitMonthlySummary.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        lowestWeek: WeekSummary.fromJson(
            json['lowest_week'] as Map<String, dynamic>),
      );
}

class InsightsData {
  final int totalCheckins;
  final int activeHabits;
  final int monthlyCompleted;
  final int monthlyPossible;
  final double monthlyRate;
  final List<DayCount> dayOfWeek;
  final String strongestDay;
  final List<HabitStreakSummary> habitStreaks;
  final List<EnergyCorrelationPoint> energyCorrelation;
  final bool advancedUnlocked;
  final int unlockThreshold;
  final int maxHabitCheckins;
  final List<HabitCorrelation> correlations;
  final List<HabitForecast> forecasts;
  final MonthlyReview? monthlyReview;

  const InsightsData({
    required this.totalCheckins,
    required this.activeHabits,
    required this.monthlyCompleted,
    required this.monthlyPossible,
    required this.monthlyRate,
    required this.dayOfWeek,
    required this.strongestDay,
    required this.habitStreaks,
    this.energyCorrelation = const [],
    this.advancedUnlocked = false,
    this.unlockThreshold = 21,
    this.maxHabitCheckins = 0,
    this.correlations = const [],
    this.forecasts = const [],
    this.monthlyReview,
  });

  factory InsightsData.fromJson(Map<String, dynamic> json) => InsightsData(
        totalCheckins: json['total_checkins'] as int? ?? 0,
        activeHabits: json['active_habits'] as int? ?? 0,
        monthlyCompleted: json['monthly_completed'] as int? ?? 0,
        monthlyPossible: json['monthly_possible'] as int? ?? 0,
        monthlyRate: (json['monthly_rate'] as num?)?.toDouble() ?? 0.0,
        dayOfWeek: (json['day_of_week'] as List<dynamic>?)
                ?.map((e) => DayCount.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        strongestDay: json['strongest_day'] as String? ?? '',
        habitStreaks: (json['habit_streaks'] as List<dynamic>?)
                ?.map((e) =>
                    HabitStreakSummary.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        energyCorrelation: (json['energy_correlation'] as List<dynamic>?)
                ?.map((e) => EnergyCorrelationPoint.fromJson(
                    e as Map<String, dynamic>))
                .toList() ??
            [],
        advancedUnlocked: json['advanced_unlocked'] as bool? ?? false,
        unlockThreshold: json['unlock_threshold'] as int? ?? 21,
        maxHabitCheckins: json['max_habit_checkins'] as int? ?? 0,
        correlations: (json['correlations'] as List<dynamic>?)
                ?.map((e) =>
                    HabitCorrelation.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        forecasts: (json['forecasts'] as List<dynamic>?)
                ?.map((e) =>
                    HabitForecast.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        monthlyReview: json['monthly_review'] != null
            ? MonthlyReview.fromJson(
                json['monthly_review'] as Map<String, dynamic>)
            : null,
      );
}
