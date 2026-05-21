import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/api_client.dart';
import '../models/daily_log.dart';

part 'daily_log_provider.g.dart';

@riverpod
class DailyLog extends _$DailyLog {
  @override
  bool build() => false; // submittedToday (session-scoped)

  Future<bool> submit({int? mood, int? energy}) async {
    if (state) return true; // already submitted this session
    try {
      final dio = ref.read(dioProvider);
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      await dio.post('/daily-log', data: {
        'date': dateStr,
        if (mood != null) 'mood': mood,
        if (energy != null) 'energy': energy,
      });
      state = true;
      return true;
    } on DioException catch (_) {
      return false;
    }
  }

  void markSkipped() => state = true;
}

@riverpod
Future<DailyLogData?> todayLog(Ref ref) async {
  final dio = ref.read(dioProvider);
  final today = DateTime.now();
  final dateStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  try {
    final response =
        await dio.get('/daily-log', queryParameters: {'date': dateStr});
    if (response.data == null || (response.data as Map).isEmpty) return null;
    return DailyLogData.fromJson(response.data as Map<String, dynamic>);
  } on DioException catch (_) {
    return null;
  }
}
