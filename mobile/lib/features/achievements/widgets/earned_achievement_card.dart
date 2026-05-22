import 'package:flutter/material.dart';
import '../models/achievement.dart';

class EarnedAchievementCard extends StatelessWidget {
  final AchievementItem item;

  const EarnedAchievementCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locked = item.isLocked;

    return Card(
      color: locked
          ? colorScheme.surfaceContainerHighest
          : colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: locked ? 0 : 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: locked ? 0.35 : 1.0,
              child: Text(item.icon, style: const TextStyle(fontSize: 36)),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: locked
                    ? colorScheme.onSurface.withValues(alpha: 0.45)
                    : colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (!locked && item.earnedAt != null)
              Text(
                _formatDate(item.earnedAt!),
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                ),
              )
            else if (locked)
              Text(
                item.description,
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurface.withValues(alpha: 0.35),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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
