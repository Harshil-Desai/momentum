import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/achievements_provider.dart';
import '../widgets/earned_achievement_card.dart';
import '../widgets/progress_achievement_tile.dart';
import '../widgets/achievement_nudge_banner.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to load achievements'),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.read(achievementsProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) {
          final nudges = data.nudges;
          return RefreshIndicator(
            onRefresh: () => ref.read(achievementsProvider.notifier).refresh(),
            child: CustomScrollView(
              slivers: [
                // Nudge banner
                if (nudges.isNotEmpty)
                  SliverToBoxAdapter(
                    child: AchievementNudgeBanner(nudge: nudges.first),
                  ),

                // Earned section
                if (data.earned.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
                      child: Text(
                        'EARNED',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) =>
                            EarnedAchievementCard(item: data.earned[i]),
                        childCount: data.earned.length,
                      ),
                    ),
                  ),
                ],

                // In Progress section
                if (data.inProgress.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
                      child: Text(
                        'IN PROGRESS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) =>
                          ProgressAchievementTile(item: data.inProgress[i]),
                      childCount: data.inProgress.length,
                    ),
                  ),
                ],

                // Empty state
                if (data.earned.isEmpty && data.inProgress.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🌱',
                              style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 16),
                          Text(
                            'Start checking in to earn achievements',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }
}
