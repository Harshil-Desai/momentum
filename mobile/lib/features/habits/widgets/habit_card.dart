import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit.dart';
import '../providers/habits_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/icon_picker.dart';
import '../widgets/milestone_overlay.dart';

class HabitCard extends ConsumerStatefulWidget {
  const HabitCard({super.key, required this.habit});

  final Habit habit;

  @override
  ConsumerState<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends ConsumerState<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _streakController;
  late Animation<double> _streakScale;
  int _lastStreak = 0;

  @override
  void initState() {
    super.initState();
    _streakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _streakScale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _streakController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _streakController.dispose();
    super.dispose();
  }

  Color get _accent => MomentumPigments.fromHex(widget.habit.color);

  Future<void> _handleCheckin(BuildContext context) async {
    HapticFeedback.lightImpact();
    final historyData = ref.read(habitHistoryDataProvider(widget.habit.id)).valueOrNull;
    final alreadyChecked = historyData?.checkedToday ?? false;

    if (alreadyChecked) {
      await ref.read(habitCheckinProvider(widget.habit.id).notifier).removeToday();
      return;
    }

    final milestone =
        await ref.read(habitCheckinProvider(widget.habit.id).notifier).logToday();

    if (!context.mounted) return;

    if (milestone > 0) {
      await showGeneralDialog(
        context: context,
        barrierDismissible: false,
        pageBuilder: (ctx, _, __) => MilestoneOverlay(
          habitName: widget.habit.name,
          habitIcon: widget.habit.icon,
          milestoneValue: milestone,
          habitColor: widget.habit.color,
        ),
      );
    } else if (milestone < 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to log check-in')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final habit = widget.habit;
    final accent = _accent;
    final accentTint = accent.withAlpha(26); // ~10%

    final historyAsync = ref.watch(habitHistoryDataProvider(habit.id));
    final streakAsync = ref.watch(habitStreakProvider(habit.id));
    final checkedToday = historyAsync.maybeWhen(
      data: (h) => h.checkedToday,
      orElse: () => false,
    );
    final streak = streakAsync.maybeWhen(
      data: (s) => s,
      orElse: () => 0,
    );
    final checkinState = ref.watch(habitCheckinProvider(habit.id));
    final isLoading = checkinState.isLoading;

    // Pulse animation when streak increases
    streakAsync.whenData((s) {
      if (s > _lastStreak) {
        _streakController.forward(from: 0);
      }
      _lastStreak = s;
    });

    return Dismissible(
      key: ValueKey(habit.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final historyData =
            ref.read(habitHistoryDataProvider(habit.id)).valueOrNull;
        final count = historyData?.lifetimeCount ?? 0;
        final eulogyLine = count > 0
            ? 'You showed up for this $count time${count == 1 ? '' : 's'}. That counts.'
            : 'You can always come back to this.';

        return await showModalBottomSheet<bool>(
          context: context,
          builder: (ctx) => _ArchiveSheet(
            habitName: habit.name,
            eulogyLine: eulogyLine,
          ),
        );
      },
      onDismissed: (_) {
        ref.read(habitsProvider.notifier).archiveHabit(habit.id);
      },
      background: ColoredBox(
        color: mc.archiveReveal,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 28),
            child: Text(
              'Archive',
              style: GoogleFonts.fraunces(
                fontSize: 18, fontStyle: FontStyle.italic,
                color: mc.bgCanvas, letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ),
      child: InkWell(
        onTap: () => context.push('/habits/${habit.id}', extra: habit),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Habit icon tile (SVG)
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: accentTint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: HabitSvgIcon(
                        path: habit.icon ?? kDefaultHabitIcon,
                        size: 30,
                        color: _accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  // Name + streak
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 17, fontWeight: FontWeight.w500,
                            color: checkedToday
                                ? mc.inkTertiary
                                : mc.inkPrimary,
                            letterSpacing: -0.2, height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            ScaleTransition(
                              scale: _streakScale,
                              child: Text(
                                streak == 0 ? '—' : '$streak',
                                style: GoogleFonts.fraunces(
                                  fontSize: 56, fontWeight: FontWeight.w400,
                                  color: streak == 0
                                      ? mc.inkTertiary
                                      : accent,
                                  letterSpacing: -1.4, height: 1,
                                ).copyWith(
                                  fontFeatures: const [
                                    FontFeature.liningFigures(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (streak > 0)
                              Text(
                                streak == 1 ? 'day' : 'days',
                                style: GoogleFonts.inter(
                                  fontSize: 12, color: mc.inkSecondary,
                                  letterSpacing: 0.4,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  // Check circle
                  _CheckCircle(
                    accent: accent,
                    bgCanvas: mc.bgCanvas,
                    checked: checkedToday,
                    loading: isLoading,
                    onTap: () => _handleCheckin(context),
                  ),
                ],
              ),
            ),
            // Hairline divider
            Divider(height: 1, color: mc.hairline, indent: 24, endIndent: 24),
          ],
        ),
      ),
    );
  }
}

// ── Check circle ─────────────────────────────────────────────────────────────

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({
    required this.accent,
    required this.bgCanvas,
    required this.checked,
    required this.loading,
    required this.onTap,
  });

  final Color accent;
  final Color bgCanvas;
  final bool checked;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SizedBox(
        width: 44, height: 44,
        child: Center(
          child: SizedBox(
            width: 22, height: 22,
            child: CircularProgressIndicator(strokeWidth: 1.8, color: accent),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutBack,
        width: 44, height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: checked ? accent : Colors.transparent,
          border: Border.all(color: accent, width: 1.5),
        ),
        child: Center(
          child: AnimatedOpacity(
            opacity: checked ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 220),
            child: AnimatedScale(
              scale: checked ? 1.0 : 0.6,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              child: Icon(Icons.check_rounded, size: 20, color: bgCanvas),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Archive confirmation sheet ────────────────────────────────────────────────

class _ArchiveSheet extends StatelessWidget {
  const _ArchiveSheet({
    required this.habitName,
    required this.eulogyLine,
  });

  final String habitName;
  final String eulogyLine;

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
              width: 36, height: 4,
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
                  fontSize: 20, color: mc.inkPrimary, letterSpacing: -0.3,
                ),
              ),
              TextSpan(
                text: habitName,
                style: GoogleFonts.fraunces(
                  fontSize: 20, fontStyle: FontStyle.italic,
                  color: mc.inkPrimary, letterSpacing: -0.3,
                ),
              ),
              TextSpan(
                text: '?',
                style: GoogleFonts.fraunces(
                  fontSize: 20, color: mc.inkPrimary, letterSpacing: -0.3,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Text(
            eulogyLine,
            style: GoogleFonts.inter(
              fontSize: 14, color: mc.inkSecondary,
              letterSpacing: -0.1, height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _SheetButton(
            label: 'Archive',
            danger: true,
            onTap: () => Navigator.pop(context, true),
          ),
          const SizedBox(height: 4),
          _SheetButton(
            label: 'Keep going',
            onTap: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
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
