import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  // ── Schema ──────────────────────────────────────────────────────────────

  static const _ddl = [
    '''
    CREATE TABLE IF NOT EXISTS habits (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      name TEXT NOT NULL,
      icon TEXT,
      color TEXT,
      note TEXT,
      two_minute_version TEXT,
      stack_after_habit_id TEXT,
      frequency_json TEXT NOT NULL,
      is_archived INTEGER NOT NULL DEFAULT 0,
      is_negative INTEGER NOT NULL DEFAULT 0,
      subtasks_json TEXT,
      sync_status TEXT NOT NULL DEFAULT 'synced',
      synced_at INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
    ''',
    '''
    CREATE TABLE IF NOT EXISTS checkins (
      id TEXT PRIMARY KEY,
      habit_id TEXT NOT NULL,
      user_id TEXT NOT NULL,
      date TEXT NOT NULL,
      sync_status TEXT NOT NULL DEFAULT 'synced',
      synced_at INTEGER,
      created_at INTEGER NOT NULL
    )
    ''',
    'CREATE INDEX IF NOT EXISTS idx_habits_user ON habits(user_id)',
    'CREATE INDEX IF NOT EXISTS idx_checkins_habit ON checkins(habit_id)',
    'CREATE UNIQUE INDEX IF NOT EXISTS idx_checkins_habit_date ON checkins(habit_id, date)',
  ];

  Future<Database> _open() async {
    final dbPath = p.join(await getDatabasesPath(), 'momentum.db');
    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, _) async {
        for (final sql in _ddl) {
          await db.execute(sql);
        }
      },
    );
  }

  // ── Habits ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getActiveHabits(String userId) async {
    final database = await db;
    return database.query(
      'habits',
      where: 'user_id = ? AND is_archived = 0',
      whereArgs: [userId],
      orderBy: 'created_at ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getArchivedHabits(String userId) async {
    final database = await db;
    return database.query(
      'habits',
      where: 'user_id = ? AND is_archived = 1',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getHabit(String id) async {
    final database = await db;
    final rows = await database.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> upsertHabit(Map<String, dynamic> row) async {
    final database = await db;
    await database.insert(
      'habits',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertHabits(List<Map<String, dynamic>> rows) async {
    final database = await db;
    final batch = database.batch();
    for (final row in rows) {
      batch.insert('habits', row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> updateHabitSyncStatus(
    String id,
    String status, {
    int? syncedAt,
  }) async {
    final database = await db;
    await database.update(
      'habits',
      {
        'sync_status': status,
        if (syncedAt != null) 'synced_at': syncedAt,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteHabit(String id) async {
    final database = await db;
    await database.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  // ── Check-ins ────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getCheckinsForHabit(
      String habitId) async {
    final database = await db;
    return database.query(
      'checkins',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'date DESC',
    );
  }

  Future<Map<String, dynamic>?> getCheckinForDate(
      String habitId, String date) async {
    final database = await db;
    final rows = await database.query(
      'checkins',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, date],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> upsertCheckin(Map<String, dynamic> row) async {
    final database = await db;
    await database.insert(
      'checkins',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertCheckins(List<Map<String, dynamic>> rows) async {
    final database = await db;
    final batch = database.batch();
    for (final row in rows) {
      batch.insert('checkins', row,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> replaceCheckinId(String tempId, String serverId) async {
    final database = await db;
    final now = DateTime.now().millisecondsSinceEpoch;
    await database.update(
      'checkins',
      {'id': serverId, 'sync_status': 'synced', 'synced_at': now},
      where: 'id = ?',
      whereArgs: [tempId],
    );
  }

  Future<void> deleteCheckin(String id) async {
    final database = await db;
    await database.delete('checkins', where: 'id = ?', whereArgs: [id]);
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────

  Future<void> clearUserData() async {
    final database = await db;
    await database.delete('habits');
    await database.delete('checkins');
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static Map<String, dynamic> habitToRow({
    required String id,
    required String userId,
    required String name,
    String? icon,
    String? color,
    String? note,
    String? twoMinuteVersion,
    String? stackAfterHabitId,
    required Map<String, dynamic> frequency,
    bool isArchived = false,
    bool isNegative = false,
    List<dynamic>? subtasks,
    String syncStatus = 'synced',
    int? syncedAt,
    required int createdAt,
    required int updatedAt,
  }) {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'icon': icon,
      'color': color,
      'note': note,
      'two_minute_version': twoMinuteVersion,
      'stack_after_habit_id': stackAfterHabitId,
      'frequency_json': jsonEncode(frequency),
      'is_archived': isArchived ? 1 : 0,
      'is_negative': isNegative ? 1 : 0,
      'subtasks_json': subtasks != null ? jsonEncode(subtasks) : null,
      'sync_status': syncStatus,
      'synced_at': syncedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
