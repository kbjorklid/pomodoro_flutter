import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/settings/domain/settings_repository_port.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:pomodoro_app2/timer/application/timer_state/timer_notifier.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'set_timer_type_use_case.g.dart';

class SetTimerTypeUseCase {
  final PomodoroTimer _timer;
  final SettingsRepositoryPort _settings;

  SetTimerTypeUseCase(this._timer, this._settings);

  Future<void> execute(TimerType targetType) async {
    final currentStatus = _timer.getCurrentStatus();
    final currentType = _timer.getCurrentTimerType();

    if (targetType == currentType) {
      return;
    }

    if (currentType.isRest &&
        targetType.isRest &&
        currentStatus == TimerStatus.running) {
      final currentState = _timer.getCurrentState();
      if (currentState != null) {
        DateTime now = DateTime.now();
        final elapsedTime = currentState.getElapsedTimeIgnoringPauses(now);
        final targetTypeDuration = await _getDurationForType(targetType);

        if (elapsedTime < targetTypeDuration) {
          final successfullyChanged = _changeTimerTypeOnTheFly(targetType);
          if (successfullyChanged) return;
        }
      }
    }
    _timer.stopTimer();
    await _timer.resetTimer(targetType);
  }

  Future<Duration> _getDurationForType(TimerType type) async {
    switch (type) {
      case TimerType.work:
        return await _settings.getWorkDuration();
      case TimerType.shortRest:
        return await _settings.getShortRestDuration();
      case TimerType.longRest:
        return await _settings.getLongRestDuration();
    }
  }

  bool _changeTimerTypeOnTheFly(TimerType type) {
    return _timer.changeTimerTypeOnTheFly(type);
  }
}

@riverpod
SetTimerTypeUseCase setTimerTypeUseCase(Ref ref) {
  return SetTimerTypeUseCase(
    ref.watch(pomodoroTimerProvider.notifier),
    ref.read(settingsRepositoryProvider),
  );
}