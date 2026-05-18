import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/habits_provider.dart';
import '../widgets/habit_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/offline/offline_status_indicator.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  bool _profileOpen = false;

  String get _dateLabel {
    final now = DateTime.now();
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      backgroundColor: mc.bgCanvas,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Momentum',
                        style: GoogleFonts.fraunces(
                          fontSize: 22, fontWeight: FontWeight.w400,
                          color: mc.inkPrimary, letterSpacing: -0.4,
                        ),
                      ),
                      const Spacer(),
                      const OfflineStatusIndicator(),
                      const SizedBox(width: 10),
                      _AvatarButton(onTap: () => setState(() => _profileOpen = true)),
                    ],
                  ),
                ),
                // Date
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                  child: Text(
                    _dateLabel,
                    style: GoogleFonts.inter(
                      fontSize: 13, fontStyle: FontStyle.italic,
                      color: mc.inkTertiary, letterSpacing: -0.1,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Habit list ────────────────────────────────────────────
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
                      final visible =
                          habits.where((h) => !h.archived).toList();
                      if (visible.isEmpty) return _EmptyState(mc: mc);

                      return RefreshIndicator(
                        onRefresh: () =>
                            ref.read(habitsProvider.notifier).refresh(),
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 120),
                          children: [
                            ...visible.map((h) => HabitCard(habit: h)),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                              child: _ProgressLine(habits: visible),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── FAB ─────────────────────────────────────────────────────────
          Positioned(
            right: 24,
            bottom: 48,
            child: _Fab(onTap: () => context.push('/habits/new')),
          ),

          // ── Profile sheet (modal) ─────────────────────────────────────
          if (_profileOpen)
            _ProfileSheet(
              onClose: () => setState(() => _profileOpen = false),
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
            ),
        ],
      ),
    );
  }

}

// ── Progress line ──────────────────────────────────────────────────────────────
// Watches per-habit history to count only habits not yet checked in today.

class _ProgressLine extends ConsumerWidget {
  const _ProgressLine({required this.habits});

  final List habits;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mc = context.mc;

    // Count habits where checkedToday is false (or history not yet loaded).
    int waiting = 0;
    for (final h in habits) {
      final history =
          ref.watch(habitHistoryDataProvider(h.id)).valueOrNull;
      if (history == null || !history.checkedToday) waiting++;
    }

    final text = waiting == 0
        ? 'All done for today. ✓'
        : 'Keep going — $waiting habit${waiting == 1 ? '' : 's'} waiting.';

    return Text(
      text,
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

class _AvatarButton extends ConsumerWidget {
  const _AvatarButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mc = context.mc;
    // Derive initial from auth state; fall back to 'M'
    final initial = 'M';
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
    required this.onInsights,
    required this.onReflection,
    required this.onTemplates,
    required this.onSettings,
  });

  final VoidCallback onClose;
  final VoidCallback onInsights;
  final VoidCallback onReflection;
  final VoidCallback onTemplates;
  final VoidCallback onSettings;

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
                _SheetRow(label: 'Your patterns', onTap: onInsights),
                _SheetRow(label: 'This week', onTap: onReflection),
                _SheetRow(label: 'Borrow a starter habit', onTap: onTemplates),
                _SheetRow(label: 'Settings', onTap: onSettings),
                _SheetRow(
                  label: 'Sign out',
                  danger: true,
                  onTap: () {
                    onClose();
                    context.go('/login');
                  },
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
  const _Fab({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_Fab> createState() => _FabState();
}

class _FabState extends State<_Fab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
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

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.mc});
  final MomentumColors mc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A blank page.',
            style: GoogleFonts.fraunces(
              fontSize: 28, fontStyle: FontStyle.italic,
              color: mc.inkPrimary, letterSpacing: -0.4, height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap + to write your first promise — or borrow one below.',
            style: GoogleFonts.inter(
              fontSize: 14, color: mc.inkSecondary,
              letterSpacing: -0.1, height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => context.push('/templates'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: mc.hairlineStrong),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.list_alt_rounded, size: 14, color: mc.inkPrimary),
                  const SizedBox(width: 8),
                  Text(
                    'Borrow a starter habit',
                    style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: mc.inkPrimary, letterSpacing: -0.05,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
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
