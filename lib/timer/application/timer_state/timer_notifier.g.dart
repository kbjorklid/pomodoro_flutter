// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timerEventsHash() => r'4d26591bd25234f2687f7d946bd4fbf7a9926ad3';

/// See also [timerEvents].
@ProviderFor(timerEvents)
final timerEventsProvider = AutoDisposeStreamProvider<TimerEvent>.internal(
  timerEvents,
  name: r'timerEventsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$timerEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TimerEventsRef = AutoDisposeStreamProviderRef<TimerEvent>;
String _$pomodoroTimerHash() => r'8aaecc9fdef1a86d1a38bff26c9d95a96678c2ab';

/// See also [PomodoroTimer].
@ProviderFor(PomodoroTimer)
final pomodoroTimerProvider =
    AutoDisposeAsyncNotifierProvider<PomodoroTimer, TimerState>.internal(
  PomodoroTimer.new,
  name: r'pomodoroTimerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pomodoroTimerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PomodoroTimer = AutoDisposeAsyncNotifier<TimerState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
