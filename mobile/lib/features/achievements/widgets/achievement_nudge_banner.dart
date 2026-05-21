import 'package:flutter/material.dart';
import '../models/achievement.dart';

class AchievementNudgeBanner extends StatelessWidget {
  final ProgressItem nudge;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const AchievementNudgeBanner({
    super.key,
    required this.nudge,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final remaining = nudge.targetValue - nudge.currentValue;
    final label = remaining == 1
        ? '1 more step to unlock ${nudge.name}!'
        : '$remaining more steps to unlock ${nudge.name}!';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.secondary.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Text(nudge.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSecondaryContainer,
                  fontSize: 13,
                ),
              ),
            ),
            if (onDismiss != null)
              GestureDetector(
                onTap: onDismiss,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: colorScheme.onSecondaryContainer.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
