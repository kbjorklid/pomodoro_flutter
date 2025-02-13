import 'package:pomodoro_app2/history/domain/timer_session_query.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';

abstract class TimerSessionRepositoryPort {
  /// Saves a timer session
  Future<void> save(EndedTimerSession session);

  /// Gets all sessions matching the query parameters
  Future<List<EndedTimerSession>> query(TimerSessionQuery query);

  /// Deletes a session by its start time
  Future<void> delete(TimerSessionKey startedAt);

  /// Undeletes a session by its start time
  Future<void> undelete(TimerSessionKey startedAt);

  /// Gets daily session counts matching the query parameters
  Future<List<({DateTime date, int count})>> queryDailyCounts(
    TimerSessionQuery query,
  );
}
