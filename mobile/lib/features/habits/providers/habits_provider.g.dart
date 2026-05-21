// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habits_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Habits)
final habitsProvider = HabitsProvider._();

final class HabitsProvider extends $AsyncNotifierProvider<Habits, List<Habit>> {
  HabitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitsHash();

  @$internal
  @override
  Habits create() => Habits();
}

String _$habitsHash() => r'09446dba22a6aaee39795a241e092dac5b26412c';

abstract class _$Habits extends $AsyncNotifier<List<Habit>> {
  FutureOr<List<Habit>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Habit>>, List<Habit>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Habit>>, List<Habit>>,
              AsyncValue<List<Habit>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ArchivedHabits)
final archivedHabitsProvider = ArchivedHabitsProvider._();

final class ArchivedHabitsProvider
    extends $AsyncNotifierProvider<ArchivedHabits, List<Habit>> {
  ArchivedHabitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'archivedHabitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$archivedHabitsHash();

  @$internal
  @override
  ArchivedHabits create() => ArchivedHabits();
}

String _$archivedHabitsHash() => r'f7389bb4bce4a3ec0ce385bb485f921be71f0fb2';

abstract class _$ArchivedHabits extends $AsyncNotifier<List<Habit>> {
  FutureOr<List<Habit>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Habit>>, List<Habit>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Habit>>, List<Habit>>,
              AsyncValue<List<Habit>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(HabitHistoryData)
final habitHistoryDataProvider = HabitHistoryDataFamily._();

final class HabitHistoryDataProvider
    extends $AsyncNotifierProvider<HabitHistoryData, HabitHistory> {
  HabitHistoryDataProvider._({
    required HabitHistoryDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'habitHistoryDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitHistoryDataHash();

  @override
  String toString() {
    return r'habitHistoryDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HabitHistoryData create() => HabitHistoryData();

  @override
  bool operator ==(Object other) {
    return other is HabitHistoryDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitHistoryDataHash() => r'd88d16458e68fb7fade6d1db3435de5d601f60fc';

final class HabitHistoryDataFamily extends $Family
    with
        $ClassFamilyOverride<
          HabitHistoryData,
          AsyncValue<HabitHistory>,
          HabitHistory,
          FutureOr<HabitHistory>,
          String
        > {
  HabitHistoryDataFamily._()
    : super(
        retry: null,
        name: r'habitHistoryDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HabitHistoryDataProvider call(String habitId) =>
      HabitHistoryDataProvider._(argument: habitId, from: this);

  @override
  String toString() => r'habitHistoryDataProvider';
}

abstract class _$HabitHistoryData extends $AsyncNotifier<HabitHistory> {
  late final _$args = ref.$arg as String;
  String get habitId => _$args;

  FutureOr<HabitHistory> build(String habitId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<HabitHistory>, HabitHistory>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<HabitHistory>, HabitHistory>,
              AsyncValue<HabitHistory>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(HabitStreak)
final habitStreakProvider = HabitStreakFamily._();

final class HabitStreakProvider
    extends $AsyncNotifierProvider<HabitStreak, int> {
  HabitStreakProvider._({
    required HabitStreakFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'habitStreakProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitStreakHash();

  @override
  String toString() {
    return r'habitStreakProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HabitStreak create() => HabitStreak();

  @override
  bool operator ==(Object other) {
    return other is HabitStreakProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitStreakHash() => r'4344b9d1176235cb89c846f333d702ca74e27919';

final class HabitStreakFamily extends $Family
    with
        $ClassFamilyOverride<
          HabitStreak,
          AsyncValue<int>,
          int,
          FutureOr<int>,
          String
        > {
  HabitStreakFamily._()
    : super(
        retry: null,
        name: r'habitStreakProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HabitStreakProvider call(String habitId) =>
      HabitStreakProvider._(argument: habitId, from: this);

  @override
  String toString() => r'habitStreakProvider';
}

abstract class _$HabitStreak extends $AsyncNotifier<int> {
  late final _$args = ref.$arg as String;
  String get habitId => _$args;

  FutureOr<int> build(String habitId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(HabitCheckin)
final habitCheckinProvider = HabitCheckinFamily._();

final class HabitCheckinProvider
    extends $NotifierProvider<HabitCheckin, CheckinState> {
  HabitCheckinProvider._({
    required HabitCheckinFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'habitCheckinProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitCheckinHash();

  @override
  String toString() {
    return r'habitCheckinProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HabitCheckin create() => HabitCheckin();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckinState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckinState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HabitCheckinProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitCheckinHash() => r'7341a4fd7bca0a7c58355cc18afcd056b8dd94af';

final class HabitCheckinFamily extends $Family
    with
        $ClassFamilyOverride<
          HabitCheckin,
          CheckinState,
          CheckinState,
          CheckinState,
          String
        > {
  HabitCheckinFamily._()
    : super(
        retry: null,
        name: r'habitCheckinProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HabitCheckinProvider call(String habitId) =>
      HabitCheckinProvider._(argument: habitId, from: this);

  @override
  String toString() => r'habitCheckinProvider';
}

abstract class _$HabitCheckin extends $Notifier<CheckinState> {
  late final _$args = ref.$arg as String;
  String get habitId => _$args;

  CheckinState build(String habitId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CheckinState, CheckinState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CheckinState, CheckinState>,
              CheckinState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(HabitGraceDay)
final habitGraceDayProvider = HabitGraceDayFamily._();

final class HabitGraceDayProvider
    extends $NotifierProvider<HabitGraceDay, bool> {
  HabitGraceDayProvider._({
    required HabitGraceDayFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'habitGraceDayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitGraceDayHash();

  @override
  String toString() {
    return r'habitGraceDayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HabitGraceDay create() => HabitGraceDay();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HabitGraceDayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitGraceDayHash() => r'0e62ca886978f6d6e8b4d8f0f0d97eca79cb8943';

final class HabitGraceDayFamily extends $Family
    with $ClassFamilyOverride<HabitGraceDay, bool, bool, bool, String> {
  HabitGraceDayFamily._()
    : super(
        retry: null,
        name: r'habitGraceDayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HabitGraceDayProvider call(String habitId) =>
      HabitGraceDayProvider._(argument: habitId, from: this);

  @override
  String toString() => r'habitGraceDayProvider';
}

abstract class _$HabitGraceDay extends $Notifier<bool> {
  late final _$args = ref.$arg as String;
  String get habitId => _$args;

  bool build(String habitId);
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
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(HabitSubtaskCheckin)
final habitSubtaskCheckinProvider = HabitSubtaskCheckinFamily._();

final class HabitSubtaskCheckinProvider
    extends $NotifierProvider<HabitSubtaskCheckin, Set<String>> {
  HabitSubtaskCheckinProvider._({
    required HabitSubtaskCheckinFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'habitSubtaskCheckinProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitSubtaskCheckinHash();

  @override
  String toString() {
    return r'habitSubtaskCheckinProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HabitSubtaskCheckin create() => HabitSubtaskCheckin();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HabitSubtaskCheckinProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitSubtaskCheckinHash() =>
    r'c4eae9cbbe7f7b3e175921432ad28da552487bdc';

final class HabitSubtaskCheckinFamily extends $Family
    with
        $ClassFamilyOverride<
          HabitSubtaskCheckin,
          Set<String>,
          Set<String>,
          Set<String>,
          String
        > {
  HabitSubtaskCheckinFamily._()
    : super(
        retry: null,
        name: r'habitSubtaskCheckinProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HabitSubtaskCheckinProvider call(String habitId) =>
      HabitSubtaskCheckinProvider._(argument: habitId, from: this);

  @override
  String toString() => r'habitSubtaskCheckinProvider';
}

abstract class _$HabitSubtaskCheckin extends $Notifier<Set<String>> {
  late final _$args = ref.$arg as String;
  String get habitId => _$args;

  Set<String> build(String habitId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
