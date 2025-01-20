import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/timer/domain/timersession/completion_status.dart';

part 'timer_session_query.freezed.dart';

/// Query parameters for fetching timer sessions
@freezed
class TimerSessionQuery with _$TimerSessionQuery {
  const factory TimerSessionQuery({
    /// Start of the time range
    required DateTime start,
    
    /// End of the time range
    required DateTime end,
    
    /// Filter by completion status
    @Default(CompletionStatus.any) CompletionStatus completionStatus,
    
    /// Filter by session type
    @Default(TimerType.any) TimerType sessionType,
  }) = _TimerSessionQuery;
}
