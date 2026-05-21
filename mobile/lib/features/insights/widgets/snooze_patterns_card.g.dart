// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snooze_patterns_card.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(snoozeInsights)
final snoozeInsightsProvider = SnoozeInsightsProvider._();

final class SnoozeInsightsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnoozeInsight>>,
          List<SnoozeInsight>,
          FutureOr<List<SnoozeInsight>>
        >
    with
        $FutureModifier<List<SnoozeInsight>>,
        $FutureProvider<List<SnoozeInsight>> {
  SnoozeInsightsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'snoozeInsightsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$snoozeInsightsHash();

  @$internal
  @override
  $FutureProviderElement<List<SnoozeInsight>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnoozeInsight>> create(Ref ref) {
    return snoozeInsights(ref);
  }
}

String _$snoozeInsightsHash() => r'3408d1e3ea4c2bb08a41f3a551eec879112ad227';
