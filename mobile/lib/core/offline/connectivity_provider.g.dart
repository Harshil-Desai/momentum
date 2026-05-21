// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Streams true when connected, false when offline.

@ProviderFor(connectivity)
final connectivityProvider = ConnectivityProvider._();

/// Streams true when connected, false when offline.

final class ConnectivityProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Streams true when connected, false when offline.
  ConnectivityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return connectivity(ref);
  }
}

String _$connectivityHash() => r'00f46e4b8fca4a8abfb97cf8f4cc436ee2fcd3cc';

/// Watches connectivity and flushes the outbox on reconnect.

@ProviderFor(SyncManager)
final syncManagerProvider = SyncManagerProvider._();

/// Watches connectivity and flushes the outbox on reconnect.
final class SyncManagerProvider extends $NotifierProvider<SyncManager, int> {
  /// Watches connectivity and flushes the outbox on reconnect.
  SyncManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncManagerHash();

  @$internal
  @override
  SyncManager create() => SyncManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$syncManagerHash() => r'adf8185b40fc6b17974d2eb8857fa358ecd5164c';

/// Watches connectivity and flushes the outbox on reconnect.

abstract class _$SyncManager extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
