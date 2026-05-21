import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../api_client.dart';
import 'sync_service.dart';
import 'offline_queue.dart';

part 'connectivity_provider.g.dart';

/// Streams true when connected, false when offline.
@riverpod
Stream<bool> connectivity(Ref ref) {
  return Connectivity()
      .onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));
}

/// Watches connectivity and flushes the outbox on reconnect.
@riverpod
class SyncManager extends _$SyncManager {
  @override
  int build() {
    // Count of pending ops — 0 means in sync
    _watchConnectivity();
    _loadCount();
    return 0;
  }

  Future<void> _loadCount() async {
    state = await OfflineQueue.count();
  }

  void _watchConnectivity() {
    ref.listen(connectivityProvider, (prev, next) async {
      final isOnline = next.value ?? false;
      final wasOffline = !(prev?.value ?? true);
      if (isOnline && wasOffline) {
        await flush();
      }
    });
  }

  Future<void> flush() async {
    final dio = ref.read(dioProvider);
    final service = SyncService(dio);
    await service.flush();
    state = await OfflineQueue.count();
  }

  Future<void> recordPending() async {
    state = await OfflineQueue.count();
  }
}
