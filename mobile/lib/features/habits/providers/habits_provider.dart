import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/api_client.dart';
import '../../../core/database/app_database.dart';
import '../../../core/offline/connectivity_provider.dart';
import '../../../core/offline/offline_queue.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../models/habit.dart';

part 'habits_provider.g.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Habit _habitFromRow(Map<String, dynamic> row) {
  return Habit(
    id: row['id'] as String,
    userId: row['user_id'] as String,
    name: row['name'] as String,
    icon: row['icon'] as String?,
    color: row['color'] as String?,
    note: row['note'] as String?,
    twoMinuteVersion: row['two_minute_version'] as String?,
    stackAfterHabitId: row['stack_after_habit_id'] as String?,
    archived: (row['is_archived'] as int? ?? 0) == 1,
    isNegative: (row['is_negative'] as int? ?? 0) == 1,
    frequency: row['frequency_json'] != null
        ? HabitFrequency.fromJson(
            jsonDecode(row['frequency_json'] as String) as Map<String, dynamic>)
        : const HabitFrequency(type: 'daily'),
    subtasks: row['subtasks_json'] != null
        ? (jsonDecode(row['subtasks_json'] as String) as List)
            .map((e) => HabitSubtask.fromJson(e as Map<String, dynamic>))
            .toList()
        : [],
  );
}

String _todayStr() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

const _uuid = Uuid();

// ── Habits provider (local-first) ─────────────────────────────────────────────

@riverpod
class Habits extends _$Habits {
  @override
  Future<List<Habit>> build() async {
    ref.keepAlive(); // prevent disposal on route change — no reload flash
    final userId = ref.watch(authProvider).valueOrNull?.userId;
    if (userId == null || userId.isEmpty) return [];
    // If we already have data (e.g. re-entry after navigation), serve it
    // immediately and let SyncService update in the background.
    final cached = state.valueOrNull;
    if (cached != null) return cached;
    return _loadLocal(userId);
  }

  Future<List<Habit>> _loadLocal(String userId) async {
    final rows = await AppDatabase.instance.getActiveHabits(userId);
    return rows.map(_habitFromRow).toList();
  }

  Future<void> refresh() async {
    // Never reset to AsyncLoading — update in-place so UI stays responsive.
    final userId = ref.read(authProvider).valueOrNull?.userId ?? '';
    final fresh = await _loadLocal(userId);
    state = AsyncData(fresh);
  }

  Future<Habit?> createHabit({
    required String name,
    String? icon,
    String? color,
    String? note,
    String? twoMinuteVersion,
    String? stackAfterHabitId,
    bool isNegative = false,
    HabitFrequency? frequency,
    List<Map<String, dynamic>>? subtasks,
  }) async {
    final userId = ref.read(authProvider).valueOrNull?.userId ?? '';
    final freq = frequency ?? const HabitFrequency(type: 'daily');
    final now = DateTime.now().millisecondsSinceEpoch;
    final localId = _uuid.v4();

    final habit = Habit(
      id: localId,
      userId: userId,
      name: name,
      icon: icon,
      color: color,
      note: note,
      twoMinuteVersion: twoMinuteVersion,
      stackAfterHabitId: stackAfterHabitId,
      archived: false,
      isNegative: isNegative,
      frequency: freq,
      subtasks: subtasks
              ?.map((e) => HabitSubtask.fromJson(e))
              .toList() ??
          [],
    );

    // 1. Write locally.
    await AppDatabase.instance.upsertHabit(AppDatabase.habitToRow(
      id: localId,
      userId: userId,
      name: name,
      icon: icon,
      color: color,
      note: note,
      twoMinuteVersion: twoMinuteVersion,
      stackAfterHabitId: stackAfterHabitId,
      frequency: freq.toJson(),
      isNegative: isNegative,
      subtasks: subtasks,
      syncStatus: 'pending_create',
      createdAt: now,
      updatedAt: now,
    ));

    // 2. Optimistically update UI.
    final current = state.valueOrNull ?? [];
    state = AsyncData([...current, habit]);

    // 3. Enqueue sync op.
    await OfflineQueue.enqueue(PendingOp(
      method: 'POST',
      endpoint: '/habits',
      body: {
        'op_type': 'create_habit',
        '_local_id': localId,
        'name': name,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
        if (note != null) 'note': note,
        if (twoMinuteVersion != null) 'two_minute_version': twoMinuteVersion,
        if (stackAfterHabitId != null)
          'stack_after_habit_id': stackAfterHabitId,
        'is_negative': isNegative,
        'frequency': freq.toJson(),
        if (subtasks != null) 'subtasks': subtasks,
      },
      createdAt: now,
    ));

    // 4. Fire-and-forget flush.
    unawaited(_flush());

    return habit;
  }

