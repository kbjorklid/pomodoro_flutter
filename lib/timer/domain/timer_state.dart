import 'package:logger/logger.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/timer/domain/timersession/pause_record.dart';

enum TimerStatus {
  running,
  paused,
  ended,
  notStarted,
}

final _logger = Logger();

class TimerState {
  final TimerType timerType;
  final TimerStatus status;
  final Duration timerDuration;
  final DateTime? startedAt;
  final List<PauseRecord> pauses;
  final DateTime? pausedAt;
  final bool overtimeEnabled;

  bool get isStarted => startedAt != null;

  Duration getElapsedTimeIgnoringPauses([DateTime? now]) {
    if (startedAt == null) {
      return Duration.zero;
    }
    now ??= DateTime.now();
    DateTime rangeEnd = pausedAt ?? now;
    Duration elapsedTime = rangeEnd.difference(startedAt!);
    Duration timeSpentInPauses = Duration.zero;
    for (PauseRecord pause in pauses) {
      timeSpentInPauses += pause.duration;
    }
    elapsedTime -= timeSpentInPauses;
    _logger.d('getElapsedTimeIgnoringPauses: Elapsed time: $elapsedTime, '
        'pausedAt: $pausedAt, now: $now, rangeEnd: $rangeEnd, '
        'startedAt: $startedAt, timeSpentInPauses: $timeSpentInPauses');
    return elapsedTime;
  }

  bool isOvertime([DateTime? now]) {
    if (!overtimeEnabled || !isStarted) {
      return false;
    }
    return getRemainingTime(now) < Duration.zero;
  }

  Duration getRemainingTime([DateTime? now]) {
    Duration elapsedTime = getElapsedTimeIgnoringPauses(now);
    return _calculateRemainingTime(elapsedTime);
  }

  Duration _calculateRemainingTime(Duration elapsedTime) {
    Duration remainingTime = timerDuration - elapsedTime;
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
    required this.overtimeEnabled,
  });

  TimerState.initial(
      [TimerType timerType = TimerType.work,
      Duration timerDuration = const Duration(minutes: 25),
      bool overtimeEnabled = true])
      : this(
          timerType: timerType,
          status: TimerStatus.notStarted,
          timerDuration: timerDuration,
          startedAt: null,
          pauses: [],
          pausedAt: null,
          overtimeEnabled: overtimeEnabled,
        );
}

class TimerStateBuilder {
  TimerType? _timerType;
  TimerStatus? _status;
  Duration? _timerDuration;
  DateTime? _startedAt;
  List<PauseRecord>? _pauses;
  DateTime? _pausedAt;
  bool? _overtimeEnabled;

  TimerStateBuilder([TimerState? initialState]) {
    if (initialState != null) {
      _timerType = initialState.timerType;
      _status = initialState.status;
      _timerDuration = initialState.timerDuration;
      _startedAt = initialState.startedAt;
      _pauses = List.from(initialState.pauses);
      _pausedAt = initialState.pausedAt;
      _overtimeEnabled = initialState.overtimeEnabled;
    } else {
      _pauses = []; // Default to empty list
    }
  }

  TimerStateBuilder withTimerType(TimerType timerType) {
    _timerType = timerType;
    return this;
  }

  TimerStateBuilder withStatus(TimerStatus status) {
    _status = status;
    return this;
  }

  TimerStateBuilder withTimerDuration(Duration timerDuration) {
    _timerDuration = timerDuration;
    return this;
  }

  TimerStateBuilder withStartedAt(DateTime? startedAt) {
    _startedAt = startedAt;
    return this;
  }

  TimerStateBuilder withPauses(List<PauseRecord> pauses) {
    _pauses = pauses;
    return this;
  }

  TimerStateBuilder withPausedAt(DateTime? pausedAt) {
    _pausedAt = pausedAt;
    return this;
  }

  TimerStateBuilder withAdditionalPause(PauseRecord pause) {
    _pauses ??= [];
    _pauses!.add(pause);
    return this;
  }

  TimerStateBuilder withOvertimeEnabled(bool overtimeEnabled) {
    _overtimeEnabled = overtimeEnabled;
    return this;
  }

  TimerState build() {
    // Add checks for required fields if necessary
    if (_timerType == null) {
      throw StateError('timerType must be set before building.');
    }
    if (_status == null) {
      throw StateError('status must be set before building.');
    }
    if (_timerDuration == null) {
      throw StateError('timerDuration must be set before building.');
    }
    // startedAt can be null
    if (_pauses == null) {
      throw StateError('pauses must be set before building.');
    }
    // pausedAt can be null
    if (_overtimeEnabled == null) {
      throw StateError('overtimeEnabled must be set before building.');
    }

    return TimerState(
      timerType: _timerType!,
      status: _status!,
      timerDuration: _timerDuration!,
      startedAt: _startedAt,
      pauses: _pauses!,
      pausedAt: _pausedAt,
      overtimeEnabled: _overtimeEnabled!,
    );
  }
}
