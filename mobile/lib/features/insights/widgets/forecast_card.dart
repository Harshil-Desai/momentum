import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/insights_data.dart';
import '../../../core/theme/app_theme.dart';

class ForecastCard extends StatelessWidget {
  final List<HabitForecast> forecasts;
  const ForecastCard({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) return const SizedBox.shrink();
    final mc = context.mc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('TOMORROW\'S FORECAST', mc),
        const SizedBox(height: 12),
        ...forecasts.map((f) => _ForecastTile(forecast: f, mc: mc)),
      ],
    );
  }
}

class _ForecastTile extends StatelessWidget {
  final HabitForecast forecast;
  final MomentumColors mc;
  const _ForecastTile({required this.forecast, required this.mc});

  @override
  Widget build(BuildContext context) {
    final pct = (forecast.completionRate * 100).round();
    final accent = pct >= 90
        ? MomentumPigments.pine
        : pct >= 70
            ? MomentumPigments.sea
            : MomentumPigments.cobalt;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: mc.hairline.withAlpha(80),
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left accent bar
          Container(
            width: 4,
            color: accent,
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      forecast.nudgeCopy,
                      style: GoogleFonts.fraunces(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: mc.inkPrimary,
                        height: 1.4,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$pct%',
                    style: GoogleFonts.fraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: mc.inkTertiary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
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