  Future<bool> updateHabit({
    required String habitId,
    String? name,
    String? icon,
    String? color,
    String? note,
    String? twoMinuteVersion,
    String? stackAfterHabitId,
    bool? isNegative,
    HabitFrequency? frequency,
    List<Map<String, dynamic>>? subtasks,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Update local DB fields that changed.
    final existing = await AppDatabase.instance.getHabit(habitId);
    if (existing == null) return false;

    final updated = Map<String, dynamic>.from(existing)
      ..['updated_at'] = now
      ..['sync_status'] = 'pending_update'
      ..['synced_at'] = null;
    if (name != null) updated['name'] = name;
    if (icon != null) updated['icon'] = icon.isEmpty ? null : icon;
    if (color != null) updated['color'] = color.isEmpty ? null : color;
    if (note != null) updated['note'] = note.isEmpty ? null : note;
    if (twoMinuteVersion != null) {
      updated['two_minute_version'] =
          twoMinuteVersion.isEmpty ? null : twoMinuteVersion;
    }
    if (stackAfterHabitId != null) {
      updated['stack_after_habit_id'] =
          stackAfterHabitId.isEmpty ? null : stackAfterHabitId;
    }
    if (isNegative != null) updated['is_negative'] = isNegative ? 1 : 0;
    if (frequency != null) updated['frequency_json'] = jsonEncode(frequency.toJson());
    if (subtasks != null) updated['subtasks_json'] = jsonEncode(subtasks);

    await AppDatabase.instance.upsertHabit(updated);
    await refresh();

    // 2. Enqueue sync.
    await OfflineQueue.enqueue(PendingOp(
      method: 'PUT',
      endpoint: '/habits/$habitId',
      body: {
        'op_type': 'update_habit',
        '_habit_id': habitId,
        if (name != null) 'name': name,
        if (icon != null) 'icon': icon.isEmpty ? null : icon,
        if (color != null) 'color': color.isEmpty ? null : color,
        if (note != null) 'note': note.isEmpty ? null : note,
        if (twoMinuteVersion != null)
          'two_minute_version': twoMinuteVersion.isEmpty ? null : twoMinuteVersion,
        if (stackAfterHabitId != null)
          'stack_after_habit_id': stackAfterHabitId.isEmpty ? null : stackAfterHabitId,
        if (isNegative != null) 'is_negative': isNegative,
        if (frequency != null) 'frequency': frequency.toJson(),
        if (subtasks != null) 'subtasks': subtasks,
      },
      createdAt: now,
    ));

    unawaited(_flush());
    return true;
  }

  Future<bool> archiveHabit(String habitId) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Soft-delete locally.
    final existing = await AppDatabase.instance.getHabit(habitId);
    if (existing == null) return false;
    await AppDatabase.instance.upsertHabit({
      ...existing,
      'is_archived': 1,
      'updated_at': now,
      'sync_status': 'pending_delete',
      'synced_at': null,
    });

    // 2. Remove from UI state immediately.
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((h) => h.id != habitId).toList());

    // 3. Enqueue sync.
    await OfflineQueue.enqueue(PendingOp(
      method: 'DELETE',
      endpoint: '/habits/$habitId',
      body: {'op_type': 'archive_habit', '_habit_id': habitId},
      createdAt: now,
    ));

    unawaited(_flush());
    return true;
  }

  Future<bool> restoreHabit(String habitId) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.put('/habits/$habitId', data: {'archived': false});
      await refresh();
      return true;
    } on DioException catch (_) {
      return false;
    }
  }

  Future<void> _flush() async {
    try {
      await ref.read(syncManagerProvider.notifier).flush();
    } catch (_) {}
  }
}

// ── Archived habits ───────────────────────────────────────────────────────────

@riverpod
class ArchivedHabits extends _$ArchivedHabits {
  @override
  Future<List<Habit>> build() async {
    final userId = ref.watch(authProvider).valueOrNull?.userId;
    if (userId == null || userId.isEmpty) return [];
    final rows = await AppDatabase.instance.getArchivedHabits(userId);
    return rows.map(_habitFromRow).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userId = ref.read(authProvider).valueOrNull?.userId ?? '';
      final rows = await AppDatabase.instance.getArchivedHabits(userId);
      return rows.map(_habitFromRow).toList();
    });
  }
}

