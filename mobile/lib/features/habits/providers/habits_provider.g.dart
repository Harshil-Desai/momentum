// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habits_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$habitsHash() => r'09446dba22a6aaee39795a241e092dac5b26412c';

/// See also [Habits].
@ProviderFor(Habits)
final habitsProvider =
    AutoDisposeAsyncNotifierProvider<Habits, List<Habit>>.internal(
      Habits.new,
      name: r'habitsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$habitsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Habits = AutoDisposeAsyncNotifier<List<Habit>>;
String _$archivedHabitsHash() => r'f7389bb4bce4a3ec0ce385bb485f921be71f0fb2';

/// See also [ArchivedHabits].
@ProviderFor(ArchivedHabits)
final archivedHabitsProvider =
    AutoDisposeAsyncNotifierProvider<ArchivedHabits, List<Habit>>.internal(
      ArchivedHabits.new,
      name: r'archivedHabitsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$archivedHabitsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ArchivedHabits = AutoDisposeAsyncNotifier<List<Habit>>;
String _$habitHistoryDataHash() => r'3f9f76cd987a477001e20119105fc48f45f28c23';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$HabitHistoryData
    extends BuildlessAutoDisposeAsyncNotifier<HabitHistory> {
  late final String habitId;

  FutureOr<HabitHistory> build(String habitId);
}

/// See also [HabitHistoryData].
@ProviderFor(HabitHistoryData)
const habitHistoryDataProvider = HabitHistoryDataFamily();

/// See also [HabitHistoryData].
class HabitHistoryDataFamily extends Family<AsyncValue<HabitHistory>> {
  /// See also [HabitHistoryData].
  const HabitHistoryDataFamily();

  /// See also [HabitHistoryData].
  HabitHistoryDataProvider call(String habitId) {
    return HabitHistoryDataProvider(habitId);
  }

  @override
  HabitHistoryDataProvider getProviderOverride(
    covariant HabitHistoryDataProvider provider,
  ) {
    return call(provider.habitId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'habitHistoryDataProvider';
}

/// See also [HabitHistoryData].
class HabitHistoryDataProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<HabitHistoryData, HabitHistory> {
  /// See also [HabitHistoryData].
  HabitHistoryDataProvider(String habitId)
    : this._internal(
        () => HabitHistoryData()..habitId = habitId,
        from: habitHistoryDataProvider,
        name: r'habitHistoryDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$habitHistoryDataHash,
        dependencies: HabitHistoryDataFamily._dependencies,
        allTransitiveDependencies:
            HabitHistoryDataFamily._allTransitiveDependencies,
        habitId: habitId,
      );

  HabitHistoryDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.habitId,
  }) : super.internal();

  final String habitId;

  @override
  FutureOr<HabitHistory> runNotifierBuild(covariant HabitHistoryData notifier) {
    return notifier.build(habitId);
  }

  @override
  Override overrideWith(HabitHistoryData Function() create) {
    return ProviderOverride(
      origin: this,
      override: HabitHistoryDataProvider._internal(
        () => create()..habitId = habitId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        habitId: habitId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<HabitHistoryData, HabitHistory>
  createElement() {
    return _HabitHistoryDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitHistoryDataProvider && other.habitId == habitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, habitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HabitHistoryDataRef on AutoDisposeAsyncNotifierProviderRef<HabitHistory> {
  /// The parameter `habitId` of this provider.
  String get habitId;
}

class _HabitHistoryDataProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<HabitHistoryData, HabitHistory>
    with HabitHistoryDataRef {
  _HabitHistoryDataProviderElement(super.provider);

  @override
  String get habitId => (origin as HabitHistoryDataProvider).habitId;
}

String _$habitStreakHash() => r'4344b9d1176235cb89c846f333d702ca74e27919';

abstract class _$HabitStreak extends BuildlessAutoDisposeAsyncNotifier<int> {
  late final String habitId;

  FutureOr<int> build(String habitId);
}

/// See also [HabitStreak].
@ProviderFor(HabitStreak)
const habitStreakProvider = HabitStreakFamily();

/// See also [HabitStreak].
class HabitStreakFamily extends Family<AsyncValue<int>> {
  /// See also [HabitStreak].
  const HabitStreakFamily();

  /// See also [HabitStreak].
  HabitStreakProvider call(String habitId) {
    return HabitStreakProvider(habitId);
  }

  @override
  HabitStreakProvider getProviderOverride(
    covariant HabitStreakProvider provider,
  ) {
    return call(provider.habitId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'habitStreakProvider';
}

/// See also [HabitStreak].
class HabitStreakProvider
    extends AutoDisposeAsyncNotifierProviderImpl<HabitStreak, int> {
  /// See also [HabitStreak].
  HabitStreakProvider(String habitId)
    : this._internal(
        () => HabitStreak()..habitId = habitId,
        from: habitStreakProvider,
        name: r'habitStreakProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$habitStreakHash,
        dependencies: HabitStreakFamily._dependencies,
        allTransitiveDependencies: HabitStreakFamily._allTransitiveDependencies,
        habitId: habitId,
      );

  HabitStreakProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.habitId,
  }) : super.internal();

  final String habitId;

  @override
  FutureOr<int> runNotifierBuild(covariant HabitStreak notifier) {
    return notifier.build(habitId);
  }

  @override
  Override overrideWith(HabitStreak Function() create) {
    return ProviderOverride(
      origin: this,
      override: HabitStreakProvider._internal(
        () => create()..habitId = habitId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        habitId: habitId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<HabitStreak, int> createElement() {
    return _HabitStreakProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitStreakProvider && other.habitId == habitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, habitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HabitStreakRef on AutoDisposeAsyncNotifierProviderRef<int> {
  /// The parameter `habitId` of this provider.
  String get habitId;
}

class _HabitStreakProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<HabitStreak, int>
    with HabitStreakRef {
  _HabitStreakProviderElement(super.provider);

  @override
  String get habitId => (origin as HabitStreakProvider).habitId;
}

String _$habitCheckinHash() => r'6075ab4833511a40aae5c3ae8116fe539389f218';

abstract class _$HabitCheckin
    extends BuildlessAutoDisposeNotifier<CheckinState> {
  late final String habitId;

  CheckinState build(String habitId);
}

/// See also [HabitCheckin].
@ProviderFor(HabitCheckin)
const habitCheckinProvider = HabitCheckinFamily();

/// See also [HabitCheckin].
class HabitCheckinFamily extends Family<CheckinState> {
  /// See also [HabitCheckin].
  const HabitCheckinFamily();

  /// See also [HabitCheckin].
  HabitCheckinProvider call(String habitId) {
    return HabitCheckinProvider(habitId);
  }

  @override
  HabitCheckinProvider getProviderOverride(
    covariant HabitCheckinProvider provider,
  ) {
    return call(provider.habitId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'habitCheckinProvider';
}

/// See also [HabitCheckin].
class HabitCheckinProvider
    extends AutoDisposeNotifierProviderImpl<HabitCheckin, CheckinState> {
  /// See also [HabitCheckin].
  HabitCheckinProvider(String habitId)
    : this._internal(
        () => HabitCheckin()..habitId = habitId,
        from: habitCheckinProvider,
        name: r'habitCheckinProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$habitCheckinHash,
        dependencies: HabitCheckinFamily._dependencies,
        allTransitiveDependencies:
            HabitCheckinFamily._allTransitiveDependencies,
        habitId: habitId,
      );

  HabitCheckinProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.habitId,
  }) : super.internal();

  final String habitId;

  @override
  CheckinState runNotifierBuild(covariant HabitCheckin notifier) {
    return notifier.build(habitId);
  }

  @override
  Override overrideWith(HabitCheckin Function() create) {
    return ProviderOverride(
      origin: this,
      override: HabitCheckinProvider._internal(
        () => create()..habitId = habitId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        habitId: habitId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<HabitCheckin, CheckinState>
  createElement() {
    return _HabitCheckinProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitCheckinProvider && other.habitId == habitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, habitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HabitCheckinRef on AutoDisposeNotifierProviderRef<CheckinState> {
  /// The parameter `habitId` of this provider.
  String get habitId;
}

class _HabitCheckinProviderElement
    extends AutoDisposeNotifierProviderElement<HabitCheckin, CheckinState>
    with HabitCheckinRef {
  _HabitCheckinProviderElement(super.provider);

  @override
  String get habitId => (origin as HabitCheckinProvider).habitId;
}

String _$habitGraceDayHash() => r'0e62ca886978f6d6e8b4d8f0f0d97eca79cb8943';

abstract class _$HabitGraceDay extends BuildlessAutoDisposeNotifier<bool> {
  late final String habitId;

  bool build(String habitId);
}

/// See also [HabitGraceDay].
@ProviderFor(HabitGraceDay)
const habitGraceDayProvider = HabitGraceDayFamily();

/// See also [HabitGraceDay].
class HabitGraceDayFamily extends Family<bool> {
  /// See also [HabitGraceDay].
  const HabitGraceDayFamily();

  /// See also [HabitGraceDay].
  HabitGraceDayProvider call(String habitId) {
    return HabitGraceDayProvider(habitId);
  }

  @override
  HabitGraceDayProvider getProviderOverride(
    covariant HabitGraceDayProvider provider,
  ) {
    return call(provider.habitId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'habitGraceDayProvider';
}

/// See also [HabitGraceDay].
class HabitGraceDayProvider
    extends AutoDisposeNotifierProviderImpl<HabitGraceDay, bool> {
  /// See also [HabitGraceDay].
  HabitGraceDayProvider(String habitId)
    : this._internal(
        () => HabitGraceDay()..habitId = habitId,
        from: habitGraceDayProvider,
        name: r'habitGraceDayProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$habitGraceDayHash,
        dependencies: HabitGraceDayFamily._dependencies,
        allTransitiveDependencies:
            HabitGraceDayFamily._allTransitiveDependencies,
        habitId: habitId,
      );

  HabitGraceDayProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.habitId,
  }) : super.internal();

  final String habitId;

  @override
  bool runNotifierBuild(covariant HabitGraceDay notifier) {
    return notifier.build(habitId);
  }

  @override
  Override overrideWith(HabitGraceDay Function() create) {
    return ProviderOverride(
      origin: this,
      override: HabitGraceDayProvider._internal(
        () => create()..habitId = habitId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        habitId: habitId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<HabitGraceDay, bool> createElement() {
    return _HabitGraceDayProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitGraceDayProvider && other.habitId == habitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, habitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HabitGraceDayRef on AutoDisposeNotifierProviderRef<bool> {
  /// The parameter `habitId` of this provider.
  String get habitId;
}

class _HabitGraceDayProviderElement
    extends AutoDisposeNotifierProviderElement<HabitGraceDay, bool>
    with HabitGraceDayRef {
  _HabitGraceDayProviderElement(super.provider);

  @override
  String get habitId => (origin as HabitGraceDayProvider).habitId;
}

String _$habitSubtaskCheckinHash() =>
    r'c4eae9cbbe7f7b3e175921432ad28da552487bdc';

abstract class _$HabitSubtaskCheckin
    extends BuildlessAutoDisposeNotifier<Set<String>> {
  late final String habitId;

  Set<String> build(String habitId);
}

/// See also [HabitSubtaskCheckin].
@ProviderFor(HabitSubtaskCheckin)
const habitSubtaskCheckinProvider = HabitSubtaskCheckinFamily();

/// See also [HabitSubtaskCheckin].
class HabitSubtaskCheckinFamily extends Family<Set<String>> {
  /// See also [HabitSubtaskCheckin].
  const HabitSubtaskCheckinFamily();

  /// See also [HabitSubtaskCheckin].
  HabitSubtaskCheckinProvider call(String habitId) {
    return HabitSubtaskCheckinProvider(habitId);
  }

  @override
  HabitSubtaskCheckinProvider getProviderOverride(
    covariant HabitSubtaskCheckinProvider provider,
  ) {
    return call(provider.habitId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'habitSubtaskCheckinProvider';
}

/// See also [HabitSubtaskCheckin].
class HabitSubtaskCheckinProvider
    extends AutoDisposeNotifierProviderImpl<HabitSubtaskCheckin, Set<String>> {
  /// See also [HabitSubtaskCheckin].
  HabitSubtaskCheckinProvider(String habitId)
    : this._internal(
        () => HabitSubtaskCheckin()..habitId = habitId,
        from: habitSubtaskCheckinProvider,
        name: r'habitSubtaskCheckinProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$habitSubtaskCheckinHash,
        dependencies: HabitSubtaskCheckinFamily._dependencies,
        allTransitiveDependencies:
            HabitSubtaskCheckinFamily._allTransitiveDependencies,
        habitId: habitId,
      );

  HabitSubtaskCheckinProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.habitId,
  }) : super.internal();

  final String habitId;

  @override
  Set<String> runNotifierBuild(covariant HabitSubtaskCheckin notifier) {
    return notifier.build(habitId);
  }

  @override
  Override overrideWith(HabitSubtaskCheckin Function() create) {
    return ProviderOverride(
      origin: this,
      override: HabitSubtaskCheckinProvider._internal(
        () => create()..habitId = habitId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        habitId: habitId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<HabitSubtaskCheckin, Set<String>>
  createElement() {
    return _HabitSubtaskCheckinProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitSubtaskCheckinProvider && other.habitId == habitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, habitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HabitSubtaskCheckinRef on AutoDisposeNotifierProviderRef<Set<String>> {
  /// The parameter `habitId` of this provider.
  String get habitId;
}

class _HabitSubtaskCheckinProviderElement
    extends AutoDisposeNotifierProviderElement<HabitSubtaskCheckin, Set<String>>
    with HabitSubtaskCheckinRef {
  _HabitSubtaskCheckinProviderElement(super.provider);

  @override
  String get habitId => (origin as HabitSubtaskCheckinProvider).habitId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
