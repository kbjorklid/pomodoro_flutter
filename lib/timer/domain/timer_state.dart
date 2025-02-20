import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/timer/domain/timersession/pause_record.dart';

enum TimerStatus {
  running,
  paused,
  ended,
  notStarted,
}

class TimerState {
  final TimerType timerType;
  final TimerStatus status;
  final Duration timerDuration;
  final Duration remainingTime;
  final DateTime? startedAt;
  final List<PauseRecord> pauses;
  final DateTime? pausedAt;

  bool get isStarted => startedAt != null;

  Duration get elapsedTime {
    if (!isStarted) {
      return Duration.zero;
    }
    return timerDuration - remainingTime;
  }

  const TimerState({
    required this.timerType,
    required this.status,
    required this.timerDuration,
    required this.remainingTime,
    required this.startedAt,
    required this.pauses,
    required this.pausedAt,
  });

  TimerState.initial(
      [TimerType timerType = TimerType.work,
      Duration timerDuration = const Duration(minutes: 25)])
      : this(
          timerType: timerType,
          status: TimerStatus.notStarted,
          timerDuration: timerDuration,
          remainingTime: timerDuration,
          startedAt: null,
          pauses: [],
          pausedAt: null,
        );
}