// ── History provider — keyed by habitId ──────────────────────────────────────

class HabitHistory {
  final List<String> dates;
  final int lifetimeCount;
  final bool checkedToday;
  final bool missedYesterday;
  final bool graceUsedThisMonth;
  final bool canClaimGrace;
  final int bestStreak;
  const HabitHistory({
    required this.dates,
    required this.lifetimeCount,
    required this.checkedToday,
    required this.missedYesterday,
    this.graceUsedThisMonth = false,
    this.canClaimGrace = false,
    this.bestStreak = 0,
  });
}

@riverpod
class HabitHistoryData extends _$HabitHistoryData {
  @override
  Future<HabitHistory> build(String habitId) async {
    // 1. Serve local data immediately.
    final localRows =
        await AppDatabase.instance.getCheckinsForHabit(habitId);
    final localDates =
        localRows.map((r) => r['date'] as String).toList();

    // 2. Try to enrich from API; fall back gracefully.
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/habits/$habitId/history');
      final dates = (response.data['dates'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          localDates;
      final count = response.data['lifetime_count'] as int? ?? dates.length;
      final checkedToday = response.data['checked_today'] as bool? ?? false;
      final missedYesterday =
          response.data['missed_yesterday'] as bool? ?? false;
      final graceUsed =
          response.data['grace_used_this_month'] as bool? ?? false;
      final canClaimGrace =
          response.data['can_claim_grace'] as bool? ?? false;
      return HabitHistory(
        dates: dates,
        lifetimeCount: count,
        checkedToday: checkedToday,
        missedYesterday: missedYesterday,
        graceUsedThisMonth: graceUsed,
        canClaimGrace: canClaimGrace,
        bestStreak: _computeBestStreak(dates),
      );
    } catch (_) {
      final today = _todayStr();
      return HabitHistory(
        dates: localDates,
        lifetimeCount: localDates.length,
        checkedToday: localDates.contains(today),
        missedYesterday: false,
        bestStreak: _computeBestStreak(localDates),
      );
    }
  }

  int _computeBestStreak(List<String> dates) {
    if (dates.isEmpty) return 0;
    final sorted = List<String>.from(dates)..sort();
    int best = 1, current = 1;
    for (int i = 1; i < sorted.length; i++) {
      final prev = DateTime.parse(sorted[i - 1]);
      final curr = DateTime.parse(sorted[i]);
      if (curr.difference(prev).inDays == 1) {
        current++;
        if (current > best) best = current;
      } else {
        current = 1;
      }
    }
    return best;
  }
}

// ── Streak provider ───────────────────────────────────────────────────────────

@riverpod
class HabitStreak extends _$HabitStreak {
  @override
  Future<int> build(String habitId) async {
    // Always check local checkins first. For a brand-new habit with zero
    // checkins, return 0 immediately without hitting the API — this prevents
    // the server from returning stale or wrong data for newly created habits.
    final rows = await AppDatabase.instance.getCheckinsForHabit(habitId);
    if (rows.isEmpty) return 0;

    // With confirmed local checkins, try the API for authoritative streak.
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/habits/$habitId/streak');
      return response.data['current_streak'] as int;
    } catch (_) {
      final dates = rows.map((r) => r['date'] as String).toList()..sort();
      return _currentStreak(dates);
    }
  }

  // Walk backward from the most-recent checkin, counting consecutive days.
  int _currentStreak(List<String> sorted) {
    if (sorted.isEmpty) return 0;
    final today = _todayStr();
    final mostRecent = DateTime.parse(sorted.last);
    final todayDt = DateTime.parse(today);

    // Streak is broken if the most-recent checkin isn't today or yesterday.
    if (mostRecent != todayDt &&
        mostRecent != todayDt.subtract(const Duration(days: 1))) {
      return 0;
    }

    int streak = 0;
    // Anchor cursor to the actual most-recent checkin date.
    DateTime cursor = mostRecent;
    for (int i = sorted.length - 1; i >= 0; i--) {
      final d = DateTime.parse(sorted[i]);
      if (d == cursor) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  Future<void> refresh() async {
    final rows = await AppDatabase.instance.getCheckinsForHabit(habitId);
    if (rows.isEmpty) {
      state = const AsyncData(0);
      return;
    }
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/habits/$habitId/streak');
      state = AsyncData(response.data['current_streak'] as int);
    } catch (_) {
      final dates = rows.map((r) => r['date'] as String).toList()..sort();
      state = AsyncData(_currentStreak(dates));
    }
  }
}

// ── Checkin state per habit ───────────────────────────────────────────────────

class CheckinState {
  final bool isLoading;
  final String? error;
  const CheckinState({this.isLoading = false, this.error});
}

@riverpod
class HabitCheckin extends _$HabitCheckin {
  @override
  CheckinState build(String habitId) => const CheckinState();

