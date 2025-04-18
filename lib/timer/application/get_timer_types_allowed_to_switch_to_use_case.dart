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
    if (currentState == null) {
      return <TimerType>{};
    }
    final currentTimerType = currentState.timerType;
    final currentStatus = currentState.status;

    if (currentStatus == TimerStatus.notStarted ||
        currentStatus == TimerStatus.ended) {
      return TimerType.values.toSet();
    } else if (currentTimerType.isWork) {
      return <TimerType>{TimerType.work};
    }

    final allowedTimerTypes = <TimerType>{currentTimerType, TimerType.work};
    // For rest timers, check if switching to other rest type is allowed
    if (currentStatus == TimerStatus.running ||
        currentStatus == TimerStatus.paused) {
      DateTime now = DateTime.now();
      final elapsedTime =
          currentState.getElapsedTimeIgnoringPauses(now).inSeconds;

      if (currentTimerType == TimerType.shortRest) {
        final longRestDuration =
            (await _settings.getLongRestDuration()).inSeconds;
        if (elapsedTime < longRestDuration) {
          allowedTimerTypes.add(TimerType.longRest);
        }
      } else if (currentTimerType == TimerType.longRest) {
        final shortRestDuration =
            (await _settings.getShortRestDuration()).inSeconds;

        if (elapsedTime < shortRestDuration) {
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
  ref.watch(pomodoroTimerProvider);

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
