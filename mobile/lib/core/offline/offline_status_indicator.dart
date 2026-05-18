import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'connectivity_provider.dart';

/// Shows a subtle cloud-slash icon when offline, disappears when connected.
/// Meant to sit in an AppBar's actions list.
class OfflineStatusIndicator extends ConsumerWidget {
  const OfflineStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connAsync = ref.watch(connectivityProvider);
    final pendingCount = ref.watch(syncManagerProvider);

    final isOffline = connAsync.maybeWhen(
      data: (online) => !online,
      orElse: () => false,
    );

    if (!isOffline && pendingCount == 0) return const SizedBox.shrink();

    return Tooltip(
      message: pendingCount > 0
          ? '$pendingCount update${pendingCount == 1 ? '' : 's'} waiting to sync'
          : 'Offline',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              isOffline ? Icons.cloud_off_outlined : Icons.cloud_sync_outlined,
              size: 22,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            if (pendingCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Text(
                    '$pendingCount',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onError,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
