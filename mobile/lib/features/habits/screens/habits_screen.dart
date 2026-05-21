import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/habits_provider.dart';
import '../providers/selected_date_provider.dart';
import '../widgets/habit_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/offline/offline_status_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/database/app_database.dart';

// Checks whether any active habit was missed yesterday (no check-in).
final _missedYesterdayProvider = FutureProvider.autoDispose<bool>((ref) async {
  final userId = ref.watch(authProvider).value?.userId;
  if (userId == null || userId.isEmpty) return false;
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  final ys = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  final habits = await AppDatabase.instance.getActiveHabits(userId);
  if (habits.isEmpty) return false;
  final checkins = await AppDatabase.instance.getCheckinsForDate(userId, ys);
  final checkedIds = checkins.map((r) => r['habit_id'] as String).toSet();
  return habits.any((h) => !checkedIds.contains(h['id'] as String));
});

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen>
    with TickerProviderStateMixin {
  bool _profileOpen = false;
  final _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _moodController;
  late Animation<double> _moodAnimation;

  @override
  void initState() {
    super.initState();
    _moodController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      reverseDuration: const Duration(milliseconds: 420),
    );
    _moodAnimation = CurvedAnimation(
      parent: _moodController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _moodController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  Future<void> _pickDate(CadenceColors mc) async {
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final current = ref.read(selectedDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: todayNorm.subtract(const Duration(days: 30)),
      lastDate: todayNorm,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: mc.inkPrimary,
            onPrimary: mc.bgCanvas,
            surface: mc.bgCanvas,
            onSurface: mc.inkPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      ref.read(selectedDateProvider.notifier).set(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lightMc = context.mc;
    const darkMc = CadenceColors.dark;
    final selectedDate = ref.watch(selectedDateProvider);
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final isPastDay = selectedDate.isBefore(todayNorm);
    final habitsAsync = ref.watch(habitsProvider);
    final missedYesterday = ref.watch(_missedYesterdayProvider).value ?? false;

    return AnimatedBuilder(
      animation: _moodAnimation,
      builder: (context, child) {
        final t = _moodAnimation.value;
        final mc = t == 0 ? lightMc : lightMc.lerp(darkMc, t);
        return Theme(
          data: Theme.of(context).copyWith(extensions: [mc]),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                // ── Mood background (diagonal ripple reveal) ──────────────
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MoodPainter(
                      progress: t,
                      lightBg: lightMc.bgCanvas,
                      darkBg: darkMc.bgCanvas,
                    ),
                  ),
                ),

                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ──────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Cadence',
                              style: GoogleFonts.fraunces(
                                fontSize: 22, fontWeight: FontWeight.w400,
                                color: mc.inkPrimary, letterSpacing: -0.4,
                              ),
                            ),
                            const Spacer(),
                            const OfflineStatusIndicator(),
                            const SizedBox(width: 10),
                            _AvatarButton(
                              onTap: () => setState(() => _profileOpen = true),
                            ),
                          ],
                        ),
                      ),
                      // Tappable date
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                        child: GestureDetector(
                          onTap: () => _pickDate(mc),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatDate(selectedDate),
                                style: GoogleFonts.inter(
                                  fontSize: 13, fontStyle: FontStyle.italic,
                                  color: mc.inkTertiary, letterSpacing: -0.1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.expand_more_rounded,
                                size: 15,
                                color: mc.inkTertiary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Past day banner
                      if (isPastDay) ...[
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                          child: Row(
                            children: [
                              Icon(Icons.history_rounded, size: 13, color: mc.inkTertiary),
                              const SizedBox(width: 4),
                              Text(
                                'Viewing a past day — tap check circles to update',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: mc.inkTertiary,
                                  letterSpacing: -0.05,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Missed-yesterday banner
                      if (!isPastDay && missedYesterday) ...[
                        const SizedBox(height: 6),
                        _MissedDayBanner(mc: mc, onTap: () {
                          final yesterday = todayNorm.subtract(const Duration(days: 1));
                          ref.read(selectedDateProvider.notifier).set(yesterday);
                        }),
                      ],
                      const SizedBox(height: 16),

                      // ── Section tabs ─────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                        child: _SectionTabs(
                          currentIndex: _currentPage,
                          onTap: (i) {
                            _pageController.animateToPage(
                              i,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          mc: mc,
                        ),
                      ),

                      // ── Swipable habit pages ──────────────────────────────
                      Expanded(
                        child: habitsAsync.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          error: (e, _) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Could not load habits.',
                                  style: GoogleFonts.inter(
                                      color: mc.inkSecondary, fontSize: 15),
                                ),
                                const SizedBox(height: 16),
                                _InkButton(
                                  label: 'Try again',
                                  onTap: () =>
                                      ref.read(habitsProvider.notifier).refresh(),
                                ),
                              ],
                            ),
                          ),
                          data: (habits) {
                            // Exclude habits created after the selected date
                            final visibleDay = selectedDate.add(const Duration(days: 1));
                            final filtered = habits.where((h) {
                              if (h.createdAt == null) return true;
                              return !h.createdAt!.isAfter(visibleDay);
                            }).toList();
                            final building = filtered
                                .where((h) => !h.archived && !h.isNegative)
                                .toList();
                            final avoiding = filtered
                                .where((h) => !h.archived && h.isNegative)
                                .toList();

                            return PageView(
                              controller: _pageController,
                              onPageChanged: (i) {
                                setState(() => _currentPage = i);
                                if (i == 1) {
                                  _moodController.forward();
                                } else {
                                  _moodController.reverse();
                                }
                              },
                              children: [
                                _HabitPage(
                                  habits: building,
                                  emptyMessage: 'Nothing to build yet.',
                                  mc: mc,
                                  selectedDate: selectedDate,
                                  showTemplateCta: true,
                                ),
                                _HabitPage(
                                  habits: avoiding,
                                  emptyMessage: 'No avoiding habits yet.\nTap + and mark a habit as negative.',
                                  mc: mc,
                                  selectedDate: selectedDate,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // ── FAB ────────────────────────────────────────────────────
                Positioned(
                  right: 24,
                  bottom: 48,
                  child: _Fab(onTap: () => context.push('/habits/new'), mc: mc),
                ),

                // ── Profile sheet (modal) ──────────────────────────────────
                if (_profileOpen)
                  _ProfileSheet(
                    onClose: () => setState(() => _profileOpen = false),
                    onAchievements: () {
                      setState(() => _profileOpen = false);
                      context.push('/achievements');
                    },
                    onInsights: () {
                      setState(() => _profileOpen = false);
                      context.push('/insights');
                    },
                    onReflection: () {
                      setState(() => _profileOpen = false);
                      context.push('/reflection');
                    },
                    onTemplates: () {
                      setState(() => _profileOpen = false);
                      context.push('/templates');
                    },
                    onSettings: () {
                      setState(() => _profileOpen = false);
                      context.push('/settings');
                    },
                    onSignOut: () async {
                      setState(() => _profileOpen = false);
                      await ref.read(authProvider.notifier).logout();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

}

// ── Section tabs ──────────────────────────────────────────────────────────────

class _SectionTabs extends StatelessWidget {
  const _SectionTabs({
    required this.currentIndex,
    required this.onTap,
    required this.mc,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final CadenceColors mc;

  @override
  Widget build(BuildContext context) {
    const labels = ['Building', 'Avoiding'];
    return Row(
      children: List.generate(labels.length, (i) {
        final selected = i == currentIndex;
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(right: i == 0 ? 8 : 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? mc.inkPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: selected ? mc.inkPrimary : mc.hairlineStrong,
              ),
            ),
            child: Text(
              labels[i],
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? mc.bgCanvas : mc.inkTertiary,
                letterSpacing: -0.05,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Habit page (one per section) ──────────────────────────────────────────────

class _HabitPage extends ConsumerWidget {
  const _HabitPage({
    required this.habits,
    required this.emptyMessage,
    required this.mc,
    required this.selectedDate,
    this.showTemplateCta = false,
  });

  final List habits;
  final String emptyMessage;
  final CadenceColors mc;
  final DateTime selectedDate;
  final bool showTemplateCta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (habits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              emptyMessage,
              style: GoogleFonts.fraunces(
                fontSize: 17,
                fontStyle: FontStyle.italic,
                color: mc.inkTertiary,
                height: 1.5,
                letterSpacing: -0.2,
              ),
            ),
            if (showTemplateCta) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => context.push('/templates'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: mc.inkPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          size: 16, color: mc.bgCanvas),
                      const SizedBox(width: 8),
                      Text(
                        'Borrow a starter habit',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: mc.bgCanvas,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.push('/habits/new'),
                child: Text(
                  'or create your own',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: mc.inkTertiary,
                    letterSpacing: -0.05,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(habitsProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          ...habits.map((h) => HabitCard(habit: h, selectedDate: selectedDate)),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
            child: _ProgressLine(habits: habits, selectedDate: selectedDate),
          ),
        ],
      ),
    );
  }
}

// ── Progress line ──────────────────────────────────────────────────────────────
// Watches per-habit history to count only habits not yet checked in today.

class _ProgressLine extends ConsumerWidget {
  const _ProgressLine({required this.habits, required this.selectedDate});

  final List habits;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mc = context.mc;
    final dateStr = selectedDateString(selectedDate);

    int waiting = 0;
    for (final h in habits) {
      final history = ref.watch(habitHistoryDataProvider(h.id)).value;
      final checked = history != null && history.dates.contains(dateStr);
      if (!checked) waiting++;
    }

    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final isPast = selectedDate.isBefore(todayNorm);
    final doneLabel = isPast ? 'All logged for that day. ✓' : 'All done for today. ✓';
    final waitingLabel = isPast
        ? '$waiting habit${waiting == 1 ? '' : 's'} not logged for that day.'
        : 'Keep going — $waiting habit${waiting == 1 ? '' : 's'} waiting.';

    return Text(
      waiting == 0 ? doneLabel : waitingLabel,
      textAlign: TextAlign.center,
      style: GoogleFonts.fraunces(
        fontSize: 13,
        fontStyle: FontStyle.italic,
        color: mc.inkTertiary,
      ),
    );
  }
}

// ── Avatar button ─────────────────────────────────────────────────────────────

String _initials(String? name, String? email) {
  if (name != null && name.trim().isNotEmpty) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }
  if (email != null && email.isNotEmpty) {
    return email[0].toUpperCase();
  }
  return 'C';
}

class _AvatarButton extends ConsumerWidget {
  const _AvatarButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mc = context.mc;
    final auth = ref.watch(authProvider).value;
    final initial = _initials(auth?.name, auth?.email);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: mc.hairlineStrong, width: 1),
        ),
        child: Center(
          child: Text(
            initial,
            style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w500,
              color: mc.inkPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Profile sheet ─────────────────────────────────────────────────────────────

class _ProfileSheet extends StatelessWidget {
  const _ProfileSheet({
    required this.onClose,
    required this.onAchievements,
    required this.onInsights,
    required this.onReflection,
    required this.onTemplates,
    required this.onSettings,
    required this.onSignOut,
  });

  final VoidCallback onClose;
  final VoidCallback onAchievements;
  final VoidCallback onInsights;
  final VoidCallback onReflection;
  final VoidCallback onTemplates;
  final VoidCallback onSettings;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: mc.scrim,
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {}, // prevent dismiss when tapping sheet body
          child: Container(
            decoration: BoxDecoration(
              color: mc.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: mc.hairlineStrong,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _SheetRow(label: 'Achievements', onTap: onAchievements),
                _SheetRow(label: 'Your patterns', onTap: onInsights),
                _SheetRow(label: 'This week', onTap: onReflection),
                _SheetRow(label: 'Borrow a starter habit', onTap: onTemplates),
                _SheetRow(label: 'Settings', onTap: onSettings),
                _SheetRow(
                  label: 'Sign out',
                  danger: true,
                  onTap: onSignOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: mc.hairline, width: 1)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w500,
            color: danger ? mc.danger : mc.inkPrimary,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}

// ── FAB ───────────────────────────────────────────────────────────────────────

class _Fab extends StatefulWidget {
  const _Fab({required this.onTap, required this.mc});
  final VoidCallback onTap;
  final CadenceColors mc;

  @override
  State<_Fab> createState() => _FabState();
}

class _FabState extends State<_Fab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final mc = widget.mc;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: mc.inkPrimary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: mc.inkPrimary.withAlpha(51),
                blurRadius: 18, offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: mc.inkPrimary.withAlpha(31),
                blurRadius: 4, offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(Icons.add, color: mc.bgCanvas, size: 22),
          ),
        ),
      ),
    );
  }
}


// ── Mood reveal painter ───────────────────────────────────────────────────────

class _MoodPainter extends CustomPainter {
  final double progress;
  final Color lightBg;
  final Color darkBg;

  const _MoodPainter({
    required this.progress,
    required this.lightBg,
    required this.darkBg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = lightBg,
    );
    if (progress > 0) {
      final maxR = math.sqrt(size.width * size.width + size.height * size.height);
      canvas.drawCircle(
        Offset.zero,
        maxR * progress,
        Paint()..color = darkBg,
      );
    }
  }

  @override
  bool shouldRepaint(_MoodPainter old) =>
      old.progress != progress || old.lightBg != lightBg || old.darkBg != darkBg;
}


// ── Ink button (full-width, primary) ─────────────────────────────────────────

class _InkButton extends StatelessWidget {
  const _InkButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: mc.inkPrimary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w500,
              color: mc.bgCanvas, letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Missed-day banner ─────────────────────────────────────────────────────────

class _MissedDayBanner extends StatelessWidget {
  const _MissedDayBanner({required this.mc, required this.onTap});
  final CadenceColors mc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: mc.inkPrimary.withAlpha(10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: mc.hairlineStrong),
          ),
          child: Row(
            children: [
              Icon(Icons.wb_twilight_rounded, size: 15, color: mc.inkTertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Yesterday slipped by — tap to log it.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: mc.inkSecondary,
                    letterSpacing: -0.05,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 16, color: mc.inkTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
