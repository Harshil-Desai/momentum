import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/insights_data.dart';
import '../../../core/theme/app_theme.dart';

class CorrelationCard extends StatelessWidget {
  final List<HabitCorrelation> correlations;
  const CorrelationCard({super.key, required this.correlations});

  @override
  Widget build(BuildContext context) {
    if (correlations.isEmpty) return const SizedBox.shrink();
    final mc = context.mc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('HABITS THAT GO TOGETHER', mc),
        const SizedBox(height: 6),
        Text(
          'Often completed on the same day.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: mc.inkTertiary,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 12),
        ...correlations.map((c) => _CorrelationRow(correlation: c, mc: mc)),
      ],
    );
  }
}

class _CorrelationRow extends StatelessWidget {
  final HabitCorrelation correlation;
  final MomentumColors mc;
  const _CorrelationRow({required this.correlation, required this.mc});

  @override
  Widget build(BuildContext context) {
    final pct = correlation.percentage.round();
    const accent = MomentumPigments.pine;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${correlation.habitAName}  ×  ${correlation.habitBName}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: mc.inkPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: correlation.percentage / 100,
                    minHeight: 6,
                    backgroundColor: mc.hairline,
                    valueColor: const AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$pct%',
            style: GoogleFonts.fraunces(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: accent,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final MomentumColors mc;
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
