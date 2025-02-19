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

    // If target type is same as current, do nothing
    if (targetType == currentType) {
      return;
    }

    // Handle rest type transitions
    // Handle rest type transitions
    if (_isRestTypeTransition(currentType, targetType) &&
        currentStatus == TimerStatus.running) {
      final currentState = _timer.getCurrentState();
      if (currentState != null) {
        final elapsedTime = currentState.elapsedTime;
        final currentTypeDuration = currentState.timerDuration;
        final targetTypeDuration = await _getDurationForType(targetType);

        // Calculate elapsed proportion and apply to target duration
        final elapsedProportion = elapsedTime.inMilliseconds / currentTypeDuration.inMilliseconds;
        final targetElapsedTime = Duration(milliseconds:
        (targetTypeDuration.inMilliseconds * elapsedProportion).round());
        final targetRemainingTime = targetTypeDuration - targetElapsedTime;

        // Only continue if there's still time remaining in target duration
        if (targetRemainingTime.inMilliseconds > 0) {
          await _startTimerWithType(targetType);
          return;
        }
      }
    }
    // In all other cases, stop current timer and start new one
    _timer.stopTimer();
    await _startTimerWithType(targetType);
  }

  bool _isRestTypeTransition(TimerType current, TimerType target) {
    return (current == TimerType.shortRest && target == TimerType.longRest) ||
        (current == TimerType.longRest && target == TimerType.shortRest);
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

  Future<void> _startTimerWithType(TimerType type) async {
    _timer.resetTimer(type);
  }
}

@riverpod
SetTimerTypeUseCase setTimerTypeUseCase(Ref ref) {
  return SetTimerTypeUseCase(
    ref.watch(pomodoroTimerProvider.notifier),
    ref.read(settingsRepositoryProvider),
  );
}