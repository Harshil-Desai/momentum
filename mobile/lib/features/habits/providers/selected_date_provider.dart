import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => _today());

DateTime _today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

String selectedDateString(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
