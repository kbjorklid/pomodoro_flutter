import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/core/domain/events/event_bus.dart';
import 'package:pomodoro_app2/core/domain/events/timer_history_updated_event.dart';
import 'package:pomodoro_app2/history/domain/timer_session_query.dart';
import 'package:pomodoro_app2/history/domain/timer_session_repository_port.dart';
import 'package:pomodoro_app2/history/presentation/providers/timer_session_repository_provider.dart';
import 'package:pomodoro_app2/timer/application/timer_state/timer_notifier.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_todays_timer_sessions_use_case.g.dart';

class GetTodaysTimerSessionsUseCase {
  final PomodoroTimer _timer;
  final TimerSessionRepositoryPort _repository;
  final DateTime Function() _getCurrentTime;
  List<ClosedTimerSession> _historyOfTimerSessionsForToday = [];
  late final Future<void> _initializationFuture;

  StreamSubscription? _historyEventSubscription;
  StreamSubscription? _timerEventSubscription;

  GetTodaysTimerSessionsUseCase(
    this._timer,
    this._repository, {
    DateTime Function() getCurrentTime = DateTime.now,
  }) : _getCurrentTime = getCurrentTime {
    _initializationFuture = _refreshFromDataStore();
    unawaited(_initializationFuture);

    // Subscribe to history updates
    _historyEventSubscription =
        DomainEventBus.of<TimerHistoryUpdatedEvent>().listen((event) {
      unawaited(_refreshFromDataStore());
    });

    // Subscribe to timer events
    _timerEventSubscription = _timer.events.listen(_handleTimerEvent);
  }

  void _handleTimerEvent(TimerEvent event) {
    switch (event) {
      case TimerStoppedEvent():
        unawaited(_refreshFromDataStore());
      case TimerStartedEvent():
      case TimerPausedEvent():
      case TimerResumedEvent():
      case TimerCompletedEvent():
      case TimerTickEvent():
      case TimerResetEvent():
        break;
    }
  }

  Future<void> _refreshFromDataStore() async {
    final startOfDay = _startOfToday();
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = TimerSessionQuery(
      start: startOfDay,
      end: endOfDay,
    );

    final sessions = await _repository.query(query);
    _historyOfTimerSessionsForToday = List.unmodifiable(sessions);
  }

  Future<List<ClosedTimerSession>> getTodaysSessions([DateTime? now]) async {
    now ??= _getCurrentTime();
    await _initializationFuture;
    _removeYesterdaysSessions(now);
    if (_timer.getCurrentStatus() != TimerStatus.paused &&
        _timer.getCurrentStatus() != TimerStatus.running) {
      return _historyOfTimerSessionsForToday;
    }

    RunningTimerSession runningSession = _timer.getCurrentSession();
    ClosedTimerSession runningSessionSnapshot = TimerSessionSnapshot(
        runningTimerSession: runningSession, timerRangeEnd: now);
    return _historyOfTimerSessionsForToday
        .followedBy([runningSessionSnapshot]).toList();
  }

  void dispose() {
    _historyEventSubscription?.cancel();
    _timerEventSubscription?.cancel();
    _historyEventSubscription = null;
    _timerEventSubscription = null;
  }

  void _removeYesterdaysSessions(DateTime? now) {
    DateTime startOfToday = _startOfToday(now);
    containsSessionsFromYesterday(ClosedTimerSession session) =>
        session.range.end.isBefore(startOfToday);
    if (_historyOfTimerSessionsForToday.any(containsSessionsFromYesterday)) {
      final filteredSessions = _historyOfTimerSessionsForToday
          .where((session) => !containsSessionsFromYesterday(session));
      _historyOfTimerSessionsForToday = List.unmodifiable(filteredSessions);
    }
  }

  DateTime _startOfToday([DateTime? now]) {
    now ??= _getCurrentTime();
    return DateTime(now.year, now.month, now.day);
  }
}

@riverpod
GetTodaysTimerSessionsUseCase getTodaysTimerSessionsUseCase(Ref ref) {
  return GetTodaysTimerSessionsUseCase(
      ref.watch(pomodoroTimerProvider.notifier),
      ref.read(timerSessionRepositoryProvider));
}