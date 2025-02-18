import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/settings/domain/settings_repository_port.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:pomodoro_app2/timer/application/timer_state/timer_notifier.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_timer_types_allowed_to_switch_to_use_case.g.dart';

class GetTimerTypesAllowedToSwitchToUseCase {
  final PomodoroTimer _timer;
  final SettingsRepositoryPort _settings;

  GetTimerTypesAllowedToSwitchToUseCase({
    required PomodoroTimer timer,
    required SettingsRepositoryPort settings,
  })  : _timer = timer,
        _settings = settings;

  Future<Set<TimerType>> query() async {
    final currentState = _timer.getCurrentState();
    final currentTimerType = currentState?.timerType;
    final currentStatus = currentState?.status ?? TimerStatus.notStarted;

    if (currentStatus == TimerStatus.notStarted ||
        currentStatus == TimerStatus.ended) {
      return TimerType.values.toSet();
    }

    final allowedTimerTypes = <TimerType>{};

    // Work and current type are always allowed
    allowedTimerTypes.add(TimerType.work);
    allowedTimerTypes.add(currentTimerType!);

    if (currentTimerType.isWork) {
      return allowedTimerTypes;
    }

    // For rest timers, check if switching to other rest type is allowed
    if (currentState != null && currentStatus == TimerStatus.running) {
      final elapsedTime = currentState.elapsedTime;
      final currentDuration = currentState.timerDuration;

      // Calculate elapsed proportion
      final elapsedProportion =
          elapsedTime.inMilliseconds / currentDuration.inMilliseconds;

      if (currentTimerType == TimerType.shortRest) {
        final longRestDuration = await _settings.getLongRestDuration();
        final targetElapsedTime = Duration(
            milliseconds:
                (longRestDuration.inMilliseconds * elapsedProportion).round());

        if (targetElapsedTime < longRestDuration) {
          allowedTimerTypes.add(TimerType.longRest);
        }
      } else if (currentTimerType == TimerType.longRest) {
        final shortRestDuration = await _settings.getShortRestDuration();
        final targetElapsedTime = Duration(
            milliseconds:
                (shortRestDuration.inMilliseconds * elapsedProportion).round());

        if (targetElapsedTime < shortRestDuration) {
          allowedTimerTypes.add(TimerType.shortRest);
        }
      }
    }

    return allowedTimerTypes;
  }
}

@riverpod
Future<Set<TimerType>> timerTypesAllowedToSwitchTo(Ref ref) async {
  // Watch the timer state to react to changes
  final timerState = ref.watch(pomodoroTimerProvider);

  // Watch settings changes
  ref.watch(settingsRepositoryProvider);

  final useCase = GetTimerTypesAllowedToSwitchToUseCase(
    timer: ref.watch(pomodoroTimerProvider.notifier),
    settings: ref.read(settingsRepositoryProvider),
  );
  return useCase.query();
}

@riverpod
GetTimerTypesAllowedToSwitchToUseCase getTimerTypesAllowedToSwitchToUseCase(
    Ref ref) {
  ref.watch(pomodoroTimerProvider); // Watch timer state
  ref.watch(settingsRepositoryProvider); // Watch settings

  return GetTimerTypesAllowedToSwitchToUseCase(
    timer: ref.watch(pomodoroTimerProvider.notifier),
    settings: ref.read(settingsRepositoryProvider),
  );
}