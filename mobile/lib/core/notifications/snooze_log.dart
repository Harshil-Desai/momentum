import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class SnoozeEvent {
  final String habitId;
  final String habitName;
  final String option; // 'snooze_15', 'snooze_60', 'tomorrow'
  final int timestamp;

  const SnoozeEvent({
    required this.habitId,
    required this.habitName,
    required this.option,
    required this.timestamp,
  });

  Map<String, dynamic> toRow() => {
        'habit_id': habitId,
        'habit_name': habitName,
        'option': option,
        'timestamp': timestamp,
      };

  factory SnoozeEvent.fromRow(Map<String, dynamic> row) => SnoozeEvent(
        habitId: row['habit_id'] as String,
        habitName: row['habit_name'] as String,
        option: row['option'] as String,
        timestamp: row['timestamp'] as int,
      );
}

class SnoozeLog {
  static Database? _db;

  static Future<Database> _open() async {
    if (_db != null) return _db!;
    final dbPath = p.join(await getDatabasesPath(), 'momentum_snooze.db');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE snooze_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          habit_id TEXT NOT NULL,
          habit_name TEXT NOT NULL,
          option TEXT NOT NULL,
          timestamp INTEGER NOT NULL
        )
      '''),
    );
    return _db!;
  }

  static Future<void> record(SnoozeEvent event) async {
    final db = await _open();
    await db.insert('snooze_log', event.toRow());
  }

  /// Returns snooze counts per habit in the rolling [days]-day window,
  /// filtered to habits with 5+ snooze events.
  static Future<List<SnoozeInsight>> insightsForWindow(
      {int days = 30}) async {
    final db = await _open();
    final cutoff = DateTime.now()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch;

    final rows = await db.rawQuery('''
      SELECT habit_id, habit_name, COUNT(*) as snooze_count
      FROM snooze_log
      WHERE timestamp >= ?
      GROUP BY habit_id, habit_name
      HAVING snooze_count >= 5
      ORDER BY snooze_count DESC
    ''', [cutoff]);

    return rows
        .map((r) => SnoozeInsight(
              habitId: r['habit_id'] as String,
              habitName: r['habit_name'] as String,
              snoozeCount: r['snooze_count'] as int,
            ))
        .toList();
  }
}

class SnoozeInsight {
  final String habitId;
  final String habitName;
  final int snoozeCount;

  const SnoozeInsight({
    required this.habitId,
    required this.habitName,
    required this.snoozeCount,
  });

  String get message =>
      'You\'ve snoozed "$habitName" $snoozeCount time${snoozeCount == 1 ? '' : 's'} this month — worth revisiting?';
}

class SnoozeInsightService {
  static Future<List<SnoozeInsight>> insights({int days = 30}) =>
      SnoozeLog.insightsForWindow(days: days);
}