  Future<bool> removeToday() async {
    state = const CheckinState(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/habits/$habitId/checkins');
      // Remove local checkin for today.
      final today = _todayStr();
      final row = await AppDatabase.instance.getCheckinForDate(habitId, today);
      if (row != null) {
        await AppDatabase.instance.deleteCheckin(row['id'] as String);
      }
      state = const CheckinState();
      ref.invalidate(habitStreakProvider(habitId));
      ref.invalidate(habitHistoryDataProvider(habitId));
      return true;
    } on DioException catch (_) {
      state = const CheckinState();
      return false;
    }
  }

  /// Returns milestone value if one was just reached, 0 if success, -1 on failure.
  Future<int> logToday() async {
    state = const CheckinState(isLoading: true);
    final today = _todayStr();
    final now = DateTime.now().millisecondsSinceEpoch;

    // Idempotency check.
    final existing =
        await AppDatabase.instance.getCheckinForDate(habitId, today);
    if (existing != null) {
      state = const CheckinState();
      return 0;
    }

    final userId = ref.read(authProvider).valueOrNull?.userId ?? '';
    final localId = _uuid.v4();

    // 1. Write locally.
    await AppDatabase.instance.upsertCheckin({
      'id': localId,
      'habit_id': habitId,
      'user_id': userId,
      'date': today,
      'sync_status': 'pending_create',
      'synced_at': null,
      'created_at': now,
    });

    ref.invalidate(habitStreakProvider(habitId));
    ref.invalidate(habitHistoryDataProvider(habitId));

    // 2. Enqueue sync op.
    await OfflineQueue.enqueue(PendingOp(
      method: 'POST',
      endpoint: '/habits/$habitId/checkins',
      body: {
        'op_type': 'create_checkin',
        '_local_id': localId,
        '_habit_id': habitId,
        'date': today,
      },
      createdAt: now,
    ));

    // 3. Attempt immediate sync.
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/habits/$habitId/checkins',
        data: {'date': today},
      );
      final serverId = response.data['id'] as String?;
      if (serverId != null && serverId != localId) {
        await AppDatabase.instance.replaceCheckinId(localId, serverId);
      }
      // Remove the queued op since we just synced directly.
      final ops = await OfflineQueue.pending();
      for (final op in ops) {
        if (op.body['_local_id'] == localId) {
          await OfflineQueue.delete(op.id!);
          break;
        }
      }
      state = const CheckinState();
      final milestone = response.data?['milestone_reached'] as int? ?? 0;
      return milestone;
    } on DioException catch (e) {
      // Offline — local write stands; will sync later.
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        state = const CheckinState();
        return 0;
      }
      final message =
          e.response?.data?['error'] as String? ?? 'Failed to log checkin';
      state = CheckinState(error: message);
      return -1;
    }
  }
}

// ── Grace day ─────────────────────────────────────────────────────────────────

@riverpod
class HabitGraceDay extends _$HabitGraceDay {
  @override
  bool build(String habitId) => false;

  Future<bool> claim() async {
    state = true;
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/habits/$habitId/grace');
      ref.invalidate(habitStreakProvider(habitId));
      ref.invalidate(habitHistoryDataProvider(habitId));
      state = false;
      return true;
    } on DioException catch (_) {
      state = false;
      return false;
    }
  }
}

// ── Subtask checkin ───────────────────────────────────────────────────────────

@riverpod
class HabitSubtaskCheckin extends _$HabitSubtaskCheckin {
  @override
  Set<String> build(String habitId) => {};

  Future<void> toggle(String subtaskId, String date) async {
    final current = Set<String>.from(state);
    if (current.contains(subtaskId)) {
      current.remove(subtaskId);
    } else {
      current.add(subtaskId);
    }
    state = current;
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/habits/$habitId/subtask-checkin', data: {
        'date': date,
        'completed_ids': current.toList(),
      });
    } on DioException catch (_) {
      state = Set<String>.from(state)..add(subtaskId);
    }
  }
}
