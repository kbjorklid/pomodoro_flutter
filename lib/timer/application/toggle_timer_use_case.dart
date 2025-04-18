import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/application/timer_state/timer_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/timer_state.dart';

part 'toggle_timer_use_case.g.dart';

class ToggleTimerUseCase {
  final PomodoroTimer _timer;

  ToggleTimerUseCase(this._timer);

  /// Executes the use case to toggle timer state
  ///
  /// If timer is running, pauses it
  /// If timer is paused, resumes it
  /// If timer is ended or not started, starts it with default duration
  void execute() {
    switch (_timer.getCurrentStatus()) {
      case TimerStatus.running:
        _timer.pauseTimer();
        break;
      case TimerStatus.paused:
        _timer.resumeTimer();
        break;
      case TimerStatus.ended:
      case TimerStatus.notStarted:
        _timer.startTimer();
        break;
    }
  }
}

@riverpod
ToggleTimerUseCase toggleTimerUseCase(Ref ref) {
  return ToggleTimerUseCase(ref.watch(pomodoroTimerProvider.notifier));
}
