import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_date_provider.g.dart';

@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => _today();

  void set(DateTime date) => state = date;
}

DateTime _today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

String selectedDateString(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
