import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/api_client.dart';
import '../data/achievement_catalogue.dart';
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
    final raw = AchievementsData.fromJson(response.data as Map<String, dynamic>);

    // Merge catalogue with API-earned data so locked achievements always appear.
    final earnedMap = {for (final e in raw.earned) e.id: e};
    final merged = kAchievementCatalogue.map((item) {
      return earnedMap[item.id] ?? item;
    }).toList();

    // Append any API-earned achievements not in the catalogue (future-proofing).
    final catalogueIds = kAchievementCatalogue.map((e) => e.id).toSet();
    for (final earned in raw.earned) {
      if (!catalogueIds.contains(earned.id)) merged.add(earned);
    }

    return AchievementsData(
      all: merged,
      inProgress: raw.inProgress,
      newlyEarned: raw.newlyEarned,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
