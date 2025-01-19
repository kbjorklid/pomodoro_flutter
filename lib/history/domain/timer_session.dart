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
    required DateTime endedAt,
    
    /// List of all pauses during this session
    required List<PauseRecord> pauses,
    
    /// Total intended duration of the session
    required Duration totalDuration,
    
    /// Actual time spent in the session before ending
    required Duration actualDuration,
  }) = _TimerSession;

  /// Whether the session was completed (derived value)
  bool get isCompleted => actualDuration >= totalDuration;
}
