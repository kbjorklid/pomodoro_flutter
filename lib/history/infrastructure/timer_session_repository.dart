import 'package:hive/hive.dart';
import 'package:pomodoro_app2/history/domain/timer_session.dart';
import 'package:pomodoro_app2/history/domain/timer_session_query.dart';
import 'package:pomodoro_app2/history/domain/timer_session_repository_port.dart';
import 'package:pomodoro_app2/history/infrastructure/timer_session_adapter.dart';

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
    await _box.put(
      session.startedAt.toIso8601String(),
      TimerSessionAdapter(session),
    );
  }

  @override
  Future<List<TimerSession>> query(TimerSessionQuery query) async {
    final sessions = _box.values
        .where((adapter) =>
            adapter.session.startedAt.isAfter(query.start) &&
            adapter.session.startedAt.isBefore(query.end))
        .map((adapter) => adapter.session)
        .toList();
        
    // Sort by start time descending
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  @override
  Future<void> delete(DateTime startedAt) async {
    await _box.delete(startedAt.toIso8601String());
  }
}
