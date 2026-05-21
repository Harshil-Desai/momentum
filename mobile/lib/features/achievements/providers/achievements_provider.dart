import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/api_client.dart';
import '../models/achievement.dart';

part 'achievements_provider.g.dart';

@riverpod
class Achievements extends _$Achievements {
  @override
  Future<AchievementsData> build() async {
    return _fetch();
  }

  Future<AchievementsData> _fetch() async {
    final dio = ref.read(dioProvider);
    final response = await dio.get('/achievements');
    return AchievementsData.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
