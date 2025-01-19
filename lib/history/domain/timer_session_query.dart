import 'package:freezed_annotation/freezed_annotation.dart';

part 'timer_session_query.freezed.dart';

/// Query parameters for fetching timer sessions
@freezed
class TimerSessionQuery with _$TimerSessionQuery {
  const factory TimerSessionQuery({
    /// Start of the time range
    required DateTime start,
    
    /// End of the time range
    required DateTime end,
  }) = _TimerSessionQuery;
}
