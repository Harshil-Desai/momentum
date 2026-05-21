// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'templates_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Templates)
final templatesProvider = TemplatesProvider._();

final class TemplatesProvider
    extends
        $AsyncNotifierProvider<Templates, Map<String, List<HabitTemplate>>> {
  TemplatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'templatesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$templatesHash();

  @$internal
  @override
  Templates create() => Templates();
}

String _$templatesHash() => r'cba606834ae606774e3a8692d9708e857a46acf1';

abstract class _$Templates
    extends $AsyncNotifier<Map<String, List<HabitTemplate>>> {
  FutureOr<Map<String, List<HabitTemplate>>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<String, List<HabitTemplate>>>,
              Map<String, List<HabitTemplate>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, List<HabitTemplate>>>,
                Map<String, List<HabitTemplate>>
              >,
              AsyncValue<Map<String, List<HabitTemplate>>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
