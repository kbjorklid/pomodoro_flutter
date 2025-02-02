import 'dart:async';

import 'package:pomodoro_app2/core/domain/events/event_bus.dart';
import 'package:pomodoro_app2/core/domain/events/timer_history_updated_event.dart';
import 'package:pomodoro_app2/core/domain/events/timer_running_events.dart';
import 'package:pomodoro_app2/history/domain/timer_session_query.dart';
import 'package:pomodoro_app2/history/domain/timer_session_repository_port.dart';
import 'package:pomodoro_app2/timer/application/timer_service.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';

class GetTodaysTimerSessionsUseCase {
  final TimerSessionRepositoryPort _repository;
  final DateTime Function() _getCurrentTime;
  final TimerService _timerService;
  List<TimerSession> _todaysHistoryOfTimerSessions = [];
  late final Future<void> _initializationFuture;
  StreamSubscription? _historyEventSubscription;

  GetTodaysTimerSessionsUseCase(
    this._timerService,
    this._repository, {
    DateTime Function() getCurrentTime = DateTime.now,
  }) : _getCurrentTime = getCurrentTime {
    _initializationFuture = _refreshFromDataStore();
    unawaited(_initializationFuture);
    _historyEventSubscription =
        DomainEventBus.of<TimerHistoryUpdatedEvent>().listen((event) {
      unawaited(_refreshFromDataStore());
    });
  }

  Future<void> _refreshFromDataStore() async {
    final now = _getCurrentTime();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = TimerSessionQuery(
      start: startOfDay,
      end: endOfDay,
    );

    final sessions = await _repository.query(query);
    _todaysHistoryOfTimerSessions = List.unmodifiable(sessions);
  }

  Future<List<TimerSession>> getTodaysSessions() async {
    await _initializationFuture;
    TimerSession? runningSession = _timerService.getRunningSession();
    if (runningSession == null) {
      return _todaysHistoryOfTimerSessions;
    }
    return _todaysHistoryOfTimerSessions.followedBy([runningSession]).toList();
  }

  void dispose() {
    _historyEventSubscription?.cancel();
    _historyEventSubscription = null;
  }
}
