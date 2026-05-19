import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit.dart';
import '../providers/habits_provider.dart';
import '../providers/reminder_provider.dart';
import '../widgets/icon_picker.dart';
import '../../../core/theme/app_theme.dart';

class HabitDetailScreen extends ConsumerWidget {
  final Habit habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mc = context.mc;
    final accent = CadencePigments.fromHex(habit.color);
    final streakAsync = ref.watch(habitStreakProvider(habit.id));
    final historyAsync = ref.watch(habitHistoryDataProvider(habit.id));

    final streak = streakAsync.maybeWhen(data: (s) => s, orElse: () => 0);
    final history = historyAsync.valueOrNull;

    return Scaffold(
      backgroundColor: mc.bgCanvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 48),
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.chevron_left,
                        size: 28,
                        color: mc.inkPrimary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () =>
                        context.push('/habits/${habit.id}/edit', extra: habit),
                    child: Text(
                      'Edit',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: mc.inkSecondary,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Hero ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: accent.withAlpha(26),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: HabitSvgIcon(
                        path: habit.icon ?? kDefaultHabitIcon,
                        size: 34,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: GoogleFonts.fraunces(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: mc.inkPrimary,
                            letterSpacing: -0.4,
                            height: 1.2,
                          ),
                        ),
                        if (streak > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            '$streak day streak',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: accent,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        // Cadence badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(color: mc.hairline),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            habit.frequency.label,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: mc.inkTertiary,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Stat tiles ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _StatTile(
                    label: 'BEST STREAK',
                    value: history == null || history.bestStreak == 0
                        ? '—'
                        : '${history.bestStreak}',
                    suffix: history != null && history.bestStreak > 0
                        ? 'days'
                        : null,
                    accent: accent,
                    mc: mc,
                  ),
                  const SizedBox(width: 12),
                  _StatTile(
                    label: 'TOTAL CHECK-INS',
                    value: '${history?.lifetimeCount ?? 0}',
                    accent: accent,
                    mc: mc,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            Divider(height: 1, color: mc.hairline, indent: 24, endIndent: 24),
            const SizedBox(height: 24),

            // ── This month ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('THIS MONTH', mc),
                  const SizedBox(height: 12),
                  historyAsync.when(
                    loading: () => const SizedBox(
                      height: 80,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (h) =>
                        _MonthGraph(dates: h.dates, accent: accent, mc: mc),
                  ),
                ],
              ),
            ),

            // ── Why this matters ──────────────────────────────────────────
            if (habit.note != null && habit.note!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Divider(
                  height: 1, color: mc.hairline, indent: 24, endIndent: 24),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel('WHY THIS MATTERS', mc),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accent.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        habit.note!,
                        style: GoogleFonts.fraunces(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: mc.inkPrimary,
                          height: 1.55,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── On hard days ──────────────────────────────────────────────
            if (habit.twoMinuteVersion != null &&
                habit.twoMinuteVersion!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel('ON HARD DAYS', mc),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: mc.hairlineStrong, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 16, color: mc.inkTertiary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              habit.twoMinuteVersion!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: mc.inkSecondary,
                                height: 1.5,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Subtasks ──────────────────────────────────────────────────
            if (habit.subtasks.isNotEmpty) ...[
              const SizedBox(height: 24),
              Divider(
                  height: 1, color: mc.hairline, indent: 24, endIndent: 24),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel('TODAY\'S CHECKLIST', mc),
                    const SizedBox(height: 12),
                    _SubtaskChecklist(habit: habit, accent: accent, mc: mc),
                  ],
                ),
              ),
            ],

            // ── Stack chain ───────────────────────────────────────────────
            if (habit.stackAfterHabitId != null &&
                habit.stackAfterHabitId!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _StackChainBadge(habit: habit, mc: mc),
              ),
            ],

            // ── Grace day ─────────────────────────────────────────────────
            if (history != null && history.canClaimGrace) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _GraceChip(habitId: habit.id, accent: accent),
              ),
            ],

            // ── Reminder ──────────────────────────────────────────────────
            const SizedBox(height: 24),
            Divider(height: 1, color: mc.hairline, indent: 24, endIndent: 24),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('REMINDER', mc),
                  const SizedBox(height: 12),
                  _ReminderTile(habit: habit, mc: mc),
                ],
              ),
            ),

            // ── Archive button ────────────────────────────────────────────
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _ArchiveButton(habit: habit),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final CadenceColors mc;
  const _SectionLabel(this.text, this.mc);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.4,
        color: mc.inkTertiary,
      ),
    );
  }
}

