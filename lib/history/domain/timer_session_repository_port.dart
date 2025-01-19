import 'package:pomodoro_app2/history/domain/timer_session.dart';

abstract class TimerSessionRepositoryPort {
  /// Saves a timer session
  Future<void> save(TimerSession session);

  /// Gets all sessions within a time range
  Future<List<TimerSession>> getSessionsInRange(DateTime start, DateTime end);

  /// Deletes a session by its start time
  Future<void> delete(DateTime startedAt);
}
