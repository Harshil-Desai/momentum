import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../habits/models/habit.dart';
import '../../habits/providers/habits_provider.dart';
import '../../insights/providers/insights_provider.dart';
import '../../../core/theme/app_theme.dart';

class WeeklyReflectionScreen extends ConsumerStatefulWidget {
  const WeeklyReflectionScreen({super.key});

  @override
  ConsumerState<WeeklyReflectionScreen> createState() =>
      _WeeklyReflectionScreenState();
}

class _WeeklyReflectionScreenState
    extends ConsumerState<WeeklyReflectionScreen> {
  final _journalController = TextEditingController();
  bool _saved = false;

  static const _prefKey = 'weekly_reflection_note';

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final prefs = await SharedPreferences.getInstance();
    final note = prefs.getString(_weekKey());
    if (note != null && mounted) {
      setState(() => _journalController.text = note);
    }
  }

  Future<void> _saveNote() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weekKey(), _journalController.text.trim());
    if (mounted) setState(() => _saved = true);
  }

  String _weekKey() {
    final now = DateTime.now();
    final weekNumber = _isoWeek(now);
    return '${_prefKey}_${now.year}_w$weekNumber';
  }

  int _isoWeek(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDayOfYear).inDays + 1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  String _weekRangeLabel() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[monday.month]} ${monday.day} – ${months[sunday.month]} ${sunday.day}';
  }

  List<String> _buildWeeklySummary(dynamic insights, List<Habit> habits) {
    final lines = <String>[];
    if (insights == null) return lines;

    final totalThisMonth = insights.monthlyCompleted as int;
    final daysElapsed = DateTime.now().day;
    final activeHabits = habits.length;

    final weekCheckins = daysElapsed > 0
        ? (totalThisMonth * 7 / daysElapsed).round()
        : 0;
    final weekPossible = activeHabits * 7;

    if (weekPossible > 0) {
      final pct = (weekCheckins / weekPossible * 100).round().clamp(0, 100);
      if (pct >= 80) {
        lines.add(
            'You showed up $weekCheckins out of $weekPossible possible times this week. That\'s the kind of week that builds something.');
      } else if (pct >= 50) {
        lines.add(
            'You checked in about $weekCheckins times this week. More than half. Keep going.');
      } else if (weekCheckins > 0) {
        lines.add(
            'A quieter week — $weekCheckins check-ins. Every one still counts.');
      } else {
        lines.add('This week was hard. That\'s okay. You\'re still here.');
      }
    }

    if (insights.strongestDay.isNotEmpty) {
      lines.add(
          'Your most consistent day lately has been ${insights.strongestDay}s.');
    }

    final best = (insights.habitStreaks as List<dynamic>).fold<int>(
      0,
      (max, h) => (h.bestStreak as int) > max ? h.bestStreak as int : max,
    );
    if (best > 0) {
      lines.add('Your longest streak ever: $best days.');
    }

    return lines;
  }

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final habitsAsync = ref.watch(habitsProvider);
    final insightsAsync = ref.watch(insightsProvider);

    return Scaffold(
      backgroundColor: mc.bgCanvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 20, 0),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.chevron_left,
                      size: 28, color: mc.inkPrimary),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This week',
                    style: GoogleFonts.fraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: mc.inkPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _weekRangeLabel(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: mc.inkTertiary,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Divider(height: 1, color: mc.hairline),

            // ── Body ──────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                children: [
                  // Prose summary
                  insightsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (insights) => habitsAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (habits) {
                        final lines = _buildWeeklySummary(insights, habits);
                        if (lines.isEmpty) return const SizedBox.shrink();
                        return Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: CadencePigments.pine.withAlpha(18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: lines
                                    .map((line) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Text(
                                            line,
                                            style: GoogleFonts.fraunces(
                                              fontSize: 15,
                                              fontStyle: FontStyle.italic,
                                              color: mc.inkPrimary,
                                              height: 1.55,
                                              letterSpacing: -0.1,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 28),
                          ],
                        );
                      },
                    ),
                  ),

                  // Journal prompt
                  Text(
                    'What made this week easier or harder?',
                    style: GoogleFonts.fraunces(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: mc.inkPrimary,
                      letterSpacing: -0.2,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Optional. Just for you.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: mc.inkTertiary,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Textarea
                  Container(
                    decoration: BoxDecoration(
                      color: mc.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _journalController,
                      maxLines: 7,
                      onChanged: (_) => setState(() => _saved = false),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: mc.inkPrimary,
                        height: 1.55,
                        letterSpacing: -0.1,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Write anything…',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 15,
                          color: mc.inkTertiary,
                          fontStyle: FontStyle.italic,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Save button
                  GestureDetector(
                    onTap: _journalController.text.isEmpty ? null : _saveNote,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: _journalController.text.isEmpty
                            ? mc.hairlineStrong
                            : mc.inkPrimary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          _saved ? 'Saved' : 'Save note',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _journalController.text.isEmpty
                                ? mc.inkTertiary
                                : mc.bgCanvas,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