// ── Stat tile ─────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;
  final Color accent;
  final CadenceColors mc;

  const _StatTile({
    required this.label,
    required this.value,
    this.suffix,
    required this.accent,
    required this.mc,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          border: Border.all(color: mc.hairline, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
                color: mc.inkTertiary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.fraunces(
                    fontSize: 40,
                    fontWeight: FontWeight.w400,
                    color: value == '—' ? mc.inkTertiary : accent,
                    letterSpacing: -1.0,
                    height: 1,
                  ),
                ),
                if (suffix != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    suffix!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: mc.inkSecondary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Month graph ───────────────────────────────────────────────────────────────

class _MonthGraph extends StatelessWidget {
  final List<String> dates;
  final Color accent;
  final CadenceColors mc;

  const _MonthGraph({
    required this.dates,
    required this.accent,
    required this.mc,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final checkedSet = dates.toSet();

    final firstDay = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    // Sun=0 grid: Dart weekday Mon=1...Sun=7 → Sun=0 offset via % 7
    final startOffset = firstDay.weekday % 7;
    final numWeeks = ((startOffset + daysInMonth) / 7).ceil();

    String dateStr(int day) =>
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    final todayStr = dateStr(now.day);

    int kept = 0;
    for (int d = 1; d <= now.day; d++) {
      if (checkedSet.contains(dateStr(d))) kept++;
    }

    const months = [
      '',
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    const cellH = 18.0;
    const cellGap = 3.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day-of-week labels (Mon, Wed, Fri)
            Column(
              children: List.generate(7, (i) {
                final show = i == 1 || i == 3 || i == 5;
                return SizedBox(
                  height: cellH + cellGap,
                  child: show
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            dayLabels[i],
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: mc.inkTertiary,
                            ),
                          ),
                        )
                      : null,
                );
              }),
            ),
            const SizedBox(width: 6),
            // Week columns
            ...List.generate(numWeeks, (weekIdx) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: List.generate(7, (dow) {
                      final cellIndex = weekIdx * 7 + dow;
                      final dayNum = cellIndex - startOffset + 1;

                      if (dayNum < 1 || dayNum > daysInMonth) {
                        return SizedBox(height: cellH + cellGap);
                      }

                      final ds = dateStr(dayNum);
                      final isToday = ds == todayStr;
                      final isFuture = dayNum > now.day;
                      final isKept = checkedSet.contains(ds);

                      Color cellColor;
                      BoxBorder? border;
                      if (isFuture) {
                        cellColor = Colors.transparent;
                      } else if (isKept) {
                        cellColor = accent;
                      } else {
                        cellColor = mc.hairlineStrong;
                      }
                      if (isToday && !isKept) {
                        border = Border.all(color: accent, width: 1.5);
                        cellColor = Colors.transparent;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: cellGap),
                        height: cellH,
                        decoration: BoxDecoration(
                          color: cellColor,
                          borderRadius: BorderRadius.circular(3),
                          border: border,
                        ),
                      );
                    }),
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${months[now.month]} · $kept of ${now.day} so far',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: mc.inkTertiary,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}

// ── Grace chip ────────────────────────────────────────────────────────────────

class _GraceChip extends ConsumerWidget {
  final String habitId;
  final Color accent;
  const _GraceChip({required this.habitId, required this.accent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(habitGraceDayProvider(habitId));

    return GestureDetector(
      onTap: isLoading
          ? null
          : () async {
              final ok = await ref
                  .read(habitGraceDayProvider(habitId).notifier)
                  .claim();
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Grace day already used this month'),
                  ),
                );
              }
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: accent.withAlpha(20),
          border: Border.all(color: accent.withAlpha(70)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child:
                    CircularProgressIndicator(strokeWidth: 2, color: accent),
              )
            else
              Icon(Icons.shield_outlined, size: 16, color: accent),
            const SizedBox(width: 10),
            Text(
              'Use a grace day · keep the streak',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: accent,
                letterSpacing: -0.05,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reminder tile ─────────────────────────────────────────────────────────────

class _ReminderTile extends ConsumerWidget {
  final Habit habit;
  final CadenceColors mc;
  const _ReminderTile({required this.habit, required this.mc});

  Future<void> _pickTime(
      BuildContext context, WidgetRef ref, TimeOfDay? current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current ?? const TimeOfDay(hour: 8, minute: 0),
      helpText: 'Set daily reminder',
    );
    if (picked != null && context.mounted) {
      final ok = await ref
          .read(habitReminderNotifierProvider(habit.id).notifier)
          .set(habit, picked);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please allow notifications in Settings to set a reminder'),
          ),
        );
        return;
      }
      ref.invalidate(habitReminderNotifierProvider(habit.id));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminderAsync = ref.watch(habitReminderNotifierProvider(habit.id));
    final reminder = reminderAsync.valueOrNull;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: mc.hairlineStrong, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: mc.hairline,
            ),
            child: Center(
              child: Icon(
                reminder != null
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_none_outlined,
                size: 18,
                color: mc.inkPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reminder != null
                  ? 'Daily at ${reminder.label}'
                  : 'No reminder set',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: mc.inkPrimary,
                letterSpacing: -0.1,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _pickTime(context, ref, reminder?.timeOfDay),
            child: Text(
              reminder != null ? 'Change' : 'Set time',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: mc.inkSecondary,
                letterSpacing: -0.05,
              ),
            ),
          ),
          if (reminder != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => ref
                  .read(habitReminderNotifierProvider(habit.id).notifier)
                  .cancel(),
              child: Icon(Icons.close, size: 16, color: mc.inkTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Subtask checklist ─────────────────────────────────────────────────────────

class _SubtaskChecklist extends ConsumerWidget {
  final Habit habit;
  final Color accent;
  final CadenceColors mc;
  const _SubtaskChecklist(
      {required this.habit, required this.accent, required this.mc});

  String get _todayStr {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedIds = ref.watch(habitSubtaskCheckinProvider(habit.id));
    final total = habit.subtasks.length;
    final done =
        habit.subtasks.where((s) => completedIds.contains(s.id)).length;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: mc.hairlineStrong, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: total == 0 ? 0.0 : done / total,
            minHeight: 4,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
          // Subtask rows
          ...habit.subtasks.asMap().entries.map((entry) {
            final idx = entry.key;
            final subtask = entry.value;
            final checked = completedIds.contains(subtask.id);
            final isLast = idx == habit.subtasks.length - 1;
            return Column(
              children: [
                InkWell(
                  onTap: () => ref
                      .read(habitSubtaskCheckinProvider(habit.id).notifier)
                      .toggle(subtask.id, _todayStr),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: checked ? accent : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: checked ? accent : mc.hairlineStrong,
                              width: 1.5,
                            ),
                          ),
                          child: checked
                              ? Icon(Icons.check_rounded,
                                  size: 12, color: mc.bgCanvas)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            subtask.label,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: checked ? mc.inkTertiary : mc.inkPrimary,
                              decoration: checked
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: mc.inkTertiary,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(
                      height: 1, color: mc.hairline, indent: 48, endIndent: 0),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Stack chain badge ─────────────────────────────────────────────────────────

class _StackChainBadge extends ConsumerWidget {
  final Habit habit;
  final CadenceColors mc;
  const _StackChainBadge({required this.habit, required this.mc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final stackHabit = habitsAsync.valueOrNull
        ?.where((h) => h.id == habit.stackAfterHabitId)
        .firstOrNull;

    if (stackHabit == null) return const SizedBox.shrink();

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _ChainChip(label: stackHabit.name, mc: mc),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward, size: 12, color: mc.inkTertiary),
        ),
        _ChainChip(label: habit.name, mc: mc, highlighted: true),
      ],
    );
  }
}

class _ChainChip extends StatelessWidget {
  final String label;
  final CadenceColors mc;
  final bool highlighted;
  const _ChainChip(
      {required this.label, required this.mc, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: highlighted ? mc.inkPrimary.withAlpha(8) : null,
        border: Border.all(
            color: highlighted ? mc.hairlineStrong : mc.hairline),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: highlighted ? FontWeight.w500 : FontWeight.normal,
          color: mc.inkPrimary,
        ),
      ),
    );
  }
}

// ── Archive button ────────────────────────────────────────────────────────────

class _ArchiveButton extends ConsumerWidget {
  final Habit habit;
  const _ArchiveButton({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mc = context.mc;
    return GestureDetector(
      onTap: () async {
        final confirmed = await showModalBottomSheet<bool>(
          context: context,
          builder: (_) => _ArchiveSheet(habit: habit),
        );
        if (confirmed == true && context.mounted) {
          await ref.read(habitsProvider.notifier).archiveHabit(habit.id);
          if (context.mounted) context.pop();
        }
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: mc.hairlineStrong),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            'Archive habit',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: mc.danger,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArchiveSheet extends StatelessWidget {
  final Habit habit;
  const _ArchiveSheet({required this.habit});

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: mc.hairlineStrong,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: 'Archive ',
                style: GoogleFonts.fraunces(
                  fontSize: 20,
                  color: mc.inkPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              TextSpan(
                text: habit.name,
                style: GoogleFonts.fraunces(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: mc.inkPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              TextSpan(
                text: '?',
                style: GoogleFonts.fraunces(
                  fontSize: 20,
                  color: mc.inkPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Text(
            'You can always bring it back from settings.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: mc.inkSecondary,
              letterSpacing: -0.1,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () => Navigator.pop(context, true),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
              child: Text(
                'Archive',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: mc.danger,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.pop(context, false),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
              child: Text(
                'Keep going',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: mc.inkPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
