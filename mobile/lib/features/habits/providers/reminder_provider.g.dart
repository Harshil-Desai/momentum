// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HabitReminderNotifier)
final habitReminderProvider = HabitReminderNotifierFamily._();

final class HabitReminderNotifierProvider
    extends $AsyncNotifierProvider<HabitReminderNotifier, HabitReminder?> {
  HabitReminderNotifierProvider._({
    required HabitReminderNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'habitReminderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitReminderNotifierHash();

  @override
  String toString() {
    return r'habitReminderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HabitReminderNotifier create() => HabitReminderNotifier();

  @override
  bool operator ==(Object other) {
    return other is HabitReminderNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitReminderNotifierHash() =>
    r'1bd127cd0d4c02add65a3e77229e5db1178997f9';

final class HabitReminderNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          HabitReminderNotifier,
          AsyncValue<HabitReminder?>,
          HabitReminder?,
          FutureOr<HabitReminder?>,
          String
        > {
  HabitReminderNotifierFamily._()
    : super(
        retry: null,
        name: r'habitReminderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HabitReminderNotifierProvider call(String habitId) =>
      HabitReminderNotifierProvider._(argument: habitId, from: this);

  @override
  String toString() => r'habitReminderProvider';
}

abstract class _$HabitReminderNotifier extends $AsyncNotifier<HabitReminder?> {
  late final _$args = ref.$arg as String;
  String get habitId => _$args;

  FutureOr<HabitReminder?> build(String habitId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<HabitReminder?>, HabitReminder?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<HabitReminder?>, HabitReminder?>,
              AsyncValue<HabitReminder?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
