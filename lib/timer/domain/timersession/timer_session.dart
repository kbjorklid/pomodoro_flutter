import 'package:flutter/material.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';

import 'pause_record.dart';

class TimerSessionKey {
  final DateTime startedAt;

  TimerSessionKey(DateTime dateTime)
      : startedAt = DateTime.fromMillisecondsSinceEpoch(
            dateTime.millisecondsSinceEpoch,
            isUtc: true);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerSessionKey &&
          runtimeType == other.runtimeType &&
          toString() == other.toString();

  @override
  int get hashCode => startedAt.hashCode;

  @override
  String toString() {
    // Do not modify this, it may be used to store and access stored
    // sessions.
    return 'TSK(${startedAt.toIso8601String()})';
  }
}

abstract class TimerSession {
  TimerType get sessionType;

  DateTime get startedAt;

  List<PauseRecord> get pauses;

  Duration get totalDuration;

  bool get isEnded;

  late final TimerSessionKey key = TimerSessionKey(startedAt);

  @override
  String toString() {
    return _ToStringBuilder(this)
        .add('sessionType', sessionType)
        .add('startedAt', startedAt)
        .add('pauses', pauses)
        .add('targetDuration', totalDuration)
        .add('isEnded', isEnded)
        .toString();
  }
}

class RunningTimerSession extends TimerSession {
  @override
  final TimerType sessionType;
  @override
  final DateTime startedAt;
  final DateTime? pausedAt;
  @override
  final List<PauseRecord> pauses;
  @override
  final Duration totalDuration;
  @override
  final bool isEnded = false;

  RunningTimerSession(
      {required this.sessionType,
      required this.startedAt,
      required this.pausedAt,
      required Iterable<PauseRecord> pauses,
      required this.totalDuration})
      : pauses = List.unmodifiable(pauses);

  @override
  String toString() {
    return _ToStringBuilder(this)
        .add('sessionType', sessionType)
        .add('startedAt', startedAt)
        .add('pausedAt', pausedAt)
        .add('pauses', pauses)
        .add('targetDuration', totalDuration)
        .add('isEnded', isEnded)
        .toString();
  }
}

abstract class ClosedTimerSession extends TimerSession {
  DateTime get timerRangeEnd;

  DateTimeRange get range =>
      DateTimeRange(start: startedAt, end: timerRangeEnd);

  Duration get durationWithoutPauseTime =>
      timerRangeEnd.difference(startedAt) -
      pauses.fold(Duration.zero, (sum, pause) => sum + pause.duration);

  bool get isCompleted => durationWithoutPauseTime >= totalDuration;
}

class TimerSessionSnapshot extends ClosedTimerSession {
  @override
  TimerType get sessionType => _runningTimerSession.sessionType;

  @override
  DateTime get startedAt => _runningTimerSession.startedAt;

  @override
  bool get isEnded => _runningTimerSession.isEnded;

  @override
  DateTime timerRangeEnd;

  @override
  List<PauseRecord> get pauses {
    if (_runningTimerSession.pausedAt == null) {
      return _runningTimerSession.pauses;
    }
    return _runningTimerSession.pauses +
        [
          PauseRecord(
            pausedAt: _runningTimerSession.pausedAt!,
            resumedAt: timerRangeEnd,
          )
        ];
  }

  @override
  Duration get totalDuration => _runningTimerSession.totalDuration;

  TimerSessionSnapshot({
    required runningTimerSession,
    required this.timerRangeEnd,
  }) : _runningTimerSession = runningTimerSession;

  final RunningTimerSession _runningTimerSession;

  @override
  String toString() {
    return _ToStringBuilder(this)
        .add('sessionType', sessionType)
        .add('startedAt', startedAt)
        .add('timerRanngeEnd', timerRangeEnd)
        .add('pauses', pauses)
        .add('targetDuration', totalDuration)
        .add('isEnded', isEnded)
        .add('durationWithoutPauseTime', durationWithoutPauseTime)
        .toString();
  }
}

class EndedTimerSession extends ClosedTimerSession {
  @override
  final TimerType sessionType;
  @override
  final DateTime startedAt;
  @override
  final DateTime timerRangeEnd;
  @override
  final List<PauseRecord> pauses;
  @override
  final Duration totalDuration;
  @override
  final bool isEnded = true;

  EndedTimerSession(
      {required this.sessionType,
      required this.startedAt,
      required endedAt,
      required Iterable<PauseRecord> pauses,
      required this.totalDuration})
      : timerRangeEnd = endedAt,
        pauses = List.unmodifiable(pauses);

  @override
  String toString() {
    return _ToStringBuilder(this)
        .add('sessionType', sessionType)
        .add('startedAt', startedAt)
        .add('timerRangeEnd', timerRangeEnd)
        .add('pauses', pauses)
        .add('targetDuration', totalDuration)
        .add('isEnded', isEnded)
        .add('durationWithoutPauseTime', durationWithoutPauseTime)
        .toString();
  }
}

class _ToStringBuilder {
  final StringBuffer _buffer = StringBuffer();

  _ToStringBuilder(Object theObject) {
    _buffer.write(theObject.runtimeType.toString());
    _buffer.write('(');
  }

  _ToStringBuilder add(String key, dynamic value) {
    if (value == null) {
      _buffer.write('$key: [null]; ');
      return this;
    }
    String valueStr;
    switch (value.runtimeType) {
      case DateTime _:
        valueStr = (value as DateTime).toIso8601String();
        break;
      case Iterable _:
        valueStr = (value as Iterable).join(', ');
        break;
      default:
        valueStr = value.toString();
    }

    _buffer.write('$key: $valueStr; ');
    return this;
  }

  @override
  String toString() {
    _buffer.write(')');
    return _buffer.toString();
  }
}
