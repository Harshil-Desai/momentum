// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insights_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Insights)
final insightsProvider = InsightsProvider._();

final class InsightsProvider
    extends $AsyncNotifierProvider<Insights, InsightsData> {
  InsightsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'insightsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$insightsHash();

  @$internal
  @override
  Insights create() => Insights();
}

String _$insightsHash() => r'25b97468f300aa9b0b62a8f9542f40076c6a6bb9';

abstract class _$Insights extends $AsyncNotifier<InsightsData> {
  FutureOr<InsightsData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<InsightsData>, InsightsData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<InsightsData>, InsightsData>,
              AsyncValue<InsightsData>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
