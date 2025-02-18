
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/core/domain/events/event_bus.dart';
import 'package:pomodoro_app2/core/domain/events/timer_history_updated_event.dart';
import 'package:pomodoro_app2/history/domain/timer_session_query.dart';
import 'package:pomodoro_app2/history/presentation/providers/timer_session_repository_provider.dart';
import 'package:pomodoro_app2/timer/domain/timersession/completion_status.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';

final todaySessionsProvider = FutureProvider<List<TimerSession>>((ref) {
  final now = DateTime.now();
  final startTime = DateTime(now.year, now.month, now.day, 8);
  final endTime = DateTime(now.year, now.month, now.day, 23);

  return ref.read(timerSessionRepositoryProvider).query(TimerSessionQuery(
        start: startTime,
        end: endTime,
        completionStatus: CompletionStatus.any,
      ));
});

final timerHistoryUpdateProvider = StreamProvider.autoDispose<void>((ref) {
  return DomainEventBus.of<TimerHistoryUpdatedEvent>();
});

