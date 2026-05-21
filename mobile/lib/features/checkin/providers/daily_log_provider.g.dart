// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_log_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DailyLog)
final dailyLogProvider = DailyLogProvider._();

final class DailyLogProvider extends $NotifierProvider<DailyLog, bool> {
  DailyLogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyLogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyLogHash();

  @$internal
  @override
  DailyLog create() => DailyLog();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$dailyLogHash() => r'd36331f33bf506806ead3cb547a9469fef278987';

abstract class _$DailyLog extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(todayLog)
final todayLogProvider = TodayLogProvider._();

final class TodayLogProvider
    extends
        $FunctionalProvider<
          AsyncValue<DailyLogData?>,
          DailyLogData?,
          FutureOr<DailyLogData?>
        >
    with $FutureModifier<DailyLogData?>, $FutureProvider<DailyLogData?> {
  TodayLogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayLogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayLogHash();

  @$internal
  @override
  $FutureProviderElement<DailyLogData?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DailyLogData?> create(Ref ref) {
    return todayLog(ref);
  }
}

String _$todayLogHash() => r'75ba8d781cc42aa2e81c7895a301034b35f0bac2';
