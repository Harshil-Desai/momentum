// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievements_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Achievements)
final achievementsProvider = AchievementsProvider._();

final class AchievementsProvider
    extends $AsyncNotifierProvider<Achievements, AchievementsData> {
  AchievementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'achievementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$achievementsHash();

  @$internal
  @override
  Achievements create() => Achievements();
}

String _$achievementsHash() => r'43d583d537e338237b8a6261d14b1c592dbfdb0f';

abstract class _$Achievements extends $AsyncNotifier<AchievementsData> {
  FutureOr<AchievementsData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<AchievementsData>, AchievementsData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AchievementsData>, AchievementsData>,
              AsyncValue<AchievementsData>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
