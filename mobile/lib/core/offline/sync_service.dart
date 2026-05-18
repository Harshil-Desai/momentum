import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../database/app_database.dart';
import 'offline_queue.dart';

class SyncService {
  SyncService(this._dio);

  final Dio _dio;
  bool _syncing = false;

  // ── Full refresh ─────────────────────────────────────────────────────────
  // Pulls all server data into the local DB. Call after login and foreground.

  Future<void> fullRefresh(String userId) async {
    try {
      final habitsResponse = await _dio.get('/habits');
      final rawList = habitsResponse.data;
      final List<dynamic> habitsJson =
          rawList is Map ? (rawList['habits'] as List? ?? []) : rawList as List;

      final now = DateTime.now().millisecondsSinceEpoch;

      final habitRows = habitsJson.map((h) {
        final map = h as Map<String, dynamic>;
        return AppDatabase.habitToRow(
          id: map['id'] as String,
          userId: userId,
          name: map['name'] as String,
          icon: map['icon'] as String?,
          color: map['color'] as String?,
          note: map['note'] as String?,
          twoMinuteVersion: map['two_minute_version'] as String?,
          stackAfterHabitId: map['stack_after_habit_id'] as String?,
          frequency: map['frequency'] as Map<String, dynamic>? ?? {},
          isArchived: map['archived'] as bool? ?? false,
          isNegative: map['is_negative'] as bool? ?? false,
          subtasks: map['subtasks'] as List?,
          syncStatus: 'synced',
          syncedAt: now,
          createdAt: _parseDate(map['created_at']),
          updatedAt: _parseDate(map['updated_at']),
        );
      }).toList();

      await AppDatabase.instance.upsertHabits(habitRows);

      // Fetch checkins per habit in parallel — silently skip failures.
      await Future.wait(
        habitsJson.map((h) async {
          final habitId = (h as Map<String, dynamic>)['id'] as String;
          try {
            final r = await _dio.get('/habits/$habitId/history');
            final dates = (r.data['dates'] as List?)?.cast<String>() ?? [];
            final rows = dates.map((date) {
              return {
                'id': '${habitId}_$date',
                'habit_id': habitId,
                'user_id': userId,
                'date': date,
                'sync_status': 'synced',
                'synced_at': now,
                'created_at': _parseDate(date),
              };
            }).toList();
            if (rows.isNotEmpty) {
              await AppDatabase.instance.upsertCheckins(rows);
            }
          } catch (_) {
            // Ignore per-habit failures — local data stays usable.
          }
        }),
      );
    } catch (e) {
      debugPrint('[SyncService] fullRefresh failed: $e');
    }
  }

  // ── Flush outbox ─────────────────────────────────────────────────────────

  Future<void> flush() async {
    if (_syncing) return;
    _syncing = true;
    try {
      final ops = await OfflineQueue.pending();
      for (final op in ops) {
        try {
          await _execute(op);
          await OfflineQueue.delete(op.id!);
        } on DioException catch (e) {
          final status = e.response?.statusCode;
          if (status == 409 || status == 200) {
            await OfflineQueue.delete(op.id!);
          } else if (status != null &&
              status != 408 &&
              status != 429 &&
              status >= 400 &&
              status < 500) {
            debugPrint('[SyncService] dropping op ${op.id}: ${e.message}');
            await OfflineQueue.delete(op.id!);
          } else {
            await OfflineQueue.incrementRetry(op.id!);
          }
        }
      }
    } finally {
      _syncing = false;
    }
  }

  Future<void> _execute(PendingOp op) async {
    // Typed ops written by HabitsProvider carry a 'op_type' field in the body.
    final opType = op.body['op_type'] as String?;

    if (opType != null) {
      await _executeTyped(op, opType);
      return;
    }

    // Legacy generic ops from the Dio interceptor.
    switch (op.method.toUpperCase()) {
      case 'POST':
        await _dio.post(op.endpoint, data: op.body);
      case 'PUT':
        await _dio.put(op.endpoint, data: op.body);
      case 'DELETE':
        await _dio.delete(op.endpoint);
      default:
        await _dio.post(op.endpoint, data: op.body);
    }
  }

  Future<void> _executeTyped(PendingOp op, String opType) async {
    final payload = Map<String, dynamic>.from(op.body)..remove('op_type');

    switch (opType) {
      case 'create_habit':
        final localId = payload.remove('_local_id') as String;
        final response = await _dio.post('/habits', data: payload);
        final serverId = response.data['id'] as String?;
        if (serverId != null && serverId != localId) {
          // Server assigned a different ID — update local record.
          final existing = await AppDatabase.instance.getHabit(localId);
          if (existing != null) {
            final updated = Map<String, dynamic>.from(existing)
              ..['id'] = serverId
              ..['sync_status'] = 'synced'
              ..['synced_at'] = DateTime.now().millisecondsSinceEpoch;
            await AppDatabase.instance.upsertHabit(updated);
            await AppDatabase.instance.deleteHabit(localId);
          }
        } else if (serverId != null) {
          await AppDatabase.instance.updateHabitSyncStatus(
            serverId,
            'synced',
            syncedAt: DateTime.now().millisecondsSinceEpoch,
          );
        }

      case 'update_habit':
        final habitId = payload.remove('_habit_id') as String;
        await _dio.put('/habits/$habitId', data: payload);
        await AppDatabase.instance.updateHabitSyncStatus(
          habitId,
          'synced',
          syncedAt: DateTime.now().millisecondsSinceEpoch,
        );

      case 'archive_habit':
        final habitId = payload['_habit_id'] as String;
        await _dio.delete('/habits/$habitId');
        await AppDatabase.instance.updateHabitSyncStatus(
          habitId,
          'synced',
          syncedAt: DateTime.now().millisecondsSinceEpoch,
        );

      case 'create_checkin':
        final localId = payload.remove('_local_id') as String;
        final habitId = payload.remove('_habit_id') as String;
        final response = await _dio.post(
          '/habits/$habitId/checkins',
          data: {'date': payload['date']},
        );
        final serverId = response.data['id'] as String?;
        if (serverId != null && serverId != localId) {
          await AppDatabase.instance.replaceCheckinId(localId, serverId);
        } else {
          final now = DateTime.now().millisecondsSinceEpoch;
          final database = AppDatabase.instance;
          final existing = await (database.db.then((d) => d.query(
                'checkins',
                where: 'id = ?',
                whereArgs: [localId],
                limit: 1,
              )));
          if (existing.isNotEmpty) {
            await database.upsertCheckin({
              ...existing.first,
              'sync_status': 'synced',
              'synced_at': now,
            });
          }
        }
    }
  }

  static int _parseDate(dynamic value) {
    if (value == null) return DateTime.now().millisecondsSinceEpoch;
    if (value is int) return value;
    try {
      return DateTime.parse(value as String).millisecondsSinceEpoch;
    } catch (_) {
      return DateTime.now().millisecondsSinceEpoch;
    }
  }
}
