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
  final DateTime? startedAt;
  final List<PauseRecord> pauses;
  final DateTime? pausedAt;

  bool get isStarted => startedAt != null;

  Duration getElapsedTimeIgnoringPauses([DateTime? now]) {
    if (startedAt == null) {
      return Duration.zero;
    }
    DateTime rangeEnd = pausedAt ?? now ?? DateTime.now();
    Duration elapsedTime = rangeEnd.difference(startedAt!);
    for (PauseRecord pause in pauses) {
      elapsedTime -= pause.duration;
    }
    if (elapsedTime > timerDuration) {
      elapsedTime = timerDuration;
    }
    return elapsedTime;
  }

  Duration getRemainingTime([DateTime? now]) {
    Duration elapsedTime = getElapsedTimeIgnoringPauses(now);
    return _calculateRemainingTime(elapsedTime);
  }

  Duration _calculateRemainingTime(Duration elapsedTime) {
    Duration remainingTime = timerDuration - elapsedTime;
    if (remainingTime < Duration.zero) {
      remainingTime = Duration.zero;
    }
    return remainingTime;
  }

  (Duration, Duration) getRemainingAndElapsedTime([DateTime? now]) {
    Duration elapsedTime = getElapsedTimeIgnoringPauses(now);
    Duration remainingTime = _calculateRemainingTime(elapsedTime);
    return (remainingTime, elapsedTime);
  }

  DateTime? get estimatedEndTime {
    if (startedAt == null || pausedAt != null) {
      return null;
    }
    var result = startedAt!.add(timerDuration);
    for (PauseRecord pause in pauses) {
      result = result.add(pause.duration);
    }
    return result;
  }

  const TimerState({
    required this.timerType,
    required this.status,
    required this.timerDuration,
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
          startedAt: null,
          pauses: [],
          pausedAt: null,
        );
}
