import 'package:pomodoro_app2/history/domain/timer_session_query.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';

abstract class TimerSessionRepositoryPort {
  /// Saves a timer session
  Future<void> save(TimerSession session);

  /// Gets all sessions matching the query parameters
  Future<List<TimerSession>> query(TimerSessionQuery query);

  /// Deletes a session by its start time
  Future<void> delete(DateTime startedAt);
}
