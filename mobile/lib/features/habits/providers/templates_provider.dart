import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/api_client.dart';
import '../models/template.dart';

part 'templates_provider.g.dart';

@riverpod
class Templates extends _$Templates {
  @override
  Future<Map<String, List<HabitTemplate>>> build() async {
    return _fetchTemplates();
  }

  Future<Map<String, List<HabitTemplate>>> _fetchTemplates() async {
    final dio = ref.read(dioProvider);
    final response = await dio.get('/templates');
    final list = response.data['templates'] as List<dynamic>? ?? [];
    final templates = list
        .map((e) => HabitTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
    // Group by category
    final grouped = <String, List<HabitTemplate>>{};
    for (final t in templates) {
      grouped.putIfAbsent(t.category, () => []).add(t);
    }
    return grouped;
  }

  Future<bool> adopt(String templateId) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/templates/$templateId/adopt');
      return true;
    } catch (_) {
      return false;
    }
  }
}
