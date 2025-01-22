import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:pomodoro_app2/core/infrastructure/duration_adapter.dart';
import 'package:pomodoro_app2/history/domain/timer_session_query.dart';
import 'package:pomodoro_app2/history/domain/timer_session_repository_port.dart';
import 'package:pomodoro_app2/history/infrastructure/dtos/timer_session_dto.dart';
import 'package:pomodoro_app2/timer/domain/timersession/completion_status.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';

import 'dtos/pause_record_dto.dart';

final _logger = Logger();
class TimerSessionRepository implements TimerSessionRepositoryPort {
  static const _boxName = 'timerSessions';
  late final Box<TimerSessionDTO> _box;

  TimerSessionRepository() {
    _init();
  }

  Future<void> _init() async {
    Hive.registerAdapter(DurationAdapter());
    Hive.registerAdapter(TimerSessionDTOAdapter());
    Hive.registerAdapter(PauseRecordDTOAdapter());
    _box = await Hive.openBox<TimerSessionDTO>(_boxName);
  }

  @override
  Future<void> save(TimerSession session) async {
    _logger.d('Saving timer session: ${session.sessionType} '
        'started at ${session.startedAt}');
    await _box.put(
      session.startedAt.toIso8601String(),
      TimerSessionDTO.fromDomain(session),
    );
    _logger.d('Session saved successfully');
  }

  @override
  Future<List<TimerSession>> query(TimerSessionQuery query) async {
    _logger.d('Querying sessions: '
        'start=${query.start}, end=${query.end}, '
        'type=${query.sessionType}, status=${query.completionStatus}');
    final sessions = _box.values
        .where((dto) =>
            dto.startedAt.isAfter(query.start) &&
            dto.startedAt.isBefore(query.end) &&
            (query.sessionType == null ||
                dto.sessionTypeCode == query.sessionType?.index) &&
            (query.completionStatus == CompletionStatus.any ||
                (query.completionStatus == CompletionStatus.completed
                    ? dto.toDomain().isCompleted
                    : !dto.toDomain().isCompleted)))
        .map((dto) => dto.toDomain())
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

  @override
  Future<List<({DateTime date, int count})>> queryDailyCounts(
    TimerSessionQuery query,
  ) async {
    _logger.d('Querying daily counts: '
        'start=${query.start}, end=${query.end}, '
        'type=${query.sessionType}, status=${query.completionStatus}');

    final sessions = await this.query(query);
    final counts = <DateTime, int>{};

    for (final session in sessions) {
      // Normalize dates to midnight for grouping
      final date = DateTime(
        session.startedAt.year,
        session.startedAt.month,
        session.startedAt.day,
      );

      counts.update(date, (v) => v + 1, ifAbsent: () => 1);
    }

    // Convert to sorted list of records
    final results = counts.entries
        .map((e) => (date: e.key, count: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    _logger.d('Found ${results.length} days with sessions');
    return results;
  }
}
