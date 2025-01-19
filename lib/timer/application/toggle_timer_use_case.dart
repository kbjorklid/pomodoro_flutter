import 'package:pomodoro_app2/timer/application/timer_service.dart';

import '../domain/timer_state.dart';

/// Use case for toggling timer state between running and paused
class ToggleTimerUseCase {
  final TimerService _timerService;

  ToggleTimerUseCase(this._timerService);

  /// Executes the use case to toggle timer state
  ///
  /// If timer is running, pauses it
  /// If timer is paused, resumes it
  /// If timer is ended or not started, starts it
  void execute() {
    final state = _timerService.state;
    switch (state.status) {
      case TimerStatus.running:
        _timerService.pause();
        break;
      case TimerStatus.paused:
        _timerService.resume();
        break;
      case TimerStatus.ended:
      case TimerStatus.notStarted:
        _timerService.startFromBeginning();
        break;
    }
  }
}
