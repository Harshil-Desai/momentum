// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$habitReminderNotifierHash() =>
    r'7fac5bf8a7677538293f17658f8c7a1ee28d71c3';

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

abstract class _$HabitReminderNotifier
    extends BuildlessAutoDisposeAsyncNotifier<HabitReminder?> {
  late final String habitId;

  FutureOr<HabitReminder?> build(String habitId);
}

/// See also [HabitReminderNotifier].
@ProviderFor(HabitReminderNotifier)
const habitReminderNotifierProvider = HabitReminderNotifierFamily();

/// See also [HabitReminderNotifier].
class HabitReminderNotifierFamily extends Family<AsyncValue<HabitReminder?>> {
  /// See also [HabitReminderNotifier].
  const HabitReminderNotifierFamily();

  /// See also [HabitReminderNotifier].
  HabitReminderNotifierProvider call(String habitId) {
    return HabitReminderNotifierProvider(habitId);
  }

  @override
  HabitReminderNotifierProvider getProviderOverride(
    covariant HabitReminderNotifierProvider provider,
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
  String? get name => r'habitReminderNotifierProvider';
}

/// See also [HabitReminderNotifier].
class HabitReminderNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          HabitReminderNotifier,
          HabitReminder?
        > {
  /// See also [HabitReminderNotifier].
  HabitReminderNotifierProvider(String habitId)
    : this._internal(
        () => HabitReminderNotifier()..habitId = habitId,
        from: habitReminderNotifierProvider,
        name: r'habitReminderNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$habitReminderNotifierHash,
        dependencies: HabitReminderNotifierFamily._dependencies,
        allTransitiveDependencies:
            HabitReminderNotifierFamily._allTransitiveDependencies,
        habitId: habitId,
      );

  HabitReminderNotifierProvider._internal(
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
  FutureOr<HabitReminder?> runNotifierBuild(
    covariant HabitReminderNotifier notifier,
  ) {
    return notifier.build(habitId);
  }

  @override
  Override overrideWith(HabitReminderNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: HabitReminderNotifierProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<HabitReminderNotifier, HabitReminder?>
  createElement() {
    return _HabitReminderNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitReminderNotifierProvider && other.habitId == habitId;
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
mixin HabitReminderNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<HabitReminder?> {
  /// The parameter `habitId` of this provider.
  String get habitId;
}

class _HabitReminderNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          HabitReminderNotifier,
          HabitReminder?
        >
    with HabitReminderNotifierRef {
  _HabitReminderNotifierProviderElement(super.provider);

  @override
  String get habitId => (origin as HabitReminderNotifierProvider).habitId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
