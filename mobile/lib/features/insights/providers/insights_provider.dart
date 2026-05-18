import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/api_client.dart';
import '../models/insights_data.dart';

part 'insights_provider.g.dart';

@riverpod
class Insights extends _$Insights {
  @override
  Future<InsightsData> build() async {
    return _fetch();
  }

  Future<InsightsData> _fetch() async {
    final dio = ref.read(dioProvider);
    final response = await dio.get('/insights');
    return InsightsData.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
