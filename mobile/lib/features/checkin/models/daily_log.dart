class DailyLogData {
  final String? id;
  final int? mood;
  final int? energy;

  const DailyLogData({this.id, this.mood, this.energy});

  factory DailyLogData.fromJson(Map<String, dynamic> json) {
    return DailyLogData(
      id: json['id'] as String?,
      mood: json['mood'] as int?,
      energy: json['energy'] as int?,
    );
  }
}
