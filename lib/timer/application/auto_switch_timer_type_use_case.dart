import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/settings/domain/settings_repository_port.dart';
import 'package:pomodoro_app2/timer/application/set_timer_type_use_case.dart';
import 'package:pomodoro_app2/timer/application/timer_state/timer_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';

part 'auto_switch_timer_type_use_case.g.dart';

class AutoSwitchTimerTypeUseCase {
  final SetTimerTypeUseCase _setTimerTypeUseCase;
  final SettingsRepositoryPort _settingsRepository;
  final PomodoroTimer _timer;

  AutoSwitchTimerTypeUseCase(
    this._setTimerTypeUseCase,
    this._settingsRepository,
    this._timer,
  );

  Future<void> execute() async {
    final autoSwitchEnabled = await _settingsRepository.getAutoSwitchTimer();
    if (!autoSwitchEnabled) {
      return;
    }

    final currentTimerType = _timer.getCurrentTimerType();

    TimerType targetType;
    if (currentTimerType == TimerType.work) {
      targetType = TimerType.shortRest;
    } else if (currentTimerType == TimerType.shortRest ||
        currentTimerType == TimerType.longRest) {
      targetType = TimerType.work;
    } else {
      // Default to work if the current type is unknown
      targetType = TimerType.work;
    }

    await _setTimerTypeUseCase.execute(targetType);
  }
}

@riverpod
AutoSwitchTimerTypeUseCase autoSwitchTimerTypeUseCase(Ref ref) {
  return AutoSwitchTimerTypeUseCase(
    ref.watch(setTimerTypeUseCaseProvider),
    ref.read(settingsRepositoryProvider),
    ref.read(pomodoroTimerProvider.notifier),
  );
}
