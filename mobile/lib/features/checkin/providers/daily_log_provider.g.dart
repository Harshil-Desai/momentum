// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_log_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todayLogHash() => r'75ba8d781cc42aa2e81c7895a301034b35f0bac2';

/// See also [todayLog].
@ProviderFor(todayLog)
final todayLogProvider = AutoDisposeFutureProvider<DailyLogData?>.internal(
  todayLog,
  name: r'todayLogProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayLogHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayLogRef = AutoDisposeFutureProviderRef<DailyLogData?>;
String _$dailyLogHash() => r'd36331f33bf506806ead3cb547a9469fef278987';

/// See also [DailyLog].
@ProviderFor(DailyLog)
final dailyLogProvider = AutoDisposeNotifierProvider<DailyLog, bool>.internal(
  DailyLog.new,
  name: r'dailyLogProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dailyLogHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DailyLog = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
