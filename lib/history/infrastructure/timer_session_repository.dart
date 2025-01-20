import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/history/domain/timer_session_query.dart';
import 'package:pomodoro_app2/history/domain/timer_session_repository_port.dart';
import 'package:pomodoro_app2/history/infrastructure/timer_session_adapter.dart';
import 'package:pomodoro_app2/timer/domain/timersession/completion_status.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';

final _logger = Logger();
class TimerSessionRepository implements TimerSessionRepositoryPort {
  static const _boxName = 'timerSessions';
  late final Box<TimerSessionAdapter> _box;

  TimerSessionRepository() {
    _init();
  }

  Future<void> _init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TimerSessionAdapterAdapter());
    }
    _box = await Hive.openBox<TimerSessionAdapter>(_boxName);
  }

  @override
  Future<void> save(TimerSession session) async {
    _logger.d('Saving timer session: ${session.sessionType} '
        'started at ${session.startedAt}');
    await _box.put(
      session.startedAt.toIso8601String(),
      TimerSessionAdapter(session),
    );
    _logger.d('Session saved successfully');
  }

  @override
  Future<List<TimerSession>> query(TimerSessionQuery query) async {
    _logger.d('Querying sessions: '
        'start=${query.start}, end=${query.end}, '
        'type=${query.sessionType}, status=${query.completionStatus}');
    final sessions = _box.values
        .where((adapter) =>
            adapter.session.startedAt.isAfter(query.start) &&
            adapter.session.startedAt.isBefore(query.end) &&
            (query.sessionType == TimerType.any ||
                adapter.session.sessionType == query.sessionType) &&
            (query.completionStatus == CompletionStatus.any ||
                (query.completionStatus == CompletionStatus.completed
                    ? adapter.session.isCompleted
                    : !adapter.session.isCompleted)))
        .map((adapter) => adapter.session)
        .toList();
        
    // Sort by start time descending
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    _logger.d('Found ${sessions.length} matching sessions');
    return sessions;
  }

  @override
  Future<void> delete(DateTime startedAt) async {
    _logger.d('Deleting session started at $startedAt');
    await _box.delete(startedAt.toIso8601String());
    _logger.d('Session deleted successfully');
  }
}
