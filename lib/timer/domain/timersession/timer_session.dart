import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';

import 'pause_record.dart';

part 'timer_session.freezed.dart';

/// Represents a completed or incomplete timer session
@freezed
class TimerSession with _$TimerSession {
  const TimerSession._();

  const factory TimerSession({
    /// Type of session (work or rest)
    required TimerType sessionType,

    /// When the session started
    required DateTime startedAt,

    /// When the session ended (completed or stopped)
    required DateTime? endedAt,

    /// List of all pauses during this session
    required List<PauseRecord> pauses,

    /// Total intended duration of the session
    required Duration totalDuration,
  }) = _TimerSession;

  bool get isEndecd => endedAt != null;

  /// Whether the session was completed (derived value)
  bool get isCompleted {
    Duration? duration = durationWithoutPauseTime;
    if (duration == null) return false;
    return duration >= totalDuration;
  }

  Duration? get durationWithoutPauseTime {
    DateTime? end = endedAt;
    if (end == null) return null;
    return end.difference(startedAt) -
        pauses.fold(Duration.zero, (sum, pause) => sum + pause.duration);
  }

  DateTimeRange? get range {
    DateTime? end = endedAt;
    if (end == null) return null;
    return DateTimeRange(start: startedAt, end: end);
  }

  @override
  String toString() {
    return 'TimerSession(sessionType: $sessionType, '
        'startedAt: ${startedAt.toString().split('.').first}, '
        'endedAt: ${endedAt.toString().split('.').first}, '
        'totalDuration: $totalDuration, '
        'isCompleted: $isCompleted)';
  }
}
