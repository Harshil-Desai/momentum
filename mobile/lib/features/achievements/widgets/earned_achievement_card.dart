import 'package:flutter/material.dart';
import '../models/achievement.dart';

class EarnedAchievementCard extends StatelessWidget {
  final AchievementItem item;

  const EarnedAchievementCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              item.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.earnedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatDate(item.earnedAt!),
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
