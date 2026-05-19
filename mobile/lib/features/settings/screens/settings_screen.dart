import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../../habits/providers/habits_provider.dart';
import '../../habits/models/habit.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mc = context.mc;
    final archivedAsync = ref.watch(archivedHabitsProvider);

    return Scaffold(
      backgroundColor: mc.bgCanvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────
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
              child: Text(
                'Settings',
                style: GoogleFonts.fraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: mc.inkPrimary,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Divider(height: 1, color: mc.hairline),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 40),
                children: [
                  // ── Past habits ──────────────────────────────────────
                  _SettingsSectionLabel('PAST HABITS', mc),
                  archivedAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (_, __) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: Text(
                        'Could not load past habits.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: mc.inkTertiary,
                        ),
                      ),
                    ),
                    data: (habits) => habits.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            child: Text(
                              'No archived habits yet.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: mc.inkTertiary,
                                letterSpacing: -0.1,
                              ),
                            ),
                          )
                        : Column(
                            children: habits
                                .map((h) => _ArchivedHabitRow(habit: h, mc: mc))
                                .toList(),
                          ),
                  ),

                  Divider(height: 1, color: mc.hairline),

                  // ── Appearance ────────────────────────────────────────
                  _SettingsSectionLabel('APPEARANCE', mc),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    child: _ThemeSelector(mc: mc),
                  ),

                  Divider(height: 1, color: mc.hairline),

                  // ── Account ───────────────────────────────────────────
                  _SettingsSectionLabel('ACCOUNT', mc),
                  _AccountRow(
                    label: 'Sign out',
                    danger: true,
                    mc: mc,
                    onTap: () async {
                      final confirmed = await showModalBottomSheet<bool>(
                        context: context,
                        builder: (ctx) => _SignOutSheet(mc: mc),
                      );
                      if (confirmed == true) {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) context.go('/login');
                      }
                    },
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

// ── Section label ─────────────────────────────────────────────────────────────

class _SettingsSectionLabel extends StatelessWidget {
  final String text;
  final CadenceColors mc;
  const _SettingsSectionLabel(this.text, this.mc);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.4,
          color: mc.inkTertiary,
        ),
      ),
    );
  }
}

// ── Archived habit row ────────────────────────────────────────────────────────

class _ArchivedHabitRow extends ConsumerWidget {
  final Habit habit;
  final CadenceColors mc;
  const _ArchivedHabitRow({required this.habit, required this.mc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: mc.hairline,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      habit.icon ?? '📌',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: mc.inkTertiary,
                          letterSpacing: -0.1,
                        ),
                      ),
                      if (habit.note != null && habit.note!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          habit.note!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: mc.inkTertiary,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await ref
                        .read(habitsProvider.notifier)
                        .restoreHabit(habit.id);
                    ref.invalidate(archivedHabitsProvider);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: mc.hairlineStrong),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'Restore',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: mc.inkPrimary,
                        letterSpacing: -0.05,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: mc.hairline),
        ],
      ),
    );
  }
}

// ── Account row ───────────────────────────────────────────────────────────────

class _AccountRow extends StatelessWidget {
  final String label;
  final bool danger;
  final VoidCallback onTap;
  final CadenceColors mc;

  const _AccountRow({
    required this.label,
    required this.onTap,
    required this.mc,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: danger ? mc.danger : mc.inkPrimary,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}

// ── Theme selector ────────────────────────────────────────────────────────────

class _ThemeSelector extends ConsumerWidget {
  final CadenceColors mc;
  const _ThemeSelector({required this.mc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeNotifierProvider);
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.system,
          label: Text('System'),
          icon: Icon(Icons.brightness_auto, size: 16),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          label: Text('Light'),
          icon: Icon(Icons.light_mode, size: 16),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text('Dark'),
          icon: Icon(Icons.dark_mode, size: 16),
        ),
      ],
      selected: {current},
      onSelectionChanged: (selection) =>
          ref.read(themeNotifierProvider.notifier).setMode(selection.first),
    );
  }
}

// ── Sign out confirmation sheet ───────────────────────────────────────────────

class _SignOutSheet extends StatelessWidget {
  final CadenceColors mc;
  const _SignOutSheet({required this.mc});

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Sign out?',
            style: GoogleFonts.fraunces(
              fontSize: 20,
              color: mc.inkPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () => Navigator.pop(context, true),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Sign out',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: mc.danger,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
          Divider(height: 1, color: mc.hairline),
          InkWell(
            onTap: () => Navigator.pop(context, false),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Cancel',
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
