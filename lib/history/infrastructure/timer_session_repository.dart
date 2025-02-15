import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:pomodoro_app2/core/domain/events/event_bus.dart';
import 'package:pomodoro_app2/core/domain/events/timer_history_updated_event.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
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
  late final Future<void> _initialized;

  TimerSessionRepository() {
    _initialized = _init();
  }

  Future<void> _init() async {
    Hive.registerAdapter(DurationAdapter());
    Hive.registerAdapter(TimerSessionDTOAdapter());
    Hive.registerAdapter(PauseRecordDTOAdapter());
    _box = await Hive.openBox<TimerSessionDTO>(_boxName);
  }

  @override
  Future<void> save(EndedTimerSession session) async {
    _logger.d('Saving timer session with key: ${session.key}');

    _logger.d('Saving timer session: ${session.sessionType} '
        'started at ${session.startedAt}, pauses: ${session.pauses}');
    var dto = TimerSessionDTO.fromDomain(session);
    await _initialized;
    await _put(session.key, dto);
    _sendEventForHistoryUpdate();
    _logger.d('Session saved successfully');
  }

  Future<void> _put(TimerSessionKey key, TimerSessionDTO dto) async {
    await _initialized;
    await _box.put(key.toString(), dto);
  }

  TimerSessionDTO? _get(TimerSessionKey key) {
    return _box.get(key.toString());
  }

  @override
  Future<List<EndedTimerSession>> query(TimerSessionQuery query) async {
    await _initialized;
    _logger.d('Querying sessions: '
        'start=${query.start}, end=${query.end}, '
        'type=${query.sessionType}, status=${query.completionStatus}');
    final sessions = _box.values
        .where((dto) =>
            !dto.deleted &&
            ((dto.startedAt.isAfter(query.start) &&
                    dto.startedAt.isBefore(query.end)) ||
                (dto.endedAt.isAfter(query.start) &&
                    dto.endedAt.isBefore(query.end))) &&
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
    if (Logger.level.index <= Level.debug.index) {
      var debugStr = sessions.fold(
          "", (previousValue, element) => '$previousValue\n  $element');
      _logger.d('Found ${sessions.length} matching sessions: $debugStr');
      for (var session in sessions) {
        _logger.d('Session key: ${session.key.toString()}');
      }
    }
    return sessions;
  }

  @override
  Future<void> delete(TimerSessionKey key) async {
    await _initialized;
    _logger.d('Attempting to delete session with key: ${key}'); // Add th

    _logger.d('Soft deleting session with key ${key.toString()}');
    final dto = _get(key);
    _logger.d('Found DTO: $dto');
    if (dto != null) {
      final updatedDto = TimerSessionDTO(
        sessionTypeCode: dto.sessionTypeCode,
        startedAt: dto.startedAt,
        endedAt: dto.endedAt,
        pauses: dto.pauses,
        totalDuration: dto.totalDuration,
        deleted: true,
      );
      await _put(key, updatedDto);
      _sendEventForHistoryUpdate();
      _logger.d('Session soft deleted successfully');
    } else {
      _logger.w('Session not found for soft deletion');
    }
  }

  @override
  Future<void> undelete(TimerSessionKey key) async {
    await _initialized;
    _logger.d('Restoring session with key ${key.toString()}');
    final dto = _get(key);
    if (dto != null) {
      final updatedDto = TimerSessionDTO(
        sessionTypeCode: dto.sessionTypeCode,
        startedAt: dto.startedAt,
        endedAt: dto.endedAt,
        pauses: dto.pauses,
        totalDuration: dto.totalDuration,
        deleted: false,
      );
      await _put(key, updatedDto);
      _sendEventForHistoryUpdate();
      _logger.d('Session restored successfully');
    } else {
      _logger.w('Session not found for restore');
    }
  }

  @override
  Future<List<({DateTime date, int count})>> queryDailyCounts(
    TimerSessionQuery query,
  ) async {
    await _initialized;
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

  void _sendEventForHistoryUpdate() {
    DomainEventBus.publish(TimerHistoryUpdatedEvent());
  }

  @override
  Future<int> getPomodoroCountForDate(DateTime date) async {
    await _initialized;
    _logger.d('Getting pomodoro count for date: $date');

    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final query = TimerSessionQuery(
      start: start,
      end: end,
      sessionType: TimerType.work,
    );

    final sessions = await this.query(query);
    final count = sessions.where((s) => s.isCompleted).length;

    _logger.d('Found $count pomodoros for date: $date');
    return count;
  }
}
