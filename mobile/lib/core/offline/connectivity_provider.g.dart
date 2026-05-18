// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectivityHash() => r'00f46e4b8fca4a8abfb97cf8f4cc436ee2fcd3cc';

/// Streams true when connected, false when offline.
///
/// Copied from [connectivity].
@ProviderFor(connectivity)
final connectivityProvider = AutoDisposeStreamProvider<bool>.internal(
  connectivity,
  name: r'connectivityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityRef = AutoDisposeStreamProviderRef<bool>;
String _$syncManagerHash() => r'adf8185b40fc6b17974d2eb8857fa358ecd5164c';

/// Watches connectivity and flushes the outbox on reconnect.
///
/// Copied from [SyncManager].
@ProviderFor(SyncManager)
final syncManagerProvider =
    AutoDisposeNotifierProvider<SyncManager, int>.internal(
      SyncManager.new,
      name: r'syncManagerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$syncManagerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SyncManager = AutoDisposeNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
