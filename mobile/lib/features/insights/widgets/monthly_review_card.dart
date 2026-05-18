import 'package:flutter/material.dart';
import '../models/insights_data.dart';

class MonthlyReviewCard extends StatelessWidget {
  final MonthlyReview review;
  const MonthlyReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final month = _formatMonth(review.month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SectionLabel('$month in review'),
            const Spacer(),
            Text(
              '${review.totalCheckins} check-ins',
              style: TextStyle(
                  fontSize: 13,
                  color: scheme.primary,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (review.wins.isNotEmpty) ...[
          _GroupHeader('Wins', Icons.emoji_events, scheme.primary),
          const SizedBox(height: 6),
          ...review.wins.map((h) => _HabitRow(habit: h, scheme: scheme)),
          const SizedBox(height: 12),
        ],
        if (review.held.isNotEmpty) ...[
          _GroupHeader('Holding steady', Icons.horizontal_rule, scheme.tertiary),
          const SizedBox(height: 6),
          ...review.held.map((h) => _HabitRow(habit: h, scheme: scheme)),
          const SizedBox(height: 12),
        ],
        if (review.droppedOff.isNotEmpty) ...[
          _GroupHeader(
              'Could use attention', Icons.trending_down, scheme.error),
          const SizedBox(height: 6),
          ...review.droppedOff.map((h) => _HabitRow(habit: h, scheme: scheme)),
          const SizedBox(height: 12),
        ],
        if (review.lowestWeek.checkins < review.totalCheckins) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Quietest week started ${review.lowestWeek.weekStart} — ${review.lowestWeek.checkins} check-ins.',
                    style: TextStyle(
                        fontSize: 13, color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatMonth(String yearMonth) {
    final parts = yearMonth.split('-');
    if (parts.length < 2) return yearMonth;
    final months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final m = int.tryParse(parts[1]) ?? 0;
    return '${months[m]} ${parts[0]}';
  }
}

class _GroupHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _GroupHeader(this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

class _HabitRow extends StatelessWidget {
  final HabitMonthlySummary habit;
  final ColorScheme scheme;
  const _HabitRow({required this.habit, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(habit.habitName,
                style: const TextStyle(fontSize: 14)),
          ),
          Text(
            '${habit.ratePct.round()}%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
