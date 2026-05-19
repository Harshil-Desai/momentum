import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/insights_data.dart';
import '../providers/insights_provider.dart';
import '../widgets/snooze_patterns_card.dart';
import '../widgets/correlation_card.dart';
import '../widgets/forecast_card.dart';
import '../widgets/monthly_review_card.dart';
import '../../../core/theme/app_theme.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mc = context.mc;
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
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.chevron_left,
                          size: 28, color: mc.inkPrimary),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/reflection'),
                    child: Text(
                      'This week',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: mc.inkSecondary,
                        letterSpacing: -0.1,
                        decoration: TextDecoration.underline,
                        decorationColor: mc.inkSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your patterns',
                    style: GoogleFonts.fraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: mc.inkPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'A mirror, not a megaphone.',
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

            // ── Body ────────────────────────────────────────────────────
            Expanded(
              child: insightsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Could not load insights',
                        style: GoogleFonts.inter(color: mc.inkSecondary),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () =>
                            ref.read(insightsProvider.notifier).refresh(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: mc.hairlineStrong),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            'Try again',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: mc.inkPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                data: (data) => _InsightsBody(data: data),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightsBody extends StatelessWidget {
  final InsightsData data;
  const _InsightsBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      children: [
        // ── Snooze patterns ────────────────────────────────────────────
        const SnoozePatternsCard(),

        // ── Big stat tiles ─────────────────────────────────────────────
        Row(
          children: [
            _BigStatTile(
              value: '${data.totalCheckins}',
              label: 'total check-ins',
              mc: mc,
            ),
            const SizedBox(width: 12),
            _BigStatTile(
              value: '${(data.monthlyRate * 100).round()}%',
              label: 'this month',
              mc: mc,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ── Your rhythm ────────────────────────────────────────────────
        if (data.strongestDay.isNotEmpty) ...[
          _SectionLabel('YOUR RHYTHM', mc),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CadencePigments.iris.withAlpha(18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'You check in most on ${data.strongestDay}s.',
              style: GoogleFonts.fraunces(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: mc.inkPrimary,
                height: 1.55,
                letterSpacing: -0.1,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // ── Day of week chart ──────────────────────────────────────────
        if (data.dayOfWeek.isNotEmpty) ...[
          _SectionLabel('DAY OF WEEK', mc),
          const SizedBox(height: 12),
          _DayOfWeekChart(counts: data.dayOfWeek, mc: mc),
          const SizedBox(height: 24),
        ],

        // ── Streaks ────────────────────────────────────────────────────
        if (data.habitStreaks.isNotEmpty) ...[
          _SectionLabel('STREAKS', mc),
          const SizedBox(height: 4),
          ...data.habitStreaks.map((h) => _StreakRow(habit: h, mc: mc)),
          const SizedBox(height: 24),
        ],

        // ── Energy & completion ────────────────────────────────────────
        if (data.energyCorrelation.length >= 3) ...[
          _SectionLabel('ENERGY & COMPLETION', mc),
          const SizedBox(height: 12),
          _EnergyCorrelationChart(points: data.energyCorrelation, mc: mc),
          const SizedBox(height: 24),
        ],

        // ── Advanced insights ──────────────────────────────────────────
        if (data.advancedUnlocked) ...[
          if (data.monthlyReview != null) ...[
            MonthlyReviewCard(review: data.monthlyReview!),
            const SizedBox(height: 24),
          ],
          if (data.forecasts.isNotEmpty) ...[
            ForecastCard(forecasts: data.forecasts),
            const SizedBox(height: 24),
          ],
          if (data.correlations.isNotEmpty) ...[
            CorrelationCard(correlations: data.correlations),
            const SizedBox(height: 24),
          ],
        ] else ...[
          _AdvancedTeaser(
            current: data.maxHabitCheckins,
            threshold: data.unlockThreshold,
            mc: mc,
          ),
          const SizedBox(height: 24),
        ],

        // ── Empty nudge ────────────────────────────────────────────────
        if (data.totalCheckins == 0)
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Text(
              'Check in to your habits to start\nseeing your patterns here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: mc.inkTertiary,
                height: 1.6,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Big stat tile ─────────────────────────────────────────────────────────────

class _BigStatTile extends StatelessWidget {
  final String value;
  final String label;
  final CadenceColors mc;

  const _BigStatTile({
    required this.value,
    required this.label,
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
              value,
              style: GoogleFonts.fraunces(
                fontSize: 40,
                fontWeight: FontWeight.w400,
                color: mc.inkPrimary,
                letterSpacing: -1.0,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: mc.inkTertiary,
                letterSpacing: -0.05,
              ),
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

// ── Day of week chart ─────────────────────────────────────────────────────────

class _DayOfWeekChart extends StatelessWidget {
  final List<DayCount> counts;
  final CadenceColors mc;
  const _DayOfWeekChart({required this.counts, required this.mc});

  @override
  Widget build(BuildContext context) {
    final maxCount = counts.isEmpty
        ? 1
        : counts.map((c) => c.count).reduce((a, b) => a > b ? a : b);

    final countMap = {for (var c in counts) c.dayOfWeek: c.count};
    final accentColor = CadencePigments.cobalt;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (dow) {
        final count = countMap[dow] ?? 0;
        final fraction = maxCount == 0 ? 0.0 : count / maxCount;
        final isStrongest = count == maxCount && count > 0;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              children: [
                if (count > 0)
                  Text(
                    '$count',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isStrongest ? accentColor : mc.inkTertiary,
                    ),
                  )
                else
                  const SizedBox(height: 13),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  height: 72 * fraction + 4,
                  decoration: BoxDecoration(
                    color: isStrongest
                        ? accentColor
                        : accentColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DayCount.dayNames[dow],
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight:
                        isStrongest ? FontWeight.w600 : FontWeight.normal,
                    color: isStrongest ? accentColor : mc.inkTertiary,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── Streak row ────────────────────────────────────────────────────────────────

class _StreakRow extends StatelessWidget {
  final HabitStreakSummary habit;
  final CadenceColors mc;
  const _StreakRow({required this.habit, required this.mc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              habit.habitName,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: mc.inkPrimary,
                letterSpacing: -0.1,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${habit.currentStreak}',
                style: GoogleFonts.fraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: mc.inkPrimary,
                  letterSpacing: -0.4,
                  height: 1,
                ),
              ),
              Text(
                '${habit.bestStreak} best',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: mc.inkTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Advanced teaser ───────────────────────────────────────────────────────────

class _AdvancedTeaser extends StatelessWidget {
  final int current;
  final int threshold;
  final CadenceColors mc;
  const _AdvancedTeaser(
      {required this.current, required this.threshold, required this.mc});

  @override
  Widget build(BuildContext context) {
    final remaining = threshold - current;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: mc.hairline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline_rounded,
                  size: 14, color: mc.inkTertiary),
              const SizedBox(width: 6),
              Text(
                'More patterns coming',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: mc.inkPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Log $remaining more check-ins on any one habit to unlock habit correlations, forecasts, and monthly reviews.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: mc.inkSecondary,
              letterSpacing: -0.1,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: current / threshold,
                    minHeight: 5,
                    backgroundColor: mc.hairline,
                    valueColor: AlwaysStoppedAnimation<Color>(mc.inkPrimary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$current / $threshold',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: mc.inkTertiary,
                  letterSpacing: -0.05,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Energy correlation chart ──────────────────────────────────────────────────

class _EnergyCorrelationChart extends StatelessWidget {
  final List<EnergyCorrelationPoint> points;
  final CadenceColors mc;
  const _EnergyCorrelationChart(
      {required this.points, required this.mc});

  @override
  Widget build(BuildContext context) {
    final accentColor = CadencePigments.sea;
    final maxRate = points.isEmpty
        ? 1.0
        : points
            .map((p) => p.completionRate)
            .reduce((a, b) => a > b ? a : b);

    final rateMap = {for (var p in points) p.energyLevel: p.completionRate};

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(5, (i) {
            final level = i + 1;
            final rate = rateMap[level] ?? 0.0;
            final fraction = maxRate == 0 ? 0.0 : rate / maxRate;
            final isHighest = rateMap.isNotEmpty &&
                rate ==
                    points
                        .map((p) => p.completionRate)
                        .reduce((a, b) => a > b ? a : b) &&
                rate > 0;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  children: [
                    Text(
                      rate > 0 ? '${(rate * 100).round()}%' : '',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: isHighest ? accentColor : mc.inkTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      height: 60 * fraction + 4,
                      decoration: BoxDecoration(
                        color: isHighest
                            ? accentColor
                            : accentColor.withAlpha(51),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      EnergyCorrelationPoint.labels[level],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: isHighest ? accentColor : mc.inkTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          'Completion rate by energy level',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: mc.inkTertiary,
            letterSpacing: -0.05,
          ),
        ),
      ],
    );
  }
}
